#define AppName "ChatGPT Workspace Setup"
#define AppVersion "1.2.3"
#define AppPublisher "Artllex"
#define SourceRoot ".."

[Setup]
AppId={{19B5023F-C9B4-49DF-B62B-F6E24B56B317}
AppName={#AppName}
AppVersion={#AppVersion}
LanguageDetectionMethod=none
ShowLanguageDialog=yes
AppPublisher={#AppPublisher}
DefaultDirName={localappdata}\Programs\ChatGPTFolderLauncher
DisableDirPage=yes
DefaultGroupName={#AppName}
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
MinVersion=10.0
OutputDir=..\dist
OutputBaseFilename=ChatGPT-Workspace-Setup-{#AppVersion}
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
WizardSizePercent=110
DisableWelcomePage=no
SetupIconFile={#SourceRoot}\ChatGPT.ico
LicenseFile={#SourceRoot}\LICENSE
ChangesEnvironment=no
Uninstallable=IsRealInstall
UninstallDisplayName={#AppName}
UninstallDisplayIcon={app}\ChatGPT-Workspace-Setup.exe
VersionInfoVersion={#AppVersion}
VersionInfoCompany={#AppPublisher}
VersionInfoDescription=Per-application TEMP and projectless task folder configuration for ChatGPT
SetupLogging=yes
CloseApplications=no
RestartApplications=no

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "polish"; MessagesFile: "compiler:Languages\Polish.isl"

[CustomMessages]
english.RootTitle=Folder configuration
english.RootDescription=Choose the root folder for your local ChatGPT workspace
english.RootPrompt=Root folder:
english.PathsTitle=TEMP and task folders
english.PathsDescription=Review the derived paths or change either one
english.TempPrompt=ChatGPT temporary files (TEMP):
english.InboxPrompt=Tasks without a project (inbox):
english.RunName=ChatGPT Workspace
english.SettingsName=ChatGPT Workspace Setup
english.DesktopTask=Create a desktop shortcut
english.ShortcutTitle=Desktop shortcut
english.ShortcutDescription=Choose whether Setup should create a desktop shortcut
english.ShortcutPrompt=How do you want to start ChatGPT Workspace?
english.CreateDesktop=Create the ChatGPT Workspace shortcut on the desktop
english.SkipDesktop=Do not create a desktop shortcut
english.PathError=Enter full local paths, for example C:\CODE. TEMP and inbox must be different subfolders.
polish.RootTitle=Konfiguracja folderów
polish.RootDescription=Wybierz katalog główny lokalnego środowiska pracy ChatGPT
polish.RootPrompt=Katalog główny:
polish.PathsTitle=Foldery TEMP i zadań
polish.PathsDescription=Sprawdź wyliczone ścieżki lub zmień dowolną z nich
polish.TempPrompt=Pliki tymczasowe ChatGPT (TEMP):
polish.InboxPrompt=Folder zadań bez projektu (inbox):
polish.RunName=ChatGPT Workspace
polish.SettingsName=ChatGPT Workspace Setup
polish.DesktopTask=Utwórz skrót na pulpicie
polish.ShortcutTitle=Skrót na pulpicie
polish.ShortcutDescription=Wybierz, czy instalator ma utworzyć skrót na pulpicie
polish.ShortcutPrompt=Jak chcesz uruchamiać ChatGPT Workspace?
polish.CreateDesktop=Utwórz skrót ChatGPT Workspace na pulpicie
polish.SkipDesktop=Nie twórz skrótu na pulpicie
polish.PathError=Podaj pełne lokalne ścieżki, np. C:\CODE. TEMP i inbox muszą być różnymi podfolderami.

[Files]
Source: "{#SourceRoot}\Start-ChatGPT.ps1"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceRoot}\ChatGPT-Workspace-Setup.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceRoot}\ChatGPT-Workspace.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceRoot}\ChatGPT.ico"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceRoot}\LICENSE"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceRoot}\INSTALACJA.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceRoot}\INSTALLATION.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceRoot}\FirefoxDownloadHost.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceRoot}\Download-Router.xpi"; DestDir: "{app}"; Flags: ignoreversion

[Registry]
Root: HKCU32; Subkey: "Software\Mozilla\NativeMessagingHosts\com.artllex.download_router"; ValueType: string; ValueName: ""; ValueData: "{app}\firefox-native-host.json"; Flags: uninsdeletekey; Check: IsRealInstall
Root: HKCU64; Subkey: "Software\Mozilla\NativeMessagingHosts\com.artllex.download_router"; ValueType: string; ValueName: ""; ValueData: "{app}\firefox-native-host.json"; Flags: uninsdeletekey; Check: IsRealInstall

[Icons]
Name: "{group}\{cm:RunName}"; Filename: "{app}\ChatGPT-Workspace.exe"; WorkingDir: "{app}"; IconFilename: "{app}\ChatGPT-Workspace.exe"; Check: IsRealInstall
Name: "{group}\{cm:SettingsName}"; Filename: "{app}\ChatGPT-Workspace-Setup.exe"; WorkingDir: "{app}"; IconFilename: "{app}\ChatGPT.ico"; Check: IsRealInstall
Name: "{group}\{cm:UninstallProgram,{#AppName}}"; Filename: "{uninstallexe}"; Check: IsRealInstall
Name: "{autodesktop}\{cm:RunName}"; Filename: "{app}\ChatGPT-Workspace.exe"; WorkingDir: "{app}"; IconFilename: "{app}\ChatGPT-Workspace.exe"; Check: ShouldCreateDesktopShortcut

[InstallDelete]
Type: files; Name: "{app}\ChatGPT-Folder-Setup.exe"

[UninstallDelete]
Type: files; Name: "{app}\folders.xml"
Type: files; Name: "{app}\folders.xml.previous"
Type: files; Name: "{app}\firefox-native-host.json"

[Code]
var
  RootPage: TInputDirWizardPage;
  PathsPage: TInputDirWizardPage;
  ShortcutPage: TWizardPage;
  ShortcutPromptLabel: TNewStaticText;
  CreateDesktopRadio: TNewRadioButton;
  SkipDesktopRadio: TNewRadioButton;
  LastDerivedRoot: string;

function IsRealInstall: Boolean;
begin
  Result := CompareText(ExpandConstant('{param:PORTABLETEST|0}'), '1') <> 0;
end;

function ShouldCreateDesktopShortcut: Boolean;
begin
  Result := IsRealInstall and CreateDesktopRadio.Checked;
end;

function IsFullSafePath(Value: string): Boolean;
begin
  Result := (Length(Value) >= 3) and (((Value[1] >= 'A') and (Value[1] <= 'Z')) or ((Value[1] >= 'a') and (Value[1] <= 'z'))) and (Value[2] = ':') and (Value[3] = '\') and
    (Pos('''', Value) = 0) and (Pos('"', Value) = 0) and (Pos('*', Value) = 0) and (Pos('?', Value) = 0);
end;

function TrimSlash(Value: string): string;
begin
  Result := RemoveBackslashUnlessRoot(Trim(Value));
end;

function XmlEscape(Value: string): string;
begin
  Result := Value;
  StringChangeEx(Result, '&', '&amp;', True);
  StringChangeEx(Result, '<', '&lt;', True);
  StringChangeEx(Result, '>', '&gt;', True);
  StringChangeEx(Result, '"', '&quot;', True);
  StringChangeEx(Result, '''', '&apos;', True);
end;

function JsonEscape(Value: string): string;
begin
  Result := Value;
  StringChangeEx(Result, '\', '\\', True);
  StringChangeEx(Result, '"', '\"', True);
end;

function XmlValue(Xml, Tag: string): string;
var A, B: Integer; OpenTag, CloseTag: string;
begin
  Result := ''; OpenTag := '<' + Tag + '>'; CloseTag := '</' + Tag + '>';
  A := Pos(OpenTag, Xml);
  if A > 0 then begin
    A := A + Length(OpenTag); B := Pos(CloseTag, Copy(Xml, A, MaxInt));
    if B > 0 then Result := Copy(Xml, A, B - 1);
  end;
  StringChangeEx(Result, '&apos;', '''', True);
  StringChangeEx(Result, '&quot;', '"', True);
  StringChangeEx(Result, '&gt;', '>', True);
  StringChangeEx(Result, '&lt;', '<', True);
  StringChangeEx(Result, '&amp;', '&', True);
end;

procedure DerivePaths;
var R: string;
begin
  R := TrimSlash(RootPage.Values[0]);
  if (PathsPage.Values[0] = LastDerivedRoot + '\temp') or (PathsPage.Values[0] = '') then PathsPage.Values[0] := R + '\temp';
  if (PathsPage.Values[1] = LastDerivedRoot + '\inbox') or (PathsPage.Values[1] = '') then PathsPage.Values[1] := R + '\inbox';
  LastDerivedRoot := R;
end;

procedure InitializeWizard;
var Xml, R, T, I: string; Lines: TArrayOfString; N: Integer;
begin
  R := 'C:\CODE'; T := R + '\temp'; I := R + '\inbox';
  if LoadStringsFromFile(ExpandConstant('{localappdata}\Programs\ChatGPTFolderLauncher\folders.xml'), Lines) then begin
    Xml := '';
    for N := 0 to GetArrayLength(Lines) - 1 do Xml := Xml + Lines[N] + #13#10;
    if XmlValue(Xml, 'Root') <> '' then R := XmlValue(Xml, 'Root');
    if XmlValue(Xml, 'Temp') <> '' then T := XmlValue(Xml, 'Temp');
    if XmlValue(Xml, 'Inbox') <> '' then I := XmlValue(Xml, 'Inbox');
  end;
  if ExpandConstant('{param:ROOT|}') <> '' then R := ExpandConstant('{param:ROOT|}');
  if ExpandConstant('{param:TEMP|}') <> '' then T := ExpandConstant('{param:TEMP|}') else T := R + '\temp';
  if ExpandConstant('{param:INBOX|}') <> '' then I := ExpandConstant('{param:INBOX|}') else I := R + '\inbox';
  RootPage := CreateInputDirPage(wpSelectDir, CustomMessage('RootTitle'), CustomMessage('RootDescription'), CustomMessage('RootPrompt'), False, '');
  RootPage.Add(''); RootPage.Values[0] := R; LastDerivedRoot := R;
  PathsPage := CreateInputDirPage(RootPage.ID, CustomMessage('PathsTitle'), CustomMessage('PathsDescription'), '', False, '');
  PathsPage.Add(CustomMessage('TempPrompt')); PathsPage.Add(CustomMessage('InboxPrompt'));
  PathsPage.Values[0] := T; PathsPage.Values[1] := I;
  ShortcutPage := CreateCustomPage(PathsPage.ID, CustomMessage('ShortcutTitle'), CustomMessage('ShortcutDescription'));
  ShortcutPromptLabel := TNewStaticText.Create(ShortcutPage);
  ShortcutPromptLabel.Parent := ShortcutPage.Surface;
  ShortcutPromptLabel.Left := 0;
  ShortcutPromptLabel.Top := ScaleY(8);
  ShortcutPromptLabel.AutoSize := True;
  ShortcutPromptLabel.Caption := CustomMessage('ShortcutPrompt');
  CreateDesktopRadio := TNewRadioButton.Create(ShortcutPage);
  CreateDesktopRadio.Parent := ShortcutPage.Surface;
  CreateDesktopRadio.Left := ScaleX(16);
  CreateDesktopRadio.Top := ShortcutPromptLabel.Top + ShortcutPromptLabel.Height + ScaleY(26);
  CreateDesktopRadio.Width := ShortcutPage.SurfaceWidth - CreateDesktopRadio.Left;
  CreateDesktopRadio.Height := ScaleY(24);
  CreateDesktopRadio.Caption := CustomMessage('CreateDesktop');
  CreateDesktopRadio.Checked := True;
  SkipDesktopRadio := TNewRadioButton.Create(ShortcutPage);
  SkipDesktopRadio.Parent := ShortcutPage.Surface;
  SkipDesktopRadio.Left := CreateDesktopRadio.Left;
  SkipDesktopRadio.Top := CreateDesktopRadio.Top + ScaleY(34);
  SkipDesktopRadio.Width := CreateDesktopRadio.Width;
  SkipDesktopRadio.Height := CreateDesktopRadio.Height;
  SkipDesktopRadio.Caption := CustomMessage('SkipDesktop');
end;

function NextButtonClick(CurPageID: Integer): Boolean;
var R, T, I: string;
begin
  Result := True;
  if CurPageID = RootPage.ID then DerivePaths;
  if CurPageID = PathsPage.ID then begin
    R := TrimSlash(RootPage.Values[0]); T := TrimSlash(PathsPage.Values[0]); I := TrimSlash(PathsPage.Values[1]);
    if (not IsFullSafePath(R)) or (not IsFullSafePath(T)) or (not IsFullSafePath(I)) or
      (CompareText(T, I) = 0) or (Length(T) = 3) or (Length(I) = 3) then begin
      MsgBox(CustomMessage('PathError'), mbError, MB_OK); Result := False; exit;
    end;
    RootPage.Values[0] := R; PathsPage.Values[0] := T; PathsPage.Values[1] := I;
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var Xml, Backup, NativeManifest: string;
begin
  if CurStep = ssPostInstall then begin
    ForceDirectories(RootPage.Values[0]); ForceDirectories(PathsPage.Values[0]); ForceDirectories(PathsPage.Values[1]);
    Xml := '<?xml version="1.0" encoding="utf-8"?>' + #13#10 + '<Folders>' + #13#10 +
      '  <Root>' + XmlEscape(RootPage.Values[0]) + '</Root>' + #13#10 +
      '  <Temp>' + XmlEscape(PathsPage.Values[0]) + '</Temp>' + #13#10 +
      '  <Inbox>' + XmlEscape(PathsPage.Values[1]) + '</Inbox>' + #13#10 +
      '  <Language>' + ActiveLanguage + '</Language>' + #13#10 + '</Folders>' + #13#10;
    if FileExists(ExpandConstant('{app}\folders.xml')) then begin
      Backup := ExpandConstant('{app}\folders.xml.previous'); DeleteFile(Backup);
      RenameFile(ExpandConstant('{app}\folders.xml'), Backup);
    end;
    SaveStringToFile(ExpandConstant('{app}\folders.xml'), Xml, False);
    NativeManifest := '{' + #13#10 +
      '  "name": "com.artllex.download_router",' + #13#10 +
      '  "description": "Routes Firefox downloads to configured local folders",' + #13#10 +
      '  "path": "' + JsonEscape(ExpandConstant('{app}\FirefoxDownloadHost.exe')) + '",' + #13#10 +
      '  "type": "stdio",' + #13#10 +
      '  "allowed_extensions": ["download-router@artllex"]' + #13#10 +
      '}' + #13#10;
    SaveStringToFile(ExpandConstant('{app}\firefox-native-host.json'), NativeManifest, False);
  end;
end;
