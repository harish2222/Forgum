# PowerShell Integration

This guide shows you how to make Forgum part of your PowerShell experience. After this, Forgum will greet you every time you open PowerShell.

## What is a PowerShell Profile?

Your PowerShell profile is a special file that runs automatically when you open PowerShell. Think of it like a "startup script" — anything you put in there runs every time.

## Step 1: Find Your Profile

Open PowerShell and type:

```powershell
$PROFILE
```

This shows you the path to your profile file. It's usually something like:
- **Windows**: `C:\Users\YourName\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`
- **Mac/Linux**: `~/.config/powershell/Microsoft.PowerShell_profile.ps1`

## Step 2: Open Your Profile

```powershell
# Open in Notepad (Windows)
notepad $PROFILE

# Open in VS Code (any platform)
code $PROFILE

# Open in Vim (Mac/Linux)
vim $PROFILE
```

If PowerShell says the file doesn't exist, create it:

```powershell
New-Item -ItemType File -Path $PROFILE -Force
```

## Step 3: Add Forgum

Copy and paste these lines into your profile file:

```powershell
# ============================================
# Forgum - Fortune Cow for PowerShell
# ============================================

# Import the module
Import-Module Forgum -ErrorAction SilentlyContinue

# Show a cow with a random fortune when PowerShell starts
Invoke-Forgum
```

## Step 4: Save and Restart

1. Save the file (Ctrl+S in most editors)
2. Close PowerShell
3. Open PowerShell again

You should see a cow with a fortune!

## Advanced Profile Setups

### Setup 1: Fortune Every Time (Simple)

```powershell
Import-Module Forgum -ErrorAction SilentlyContinue
Invoke-Forgum
```

### Setup 2: Random Cow Every Time

```powershell
Import-Module Forgum -ErrorAction SilentlyContinue

# Pick a random cow and show a fortune
$cows = Get-CFCow
$randomCow = $cows | Get-Random
Invoke-Forgum -CowFile $randomCow.Name
```

### Setup 3: Different Cow for Each Day

```powershell
Import-Module Forgum -ErrorAction SilentlyContinue

# Use day of year to pick a consistent cow for the day
$cows = Get-CFCow
$dayCow = $cows[(Get-Date).DayOfYear % $cows.Count]
Invoke-Forgum -CowFile $dayCow.Name
```

### Setup 4: Rainbow Mode

```powershell
Import-Module Forgum -ErrorAction SilentlyContinue

# Enable rainbow colors
$config = Get-CFConfig
$config.lolcat.enabled = $true
Set-CFConfig -Config $config

Invoke-Forgum
```

### Setup 5: Quiet Mode (Only on First Open)

```powershell
Import-Module Forgum -ErrorAction SilentlyContinue

# Only show fortune if this is the first PowerShell window
$hostWindow = (Get-Process -Id $PID).MainWindowTitle
if ($hostWindow -eq 'Windows PowerShell' -or $hostWindow -eq 'pwsh') {
    Invoke-Forgum
}
```

## Sample Configurations (Copy-Paste Ready)

These are complete, ready-to-use profile snippets for common setups.

### Pattern 1: Basic Forgum (Fortune Cow on Startup)

```powershell
# ============================================
# Forgum - Basic Fortune Cow
# ============================================
# Shows a cow with a random fortune every time PowerShell opens.

Import-Module Forgum -ErrorAction SilentlyContinue

# Invoke-Forgum calls the default cow and a random fortune
Invoke-Forgum
```

**Expected output:**
```
  ╭─────────────────────────────────────────╮
  │ The best way to predict the future is   │
  │ to invent it.                           │
  ╰─────────────────────────────────────────╯
            \   ^__^
             \  (oo)\_______
                (__)\       )\/\
                    ||----w |
                    ||     ||
```

### Pattern 2: Random Thoughts + Fixed Animal (tux)

```powershell
# ============================================
# Forgum - Random Thoughts + Fixed Animal
# ============================================
# Always uses the tux cow with a random fortune.

Import-Module Forgum -ErrorAction SilentlyContinue

function Show-FortuneCow {
    $fortune = Get-Fortune
    Invoke-Cowsay -Text $fortune -CowFile 'tux'
}

# Call on startup
Show-FortuneCow
```

**Expected output:**
```
  ╭─────────────────────────────────────────╮
  │ The best way to predict the future is   │
  │ to invent it.                           │
  ╰─────────────────────────────────────────╯
         \
          \
            .--.
           |o_o |
           |:_/ |
          //   \ \
         (|     | )
        /'\_   _/`\
        \___)=(___/
```

### Pattern 3: Random Thoughts + Fixed Animal + Lolcat

```powershell
# ============================================
# Forgum - Random Thoughts + Fixed Animal + Rainbow
# ============================================
# Shows tux cow with fortune and rainbow colors.

Import-Module Forgum -ErrorAction SilentlyContinue

function Show-FortuneCow {
    $fortune = Get-Fortune
    Invoke-Cowsay -Text $fortune -CowFile 'tux' -Lolcat
}

# Call on startup
Show-FortuneCow
```

**Expected output:** Same as Pattern 2 but with rainbow-colored text.

### Pattern 4: Random Thoughts + Random Animal

```powershell
# ============================================
# Forgum - Random Thoughts + Random Animal
# ============================================
# Picks a random cow each time with a random fortune.

Import-Module Forgum -ErrorAction SilentlyContinue

function Show-FortuneCow {
    $fortune = Get-Fortune
    $cow = (Get-CFCow | Get-Random).Name
    Invoke-Cowsay -Text $fortune -CowFile $cow
}

# Call on startup
Show-FortuneCow
```

### Pattern 5: Config-Based Toggle (Cow + Lolcat from config.json)

```powershell
# ============================================
# Forgum - Config-Based Toggle
# ============================================
# Reads cow and lolcat settings from config.json.
# Edit config.json to change cow/lolcat without touching the profile.

Import-Module Forgum -ErrorAction SilentlyContinue

function Show-FortuneCow {
    $config = Get-CFConfig

    # If config says random, pick random cow; otherwise use configured cow
    if ($config.cow.random) {
        $cow = (Get-CFCow | Get-Random).Name
    } elseif ($config.cow.file -ne 'default') {
        $cow = $config.cow.file
    } else {
        $cow = 'default'
    }

    # Build parameters
    $params = @{
        Text    = (Get-Fortune)
        CowFile = $cow
    }

    # Add Lolcat flag if enabled in config
    if ($config.lolcat.enabled) {
        $params['Lolcat'] = $true
    }

    Invoke-Cowsay @params
}

# Call on startup
Show-FortuneCow
```

**To toggle lolcat:** Edit your `config.json` and set `"enabled": true` under `lolcat`. No profile changes needed.

## Custom Profile Functions

Add these handy shortcuts to your profile:

```powershell
# Quick fortune
function ff { Invoke-Forgum }

# Fortune with a specific cow
function fc { param([string]$Cow) Invoke-Forgum -CowFile $Cow }

# Toggle rainbow
function lolcat {
    $config = Get-CFConfig
    $config.lolcat.enabled = -not $config.lolcat.enabled
    Set-CFConfig -Config $config
    Write-Host "Rainbow: $(if ($config.lolcat.enabled) {'ON'} else {'OFF'})" -ForegroundColor $(if ($config.lolcat.enabled) {'Magenta'} else {'Gray'})
}

# Change settings permanently
# Usage: forgum-set -Cow dragon -Lolcat $true
function forgum-set { Set-Forgum @args }

# Random cow gallery (shows 3 cows)
function cowgallery {
    Get-CFCow | Get-Random -Count 3 | ForEach-Object {
        Invoke-Cowsay -Text (Get-Fortune) -CowFile $_.Name
    }
}
```

## Cross-Shell Persistence

Forgum's configuration is shared across all shells (PowerShell, Bash, Zsh, Fish) because they all read from the same `config.json` file.

You can use `Set-Forgum` in your PowerShell `$PROFILE` to ensure certain settings are always applied when you start a session:

```powershell
# Force a specific cow and animation every time PowerShell starts
Set-Forgum -Cow dragon -Animation bounce
```

If you primarily use Bash or Zsh but want to change Forgum settings without opening PowerShell, you can add an alias to your `.bashrc` or `.zshrc`:

```bash
# Add to ~/.bashrc or ~/.zshrc
alias forgum-set='pwsh -Command "Set-Forgum"'

# Now you can use it directly from Bash:
# forgum-set -Cow tux -Animation talking
```

## What Each Line Does

| Line | What It Does |
|:-----|:-------------|
| `Import-Module Forgum` | Loads Forgum into PowerShell |
| `-ErrorAction SilentlyContinue` | Ignores errors if Forgum isn't installed |
| `Invoke-Forgum` | Shows a cow with a random fortune |
| `Get-CFConfig` | Reads the current settings |
| `Set-CFConfig` | Saves new settings |

## Troubleshooting

**"Import-Module : The specified module 'Forgum' was not loaded"**
- Forgum isn't installed yet. Go back to [Getting Started](Getting-Started).

**"Invoke-Forgum : The term 'Invoke-Forgum' is not recognized"**
- The import line might have an error. Check for typos.

**No cow appears on startup**
- Make sure `Invoke-Forgum` is on its own line in your profile.
- Restart PowerShell to test.

**PowerShell startup hangs for 30+ seconds after adding Forgum to my profile**
- Root cause: Forgum's animation engine runs an infinite loop when `animation.mode` is set to anything other than `static` (e.g. `talking`, `typewriter`, `bounce`, `disco`). When an animation fires during profile load, the loop never exits and PowerShell cannot finish startup.
- **Fix 1 — disable animations for startup** (preferred): set `animation.mode = 'static'` in your config:
  ```powershell
  $config = Get-CFConfig
  $config.animation.mode = 'static'
  Set-CFConfig -Config $config
  ```
  Or in `config.json`:
  ```json
  { "animation": { "mode": "static" } }
  ```
- **Fix 2 — skip auto-start for the current session**:
  ```powershell
  $env:FORGUM_NOAUTOSTART = '1'
  Import-Module Forgum
  ```
  This is useful when the config is read-only or you're locked out of editing it.

After applying either fix, restart your PowerShell window. Startup should return to under one second.

---

**Back:** [Getting Started](Getting-Started) | **Next:** [Bash & Zsh Integration →](Bash-Zsh-Integration)
