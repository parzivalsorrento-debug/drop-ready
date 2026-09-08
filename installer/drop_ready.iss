#define MyAppName "Drop Ready"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "Drop Ready"
#define MyAppExeName "drop_ready.exe"

[Setup]
AppId={{C5B07333-1DE3-4D5B-9E3E-79C4D01B41D0}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\Drop Ready
DefaultGroupName=Drop Ready
DisableProgramGroupPage=yes
OutputDir=output
OutputBaseFilename=DropReadySetup-1.0.0
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
ArchitecturesInstallIn64BitMode=x64
UninstallDisplayName=Drop Ready
PrivilegesRequired=lowest

[Files]
Source: "..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdirs ignoreversion

[Icons]
Name: "{autoprograms}\Drop Ready"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\Drop Ready"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "Create a &desktop shortcut"; GroupDescription: "Additional shortcuts:"

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Launch Drop Ready"; Flags: nowait postinstall skipifsilent
