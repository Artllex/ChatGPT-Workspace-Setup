$ErrorActionPreference='Stop'
$source=Join-Path $PSScriptRoot 'firefox-extension'
$zip=Join-Path $PSScriptRoot 'Download-Router.zip'
$xpi=Join-Path $PSScriptRoot 'Download-Router.xpi'
& (Join-Path $PSScriptRoot 'Generate-Firefox-Icons.ps1')
Compress-Archive -Path (Join-Path $source '*') -DestinationPath $zip -CompressionLevel Optimal -Force
Move-Item -LiteralPath $zip -Destination $xpi -Force
