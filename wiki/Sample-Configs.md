# Forgum Sample Configurations

Every combination of Forgum usage across all supported platforms and shells. Each code block is complete and copy-pasteable.

---

## Quick Reference Table

| Use Case | PowerShell | Bash/Zsh | Fish | Git-Bash | tmux |
|----------|-----------|----------|------|----------|------|
| Basic fortune | `Import-Module Forgum; Invoke-Forgum` | `pwsh -NoProfile -Command "... Invoke-Forgum"` | Same as Bash | Same as Bash | `set -g status-right "#(...)"` |
| Fixed cow (tux) | `Invoke-Forgum -CowFile 'tux'` | `pwsh -Command "... Invoke-Forgum -CowFile 'tux'"` | Same as Bash | Same as Bash | `set -g status-right "#(... Invoke-Cowsay -CowFile tux ...)"` |
| Lolcat on | `Set-CFConfig` + `Invoke-Forgum` | pwsh inline config toggle | Same as Bash | Same as Bash | pwsh inline config toggle |
| Random cow | `$cows \| Get-Random` | `shuf -n1` / array pick | `random 1 (count $cows)` | Same as Bash | N/A |
| Full combo | Random cow + lolcat + fortune | pwsh -Command with all options | Fish functions | Git-Bash alias | Inline pwsh |

---

## Use Case 1: Basic Forgum (Fortune Cow on Startup)

### PowerShell ($PROFILE)

```powershell
# ============================================
# Forgum - Basic Startup Fortune
# ============================================

# Import the module (silently ignores if not installed)
Import-Module Forgum -ErrorAction SilentlyContinue

# Show a cow with a random fortune when PowerShell starts
Invoke-Forgum
```

**Add to your profile:**
```powershell
# Open your profile in notepad
notepad $PROFILE

# Paste the code above, save, restart PowerShell
```

### Bash (~/.bashrc)

```bash
# ============================================
# Forgum - Basic Startup Fortune (Bash)
# ============================================

# Show a cow with a fortune when opening a new terminal
if command -v pwsh &>/dev/null; then
    if [ -t 1 ]; then
        pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Invoke-Forgum" 2>/dev/null
    fi
fi
```

**Add to your profile:**
```bash
# Append to ~/.bashrc
echo '' >> ~/.bashrc
echo '# Forgum' >> ~/.bashrc
echo 'if command -v pwsh &>/dev/null; then' >> ~/.bashrc
echo '    if [ -t 1 ]; then' >> ~/.bashrc
echo '        pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Invoke-Forgum" 2>/dev/null' >> ~/.bashrc
echo '    fi' >> ~/.bashrc
echo 'fi' >> ~/.bashrc
source ~/.bashrc
```

### Zsh (~/.zshrc)

```zsh
# ============================================
# Forgum - Basic Startup Fortune (Zsh)
# ============================================

# Show a cow with a fortune when opening a new terminal
if command -v pwsh &>/dev/null; then
    if [ -t 1 ]; then
        pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Invoke-Forgum" 2>/dev/null
    fi
fi
```

**Add to your profile:**
```zsh
# Append to ~/.zshrc
echo '' >> ~/.zshrc
echo '# Forgum' >> ~/.zshrc
echo 'if command -v pwsh &>/dev/null; then' >> ~/.zshrc
echo '    if [ -t 1 ]; then' >> ~/.zshrc
echo '        pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Invoke-Forgum" 2>/dev/null' >> ~/.zshrc
echo '    fi' >> ~/.zshrc
echo 'fi' >> ~/.zshrc
source ~/.zshrc
```

### Fish (~/.config/fish/config.fish)

```fish
# ============================================
# Forgum - Basic Startup Fortune (Fish)
# ============================================

# Fish uses fish_greeting to show output on startup
function fish_greeting
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Invoke-Forgum" 2>/dev/null
end
```

**Add to your profile:**
```fish
# Append to ~/.config/fish/config.fish
echo '' >> ~/.config/fish/config.fish
echo '# Forgum' >> ~/.config/fish/config.fish
echo 'function fish_greeting' >> ~/.config/fish/config.fish
echo '    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Invoke-Forgum" 2>/dev/null' >> ~/.config/fish/config.fish
echo 'end' >> ~/.config/fish/config.fish
source ~/.config/fish/config.fish
```

### Git-Bash (~/.bashrc)

```bash
# ============================================
# Forgum - Basic Startup Fortune (Git-Bash)
# ============================================
# Git-Bash is Bash on Windows. Use pwsh (PowerShell Core) or powershell.exe.

# Option A: Using PowerShell Core (pwsh) — recommended
if command -v pwsh &>/dev/null; then
    if [ -t 1 ]; then
        pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Invoke-Forgum" 2>/dev/null
    fi
fi

# Option B: Using Windows PowerShell (powershell.exe) — fallback
# Uncomment if pwsh is not installed:
# if [ -t 1 ]; then
#     powershell.exe -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Invoke-Forgum" 2>/dev/null
# fi
```

**Add to your profile:**
```bash
# Git-Bash uses ~/.bashrc
notepad ~/.bashrc
# Paste the code above, save, restart Git-Bash
```

---

## Use Case 2: Random Thoughts + Fixed Animal (e.g., tux)

### PowerShell ($PROFILE)

```powershell
# ============================================
# Forgum - Fixed Cow: Tux
# ============================================

Import-Module Forgum -ErrorAction SilentlyContinue

# Always show tux with a random fortune
Invoke-Forgum -CowFile 'tux'
```

### Bash (~/.bashrc)

```bash
# ============================================
# Forgum - Fixed Cow: Tux (Bash)
# ============================================

if command -v pwsh &>/dev/null; then
    if [ -t 1 ]; then
        pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Invoke-Forgum -CowFile 'tux'" 2>/dev/null
    fi
fi
```

### Zsh (~/.zshrc)

```zsh
# ============================================
# Forgum - Fixed Cow: Tux (Zsh)
# ============================================

if command -v pwsh &>/dev/null; then
    if [ -t 1 ]; then
        pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Invoke-Forgum -CowFile 'tux'" 2>/dev/null
    fi
fi
```

### Fish (~/.config/fish/config.fish)

```fish
# ============================================
# Forgum - Fixed Cow: Tux (Fish)
# ============================================

function fish_greeting
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Invoke-Forgum -CowFile 'tux'" 2>/dev/null
end
```

### Git-Bash (~/.bashrc)

```bash
# ============================================
# Forgum - Fixed Cow: Tux (Git-Bash)
# ============================================

if command -v pwsh &>/dev/null; then
    if [ -t 1 ]; then
        pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Invoke-Forgum -CowFile 'tux'" 2>/dev/null
    fi
fi
```

---

## Use Case 3: Random Thoughts + Fixed Animal + Lolcat

### PowerShell ($PROFILE)

```powershell
# ============================================
# Forgum - Fixed Cow + Lolcat Rainbow
# ============================================

Import-Module Forgum -ErrorAction SilentlyContinue

# Enable lolcat rainbow colors
$config = Get-CFConfig
$config.lolcat.enabled = $true
Set-CFConfig -Config $config

# Show tux with fortune in rainbow colors
Invoke-Forgum -CowFile 'tux'
```

### Bash (~/.bashrc)

```bash
# ============================================
# Forgum - Fixed Cow + Lolcat Rainbow (Bash)
# ============================================

if command -v pwsh &>/dev/null; then
    if [ -t 1 ]; then
        pwsh -NoProfile -Command "
            Import-Module Forgum -ErrorAction SilentlyContinue;
            `$config = Get-CFConfig;
            `$config.lolcat.enabled = `$true;
            Set-CFConfig -Config `$config;
            Invoke-Forgum -CowFile 'tux'
        " 2>/dev/null
    fi
fi
```

### Zsh (~/.zshrc)

```zsh
# ============================================
# Forgum - Fixed Cow + Lolcat Rainbow (Zsh)
# ============================================

if command -v pwsh &>/dev/null; then
    if [ -t 1 ]; then
        pwsh -NoProfile -Command "
            Import-Module Forgum -ErrorAction SilentlyContinue;
            `$config = Get-CFConfig;
            `$config.lolcat.enabled = `$true;
            Set-CFConfig -Config `$config;
            Invoke-Forgum -CowFile 'tux'
        " 2>/dev/null
    fi
fi
```

### Fish (~/.config/fish/config.fish)

```fish
# ============================================
# Forgum - Fixed Cow + Lolcat Rainbow (Fish)
# ============================================

function fish_greeting
    pwsh -NoProfile -Command "
        Import-Module Forgum -ErrorAction SilentlyContinue;
        `$config = Get-CFConfig;
        `$config.lolcat.enabled = `$true;
        Set-CFConfig -Config `$config;
        Invoke-Forgum -CowFile 'tux'
    " 2>/dev/null
end
```

### Git-Bash (~/.bashrc)

```bash
# ============================================
# Forgum - Fixed Cow + Lolcat Rainbow (Git-Bash)
# ============================================

if command -v pwsh &>/dev/null; then
    if [ -t 1 ]; then
        pwsh -NoProfile -Command "
            Import-Module Forgum -ErrorAction SilentlyContinue;
            `$config = Get-CFConfig;
            `$config.lolcat.enabled = `$true;
            Set-CFConfig -Config `$config;
            Invoke-Forgum -CowFile 'tux'
        " 2>/dev/null
    fi
fi
```

---

## Use Case 4: Random Thoughts + Random Animal (No Lolcat)

### PowerShell ($PROFILE)

```powershell
# ============================================
# Forgum - Random Cow on Every Startup
# ============================================

Import-Module Forgum -ErrorAction SilentlyContinue

# Pick a random cow and show a fortune
$cows = Get-CFCow
$randomCow = $cows | Get-Random
Invoke-Forgum -CowFile $randomCow.Name
```

### Bash (~/.bashrc)

```bash
# ============================================
# Forgum - Random Cow on Every Startup (Bash)
# ============================================

forgum_random_cow() {
    local cows=("default" "tux" "dragon" "cat" "elephant" "doge" "bunny" "moose" "whale" "koala" "penguin" "sheep" "cow" "ghost" "robot")
    local cow=${cows[$RANDOM % ${#cows[@]}]}
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Invoke-Forgum -CowFile '$cow'" 2>/dev/null
}

if command -v pwsh &>/dev/null; then
    if [ -t 1 ]; then
        forgum_random_cow
    fi
fi
```

### Zsh (~/.zshrc)

```zsh
# ============================================
# Forgum - Random Cow on Every Startup (Zsh)
# ============================================

forgum_random_cow() {
    local cows=("default" "tux" "dragon" "cat" "elephant" "doge" "bunny" "moose" "whale" "koala" "penguin" "sheep" "cow" "ghost" "robot")
    local cow=${cows[$((RANDOM % ${#cows[@]}))]}
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Invoke-Forgum -CowFile '$cow'" 2>/dev/null
}

if command -v pwsh &>/dev/null; then
    if [ -t 1 ]; then
        forgum_random_cow
    fi
fi
```

### Fish (~/.config/fish/config.fish)

```fish
# ============================================
# Forgum - Random Cow on Every Startup (Fish)
# ============================================

function fish_greeting
    set cows default tux dragon cat elephant doge bunny moose whale koala penguin sheep cow ghost robot
    set cow $cows[(random 1 (count $cows))]
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Invoke-Forgum -CowFile '$cow'" 2>/dev/null
end
```

### Git-Bash (~/.bashrc)

```bash
# ============================================
# Forgum - Random Cow on Every Startup (Git-Bash)
# ============================================

forgum_random_cow() {
    local cows=("default" "tux" "dragon" "cat" "elephant" "doge" "bunny" "moose" "whale" "koala" "penguin" "sheep" "cow" "ghost" "robot")
    local cow=${cows[$RANDOM % ${#cows[@]}]}
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Invoke-Forgum -CowFile '$cow'" 2>/dev/null
}

if command -v pwsh &>/dev/null; then
    if [ -t 1 ]; then
        forgum_random_cow
    fi
fi
```

---

## Use Case 5: Random Thoughts + Random Animal + Lolcat (FULL)

### PowerShell ($PROFILE)

```powershell
# ============================================
# Forgum - Full Combo: Random Cow + Lolcat
# ============================================

Import-Module Forgum -ErrorAction SilentlyContinue

# Enable lolcat
$config = Get-CFConfig
$config.lolcat.enabled = $true
Set-CFConfig -Config $config

# Pick random cow and show fortune in rainbow
$cows = Get-CFCow
$randomCow = $cows | Get-Random
Invoke-Forgum -CowFile $randomCow.Name
```

### Bash (~/.bashrc)

```bash
# ============================================
# Forgum - Full Combo: Random Cow + Lolcat (Bash)
# ============================================

forgum_full() {
    local cows=("default" "tux" "dragon" "cat" "elephant" "doge" "bunny" "moose" "whale" "koala" "penguin" "sheep" "cow" "ghost" "robot")
    local cow=${cows[$RANDOM % ${#cows[@]}]}
    pwsh -NoProfile -Command "
        Import-Module Forgum -ErrorAction SilentlyContinue;
        `$config = Get-CFConfig;
        `$config.lolcat.enabled = `$true;
        Set-CFConfig -Config `$config;
        Invoke-Forgum -CowFile '$cow'
    " 2>/dev/null
}

if command -v pwsh &>/dev/null; then
    if [ -t 1 ]; then
        forgum_full
    fi
fi
```

### Zsh (~/.zshrc)

```zsh
# ============================================
# Forgum - Full Combo: Random Cow + Lolcat (Zsh)
# ============================================

forgum_full() {
    local cows=("default" "tux" "dragon" "cat" "elephant" "doge" "bunny" "moose" "whale" "koala" "penguin" "sheep" "cow" "ghost" "robot")
    local cow=${cows[$((RANDOM % ${#cows[@]}))]}
    pwsh -NoProfile -Command "
        Import-Module Forgum -ErrorAction SilentlyContinue;
        `$config = Get-CFConfig;
        `$config.lolcat.enabled = `$true;
        Set-CFConfig -Config `$config;
        Invoke-Forgum -CowFile '$cow'
    " 2>/dev/null
}

if command -v pwsh &>/dev/null; then
    if [ -t 1 ]; then
        forgum_full
    fi
fi
```

### Fish (~/.config/fish/config.fish)

```fish
# ============================================
# Forgum - Full Combo: Random Cow + Lolcat (Fish)
# ============================================

function fish_greeting
    set cows default tux dragon cat elephant doge bunny moose whale koala penguin sheep cow ghost robot
    set cow $cows[(random 1 (count $cows))]
    pwsh -NoProfile -Command "
        Import-Module Forgum -ErrorAction SilentlyContinue;
        `$config = Get-CFConfig;
        `$config.lolcat.enabled = `$true;
        Set-CFConfig -Config `$config;
        Invoke-Forgum -CowFile '$cow'
    " 2>/dev/null
end
```

### Git-Bash (~/.bashrc)

```bash
# ============================================
# Forgum - Full Combo: Random Cow + Lolcat (Git-Bash)
# ============================================

forgum_full() {
    local cows=("default" "tux" "dragon" "cat" "elephant" "doge" "bunny" "moose" "whale" "koala" "penguin" "sheep" "cow" "ghost" "robot")
    local cow=${cows[$RANDOM % ${#cows[@]}]}
    pwsh -NoProfile -Command "
        Import-Module Forgum -ErrorAction SilentlyContinue;
        `$config = Get-CFConfig;
        `$config.lolcat.enabled = `$true;
        Set-CFConfig -Config `$config;
        Invoke-Forgum -CowFile '$cow'
    " 2>/dev/null
}

if command -v pwsh &>/dev/null; then
    if [ -t 1 ]; then
        forgum_full
    fi
fi
```

---

## Use Case 6: Config-Based Toggle (Dynamic)

This pattern reads `config.json` at startup to decide what to show. Useful for toggling behavior without editing your profile.

### PowerShell ($PROFILE)

```powershell
# ============================================
# Forgum - Config-Driven Startup
# ============================================

Import-Module Forgum -ErrorAction SilentlyContinue

# Read config and decide what to show
if (Get-Command Get-CFConfig -ErrorAction Ignore) {
    $config = Get-CFConfig

    if ($config.startup.enabled) {
        $params = @{}

        # Apply cow setting
        if ($config.cow.random) {
            $cows = Get-CFCow
            $params['CowFile'] = ($cows | Get-Random).Name
        } elseif ($config.cow.file -and $config.cow.file -ne 'default') {
            $params['CowFile'] = $config.cow.file
        }

        # Apply lolcat
        if ($config.lolcat.enabled) {
            $config.lolcat.enabled = $true
            Set-CFConfig -Config $config
        }

        Invoke-Forgum @params
    }
}
```

### Bash (~/.bashrc)

```bash
# ============================================
# Forgum - Config-Driven Startup (Bash)
# ============================================

forgum_config_driven() {
    pwsh -NoProfile -Command "
        Import-Module Forgum -ErrorAction SilentlyContinue;
        if (Get-Command Get-CFConfig -ErrorAction Ignore) {
            `$config = Get-CFConfig;
            if (`$config.startup.enabled) {
                `$params = @{};
                if (`$config.cow.random) {
                    `$cows = Get-CFCow;
                    `$params['CowFile'] = (`$cows | Get-Random).Name;
                } elseif (`$config.cow.file -and `$config.cow.file -ne 'default') {
                    `$params['CowFile'] = `$config.cow.file;
                };
                if (`$config.lolcat.enabled) {
                    Set-CFConfig -Config `$config;
                };
                Invoke-Forgum @`$params;
            }
        }
    " 2>/dev/null
}

if command -v pwsh &>/dev/null; then
    if [ -t 1 ]; then
        forgum_config_driven
    fi
fi
```

### Zsh (~/.zshrc)

```zsh
# ============================================
# Forgum - Config-Driven Startup (Zsh)
# ============================================

forgum_config_driven() {
    pwsh -NoProfile -Command "
        Import-Module Forgum -ErrorAction SilentlyContinue;
        if (Get-Command Get-CFConfig -ErrorAction Ignore) {
            `$config = Get-CFConfig;
            if (`$config.startup.enabled) {
                `$params = @{};
                if (`$config.cow.random) {
                    `$cows = Get-CFCow;
                    `$params['CowFile'] = (`$cows | Get-Random).Name;
                } elseif (`$config.cow.file -and `$config.cow.file -ne 'default') {
                    `$params['CowFile'] = `$config.cow.file;
                };
                if (`$config.lolcat.enabled) {
                    Set-CFConfig -Config `$config;
                };
                Invoke-Forgum @`$params;
            }
        }
    " 2>/dev/null
}

if command -v pwsh &>/dev/null; then
    if [ -t 1 ]; then
        forgum_config_driven
    fi
fi
```

### Fish (~/.config/fish/config.fish)

```fish
# ============================================
# Forgum - Config-Driven Startup (Fish)
# ============================================

function fish_greeting
    pwsh -NoProfile -Command "
        Import-Module Forgum -ErrorAction SilentlyContinue;
        if (Get-Command Get-CFConfig -ErrorAction Ignore) {
            `$config = Get-CFConfig;
            if (`$config.startup.enabled) {
                `$params = @{};
                if (`$config.cow.random) {
                    `$cows = Get-CFCow;
                    `$params['CowFile'] = (`$cows | Get-Random).Name;
                } elseif (`$config.cow.file -and `$config.cow.file -ne 'default') {
                    `$params['CowFile'] = `$config.cow.file;
                };
                if (`$config.lolcat.enabled) {
                    Set-CFConfig -Config `$config;
                };
                Invoke-Forgum @`$params;
            }
        }
    " 2>/dev/null
end
```

### Git-Bash (~/.bashrc)

```bash
# ============================================
# Forgum - Config-Driven Startup (Git-Bash)
# ============================================

forgum_config_driven() {
    pwsh -NoProfile -Command "
        Import-Module Forgum -ErrorAction SilentlyContinue;
        if (Get-Command Get-CFConfig -ErrorAction Ignore) {
            `$config = Get-CFConfig;
            if (`$config.startup.enabled) {
                `$params = @{};
                if (`$config.cow.random) {
                    `$cows = Get-CFCow;
                    `$params['CowFile'] = (`$cows | Get-Random).Name;
                } elseif (`$config.cow.file -and `$config.cow.file -ne 'default') {
                    `$params['CowFile'] = `$config.cow.file;
                };
                if (`$config.lolcat.enabled) {
                    Set-CFConfig -Config `$config;
                };
                Invoke-Forgum @`$params;
            }
        }
    " 2>/dev/null
}

if command -v pwsh &>/dev/null; then
    if [ -t 1 ]; then
        forgum_config_driven
    fi
fi
```

---

## Use Case 7: tmux Integration

### Basic Fortune in Status Bar (~/.tmux.conf)

```bash
# ============================================
# Forgum - Fortune in tmux Status Bar
# ============================================

# Show a fortune in the bottom-right corner
set -g status-right "#(pwsh -NoProfile -Command 'Import-Module Forgum -ErrorAction SilentlyContinue; Get-Fortune' 2>/dev/null)"

# Update every 5 minutes (300 seconds)
set -g status-interval 300

# Style the status bar
set -g status-style bg=black,fg=white
set -g status-right-style fg=cyan
```

### With Lolcat in tmux (~/.tmux.conf)

```bash
# ============================================
# Forgum - Colored Fortune in tmux Status Bar
# ============================================

# Show a rainbow-colored fortune in the status bar
set -g status-right "#(pwsh -NoProfile -Command 'Import-Module Forgum -ErrorAction SilentlyContinue; `$config = Get-CFConfig; `$config.lolcat.enabled = `$true; Set-CFConfig -Config `$config; Get-Fortune' 2>/dev/null)"

# Update every 5 minutes
set -g status-interval 300

# Style the status bar
set -g status-style bg=black,fg=white
set -g status-right-style fg=magenta
```

### Fortune + Time (~/.tmux.conf)

```bash
# ============================================
# Forgum - Fortune + Time in tmux Status Bar
# ============================================

set -g status-right "#(pwsh -NoProfile -Command 'Import-Module Forgum -ErrorAction SilentlyContinue; Get-Fortune' 2>/dev/null) | %H:%M"
set -g status-interval 300
set -g status-style bg=black,fg=white
set -g status-right-style fg=cyan
```

### Cow + Fortune on Left Side (~/.tmux.conf)

```bash
# ============================================
# Forgum - Cow + Fortune on Left Side of tmux
# ============================================

set -g status-left "#(pwsh -NoProfile -Command 'Import-Module Forgum -ErrorAction SilentlyContinue; Invoke-Cowsay -Text (Get-Fortune) -CowFile default' 2>/dev/null)"
set -g status-interval 300
set -g status-style bg=black,fg=white
set -g status-left-style fg=green
```

### Fixed Cow in Status Bar (~/.tmux.conf)

```bash
# ============================================
# Forgum - Tux in tmux Status Bar
# ============================================

set -g status-right "#(pwsh -NoProfile -Command 'Import-Module Forgum -ErrorAction SilentlyContinue; Invoke-Cowsay -Text (Get-Fortune) -CowFile tux' 2>/dev/null)"
set -g status-interval 300
```

### Colored Fortune with tmux Style (~/.tmux.conf)

```bash
# ============================================
# Forgum - Colored Fortune with tmux Formatting
# ============================================

set -g status-right "#[fg=cyan]#(pwsh -NoProfile -Command 'Import-Module Forgum -ErrorAction SilentlyContinue; Get-Fortune' 2>/dev/null)#[default]"
set -g status-interval 300
```

### Reload tmux Config

```bash
# Apply changes without restarting tmux
tmux source-file ~/.tmux.conf

# Or start a new session
tmux new-session
```

---

## Use Case 8: Aliases and Shortcuts

### PowerShell Aliases ($PROFILE)

```powershell
# ============================================
# Forgum - PowerShell Aliases & Shortcuts
# ============================================

Import-Module Forgum -ErrorAction SilentlyContinue

# Quick fortune — type `ff` to see a cow
function ff { Invoke-Forgum }

# Fortune with a specific cow — type `fc tux`
function fc { param([string]$Cow) Invoke-Forgum -CowFile $Cow }

# Cowsay with your own message — type `cow hello`
function cow { param([string]$Text) Invoke-Cowsay -Text $Text }

# Toggle rainbow — type `lolcat`
function lolcat {
    $config = Get-CFConfig
    $config.lolcat.enabled = -not $config.lolcat.enabled
    Set-CFConfig -Config $config
    Write-Host "Lolcat: $(if ($config.lolcat.enabled) {'ON'} else {'OFF'})" -ForegroundColor $(if ($config.lolcat.enabled) {'Magenta'} else {'Gray'})
}

# Random cow gallery — type `cowgallery`
function cowgallery {
    param([int]$Count = 3)
    Get-CFCow | Get-Random -Count $Count | ForEach-Object {
        Invoke-Cowsay -Text (Get-Fortune) -CowFile $_.Name
    }
}

# View config — type `cowconfig`
function cowconfig { Get-CFConfig | ConvertTo-Json -Depth 4 }

# Preview a cow — type `cowpreview dragon`
function cowpreview {
    param([string]$Cow = 'default', [string]$Text = 'Hello!')
    Invoke-Cowsay -Text $Text -CowFile $Cow
}

# Set animation — type `cow-animate typewriter`
function cow-animate {
    param([ValidateSet('static','talking','typewriter')]$Mode)
    $config = Get-CFConfig
    $config.animation.mode = $Mode
    Set-CFConfig -Config $config
    Write-Host "Animation: $Mode"
}

# Set cow eyes — type `cow-eyes dead`
function cow-eyes {
    param(
        [ValidateSet('borg','dead','greedy','paranoia','stoned','tired','wasted','youthful')]$Preset,
        [string]$Custom
    )
    $eyes = switch ($Preset) {
        'borg' {'=='}, 'dead' {'xx'}, 'greedy' {'$$'}, 'paranoia' {'@@'},
        'stoned' {'**'}, 'tired' {'--'}, 'wasted' {'OO'}, 'youthful' {'..'}
        default { $Custom }
    }
    $config = Get-CFConfig
    $config.cow.eyes = $eyes
    Set-CFConfig -Config $config
    Write-Host "Cow eyes: $eyes"
}

# Tab completion for Invoke-Cowsay -CowFile
Register-ArgumentCompleter -CommandName Invoke-Cowsay -ParameterName CowFile -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    Get-CFCow | Where-Object { $_ -like "*$wordToComplete*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
```

### Bash Aliases (~/.bashrc)

```bash
# ============================================
# Forgum - Bash/Zsh Aliases & Shortcuts
# ============================================

# Quick fortune
alias ff='pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Invoke-Forgum"'

# Fortune with a specific cow — fc tux
fc() {
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Invoke-Forgum -CowFile '$1'" 2>/dev/null
}

# Cowsay with your own message — cow hello
cow() {
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Invoke-Cowsay -Text '$*'" 2>/dev/null
}

# Toggle rainbow
rainbow() {
    pwsh -NoProfile -Command "
        Import-Module Forgum -ErrorAction SilentlyContinue;
        `$config = Get-CFConfig;
        `$config.lolcat.enabled = -not `$config.lolcat.enabled;
        Set-CFConfig -Config `$config;
        if (`$config.lolcat.enabled) { Write-Host 'Rainbow: ON' } else { Write-Host 'Rainbow: OFF' }
    " 2>/dev/null
}

# View config
alias cowconfig='pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Get-CFConfig | ConvertTo-Json -Depth 4"'

# Preview a cow — cowpreview dragon
cowpreview() {
    local cow=${1:-default}
    local text=${2:-Hello!}
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Invoke-Cowsay -Text '$text' -CowFile '$cow'" 2>/dev/null
}

# Random cow gallery
cowgallery() {
    local count=${1:-3}
    pwsh -NoProfile -Command "
        Import-Module Forgum -ErrorAction SilentlyContinue;
        Get-CFCow | Get-Random -Count $count | ForEach-Object {
            Invoke-Cowsay -Text (Get-Fortune) -CowFile `$_.Name
        }
    " 2>/dev/null
}

# Set animation — cow-animate typewriter
cow-animate() {
    local mode=${1:-static}
    pwsh -NoProfile -Command "
        Import-Module Forgum -ErrorAction SilentlyContinue;
        `$config = Get-CFConfig;
        `$config.animation.mode = '$mode';
        Set-CFConfig -Config `$config;
        Write-Host 'Animation: $mode'
    " 2>/dev/null
}
```

### Fish Aliases (~/.config/fish/config.fish)

```fish
# ============================================
# Forgum - Fish Aliases & Shortcuts
# ============================================

# Quick fortune
function ff
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Invoke-Forgum" 2>/dev/null
end

# Fortune with a specific cow — fc tux
function fc
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Invoke-Forgum -CowFile '$argv[1]'" 2>/dev/null
end

# Cowsay with your own message — cow hello
function cow
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Invoke-Cowsay -Text '$argv'" 2>/dev/null
end

# Toggle rainbow
function rainbow
    pwsh -NoProfile -Command "
        Import-Module Forgum -ErrorAction SilentlyContinue;
        `$config = Get-CFConfig;
        `$config.lolcat.enabled = -not `$config.lolcat.enabled;
        Set-CFConfig -Config `$config;
        if (`$config.lolcat.enabled) { Write-Host 'Rainbow: ON' } else { Write-Host 'Rainbow: OFF' }
    " 2>/dev/null
end

# View config
function cowconfig
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Get-CFConfig | ConvertTo-Json -Depth 4" 2>/dev/null
end

# Preview a cow — cowpreview dragon
function cowpreview
    set cow (test (count $argv) -gt 0; and echo $argv[1]; or echo default)
    set text (test (count $argv) -gt 1; and echo $argv[2]; or echo Hello!)
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Invoke-Cowsay -Text '$text' -CowFile '$cow'" 2>/dev/null
end

# Random cow gallery
function cowgallery
    set count (test (count $argv) -gt 0; and echo $argv[1]; or echo 3)
    pwsh -NoProfile -Command "
        Import-Module Forgum -ErrorAction SilentlyContinue;
        Get-CFCow | Get-Random -Count $count | ForEach-Object {
            Invoke-Cowsay -Text (Get-Fortune) -CowFile `$_.Name
        }
    " 2>/dev/null
end

# Set animation — cow-animate typewriter
function cow-animate
    set mode (test (count $argv) -gt 0; and echo $argv[1]; or echo static)
    pwsh -NoProfile -Command "
        Import-Module Forgum -ErrorAction SilentlyContinue;
        `$config = Get-CFConfig;
        `$config.animation.mode = '$mode';
        Set-CFConfig -Config `$config;
        Write-Host 'Animation: $mode'
    " 2>/dev/null
end
```

---

## Use Case 9: Custom Functions

### PowerShell Custom Functions ($PROFILE)

```powershell
# ============================================
# Forgum - Custom Functions (PowerShell)
# ============================================

Import-Module Forgum -ErrorAction SilentlyContinue

# ── cowconfig: View or set config values ──
# Usage: cowconfig                         → show full config
#        cowconfig lolcat.enabled           → read a value
#        cowconfig lolcat.enabled true      → set a value
function cowconfig {
    param(
        [string]$Path,
        [object]$Value
    )
    $config = Get-CFConfig
    if ($Path) {
        $parts = $Path -split '\.'
        $current = $config
        foreach ($part in $parts[0..($parts.Length-2)]) {
            $current = $current.$part
        }
        if ($null -ne $Value) {
            $current.$parts[-1] = $Value
            Set-CFConfig -Config $config
            Write-Host "Set $Path = $Value" -ForegroundColor Green
        } else {
            $current.$parts[-1]
        }
    } else {
        $config | ConvertTo-Json -Depth 4
    }
}

# ── cowpreview: Preview any cow with a message ──
# Usage: cowpreview                        → default cow
#        cowpreview tux                    → tux cow
#        cowpreview dragon "Hello world!"  → custom message
function cowpreview {
    param(
        [string]$Cow = 'default',
        [string]$Text = 'Hello!'
    )
    Invoke-Cowsay -Text $Text -CowFile $Cow
}

# ── cowgallery: Show a random gallery of cows ──
# Usage: cowgallery                        → 5 random cows
#        cowgallery 10                     → 10 random cows
function cowgallery {
    param([int]$Count = 5)
    Get-CFCow | Get-Random -Count $Count | ForEach-Object {
        Invoke-Cowsay -Text (Get-Fortune) -CowFile $_
    }
}

# ── lolcat-toggle: Toggle rainbow mode ──
# Usage: lolcat-toggle                     → toggles on/off
function lolcat-toggle {
    $config = Get-CFConfig
    $config.lolcat.enabled = -not $config.lolcat.enabled
    Set-CFConfig -Config $config
    if ($config.lolcat.enabled) {
        Write-Host "Lolcat: ON" -ForegroundColor Green
    } else {
        Write-Host "Lolcat: OFF" -ForegroundColor Yellow
    }
}

# ── cow-animate: Change animation mode ──
# Usage: cow-animate static
#        cow-animate talking
#        cow-animate typewriter
function cow-animate {
    param([ValidateSet('static','talking','typewriter')]$Mode)
    $config = Get-CFConfig
    $config.animation.mode = $Mode
    Set-CFConfig -Config $config
    Write-Host "Animation: $Mode" -ForegroundColor Cyan
}

# ── cow-eyes: Set cow eyes from presets ──
# Usage: cow-eyes dead
#        cow-eyes borg
#        cow-eyes -Custom '@@'
function cow-eyes {
    param(
        [ValidateSet('borg','dead','greedy','paranoia','stoned','tired','wasted','youthful')]$Preset,
        [string]$Custom
    )
    $eyes = switch ($Preset) {
        'borg'     { '==' }
        'dead'     { 'xx' }
        'greedy'   { '$$' }
        'paranoia' { '@@' }
        'stoned'   { '**' }
        'tired'    { '--' }
        'wasted'   { 'OO' }
        'youthful' { '..' }
        default    { $Custom }
    }
    $config = Get-CFConfig
    $config.cow.eyes = $eyes
    Set-CFConfig -Config $config
    Write-Host "Cow eyes: $eyes" -ForegroundColor Cyan
}

# ── cow-mood: Set cow mood (mode) ──
# Usage: cow-mood dead
#        cow-mood paranoia
function cow-mood {
    param([ValidateSet('b','d','g','p','s','t','w','y')]$Mode)
    $config = Get-CFConfig
    $config.cow.mode = $Mode
    Set-CFConfig -Config $config
    $names = @{ b='Borg'; d='Dead'; g='Greedy'; p='Paranoia'; s='Stoned'; t='Tired'; w='Wasted'; y='Youthful' }
    Write-Host "Cow mood: $($names[$Mode])" -ForegroundColor Cyan
}

# ── cow-list: List all available cows ──
# Usage: cow-list                          → table of all cows
#        cow-list -Filter cat              → filter by name
function cow-list {
    param([string]$Filter)
    $cows = Get-CFCow
    if ($Filter) {
        $cows = $cows | Where-Object { $_ -like "*$Filter*" }
    }
    $cows | Format-Table -AutoSize
}
```

### Bash Custom Functions (~/.bashrc)

```bash
# ============================================
# Forgum - Custom Functions (Bash/Zsh)
# ============================================

# ── cowconfig: View or set config ──
cowconfig() {
    if [ -z "$1" ]; then
        pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Get-CFConfig | ConvertTo-Json -Depth 4" 2>/dev/null
    elif [ -z "$2" ]; then
        pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; `$c = Get-CFConfig; `$parts = '$1' -split '\.'; `$current = `$c; foreach (`$p in `$parts[0..(`$parts.Length-2)]) { `$current = `$current.`$p }; `$current.`$parts[-1]" 2>/dev/null
    else
        pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; `$c = Get-CFConfig; `$parts = '$1' -split '\.'; `$current = `$c; foreach (`$p in `$parts[0..(`$parts.Length-2)]) { `$current = `$current.`$p }; `$current.`$parts[-1] = '$2'; Set-CFConfig -Config `$c; Write-Host 'Set $1 = $2'" 2>/dev/null
    fi
}

# ── cowpreview: Preview any cow ──
cowpreview() {
    local cow=${1:-default}
    local text=${2:-Hello!}
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Invoke-Cowsay -Text '$text' -CowFile '$cow'" 2>/dev/null
}

# ── cowgallery: Random gallery ──
cowgallery() {
    local count=${1:-5}
    pwsh -NoProfile -Command "
        Import-Module Forgum -ErrorAction SilentlyContinue;
        Get-CFCow | Get-Random -Count $count | ForEach-Object {
            Invoke-Cowsay -Text (Get-Fortune) -CowFile `$_.Name
        }
    " 2>/dev/null
}

# ── lolcat-toggle: Toggle rainbow ──
lolcat-toggle() {
    pwsh -NoProfile -Command "
        Import-Module Forgum -ErrorAction SilentlyContinue;
        `$config = Get-CFConfig;
        `$config.lolcat.enabled = -not `$config.lolcat.enabled;
        Set-CFConfig -Config `$config;
        if (`$config.lolcat.enabled) { Write-Host 'Lolcat: ON' -ForegroundColor Green } else { Write-Host 'Lolcat: OFF' -ForegroundColor Yellow }
    " 2>/dev/null
}

# ── cow-animate: Change animation ──
cow-animate() {
    local mode=${1:-static}
    pwsh -NoProfile -Command "
        Import-Module Forgum -ErrorAction SilentlyContinue;
        `$config = Get-CFConfig;
        `$config.animation.mode = '$mode';
        Set-CFConfig -Config `$config;
        Write-Host 'Animation: $mode' -ForegroundColor Cyan
    " 2>/dev/null
}

# ── cow-eyes: Set cow eyes ──
cow-eyes() {
    local preset=$1
    local eyes
    case $preset in
        borg)     eyes='==' ;;
        dead)     eyes='xx' ;;
        greedy)   eyes='$$' ;;
        paranoia) eyes='@@' ;;
        stoned)   eyes='**' ;;
        tired)    eyes='--' ;;
        wasted)   eyes='OO' ;;
        youthful) eyes='..' ;;
        *)        eyes=$preset ;;
    esac
    pwsh -NoProfile -Command "
        Import-Module Forgum -ErrorAction SilentlyContinue;
        `$config = Get-CFConfig;
        `$config.cow.eyes = '$eyes';
        Set-CFConfig -Config `$config;
        Write-Host 'Cow eyes: $eyes' -ForegroundColor Cyan
    " 2>/dev/null
}

# ── cow-mood: Set cow mood ──
cow-mood() {
    local mode=$1
    pwsh -NoProfile -Command "
        Import-Module Forgum -ErrorAction SilentlyContinue;
        `$config = Get-CFConfig;
        `$config.cow.mode = '$mode';
        Set-CFConfig -Config `$config;
        Write-Host 'Cow mood set to: $mode' -ForegroundColor Cyan
    " 2>/dev/null
}

# ── cow-list: List all cows ──
cow-list() {
    local filter=$1
    if [ -z "$filter" ]; then
        pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Get-CFCow | Format-Table -AutoSize" 2>/dev/null
    else
        pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Get-CFCow | Where-Object { `$_ -like '*$filter*' } | Format-Table -AutoSize" 2>/dev/null
    fi
}
```

### Fish Custom Functions (~/.config/fish/config.fish)

```fish
# ============================================
# Forgum - Custom Functions (Fish)
# ============================================

# ── cowconfig: View or set config ──
function cowconfig
    if test (count $argv) -eq 0
        pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Get-CFConfig | ConvertTo-Json -Depth 4" 2>/dev/null
    else if test (count $argv) -eq 1
        pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; `$c = Get-CFConfig; `$parts = '$argv[1]' -split '\.'; `$current = `$c; foreach (`$p in `$parts[0..(`$parts.Length-2)]) { `$current = `$current.`$p }; `$current.`$parts[-1]" 2>/dev/null
    else
        pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; `$c = Get-CFConfig; `$parts = '$argv[1]' -split '\.'; `$current = `$c; foreach (`$p in `$parts[0..(`$parts.Length-2)]) { `$current = `$current.`$p }; `$current.`$parts[-1] = '$argv[2]'; Set-CFConfig -Config `$c; Write-Host 'Set $argv[1] = $argv[2]'" 2>/dev/null
    end
end

# ── cowpreview: Preview any cow ──
function cowpreview
    set cow (test (count $argv) -gt 0; and echo $argv[1]; or echo default)
    set text (test (count $argv) -gt 1; and echo $argv[2]; or echo Hello!)
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Invoke-Cowsay -Text '$text' -CowFile '$cow'" 2>/dev/null
end

# ── cowgallery: Random gallery ──
function cowgallery
    set count (test (count $argv) -gt 0; and echo $argv[1]; or echo 5)
    pwsh -NoProfile -Command "
        Import-Module Forgum -ErrorAction SilentlyContinue;
        Get-CFCow | Get-Random -Count $count | ForEach-Object {
            Invoke-Cowsay -Text (Get-Fortune) -CowFile `$_.Name
        }
    " 2>/dev/null
end

# ── lolcat-toggle: Toggle rainbow ──
function lolcat-toggle
    pwsh -NoProfile -Command "
        Import-Module Forgum -ErrorAction SilentlyContinue;
        `$config = Get-CFConfig;
        `$config.lolcat.enabled = -not `$config.lolcat.enabled;
        Set-CFConfig -Config `$config;
        if (`$config.lolcat.enabled) { Write-Host 'Lolcat: ON' -ForegroundColor Green } else { Write-Host 'Lolcat: OFF' -ForegroundColor Yellow }
    " 2>/dev/null
end

# ── cow-animate: Change animation ──
function cow-animate
    set mode (test (count $argv) -gt 0; and echo $argv[1]; or echo static)
    pwsh -NoProfile -Command "
        Import-Module Forgum -ErrorAction SilentlyContinue;
        `$config = Get-CFConfig;
        `$config.animation.mode = '$mode';
        Set-CFConfig -Config `$config;
        Write-Host 'Animation: $mode' -ForegroundColor Cyan
    " 2>/dev/null
end

# ── cow-eyes: Set cow eyes ──
function cow-eyes
    set preset $argv[1]
    switch $preset
        case borg;     set eyes '=='
        case dead;     set eyes 'xx'
        case greedy;   set eyes '$$'
        case paranoia; set eyes '@@'
        case stoned;   set eyes '**'
        case tired;    set eyes '--'
        case wasted;   set eyes 'OO'
        case youthful; set eyes '..'
        case '*';      set eyes $preset
    end
    pwsh -NoProfile -Command "
        Import-Module Forgum -ErrorAction SilentlyContinue;
        `$config = Get-CFConfig;
        `$config.cow.eyes = '$eyes';
        Set-CFConfig -Config `$config;
        Write-Host 'Cow eyes: $eyes' -ForegroundColor Cyan
    " 2>/dev/null
end

# ── cow-mood: Set cow mood ──
function cow-mood
    set mode $argv[1]
    pwsh -NoProfile -Command "
        Import-Module Forgum -ErrorAction SilentlyContinue;
        `$config = Get-CFConfig;
        `$config.cow.mode = '$mode';
        Set-CFConfig -Config `$config;
        Write-Host 'Cow mood: $mode' -ForegroundColor Cyan
    " 2>/dev/null
end

# ── cow-list: List all cows ──
function cow-list
    if test (count $argv) -eq 0
        pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Get-CFCow | Format-Table -AutoSize" 2>/dev/null
    else
        pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Get-CFCow | Where-Object { `$_ -like '*$argv[1]*' } | Format-Table -AutoSize" 2>/dev/null
    end
end
```

---

## Configuration Reference

### Config File Location

| Platform | Path |
|:---------|:-----|
| Windows | `~/Documents/PowerShell/forgum/config.json` |
| Mac/Linux | `~/.config/forgum/config.json` |
| Custom | Set the `FORGUM_CONFIG` environment variable |

### Default Config (`config.json`)

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
  "startup": {
    "enabled": true,
    "command": "Invoke-Forgum"
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

### All Fields Explained

#### `animation`

| Field | Type | Default | Description |
|:------|:-----|:--------|:------------|
| `mode` | `string` | `"static"` | How the cow appears: `static`, `talking`, `typewriter` |
| `speed` | `number` | `20` | Animation speed (higher = faster) |
| `duration` | `number` | `12` | How long animation lasts (seconds) |
| `spread` | `number` | `3.0` | How spread out the animation is |

#### `cow`

| Field | Type | Default | Description |
|:------|:-----|:--------|:------------|
| `file` | `string` | `"default"` | Which cow to use (without `.cow` extension) |
| `random` | `boolean` | `false` | Pick a random cow each time |
| `mode` | `string\|null` | `null` | Cow mood/expression preset (see table below) |
| `eyes` | `string` | `"oo"` | Two custom eye characters |
| `tongue` | `string` | `"  "` | Two custom tongue characters |

**Cow Mood Presets:**

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

#### `fortune`

| Field | Type | Default | Description |
|:------|:-----|:--------|:------------|
| `database` | `string` | `"fortunes"` | Which fortune file to use |
| `offensive` | `boolean` | `false` | Include offensive fortunes |

#### `lolcat`

| Field | Type | Default | Description |
|:------|:-----|:--------|:------------|
| `enabled` | `boolean` | `false` | Turn rainbow on/off |
| `truecolor` | `boolean` | `true` | Use 24-bit color (true) or 256-color (false) |
| `frequency` | `number` | `0.1` | Rainbow tightness (higher = tighter rainbow) |
| `invert` | `boolean` | `false` | Swap rainbow colors |

#### `output`

| Field | Type | Default | Description |
|:------|:-----|:--------|:------------|
| `wordWrap` | `boolean` | `true` | Wrap long messages to fit terminal |
| `maxWidth` | `number` | `60` | Maximum width before wrapping |

#### `startup`

| Field | Type | Default | Description |
|:------|:-----|:--------|:------------|
| `enabled` | `boolean` | `true` | Show fortune cow on terminal startup |
| `command` | `string` | `"Invoke-Forgum"` | Command to run at startup |

#### `shell`

| Field | Type | Default | Description |
|:------|:-----|:--------|:------------|
| `integration` | `string` | `"auto"` | Shell integration: `auto`, `on`, `off` |
| `tmux.enabled` | `boolean` | `false` | Enable tmux integration |
| `tmux.pane` | `string` | `"status-right"` | tmux pane: `status-right` or `status-left` |

### Quick Config Commands

```powershell
# Read all config
Get-CFConfig | ConvertTo-Json -Depth 4

# Read a specific value
(Get-CFConfig).lolcat.enabled

# Set a value
$config = Get-CFConfig
$config.lolcat.enabled = $true
Set-CFConfig -Config $config

# Reset to defaults
Remove-Item ~/Documents/PowerShell/forgum/config.json  # Windows
Remove-Item ~/.config/forgum/config.json                # Mac/Linux
```

---

## Interactive vs. Non-Interactive Setup

### Interactive (setup.ps1)

The `setup.ps1` script provides a guided wizard:

```powershell
# Run the interactive setup
.\setup.ps1

# This will prompt you for:
# - Fortune on startup (Y/n)
# - Lolcat rainbow (Y/n)
# - Default cow file (selection list)
# - Animation mode (static/talking/typewriter)
# - Shell aliases (Y/n)
# - Tab completion (Y/n)
```

### Non-Interactive (Package Managers)

For automated installs:

```powershell
# Skips all prompts, uses defaults:
# fortune=yes, lolcat=yes, cow=default, animation=static, aliases=yes, completion=yes
.\setup.ps1 -NonInteractive -Force

# Don't modify PowerShell profile
.\setup.ps1 -NonInteractive -Force -NoProfile
```

### The FORGUM_STARTUP_DONE Guard

In PowerShell profiles, the `$global:FORGUM_STARTUP_DONE` variable prevents the cow from appearing multiple times (e.g., in nested shells or when dot-sourcing the profile):

```powershell
# This pattern ensures the cow only appears once per terminal session
if (-not $global:FORGUM_STARTUP_DONE) {
    $global:FORGUM_STARTUP_DONE = $true
    Invoke-Forgum
}
```

In Bash/Zsh/Fish, the `-t 1` test ensures Forgum only runs in interactive terminals (not in scripts or piped commands):

```bash
# Only show cow if stdout is a terminal
if [ -t 1 ]; then
    pwsh -NoProfile -Command "..." 2>/dev/null
fi
```

---

## Error Handling: When Forgum Is Not Installed

All integration patterns use `-ErrorAction SilentlyContinue` (PowerShell) or `2>/dev/null` (Bash) to gracefully handle the case where Forgum is not installed:

### PowerShell

```powershell
# Silently continues if module is not found
Import-Module Forgum -ErrorAction SilentlyContinue
```

### Bash/Zsh/Fish

```bash
# Suppresses stderr if pwsh or Forgum is missing
pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Invoke-Forgum" 2>/dev/null
```

### Check Before Running

```powershell
# PowerShell: check if Forgum is available before using it
if (Get-Command Invoke-Forgum -ErrorAction Ignore) {
    Invoke-Forgum
} else {
    Write-Host "Forgum not installed. Run install.ps1" -ForegroundColor Yellow
}
```

```bash
# Bash/Zsh: check if pwsh is available
if command -v pwsh &>/dev/null; then
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Invoke-Forgum" 2>/dev/null
else
    echo "PowerShell not installed. Install pwsh first."
fi
```

---

## Complete Profile Examples

### Minimal Profile (PowerShell)

```powershell
# 3 lines — that's all you need
Import-Module Forgum -ErrorAction SilentlyContinue
Invoke-Forgum
```

### Full-Featured Profile (PowerShell)

```powershell
# ============================================
# Forgum - Full Profile Setup
# ============================================

Import-Module Forgum -ErrorAction SilentlyContinue

# Startup fortune (once per session)
if (-not $global:FORGUM_STARTUP_DONE) {
    $global:FORGUM_STARTUP_DONE = $true
    Invoke-Forgum
}

# Aliases
function ff { Invoke-Forgum }
function fc { param([string]$Cow) Invoke-Forgum -CowFile $Cow }
function cow { param([string]$Text) Invoke-Cowsay -Text $Text }
function lolcat {
    $config = Get-CFConfig
    $config.lolcat.enabled = -not $config.lolcat.enabled
    Set-CFConfig -Config $config
    Write-Host "Lolcat: $(if ($config.lolcat.enabled) {'ON'} else {'OFF'})"
}
function cowconfig { Get-CFConfig | ConvertTo-Json -Depth 4 }
function cowpreview { param([string]$Cow='default',[string]$Text='Hello!') Invoke-Cowsay -Text $Text -CowFile $Cow }
function cowgallery { param([int]$Count=5) Get-CFCow | Get-Random -Count $Count | ForEach-Object { Invoke-Cowsay -Text (Get-Fortune) -CowFile $_ } }
function cow-animate { param([ValidateSet('static','talking','typewriter')]$Mode) $c = Get-CFConfig; $c.animation.mode = $Mode; Set-CFConfig -Config $c; Write-Host "Animation: $Mode" }

# Tab completion
Register-ArgumentCompleter -CommandName Invoke-Cowsay -ParameterName CowFile -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    Get-CFCow | Where-Object { $_ -like "*$wordToComplete*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
```

### Minimal Config (Bash)

```bash
# 5 lines — fortune on terminal open
if command -v pwsh &>/dev/null; then
    if [ -t 1 ]; then
        pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Invoke-Forgum" 2>/dev/null
    fi
fi
```

### Full-Featured Config (Bash)

```bash
# ============================================
# Forgum - Full Bash/Zsh Setup
# ============================================

# Startup
if command -v pwsh &>/dev/null; then
    if [ -t 1 ]; then
        pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Invoke-Forgum" 2>/dev/null
    fi
fi

# Aliases
alias ff='pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Invoke-Forgum"'
alias cowconfig='pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Get-CFConfig | ConvertTo-Json -Depth 4"'

fc() { pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Invoke-Forgum -CowFile '$1'" 2>/dev/null; }
cow() { pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Invoke-Cowsay -Text '$*'" 2>/dev/null; }
cowpreview() { pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Invoke-Cowsay -Text '${2:-Hello!}' -CowFile '${1:-default}'" 2>/dev/null; }
lolcat-toggle() { pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; `$c = Get-CFConfig; `$c.lolcat.enabled = -not `$c.lolcat.enabled; Set-CFConfig -Config `$c" 2>/dev/null; }
cow-animate() { pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; `$c = Get-CFConfig; `$c.animation.mode = '${1:-static}'; Set-CFConfig -Config `$c" 2>/dev/null; }
```

### Full-Featured Config (Fish)

```fish
# ============================================
# Forgum - Full Fish Setup
# ============================================

# Startup
function fish_greeting
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Invoke-Forgum" 2>/dev/null
end

# Aliases
function ff
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Invoke-Forgum" 2>/dev/null
end

function fc
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Invoke-Forgum -CowFile '$argv[1]'" 2>/dev/null
end

function cow
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Invoke-Cowsay -Text '$argv'" 2>/dev/null
end

function cowconfig
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Get-CFConfig | ConvertTo-Json -Depth 4" 2>/dev/null
end

function cowpreview
    set cow (test (count $argv) -gt 0; and echo $argv[1]; or echo default)
    set text (test (count $argv) -gt 1; and echo $argv[2]; or echo Hello!)
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Invoke-Cowsay -Text '$text' -CowFile '$cow'" 2>/dev/null
end

function lolcat-toggle
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; `$c = Get-CFConfig; `$c.lolcat.enabled = -not `$c.lolcat.enabled; Set-CFConfig -Config `$c" 2>/dev/null
end

function cow-animate
    set mode (test (count $argv) -gt 0; and echo $argv[1]; or echo static)
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; `$c = Get-CFConfig; `$c.animation.mode = '$mode'; Set-CFConfig -Config `$c" 2>/dev/null
end
```
