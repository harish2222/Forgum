# Installation

This guide covers all the ways to install Forgum on your computer.

## Quick Install (Recommended)

### Windows (PowerShell)

Copy and paste this into PowerShell:

```powershell
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/harish2222/Forgum/main/install.ps1'))
```

This will:
- Download Forgum
- Install it to your PowerShell modules folder
- Add it to your PowerShell profile
- Test that everything works

### Mac/Linux (Bash/Zsh)

Copy and paste this into your terminal:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/harish2222/Forgum/main/install.sh)
```

This will:
- Check if PowerShell is installed
- Download Forgum
- Install it to the correct location
- Set up shell integration
- Test that everything works

### Fish Shell

Copy and paste this into your terminal:

```fish
bash (curl -fsSL https://raw.githubusercontent.com/harish2222/Forgum/main/install.sh | psub)
```

## Manual Install

If you prefer to do it yourself:

### Step 1: Download

```powershell
# Using git (recommended)
git clone https://github.com/harish2222/Forgum.git

# Or download from GitHub
# Go to https://github.com/harish2222/Forgum
# Click "Code" → "Download ZIP"
# Extract the ZIP file
```

### Step 2: Copy to Modules Folder

**Windows:**
```powershell
# Find your modules folder
$env:PSModulePath -split ';'

# Copy Forgum there (usually)
Copy-Item -Path ".\Forgum" -Destination "$env:USERPROFILE\Documents\PowerShell\Modules\Forgum" -Recurse
```

**Mac/Linux:**
```bash
# Find your modules folder
echo $env:PSModulePath -split ':'

# Copy Forgum there (usually)
cp -r ./Forgum ~/.local/share/powershell/Modules/Forgum
```

### Step 3: Import

```powershell
Import-Module Forgum
```

### Step 4: Test

```powershell
forgum
```

## Install from PSGallery

If Forgum is published to the PowerShell Gallery:

```powershell
Install-Module -Name Forgum -Scope CurrentUser
```

## Requirements

### Windows
- PowerShell 5.1 or newer (pre-installed on Windows 10/11)
- No other software needed

### Mac
- PowerShell 7 or newer
- Install with: `brew install powershell`

### Linux
- PowerShell 7 or newer
- Install with: `sudo apt install powershell` (Ubuntu/Debian)
- Or: `sudo yum install powershell` (CentOS/RHEL)

## Where Does Forgum Install?

| Platform | Location |
|:---------|:---------|
| Windows | `~/Documents/PowerShell/Modules/Forgum/` |
| Mac/Linux | `~/.local/share/powershell/Modules/Forgum/` |

## Config Files

| Platform | Location |
|:---------|:---------|
| Windows | `~/Documents/PowerShell/forgum/config.json` |
| Mac/Linux | `~/.config/forgum/config.json` |

## Verify Installation

Run these commands to make sure everything is working:

```powershell
# Check if Forgum is installed
Get-Module -ListAvailable | Where-Object {$_.Name -eq "Forgum"}

# Check the version
(Get-Module Forgum).Version

# Test it
forgum
```

## Uninstall

### Using the Uninstaller

**Windows:**
```powershell
.\uninstall.ps1
```

**Mac/Linux:**
```bash
# Find the uninstall script
find ~/.local/share/powershell/Modules/Forgum -name "uninstall.ps1"
# Run it
pwsh -File <path-to-uninstall.ps1>
```

### Manual Uninstall

1. Delete the Forgum folder:
   ```powershell
   # Windows
   Remove-Item ~/Documents/PowerShell/Modules/Forgum -Recurse

   # Mac/Linux
   rm -rf ~/.local/share/powershell/Modules/Forgum
   ```

2. Remove from your profile:
   - Open your PowerShell profile (`$PROFILE`)
   - Delete the `Import-Module Forgum` line
   - Delete the `forgum` line

3. Delete config (optional):
   ```powershell
   # Windows
   Remove-Item ~/Documents/PowerShell/forgum -Recurse

   # Mac/Linux
   rm -rf ~/.config/forgum
   ```

## Next Steps

Now that Forgum is installed, check out:
- [Getting Started](Getting-Started) — Try your first cow
- [PowerShell Integration](PowerShell-Integration) — Make it start automatically
- [Configuration](Configuration) — Change how it looks

---

**Back:** [Home](Home) | **Next:** [Getting Started →](Getting-Started)
