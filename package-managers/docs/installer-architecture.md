# Installer Architecture

## Overview

Forgum uses a 3-stage installation model:

1. **install.ps1 / install.sh** — Downloads and extracts module to PowerShell modules directory
2. **setup.ps1** — Configures shell integration (interactive or silent)
3. **Profile update** — Adds Import-Module, fortune cow, aliases, tab completion

## Script Relationships

```
install.ps1 -Silent
  └── setup.ps1 -NonInteractive -Force
        ├── Get-CFConfig / Set-CFConfig
        └── Update $PROFILE

install.sh
  └── (standalone, configures bash/zsh/fish profiles)
```

## Figlet Banner

All scripts display the FORGUM figlet banner on startup:

```
   ____________________________________
  |  ___/ _ \|  _ \ / ___| | | |  \/  |
  | |_ | | | | |_) | |  _| | | | |\/| |
  |  _|| |_| |  _ <| |_| | |_| | |  | |
  |_|   \___/|_| \_\\____|\___/|_|  |_|
```

## Package Manager Integration

### Winget
- InstallerType: `zip` (PowerShell module in zip)
- Downloads: `Forgum-v1.0.3.zip` from GitHub Release
- Extracts module to `~/Documents/PowerShell/Modules/Forgum/`
- Runs `setup.ps1 -NonInteractive -Force` silently

### Scoop
- Downloads zip from GitHub Release
- Extracts to scoop cache directory
- Copies module to `~/Documents/PowerShell/Modules/Forgum/`
- Runs `setup.ps1 -NonInteractive -Force`

## Setup.ps1 Toggle Flow

```
Show-Banner
  |
  +-- Check Forgum installed?
  |   +-- No -> error, exit
  |
  +-- Load config (Get-CFConfig)
  |
  +-- Toggle 1: Fortune on startup? (default: yes)
  +-- Toggle 2: Lolcat enabled? (default: yes)
  +-- Toggle 3: Default cow file (default: "default")
  +-- Toggle 4: Animation mode (default: "static")
  +-- Toggle 5: Shell aliases? (default: yes)
  +-- Toggle 6: Tab completion? (default: yes)
  |
  +-- Apply config (Set-CFConfig)
  |
  +-- Update profile
      +-- Add Import-Module Forgum
      +-- Add Show-FortuneCow startup block
      +-- Add alias functions
      +-- Add Register-ArgumentCompleter
```

## Profile Modification

The setup script modifies `$PROFILE.CurrentUserAllHosts` (or `$PROFILE.CurrentUser` as fallback).

All additions are guarded with existence checks:
- `Import-Module Forgum` — only if not already present
- `Show-FortuneCow` — only if not already present
- Alias functions — only if not already defined
- Tab completion — only if not already registered
