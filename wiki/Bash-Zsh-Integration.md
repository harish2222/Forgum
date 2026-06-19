# Bash & Zsh Integration

This guide shows you how to use Forgum from Bash or Zsh shells. Forgum is a PowerShell module, but you can call it from any shell!

## How It Works

Bash and Zsh can't run PowerShell commands directly, but they can call PowerShell with a command. We'll set up a simple shortcut.

## Step 1: Make Sure PowerShell is Installed

```bash
# Check if PowerShell is installed
pwsh --version
```

If you see a version number, you're good. If not, install PowerShell first:
- **Mac**: `brew install powershell`
- **Linux**: See [Microsoft's guide](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell)

## Step 2: Find Your Shell Config

```bash
# For Bash
echo $HOME/.bashrc

# For Zsh
echo $HOME/.zshrc
```

## Step 3: Add Forgum Functions

Open your config file:

```bash
# For Bash
nano ~/.bashrc

# For Zsh
nano ~/.zshrc
```

Add these lines at the end:

```bash
# ============================================
# Forgum - Fortune Cow for Bash/Zsh
# ============================================

# Show a cow with a fortune
forgum() {
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; forgum"
}

# Show your own message
cow() {
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; forgum -Text '$*'"
}

# Get just a fortune (no cow)
fortune-cow() {
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Get-Fortune"
}

# List available cows
cows() {
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Get-CFCow | Format-Table -AutoSize"
}

# Rainbow mode toggle
rainbow() {
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; `$config = Get-CFConfig; `$config.lolcat.enabled = -not `$config.lolcat.enabled; Set-CFConfig -Config `$config; Write-Host 'Rainbow: ' + (if (`$config.lolcat.enabled) {'ON'} else {'OFF'})"
}
```

## Step 4: Save and Reload

```bash
# For Bash
source ~/.bashrc

# For Zsh
source ~/.zshrc
```

## Step 5: Try It!

```bash
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

Add this to your `~/.bashrc` or `~/.zshrc`:

```bash
# Show a fortune cow when opening a new terminal
forgum
```

## Advanced: Random Cow on Each Open

```bash
# In ~/.bashrc or ~/.zshrc
random_cow() {
    local cows=("default" "tux" "dragon" "cat" "elephant" "doge" "bunny" "moose" "whale")
    local cow=${cows[$RANDOM % ${#cows[@]}]}
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; forgum -CowFile '$cow'"
}
random_cow
```

## Sample Configurations (Copy-Paste Ready)

These are complete, ready-to-use snippets for common setups. Add them to your `~/.bashrc` (Bash) or `~/.zshrc` (Zsh).

### Pattern 1: Basic Forgum (Fortune Cow on Startup)

**For Bash (`~/.bashrc`):**

```bash
# ============================================
# Forgum - Basic Fortune Cow
# ============================================
# Shows a cow with a random fortune every time you open a terminal.

forgum() {
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; forgum"
}

# Show fortune on every terminal open
forgum
```

**For Zsh (`~/.zshrc`):**

```zsh
# ============================================
# Forgum - Basic Fortune Cow
# ============================================
# Shows a cow with a random fortune every time you open a terminal.

forgum() {
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; forgum"
}

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

**For Bash (`~/.bashrc`):**

```bash
# ============================================
# Forgum - Random Thoughts + Fixed Animal
# ============================================
# Always uses the tux cow with a random fortune.

forgum_tux() {
    local fortune
    fortune=$(pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Get-Fortune")
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; forgum -Text '$fortune' -CowFile 'tux'"
}

# Call on startup
forgum_tux
```

**For Zsh (`~/.zshrc`):**

```zsh
# ============================================
# Forgum - Random Thoughts + Fixed Animal
# ============================================
# Always uses the tux cow with a random fortune.

forgum_tux() {
    local fortune
    fortune=$(pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Get-Fortune")
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; forgum -Text '$fortune' -CowFile 'tux'"
}

# Call on startup
forgum_tux
```

**Expected output:** Same as Pattern 1 but always with the tux penguin cow.

### Pattern 3: Random Thoughts + Fixed Animal + Lolcat

**For Bash (`~/.bashrc`):**

```bash
# ============================================
# Forgum - Random Thoughts + Fixed Animal + Rainbow
# ============================================
# Shows tux cow with fortune and rainbow colors.

forgum_tux_rainbow() {
    local fortune
    fortune=$(pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Get-Fortune")
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; forgum -Text '$fortune' -CowFile 'tux' -Lolcat"
}

# Call on startup
forgum_tux_rainbow
```

**For Zsh (`~/.zshrc`):**

```zsh
# ============================================
# Forgum - Random Thoughts + Fixed Animal + Rainbow
# ============================================
# Shows tux cow with fortune and rainbow colors.

forgum_tux_rainbow() {
    local fortune
    fortune=$(pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Get-Fortune")
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; forgum -Text '$fortune' -CowFile 'tux' -Lolcat"
}

# Call on startup
forgum_tux_rainbow
```

**Expected output:** Same as Pattern 2 but with rainbow-colored text.

### Pattern 4: Random Thoughts + Random Animal

**For Bash (`~/.bashrc`):**

```bash
# ============================================
# Forgum - Random Thoughts + Random Animal
# ============================================
# Picks a random cow each time with a random fortune.

forgum_random() {
    local cows=("default" "tux" "dragon" "cat" "elephant" "doge" "bunny" "moose" "whale")
    local cow=${cows[$RANDOM % ${#cows[@]}]}
    local fortune
    fortune=$(pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Get-Fortune")
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; forgum -Text '$fortune' -CowFile '$cow'"
}

# Call on startup
forgum_random
```

**For Zsh (`~/.zshrc`):**

```zsh
# ============================================
# Forgum - Random Thoughts + Random Animal
# ============================================
# Picks a random cow each time with a random fortune.

forgum_random() {
    local cows=("default" "tux" "dragon" "cat" "elephant" "doge" "bunny" "moose" "whale")
    local cow=${cows[$RANDOM % ${#cows[@]}]}
    local fortune
    fortune=$(pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Get-Fortune")
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; forgum -Text '$fortune' -CowFile '$cow'"
}

# Call on startup
forgum_random
```

### Pattern 5: Config-Based Toggle (Cow + Lolcat from config.json)

**For Bash (`~/.bashrc`):**

```bash
# ============================================
# Forgum - Config-Based Toggle
# ============================================
# Reads cow and lolcat settings from config.json.
# Edit config.json to change cow/lolcat without touching the profile.

forgum_config() {
    local config_file
    if [[ -n "$FORGUM_CONFIG" ]]; then
        config_file="$FORGUM_CONFIG"
    elif [[ -f "$HOME/.config/forgum/config.json" ]]; then
        config_file="$HOME/.config/forgum/config.json"
    else
        pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; forgum"
        return
    fi

    local cow lolcat_enabled
    cow=$(python3 -c "import json; c=json.load(open('$config_file')); print(c.get('cow',{}).get('file','default'))" 2>/dev/null || echo "default")
    lolcat_enabled=$(python3 -c "import json; c=json.load(open('$config_file')); print('true' if c.get('lolcat',{}).get('enabled',False) else 'false')" 2>/dev/null || echo "false")

    local lolcat_flag=""
    if [[ "$lolcat_enabled" == "true" ]]; then
        lolcat_flag="-Lolcat"
    fi

    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; forgum -Text \$(Get-Fortune) -CowFile '$cow' $lolcat_flag"
}

# Call on startup
forgum_config
```

**For Zsh (`~/.zshrc`):**

```zsh
# ============================================
# Forgum - Config-Based Toggle
# ============================================
# Reads cow and lolcat settings from config.json.
# Edit config.json to change cow/lolcat without touching the profile.

forgum_config() {
    local config_file
    if [[ -n "$FORGUM_CONFIG" ]]; then
        config_file="$FORGUM_CONFIG"
    elif [[ -f "$HOME/.config/forgum/config.json" ]]; then
        config_file="$HOME/.config/forgum/config.json"
    else
        pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; forgum"
        return
    fi

    local cow lolcat_enabled
    cow=$(python3 -c "import json; c=json.load(open('$config_file')); print(c.get('cow',{}).get('file','default'))" 2>/dev/null || echo "default")
    lolcat_enabled=$(python3 -c "import json; c=json.load(open('$config_file')); print('true' if c.get('lolcat',{}).get('enabled',False) else 'false')" 2>/dev/null || echo "false")

    local lolcat_flag=""
    if [[ "$lolcat_enabled" == "true" ]]; then
        lolcat_flag="-Lolcat"
    fi

    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; forgum -Text \$(Get-Fortune) -CowFile '$cow' $lolcat_flag"
}

# Call on startup
forgum_config
```

**To toggle lolcat:** Edit your `config.json` and set `"enabled": true` under `lolcat`. No shell config changes needed.

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

**Back:** [PowerShell Integration](PowerShell-Integration) | **Next:** [Fish Integration →](Fish-Integration)
