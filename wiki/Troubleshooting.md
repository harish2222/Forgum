# Troubleshooting

This guide helps you fix common problems with Forgum. If something isn't working, check here first!

## Common Problems

### "Import-Module : The specified module 'Forgum' was not loaded"

**What it means:** PowerShell can't find Forgum.

**How to fix it:**

1. Check if Forgum is installed:
   ```powershell
   Get-Module -ListAvailable | Where-Object {$_.Name -like "*Forgum*"}
   ```

2. If nothing shows up, install Forgum:
   ```powershell
   iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/harish2222/Forgum/main/install.ps1'))
   ```

3. If Forgum is installed but still not found, try importing it manually:
   ```powershell
   Import-Module Forgum -Force
   ```

### "forgum : The term 'forgum' is not recognized"

**What it means:** Forgum is loaded but the command name is wrong.

**How to fix it:**

1. Make sure you're using the right command:
   ```powershell
   forgum
   ```

2. Check what commands Forgum provides:
   ```powershell
   Get-Command -Module Forgum
   ```

3. If you see `forgumFortune` instead of `forgum`, you might have an old version. Reinstall Forgum.

### "Cow file not found"

**What it means:** Forgum can't find the cow file you specified.

**How to fix it:**

1. List available cows:
   ```powershell
   Get-CFCow
   ```

2. Use the exact name from the list (without `.cow`):
   ```powershell
   forgum -Text "Hello" -CowFile 'tux'
   ```

3. If you created a custom cow, make sure it's in the `Data/Cows/` folder.

### "Fortune file not found"

**What it means:** Forgum can't find the fortune database.

**How to fix it:**

1. Check if the fortune file exists:
   ```powershell
   Test-Path (Get-ConfigPath)
   ```

2. Look in the Data/Fortunes folder:
   ```powershell
   Get-ChildItem (Join-Path (Split-Path (Get-Command Forgum).Source) "Data/Fortunes")
   ```

3. If missing, reinstall Forgum or copy the fortunes file manually.

### No Output When Running Forgum

**What it means:** The command runs but nothing appears.

**How to fix it:**

1. Try with verbose output:
   ```powershell
   forgum -Verbose
   ```

2. Check if your terminal supports the output:
   ```powershell
   forgum -Text "Test" | Out-Host
   ```

3. Make sure your terminal window isn't too small.

### Rainbow Colors Not Working

**What it means:** The lolcat colors aren't showing.

**How to fix it:**

1. Check if rainbow is enabled:
   ```powershell
   (Get-CFConfig).lolcat.enabled
   ```

2. Enable it:
   ```powershell
   $config = Get-CFConfig
   $config.lolcat.enabled = $true
   Set-CFConfig -Config $config
   ```

3. Make sure your terminal supports colors. Some old terminals don't.

### "Cannot index into a null array"

**What it means:** Forgum couldn't parse the cow file.

**How to fix it:**

1. Check if the cow file is valid:
   ```powershell
   Get-CFCow -Name 'default'
   ```

2. If you're using a custom cow, check the format. See [Custom Cows](Custom-Cows).

### Slow Performance

**What it means:** Forgum takes too long to run.

**How to fix it:**

1. Disable animations:
   ```powershell
   $config = Get-CFConfig
   $config.animation.mode = 'static'
   Set-CFConfig -Config $config
   ```

2. Disable rainbow (it adds processing time):
   ```powershell
   $config = Get-CFConfig
   $config.lolcat.enabled = $false
   Set-CFConfig -Config $config
   ```

3. Use a smaller fortune database.

### Config File Corrupted

**What it means:** The config file has invalid JSON.

**How to fix it:**

1. Delete the config file:
   ```powershell
   # Windows
   Remove-Item ~/Documents/PowerShell/forgum/config.json

   # Mac/Linux
   Remove-Item ~/.config/forgum/config.json
   ```

2. Forgum will create a fresh config on next run.

3. Or reset manually:
   ```powershell
   Set-CFConfig -Config @{
       animation = @{ mode = 'static'; speed = 20; duration = 12; spread = 3.0 }
       cow = @{ file = 'default'; random = $false; mode = $null; eyes = 'oo'; tongue = '  ' }
       fortune = @{ database = 'fortunes'; offensive = $false }
       lolcat = @{ enabled = $false; truecolor = $true; frequency = 0.1; invert = $false }
       output = @{ wordWrap = $true; maxWidth = 60 }
       shell = @{ integration = 'auto'; tmux = @{ enabled = $false; pane = 'status-right' } }
   }
   ```

## Platform-Specific Issues

### PowerShell startup hangs for 30+ seconds

**What it means:** PowerShell takes a long time to start (or appears to hang) after adding `Import-Module Forgum` to your profile, or running a `forgum*` command on shell startup.

**Root cause:** Forgum's animation engine runs an infinite loop when `animation.mode` is set to anything other than `static` (e.g. `talking`, `typewriter`, `bounce`, `disco`, etc.). When an animation is triggered during profile load, the loop never exits and PowerShell cannot finish startup.

**How to fix it:**

1. **Preferred: set the animation mode to `static`** (only renders the final frame instantly):
   ```powershell
   $config = Get-CFConfig
   $config.animation.mode = 'static'
   Set-CFConfig -Config $config
   ```
   Or in `config.json`:
   ```json
   { "animation": { "mode": "static" } }
   ```

2. **Skip auto-start for the current session** (handy when the config is unreachable):
   ```powershell
   $env:FORGUM_NOAUTOSTART = '1'
   Import-Module Forgum
   ```

After fixing, restart your PowerShell window. Startup should return to under one second.

### Windows

**"Execution of scripts is disabled on this system"**
```powershell
# Fix: Set execution policy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Profile script not running**
```powershell
# Check if profile exists
Test-Path $PROFILE

# Create if missing
New-Item -ItemType File -Path $PROFILE -Force
```

### Mac/Linux

**"pwsh: command not found"**
```bash
# Install PowerShell
brew install powershell  # Mac
# or
sudo apt install powershell  # Ubuntu/Debian
```

**Permission denied**
```bash
# Fix permissions
chmod +x ~/.config/forgum/config.json
```

### tmux

**Fortune not showing in status bar**
```bash
# Test the command directly
pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Get-Fortune"

# Check tmux config
tmux show-option status-right
```

## Still Stuck?

If none of these solutions work:

1. **Check the GitHub Issues**: https://github.com/harish2222/Forgum/issues
2. **Search for your error message** — someone might have had the same problem
3. **Create a new issue** with:
   - Your operating system
   - PowerShell version (`$PSVersionTable.PSVersion`)
   - The exact error message
   - What you were trying to do

---

**Back:** [Custom Fortunes](Custom-Fortunes) | **Home:** [Home](Home)
