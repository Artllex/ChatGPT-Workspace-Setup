$ErrorActionPreference='Stop'
& "$env:WINDIR\Microsoft.NET\Framework64\v4.0.30319\csc.exe" /nologo /target:winexe "/out:$PSScriptRoot\ChatGPT-Workspace-Setup.exe" "/win32icon:$PSScriptRoot\ChatGPT.ico" "/win32manifest:$PSScriptRoot\app.manifest" /reference:System.Windows.Forms.dll /reference:System.Drawing.dll /reference:System.Xml.Linq.dll /reference:Microsoft.CSharp.dll "/resource:$PSScriptRoot\Start-ChatGPT.ps1,Launcher" "/resource:$PSScriptRoot\ChatGPT.ico,AppIcon" "$PSScriptRoot\FolderSetup.cs"
if($LASTEXITCODE -ne 0) {throw 'Build failed'}
& "$env:WINDIR\Microsoft.NET\Framework64\v4.0.30319\csc.exe" /nologo /target:winexe "/out:$PSScriptRoot\ChatGPT-Workspace.exe" "/win32icon:$PSScriptRoot\ChatGPT.ico" "/win32manifest:$PSScriptRoot\app.manifest" /reference:System.Windows.Forms.dll "$PSScriptRoot\Launcher.cs"
if($LASTEXITCODE -ne 0) {throw 'Launcher build failed'}
& "$env:WINDIR\Microsoft.NET\Framework64\v4.0.30319\csc.exe" /nologo /target:winexe "/out:$PSScriptRoot\FirefoxDownloadHost.exe" /reference:System.Web.Extensions.dll /reference:System.Xml.Linq.dll /reference:System.Windows.Forms.dll "$PSScriptRoot\FirefoxDownloadHost.cs"
if($LASTEXITCODE -ne 0) {throw 'Firefox native host build failed'}
& "$PSScriptRoot\Build-Firefox-Extension.ps1"
