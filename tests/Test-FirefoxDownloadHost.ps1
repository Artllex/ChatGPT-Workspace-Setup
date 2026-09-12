$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$testRoot = Join-Path $projectRoot 'firefox-host-self-test'
$hostPath = Join-Path $testRoot 'FirefoxDownloadHost.exe'
$tempRoot = Join-Path $testRoot 'configured-temp'
$downloads = Join-Path $testRoot 'downloads'

function Invoke-NativeHost([string]$Source, [string]$Conversation, [string]$Folder = '') {
  if ($Folder) {
    $payload = @{ action = 'move'; source = $Source; mode = 'folder'; folder = $Folder }
  } else {
    $payload = @{ action = 'move'; source = $Source; mode = 'chatgpt'; conversation = $Conversation }
  }
  $message = $payload | ConvertTo-Json -Compress
  $bytes = [Text.Encoding]::UTF8.GetBytes($message)
  $start = [Diagnostics.ProcessStartInfo]::new()
  $start.FileName = $hostPath
  $start.WorkingDirectory = $testRoot
  $start.UseShellExecute = $false
  $start.CreateNoWindow = $true
  $start.RedirectStandardInput = $true
  $start.RedirectStandardOutput = $true
  $process = [Diagnostics.Process]::Start($start)
  $length = [BitConverter]::GetBytes($bytes.Length)
  $process.StandardInput.BaseStream.Write($length, 0, 4)
  $process.StandardInput.BaseStream.Write($bytes, 0, $bytes.Length)
  $process.StandardInput.Close()

  $replyLengthBytes = [byte[]]::new(4)
  if ($process.StandardOutput.BaseStream.Read($replyLengthBytes, 0, 4) -ne 4) {
    throw 'The native host returned no response.'
  }
  $replyLength = [BitConverter]::ToInt32($replyLengthBytes, 0)
  $replyBytes = [byte[]]::new($replyLength)
  $offset = 0
  while ($offset -lt $replyLength) {
    $read = $process.StandardOutput.BaseStream.Read($replyBytes, $offset, $replyLength - $offset)
    if ($read -le 0) { break }
    $offset += $read
  }
  $process.WaitForExit()
  $reply = [Text.Encoding]::UTF8.GetString($replyBytes, 0, $offset) | ConvertFrom-Json
  if (-not $reply.ok) { throw $reply.error }
  return $reply.destination
}

if (Test-Path -LiteralPath $testRoot) {
  Remove-Item -LiteralPath $testRoot -Recurse -Force
}
New-Item -ItemType Directory -Path $testRoot, $tempRoot, $downloads | Out-Null
Copy-Item -LiteralPath (Join-Path $projectRoot 'FirefoxDownloadHost.exe') -Destination $hostPath
Set-Content -LiteralPath (Join-Path $testRoot 'folders.xml') -Encoding UTF8 -Value (
  '<?xml version="1.0" encoding="utf-8"?><Folders><Temp>' + $tempRoot + '</Temp></Folders>'
)

try {
  $source1 = Join-Path $downloads 'report.txt'
  Set-Content -LiteralPath $source1 -Value 'first'
  $destination1 = Invoke-NativeHost $source1 'Analiza: sprzedaż / 2026'
  if ((Split-Path -Leaf (Split-Path -Parent $destination1)) -ne 'Analiza_ sprzedaż _ 2026') {
    throw 'Invalid characters were not sanitized correctly.'
  }

  $source2 = Join-Path $downloads 'report.txt'
  Set-Content -LiteralPath $source2 -Value 'second'
  $destination2 = Invoke-NativeHost $source2 'Analiza: sprzedaż / 2026'
  if ((Split-Path -Leaf $destination2) -ne 'report (2).txt') {
    throw 'A duplicate filename was not uniquified.'
  }

  $source3 = Join-Path $downloads 'device.txt'
  Set-Content -LiteralPath $source3 -Value 'reserved'
  $destination3 = Invoke-NativeHost $source3 'CON'
  if ((Split-Path -Leaf (Split-Path -Parent $destination3)) -ne '_CON') {
    throw 'A reserved Windows folder name was not protected.'
  }

  $portalFolder = Join-Path $testRoot 'portal-route'
  $source4 = Join-Path $downloads 'portal.pdf'
  Set-Content -LiteralPath $source4 -Value 'portal'
  $destination4 = Invoke-NativeHost $source4 '' $portalFolder
  if ((Split-Path -Parent $destination4) -ne $portalFolder) {
    throw 'A configured website folder was not used.'
  }

  Write-Output 'Firefox native host edge cases: PASS'
} finally {
  if (Test-Path -LiteralPath $testRoot) {
    Remove-Item -LiteralPath $testRoot -Recurse -Force
  }
}
