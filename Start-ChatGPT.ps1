[CmdletBinding()]
param([switch]$CheckOnly)
$ErrorActionPreference = 'Stop'
$script:TempFolder = 'C:\CODE\temp'
$script:InboxFolder = 'C:\CODE\inbox'
$script:Language = 'english'
$settingsPath = Join-Path $PSScriptRoot 'folders.xml'
if (Test-Path -LiteralPath $settingsPath) {
    [xml]$settings = [IO.File]::ReadAllText($settingsPath)
    $script:TempFolder = [string]$settings.Folders.Temp
    $script:InboxFolder = [string]$settings.Folders.Inbox
    if ([string]$settings.Folders.Language -eq 'polish') { $script:Language = 'polish' }
    foreach ($path in @($script:TempFolder,$script:InboxFolder)) {
        if ($path -notmatch '^[A-Za-z]:\\' -or $path.Contains("'")) { throw 'Invalid folder in folders.xml' }
    }
}

function Set-InboxText([string]$Text) {
    $nl = if ($Text.Contains("`r`n")) { "`r`n" } else { "`n" }
    $sections = [regex]::Matches($Text, '(?m)^\s*\[desktop\]\s*(?:#.*)?$')
    if ($sections.Count -gt 1) { throw 'Multiple [desktop] sections; configuration was not changed.' }
    $desired = "projectlessWorkspaceRoot = '$script:InboxFolder'"
    if (!$sections.Count) { return $Text.TrimEnd() + $nl + $nl + '[desktop]' + $nl + $desired + $nl }
    $start = $sections[0].Index + $sections[0].Length
    $tail = $Text.Substring($start)
    $next = [regex]::Match($tail, '(?m)^\s*\[')
    $length = if ($next.Success) { $next.Index } else { $tail.Length }
    $body = $tail.Substring(0, $length)
    $keys = [regex]::Matches($body, '(?m)^[ \t]*projectlessWorkspaceRoot[ \t]*=[^\r\n]*')
    if ($keys.Count -gt 1) { throw 'Duplicate projectlessWorkspaceRoot; configuration was not changed.' }
    if ($keys.Count) {
        $key = $keys[0]
        if ($key.Value.Trim() -ceq $desired) { return $Text }
        $body = $body.Substring(0,$key.Index) + $desired + $body.Substring($key.Index+$key.Length)
    } else { $body = $nl + $desired + $body }
    return $Text.Substring(0,$start) + $body + $tail.Substring($length)
}

function Find-ChatGPT {
    $packages = @(Get-AppxPackage -Name OpenAI.Codex -ErrorAction SilentlyContinue)
    $packages += @(Get-AppxPackage -Name '*ChatGPT*' -ErrorAction SilentlyContinue)
    foreach ($package in ($packages | Sort-Object Version -Descending)) {
        foreach ($relative in @('app\ChatGPT.exe','ChatGPT.exe')) {
            $candidate = Join-Path $package.InstallLocation $relative
            if (Test-Path -LiteralPath $candidate -PathType Leaf) { return $candidate }
        }
    }
    throw 'ChatGPT package not found for this Windows account. Run with Windows PowerShell 5.1 as your normal user.'
}

function New-AppStartInfo([string]$Executable) {
    $info = New-Object System.Diagnostics.ProcessStartInfo
    $info.FileName = $Executable
    $info.UseShellExecute = $false
    $info.WorkingDirectory = Split-Path -Parent $Executable
    $info.EnvironmentVariables['TEMP'] = $script:TempFolder
    $info.EnvironmentVariables['TMP'] = $script:TempFolder
    return $info
}

function Start-ConfiguredChatGPT {
    $exe = Find-ChatGPT
    $configRoot = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $env:USERPROFILE '.codex' }
    $config = Join-Path $configRoot 'config.toml'
    if ($CheckOnly) {
        [pscustomobject]@{ Executable=$exe; Config=$config; AppTEMP=$script:TempFolder; Inbox=$script:InboxFolder; Running=@(Get-Process ChatGPT -ErrorAction SilentlyContinue).Count }
        return
    }
    if (Get-Process ChatGPT -ErrorAction SilentlyContinue) {
        if ($script:Language -eq 'polish') {
            $message = 'Zamknij ca' + [char]0x0142 + 'kowicie ChatGPT (tak' + [char]0x017C + 'e w zasobniku), a nast' + [char]0x0119 + 'pnie uruchom ponownie ten skr' + [char]0x00F3 + 't. ' + [char]0x017B + 'adna konfiguracja nie zosta' + [char]0x0142 + 'a zmieniona.'
            throw $message
        }
        throw 'Close ChatGPT completely, including its tray process, and then use this shortcut again. No configuration has been changed.'
    }
    foreach ($folder in @($script:TempFolder,$script:InboxFolder,$configRoot)) { [void][IO.Directory]::CreateDirectory($folder) }
    $old = if (Test-Path -LiteralPath $config) { [IO.File]::ReadAllText($config) } else { '' }
    $new = Set-InboxText $old
    if ($new -cne $old) {
        $stage = $config + '.launcher-' + [guid]::NewGuid().ToString('N') + '.tmp'
        [IO.File]::WriteAllText($stage,$new,(New-Object Text.UTF8Encoding($false)))
        if (Test-Path -LiteralPath $config) {
            if ([IO.File]::ReadAllText($config) -cne $old) { throw "Configuration changed concurrently; staged file: $stage" }
            $backup = $config + '.before-chatgpt-launcher-' + (Get-Date -Format 'yyyyMMdd-HHmmss-fff') + '.bak'
            [IO.File]::Replace($stage,$config,$backup)
        } else { [IO.File]::Move($stage,$config) }
    }
    [void][Diagnostics.Process]::Start((New-AppStartInfo $exe))
}

if ($MyInvocation.InvocationName -ne '.') {
    try { Start-ConfiguredChatGPT }
    catch {
        if ($CheckOnly) { throw }
        Add-Type -AssemblyName PresentationFramework
        [void][Windows.MessageBox]::Show($_.Exception.Message,'ChatGPT - C:\CODE','OK','Warning')
        exit 1
    }
}
