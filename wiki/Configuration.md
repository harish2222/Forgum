# Configuration

Forgum stores its settings in a JSON file. You can change how it looks and behaves by editing this file.

## Where is the Config File?

| Platform | Location |
|:---------|:---------|
| Windows | `~/Documents/PowerShell/forgum/config.json` |
| Mac/Linux | `~/.config/forgum/config.json` |
| Custom | Set the `FORGUM_CONFIG` environment variable |

## How to Change Settings

### Method 1: Use Set-Forgum (Easiest)

The `Set-Forgum` cmdlet is the recommended way to update your settings. It allows you to change configuration values with a single command without needing to handle the JSON file or configuration objects manually.

```powershell
# Enable rainbow colors and use the dragon cow
Set-Forgum -Lolcat $true -Cow dragon

# Set a talking animation with custom eyes
Set-Forgum -Animation talking -Eyes "@@"

# Enable random cows on startup
Set-Forgum -RandomCow $true

# Change multiple settings at once
Set-Forgum -Animation bounce -Cow bill-the-cat -RainbowFrequency 0.2
```

### Method 2: Advanced Manual Configuration

If you need to perform complex logic or bulk updates, you can manipulate the configuration object directly.

```powershell
# Read current settings
$config = Get-CFConfig

# Change something
$config.lolcat.enabled = $true
$config.animation.mode = 'talking'
$config.cow.file = 'tux'

# Save changes
Set-CFConfig -Config $config
```

### Method 3: Edit the Config File Directly

Open the config file in any text editor and change what you want.

## All Settings

Here's the complete config file with every setting explained:

```json
{
  "animation": {
    "mode": "static",
    "speed": 20,
    "duration": 12,
    "spread": 3.0
  },
  "cow": {
    "file": "default",
    "random": false,
    "mode": null,
    "eyes": "oo",
    "tongue": "  "
  },
  "fortune": {
    "database": "fortunes",
    "offensive": false
  },
  "lolcat": {
    "enabled": false,
    "truecolor": true,
    "frequency": 0.1,
    "invert": false
  },
  "output": {
    "wordWrap": true,
    "maxWidth": 60
  },
  "shell": {
    "integration": "auto",
    "tmux": {
      "enabled": false,
      "pane": "status-right"
    }
  }
}
```

## Settings Explained

### Animation Settings

| Setting | Values | What It Does |
|:--------|:-------|:-------------|
| `mode` | `static`, `talking`, `typewriter` | How the cow appears |
| `speed` | Any number | Animation speed (higher = faster) |
| `duration` | Any number | How long animation lasts (seconds) |
| `spread` | Any number | How spread out the animation is |

**Examples:**
```powershell
# Instant display (default)
$config.animation.mode = 'static'

# Talking animation (mouth moves)
$config.animation.mode = 'talking'

# Typewriter effect (types character by character)
$config.animation.mode = 'typewriter'

# Faster animation
$config.animation.speed = 50
```

### Cow Settings

| Setting | Values | What It Does |
|:--------|:-------|:-------------|
| `file` | Any cow name | Which cow to use |
| `random` | `true`, `false` | Pick a random cow each time |
| `mode` | `null`, `b`, `d`, `g`, `p`, `s`, `t`, `w`, `y` | Cow mood/expression |
| `eyes` | Any 2 characters | Custom eye characters |
| `tongue` | Any 2 characters | Custom tongue characters |

**Cow Modes:**
| Mode | Eyes | Name |
|:-----|:-----|:-----|
| `b` | `==` | Borg |
| `d` | `xx` | Dead |
| `g` | `$$` | Greedy |
| `p` | `@@` | Paranoia |
| `s` | `**` | Stoned |
| `t` | `--` | Tired |
| `w` | `OO` | Wasted |
| `y` | `..` | Youthful |

**Examples:**
```powershell
# Always use the tux cow
$config.cow.file = 'tux'

# Pick a random cow each time
$config.cow.random = $true

# Use dead eyes
$config.cow.mode = 'd'

# Custom eyes
$config.cow.eyes = '@@'
```

### Fortune Settings

| Setting | Values | What It Does |
|:--------|:-------|:-------------|
| `database` | Any fortune file name | Which fortune file to use |
| `offensive` | `true`, `false` | Include offensive fortunes |

**Examples:**
```powershell
# Use a custom fortune file
$config.fortune.database = 'my_fortunes'

# Include all fortunes
$config.fortune.offensive = $true
```

### Lolcat (Rainbow) Settings

| Setting | Values | What It Does |
|:--------|:-------|:-------------|
| `enabled` | `true`, `false` | Turn rainbow on/off |
| `truecolor` | `true`, `false` | Use 24-bit color (better) or 256-color |
| `frequency` | Any number | Rainbow tightness (higher = tighter) |
| `invert` | `true`, `false` | Swap colors |

**Examples:**
```powershell
# Turn on rainbow
$config.lolcat.enabled = $true

# Use 256-color mode (for older terminals)
$config.lolcat.truecolor = $false

# Tighter rainbow
$config.lolcat.frequency = 0.2

# Inverted colors
$config.lolcat.invert = $true
```

**Toggle Patterns:**

The easiest way to toggle lolcat is through your shell profile. These patterns let you control rainbow mode without editing `config.json` every time.

**PowerShell toggle function:**
```powershell
# Add to your PowerShell profile
function Toggle-Lolcat {
    $config = Get-CFConfig
    $config.lolcat.enabled = -not $config.lolcat.enabled
    Set-CFConfig -Config $config
    $status = if ($config.lolcat.enabled) { 'ON' } else { 'OFF' }
    Write-Host "Rainbow: $status" -ForegroundColor $(if ($config.lolcat.enabled) {'Magenta'} else {'Gray'})
}

# Shortcut to run fortune with or without lolcat
function ff {
    $config = Get-CFConfig
    if ($config.lolcat.enabled) {
        Invoke-Forgum -Lolcat
    } else {
        Invoke-Forgum
    }
}
```

**Bash/Zsh toggle function:**
```bash
# Add to ~/.bashrc or ~/.zshrc
toggle_lolcat() {
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; `$config = Get-CFConfig; `$config.lolcat.enabled = -not `$config.lolcat.enabled; Set-CFConfig -Config `$config; Write-Host 'Rainbow: ' + ('ON' if `$config.lolcat.enabled else 'OFF')"
}

# Shortcut to run fortune with or without lolcat
ff() {
    local enabled
    enabled=$(pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; (Get-CFConfig).lolcat.enabled")
    if [[ "$enabled" == "True" ]]; then
        pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Invoke-Forgum -Lolcat"
    else
        pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Invoke-Forgum"
    fi
}
```

**Fish toggle function:**
```fish
# Add to ~/.config/fish/config.fish
function toggle_lolcat
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; `$config = Get-CFConfig; `$config.lolcat.enabled = -not `$config.lolcat.enabled; Set-CFConfig -Config `$config; Write-Host 'Rainbow: ' -NoNewline; if (`$config.lolcat.enabled) { Write-Host 'ON' -ForegroundColor Magenta } else { Write-Host 'OFF' -ForegroundColor Gray }"
end

# Shortcut to run fortune with or without lolcat
function ff
    set enabled (pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; (Get-CFConfig).lolcat.enabled")
    if test "$enabled" = "True"
        pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Invoke-Forgum -Lolcat"
    else
        pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Invoke-Forgum"
    end
end
```

### Output Settings

| Setting | Values | What It Does |
|:--------|:-------|:-------------|
| `wordWrap` | `true`, `false` | Wrap long messages |
| `maxWidth` | Any number | Maximum width before wrapping |

**Examples:**
```powershell
# Don't wrap text
$config.output.wordWrap = $false

# Wider output
$config.output.maxWidth = 80
```

### Shell Settings

| Setting | Values | What It Does |
|:--------|:-------|:-------------|
| `integration` | `auto`, `on`, `off` | Shell integration |
| `tmux.enabled` | `true`, `false` | tmux integration |
| `tmux.pane` | `status-right`, `status-left` | Where to show in tmux |

## Reset to Defaults

If you mess up your config, delete the config file and Forgum will create a fresh one:

```powershell
# Windows
Remove-Item ~/Documents/PowerShell/forgum/config.json

# Mac/Linux
Remove-Item ~/.config/forgum/config.json
```

Or use the command:

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

---

**Back:** [tmux Integration](tmux-Integration) | **Next:** [Custom Cows →](Custom-Cows)
