; Forgum Inno Setup Script
; Installs the PowerShell module directly to the user's PSModule path
; Compile with Inno Setup 6+ (https://jrsoftware.org/isinfo.php)
;
; One-liner install (silent):
;   & "$env:TEMP\Forgum-v1.0.7-Setup.exe" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART
;
; Winget install:
;   winget install HKDEVS.Forgum

#define MyAppName "Forgum"
#define MyAppVersion "1.1.2"
#define MyAppPublisher "HKDEVS"
#define MyAppURL "https://github.com/harish2222/Forgum"
#define MyAppLicense "MIT"

[Setup]
AppId={#MyAppName}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}/issues
AppUpdatesURL={#MyAppURL}/releases
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
LicenseFile=..\LICENSE
OutputDir=..\dist
OutputBaseFilename=Forgum-v{#MyAppVersion}-Setup
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=lowest
UninstallDisplayName={#MyAppName} {#MyAppVersion}
VersionInfoVersion={#MyAppVersion}.0
VersionInfoDescription={#MyAppName} PowerShell Module Installer
CloseApplications=no
RestartApplications=no

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "..\Forgum.psd1"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\Forgum.psm1"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\bin\*"; DestDir: "{app}\bin"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\Private\*"; DestDir: "{app}\Private"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\Public\*"; DestDir: "{app}\Public"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\Data\*"; DestDir: "{app}\Data"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\LICENSE"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\README.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\install.ps1"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\install.sh"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\setup.ps1"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\uninstall.ps1"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"

[Run]
Filename: "pwsh.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -File ""{app}\setup.ps1"" -InstallOnly"; StatusMsg: "Configuring PowerShell profile..."; Flags: runhidden waituntilterminated skipifsilent skipifdoesntexist

[Code]
function GetPSModulePath: String;
var
  UserModules: String;
begin
  UserModules := ExpandConstant('{userdocs}\PowerShell\Modules');
  if DirExists(UserModules) then
    Result := UserModules
  else
    Result := ExpandConstant('{userdocs}\Documents\PowerShell\Modules');
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  ModuleDir: String;
  SourceDir: String;
  ResultCode: Integer;
begin
  if CurStep = ssPostInstall then
  begin
    ModuleDir := GetPSModulePath + '\Forgum';
    SourceDir := ExpandConstant('{app}');

    if not DirExists(ModuleDir) then
      ForceDirectories(ModuleDir);

    FileCopy(SourceDir + '\Forgum.psd1', ModuleDir + '\Forgum.psd1', False);
    FileCopy(SourceDir + '\Forgum.psm1', ModuleDir + '\Forgum.psm1', False);
    FileCopy(SourceDir + '\LICENSE', ModuleDir + '\LICENSE', False);
    FileCopy(SourceDir + '\README.md', ModuleDir + '\README.md', False);
    FileCopy(SourceDir + '\install.ps1', ModuleDir + '\install.ps1', False);
    FileCopy(SourceDir + '\install.sh', ModuleDir + '\install.sh', False);
    FileCopy(SourceDir + '\setup.ps1', ModuleDir + '\setup.ps1', False);
    FileCopy(SourceDir + '\uninstall.ps1', ModuleDir + '\uninstall.ps1', False);

    Exec('robocopy.exe', '"' + SourceDir + '\bin" "' + ModuleDir + '\bin" /E /NFL /NDL /NJH /NJS /NC /NS', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
    Exec('robocopy.exe', '"' + SourceDir + '\Private" "' + ModuleDir + '\Private" /E /NFL /NDL /NJH /NJS /NC /NS', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
    Exec('robocopy.exe', '"' + SourceDir + '\Public" "' + ModuleDir + '\Public" /E /NFL /NDL /NJH /NJS /NC /NS', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
    Exec('robocopy.exe', '"' + SourceDir + '\Data" "' + ModuleDir + '\Data" /E /NFL /NDL /NJH /NJS /NC /NS', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  ModuleDir: String;
begin
  if CurUninstallStep = usPostUninstall then
  begin
    ModuleDir := GetPSModulePath + '\Forgum';
    if DirExists(ModuleDir) then
      DelTree(ModuleDir, True, True, True);
  end;
end;
