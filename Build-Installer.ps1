$ErrorActionPreference='Stop'
& "$PSScriptRoot\Build.ps1"
$iscc='C:\Users\arkad\Documents\Codex\2026-09-09\referenced-chatgpt-conversation-this-is-an\work\InnoSetup7\ISCC.exe'
if(!(Test-Path -LiteralPath $iscc)) {throw "Inno Setup compiler not found: $iscc"}
& $iscc "$PSScriptRoot\installer\setup.iss"
if($LASTEXITCODE -ne 0) {throw 'Installer build failed'}
