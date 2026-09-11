$ErrorActionPreference='Stop'
& "$env:WINDIR\Microsoft.NET\Framework64\v4.0.30319\csc.exe" /nologo /target:winexe "/out:$PSScriptRoot\ChatGPT-Workspace-Setup.exe" "/win32icon:$PSScriptRoot\ChatGPT.ico" "/win32manifest:$PSScriptRoot\app.manifest" /reference:System.Windows.Forms.dll /reference:System.Drawing.dll /reference:System.Xml.Linq.dll /reference:Microsoft.CSharp.dll "/resource:$PSScriptRoot\Start-ChatGPT.ps1,Launcher" "/resource:$PSScriptRoot\ChatGPT.ico,AppIcon" "$PSScriptRoot\FolderSetup.cs"
if($LASTEXITCODE -ne 0) {throw 'Build failed'}
& "$env:WINDIR\Microsoft.NET\Framework64\v4.0.30319\csc.exe" /nologo /target:winexe "/out:$PSScriptRoot\ChatGPT-Workspace.exe" "/win32icon:$PSScriptRoot\ChatGPT.ico" "/win32manifest:$PSScriptRoot\app.manifest" /reference:System.Windows.Forms.dll "$PSScriptRoot\Launcher.cs"
if($LASTEXITCODE -ne 0) {throw 'Launcher build failed'}
