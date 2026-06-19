# Fish Integration

This guide shows you how to use Forgum from the Fish shell. Fish is a popular shell on Mac and Linux known for its user-friendly features.

## How It Works

Fish can't run PowerShell commands directly, but we'll create simple functions that call PowerShell with Forgum.

## Step 1: Make Sure PowerShell is Installed

```fish
# Check if PowerShell is installed
pwsh --version
```

If you see a version number, you're good. If not:
- **Mac**: `brew install powershell`
- **Linux**: See [Microsoft's guide](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell)

## Step 2: Create Forgum Functions

Fish stores its config in `~/.config/fish/config.fish`. Open it:

```fish
nano ~/.config/fish/config.fish
```

Add these lines:

```fish
# ============================================
# Forgum - Fortune Cow for Fish Shell
# ============================================

# Show a cow with a fortune
function forgum
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; forgum"
end

# Show your own message
function cow
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; forgum -Text '$argv'"
end

# Get just a fortune (no cow)
function fortune-cow
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Get-Fortune"
end

# List available cows
function cows
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Get-CFCow | Format-Table -AutoSize"
end

# Rainbow mode toggle
function rainbow
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; `$config = Get-CFConfig; `$config.lolcat.enabled = -not `$config.lolcat.enabled; Set-CFConfig -Config `$config; Write-Host 'Rainbow: ' -NoNewline; if (`$config.lolcat.enabled) { Write-Host 'ON' -ForegroundColor Magenta } else { Write-Host 'OFF' -ForegroundColor Gray }"
end
```

## Step 3: Save and Reload

```fish
# Reload Fish config
source ~/.config/fish/config.fish
```

## Step 4: Try It!

```fish
# Show a cow with a fortune
forgum

# Your own message
cow Hello World!

# Just a fortune
fortune-cow

# See all cows
cows

# Toggle rainbow
rainbow
```

## Show Fortune on Every Terminal Open

Add this to `~/.config/fish/config.fish`:

```fish
# Show a fortune cow when opening a new terminal
forgum
```

## Advanced: Random Cow on Each Open

```fish
# In ~/.config/fish/config.fish
function random_cow
    set cows default tux dragon cat elephant doge bunny moose whale
    set cow $cows[(random 1 (count $cows))]
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; forgum -CowFile '$cow'"
end
random_cow
```

## Sample Configurations (Copy-Paste Ready)

These are complete, ready-to-use snippets for common setups. Add them to your `~/.config/fish/config.fish`.

### Pattern 1: Basic Forgum (Fortune Cow on Startup)

```fish
# ============================================
# Forgum - Basic Fortune Cow
# ============================================
# Shows a cow with a random fortune every time you open a terminal.

function forgum
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; forgum"
end

# Show fortune on every terminal open
forgum
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

```fish
# ============================================
# Forgum - Random Thoughts + Fixed Animal
# ============================================
# Always uses the tux cow with a random fortune.

function forgum_tux
    set fortune (pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Get-Fortune")
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; forgum -Text '$fortune' -CowFile 'tux'"
end

# Call on startup
forgum_tux
```

**Expected output:** Same as Pattern 1 but always with the tux penguin cow.

### Pattern 3: Random Thoughts + Fixed Animal + Lolcat

```fish
# ============================================
# Forgum - Random Thoughts + Fixed Animal + Rainbow
# ============================================
# Shows tux cow with fortune and rainbow colors.

function forgum_tux_rainbow
    set fortune (pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Get-Fortune")
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; forgum -Text '$fortune' -CowFile 'tux' -Lolcat"
end

# Call on startup
forgum_tux_rainbow
```

**Expected output:** Same as Pattern 2 but with rainbow-colored text.

### Pattern 4: Random Thoughts + Random Animal

```fish
# ============================================
# Forgum - Random Thoughts + Random Animal
# ============================================
# Picks a random cow each time with a random fortune.

function forgum_random
    set cows default tux dragon cat elephant doge bunny moose whale
    set cow $cows[(random 1 (count $cows))]
    set fortune (pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Get-Fortune")
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; forgum -Text '$fortune' -CowFile '$cow'"
end

# Call on startup
forgum_random
```

### Pattern 5: Config-Based Toggle (Cow + Lolcat from config.json)

```fish
# ============================================
# Forgum - Config-Based Toggle
# ============================================
# Reads cow and lolcat settings from config.json.
# Edit config.json to change cow/lolcat without touching the profile.

function forgum_config
    set config_file ""
    if set -q FORGUM_CONFIG
        set config_file "$FORGUM_CONFIG"
    else if test -f "$HOME/.config/forgum/config.json"
        set config_file "$HOME/.config/forgum/config.json"
    else
        pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; forgum"
        return
    end

    set cow (python3 -c "import json; c=json.load(open('$config_file')); print(c.get('cow',{}).get('file','default'))" 2>/dev/null; or echo "default")
    set lolcat_enabled (python3 -c "import json; c=json.load(open('$config_file')); print('true' if c.get('lolcat',{}).get('enabled',False) else 'false')" 2>/dev/null; or echo "false")

    set lolcat_flag ""
    if test "$lolcat_enabled" = "true"
        set lolcat_flag "-Lolcat"
    end

    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; forgum -Text \$(Get-Fortune) -CowFile '$cow' $lolcat_flag"
end

# Call on startup
forgum_config
```

**To toggle lolcat:** Edit your `config.json` and set `"enabled": true` under `lolcat`. No fish config changes needed.

## Advanced: tmux Status Bar

If you use tmux, add this to `~/.tmux.conf`:

```bash
# Show a fortune in the tmux status bar
set -g status-right "#(pwsh -NoProfile -Command 'Import-Module Forgum -ErrorAction SilentlyContinue; Get-Fortune' 2>/dev/null)"
set -g status-interval 300
```

## What Each Command Does

| Command | What It Does |
|:--------|:-------------|
| `pwsh` | Starts PowerShell |
| `-NoProfile` | Doesn't load PowerShell's profile (faster) |
| `-Command` | Runs the following PowerShell code |
| `Import-Module Forgum` | Loads Forgum |
| `forgum` | Shows cow + fortune |
| `forgum -Text` | Shows cow with your message |
| `Get-Fortune` | Returns just a fortune |
| `Get-CFCow` | Lists all cow characters |

## Troubleshooting

**"pwsh: command not found"**
- PowerShell isn't installed. See Step 1 above.

**"Import-Module : The specified module 'Forgum' was not loaded"**
- Forgum isn't installed. Go to [Getting Started](Getting-Started).

**No output when running `forgum`**
- Try running the pwsh command directly to see error messages.

---

**Back:** [Bash & Zsh Integration](Bash-Zsh-Integration) | **Next:** [tmux Integration →](tmux-Integration)
