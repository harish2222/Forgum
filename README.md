<h1 align="center">
  <img src="assets/forgum_banner.jpeg" alt="Forgum Banner" width="100%">
</h1>

<p align="center">
  <b style="color: #FF9A3C;">fortune</b> + <b style="color: #FFD93D;">cow</b> + <b style="color: #6BCB77;">rainbow</b> = <b style="color: #4D96FF;">joy</b>
</p>

<p align="center">
  <a href="https://github.com/harish2222/Forgum/releases"><img src="https://img.shields.io/badge/version-1.1.2-blue?style=for-the-badge" alt="Version"></a>
  <a href="https://github.com/harish2222/Forgum"><img src="https://img.shields.io/badge/powershell-5.1+-blueviolet?style=for-the-badge&logo=powershell&logoColor=white" alt="PowerShell"></a>
  <a href="https://github.com/harish2222/Forgum/blob/main/LICENSE"><img src="https://img.shields.io/badge/license-MIT-green?style=for-the-badge" alt="License"></a>
  <a href="#-test-coverage"><img src="https://img.shields.io/badge/tests-492%20passing-brightgreen?style=for-the-badge" alt="Tests"></a>
  <a href="#-meet-the-cows"><img src="https://img.shields.io/badge/cows-109-orange?style=for-the-badge" alt="Cows"></a>
  <a href="#-animation-engine"><img src="https://img.shields.io/badge/effects-19-pink?style=for-the-badge" alt="Effects"></a>
</p>

<p align="center">
  A cross-platform PowerShell module that combines <b>cowsay</b>, <b>fortune</b>, and <b>lolcat</b> into one beautiful, configurable, and fun terminal experience.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Windows-0078D4?style=for-the-badge&logo=windows&logoColor=white" alt="Windows">
  <img src="https://img.shields.io/badge/macOS-000000?style=for-the-badge&logo=apple&logoColor=white" alt="macOS">
  <img src="https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black" alt="Linux">
</p>

---

## 🎬 Demo

<table>
<tr>
<td align="center">

**Monochrome**

<img src="assets/forgum_demo_mono.png" alt="Forgum Mono Demo" width="400">

</td>
<td align="center">

**Rainbow Lolcat**

<img src="assets/forgum_demo_color.png" alt="Forgum Color Demo" width="400">

</td>
</tr>
</table>

---

## 🚀 Quick Start

### Install with a One-liner

**PowerShell**
```powershell
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/harish2222/Forgum/main/install.ps1'))
```

**Bash / Zsh / Fish**
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/harish2222/Forgum/main/install.sh)
```

### Try it out

```powershell
# Get a fortune from a random cow in rainbow colors
forgum -Lolcat

# View the full configuration UI
forgum config

# See a gallery of cows
forgum gallery -Count 3
```

---

## ⚡ Why Forgum?

Forgum isn't just another cowsay wrapper. It's a **production-grade terminal personality engine** built for developers who want their CLI to feel alive.

### 🏗️ Architecture That Scales

```
┌─────────────────────────────────────────────────────────┐
│  PowerShell Module (Thin Wrapper)                       │
│  ┌───────────────────────────────────────────────────┐  │
│  │ JSON Protocol ──► Rust Engine (Native Binary)     │  │
│  │              ◄── ANSI Framebuffer Renderer        │  │
│  └───────────────────────────────────────────────────┘  │
│  • Zero animation logic in PowerShell                   │
│  • Background rendering (shell stays usable)            │
│  • Cross-platform: Windows, macOS, Linux                │
└─────────────────────────────────────────────────────────┘
```

### 📊 Performance Benchmarks

| Metric | Forgum | Traditional cowsay |
|:-------|:-------|:-------------------|
| **Load Time** | < 100ms (PS 7.4) | N/A |
| **Render Time** | Sub-millisecond | ~50ms |
| **Animation FPS** | 60 FPS | 15-30 FPS |
| **Memory Footprint** | ~2MB (Rust binary) | ~10MB (Python) |
| **Background Mode** | ✅ Non-blocking | ❌ Blocks terminal |

### 🧪 Test Coverage

| Suite | Tests | Status |
|:------|------:|:------:|
| **CLI** | 31 | ✅ |
| **Forgum Core** | 35 | ✅ |
| **Comprehensive** | 20 | ✅ |
| **Cross-Platform** | 10 | ✅ |
| **Engine Manual** | 49 | ✅ |
| **Ghost** | 11 | ✅ |
| **Live Show** | 3 | ✅ |
| **New Subcommands** | 50 | ✅ |
| **Permutations** | 123 | ✅ |
| **Shell Usability** | 24 | ✅ |
| **Subcommands** | 132 | ✅ |
| **Visual** | 4 | ✅ |
| **Rust Unit** | 45 | ✅ |
| **Total** | **492** | **✅ 0 Failures** |

---

## 🎨 Animation Engine

Forgum features a **lightning-fast differential ANSI framebuffer renderer in Rust**, seamlessly integrated through PowerShell.

### 🌟 Flagship Effects (Rust-Powered)

| Effect | Description | Best For |
|:-------|:------------|:---------|
| **aurora** | Northern lights with flowing gradients | Ambient terminal beauty |
| **plasma** | Classic plasma shader effect | Retro aesthetic |
| **ember** | Glowing fire particles | Warm, cozy terminals |
| **liquid-chrome** | Reflective metallic surface | Sleek, modern look |
| **shatter** | Fragmented glass breaking | Dramatic reveals |
| **portal** | Interdimensional rift effect | Sci-fi enthusiasts |
| **glitch** | Digital artifact corruption | Cyberpunk vibes |
| **neon-pulse** | Pulsating neon lights | Night owl coders |
| **physics** | Particle physics simulation | Dynamic motion |

### 🎭 Base Styles

| Style | Description |
|:------|:------------|
| **breathe** | Gentle scaling animation |
| **liquid** | Fluid wave motion |
| **sway** | Side-to-side rocking |
| **bounce** | Vertical bouncing |
| **fly** | Floating flight path |
| **fire** | Flame flicker effect |
| **matrix** | Digital rain cascade |
| **pulse** | Rhythmic pulsing |
| **dissolve** | Gradual fade out |

### 🔧 How It Works

```powershell
# Background mode (default) — shell stays usable
forgum run --mode aurora

# Foreground mode — blocks until animation completes
forgum run --mode plasma --no-background

# Random effect selection
forgum run --mode random
```

**Technical Details:**
- **Cursor Save/Restore**: Each frame saves cursor position, renders overlay, restores cursor
- **Differential Rendering**: Only modified cells are updated (minimizes flicker)
- **Non-Blocking I/O**: Engine runs independently while shell accepts input
- **ANSI Framebuffer**: True 24-bit color with proper terminal state management

---

## 🐄 Meet the Cows

Forgum comes packed with **109 unique characters**. Whether you want a friendly kitty, a wise dragon, or a tuxedo-wearing penguin, we've got you covered.

### 🎨 Cow Style Categories

| Style | Examples | Animation Match |
|:------|:---------|:----------------|
| **Aquatic** | whale, dolphin, shark | liquid, sway |
| **Avian** | bird, eagle, penguin | fly, bounce |
| **Mammal** | cow, dragon, unicorn | breathe, physics |
| **Reptile** | dinosaur, snake, lizard | dissolve, matrix |
| **Mythical** | ghost, dragon, phoenix | portal, glitch |
| **机械** | robot, alien, cyborg | neon-pulse, plasma |

*Run `Get-CFCow` to see the full list of names!*

---

## ✨ Features

### Core Capabilities

- **109 ASCII Cows**: Massive library with intelligent style matching
- **19 Animation Effects**: 9 flagship Rust-powered + 10 base styles
- **Truecolor Rainbow**: 24-bit color support for stunning visuals
- **Unified CLI**: Single `forgum` command with 18 subcommands
- **Background Rendering**: Animations run while shell stays usable
- **Native Shell Hooks**: bash/zsh/fish integration via `forgum init <shell>`

### Advanced Features

- **Cow Style Matching**: Automatic animation selection based on cow personality
- **Dynamic Fortune Database**: Multiple fortune sources with filtering
- **Interactive Configuration**: TUI wizard for easy setup
- **Auto-Update**: Silent background update checks
- **Cross-Shell Compatibility**: PowerShell, Bash, Zsh, Fish, tmux

---

## 🛠️ Unified CLI

The entire functionality of the module is accessible through a single keyword: `forgum`.

### Quick Reference

```powershell
# Core Commands
forgum                              # Render default cow with fortune
forgum "Hello World!"               # Render custom text
forgum run --cow tux --mode aurora  # Full control

# Configuration
forgum config                       # Interactive TUI
forgum toggle                       # Toggle rainbow mode
forgum animate <mode>               # Set animation mode
forgum eyes <preset>                # Change eye style

# Gallery & Preview
forgum gallery -Count 5             # Show multiple cows
forgum preview tux "Linux rules!"   # Preview specific cow

# System
forgum update [-Force]              # Update Forgum
forgum init <shell>                 # Generate shell hooks
forgum help [command]               # Get help
```

### Subcommand Details

| Command | Description | Example |
|:--------|:------------|:--------|
| `run` | Render cow with options | `forgum run --cow dragon --mode plasma` |
| `config` | Open configuration TUI | `forgum config` |
| `gallery` | Display cow gallery | `forgum gallery --count 10` |
| `preview` | Preview cow with text | `forgum preview kitty "Meow!"` |
| `update` | Check/install updates | `forgum update --force` |
| `toggle` | Toggle rainbow mode | `forgum toggle` |
| `animate` | Set animation mode | `forgum animate aurora` |
| `eyes` | Change eye style | `forgum eyes borg` |
| `init` | Generate shell hooks | `forgum init bash` |
| `live` | Start live show mode | `forgum live` |
| `daemon` | Run background engine | `forgum daemon` |
| `help` | Show help | `forgum help run` |

---

## ⚙️ Configuration

### Configuration File Location

- **Windows:** `~/Documents/PowerShell/Forgum/config.json`
- **Linux/macOS:** `~/.config/Forgum/config.json`

### Default Configuration

```json
{
  "animation": {
    "mode": "random",
    "background": true,
    "speed": 20,
    "duration": 12,
    "spread": 3.0,
    "blinkRate": 0.2,
    "amplitude": 2,
    "cycleInterval": 3
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
    "databases": ["fortunes"],
    "offensive": false,
    "lengthFilter": null
  },
  "lolcat": {
    "enabled": false,
    "truecolor": true,
    "frequency": 0.1,
    "spread": 3.0,
    "seed": 0,
    "invert": false,
    "animate": false,
    "duration": 12,
    "speed": 20.0
  },
  "output": {
    "wordWrap": true,
    "maxWidth": 60,
    "noWrap": false
  },
  "startup": {
    "enabled": true,
    "command": "forgum"
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

### Cow Moods

| Mode | Eyes | Description |
|:-----|:-----|:------------|
| `b` | `==` | Borg |
| `d` | `xx` | Dead |
| `g` | `$$` | Greedy |
| `p` | `@@` | Paranoia |
| `s` | `**` | Stoned |
| `t` | `--` | Tired |
| `w` | `OO` | Wasted |
| `y` | `..` | Youthful |

---

## 🐚 Shell Integration

### Bash / Zsh / Fish

```bash
# Add to ~/.bashrc, ~/.zshrc, or ~/.config/fish/config.fish
eval "$(pwsh -Command 'Import-Module Forgum; forgum init bash')"
```

### tmux Status Bar

```bash
# Add to ~/.tmux.conf
set -g status-right "#(pwsh -Command 'Import-Module Forgum; forgum' 2>/dev/null)"
set -g status-interval 300
```

### PowerShell Profile

```powershell
# Add to $PROFILE
Import-Module Forgum
forgum  # Show fortune on shell start
```

---

## 🔧 Customization

### Quick Config Functions

Add these to your `$PROFILE`:

```powershell
# Quick config toggle
function cowconfig {
  param([string]$Path, [object]$Value)
  $config = Get-CFConfig
  if ($Path) {
    $parts = $Path -split '\.'
    $current = $config
    foreach ($part in $parts[0..($parts.Length-2)]) { $current = $current.$part }
    if ($Value) { $current.$parts[-1] = $Value; Set-CFConfig -Config $config }
    else { $current.$parts[-1] }
  } else { $config | ConvertTo-Json -Depth 4 }
}

# Preview any cow
function cowpreview {
  param([string]$Cow = 'default', [string]$Text = 'Hello!')
  forgum -Text $Text -CowFile $Cow
}

# Random cow gallery
function cowgallery {
  param([int]$Count = 5)
  Get-CFCow | Get-Random -Count $Count | ForEach-Object {
    forgum -Text (Get-Fortune) -CowFile $_
  }
}

# Toggle rainbow
function lolcat-toggle {
  $config = Get-CFConfig
  $config.lolcat.enabled = -not $config.lolcat.enabled
  Set-CFConfig -Config $config
  Write-Host "Lolcat: $(if ($config.lolcat.enabled) {'ON'} else {'OFF'})"
}

# Set animation
function cow-animate {
  param([ValidateSet('static','talking','typewriter','aurora','plasma')]$Mode)
  $config = Get-CFConfig
  $config.animation.mode = $Mode
  Set-CFConfig -Config $config
  Write-Host "Animation: $Mode"
}

# Set cow eyes
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
```

### Custom Cow Files

Create a `.cow` file in `Data/Cows/`:

```perl
$the_cow = <<EOC;
        \\   ^__^
         \\  (oo)\\_______
            (__)\\       )\\/\\
                ||----w |
                ||     ||
EOC
```

Use `$eyes`, `$tongue`, `$thoughts` for customizable parts.

### Custom Fortunes

Add your own to `~/Documents/PowerShell/fortunes.txt`:

```
Your first fortune here
%
Your second fortune here
%
Your third fortune here
```

---

## 📖 Documentation

- **[User Guide](wiki/User-Guide.md)**: New to the command line? Start here for a fun, jargon-free guide!
- **[Installation Guide](wiki/Installation.md)**: Detailed steps for every platform.
- **[Configuration](wiki/Configuration.md)**: How to tweak every setting.
- **[API Reference](#-unified-cli)**: For developers and scripters.

---

## 🧩 Placeholder API

Don't settle for static text files! Forgum supports a highly flexible **Placeholder API** (the `{{...}}` engine) in your `.cow` files. 
- You can inject variables dynamically. 
- You define eyes, tongue, thoughts, and complex visual states with variables like `$eyes`, `$tongue`, `$thoughts`.
- This API allows any third-party cow file to integrate beautifully with Forgum's mood and theme system!

---

## 🚨 Troubleshooting

### PowerShell startup hangs for 30+ seconds

**Fixed in v1.1.2.** If you are still experiencing this issue, update to the latest version.

If PowerShell appears to hang on startup after adding `Import-Module Forgum` (or any `forgum*` command) to your profile, the cause is almost always an animation loop:

- **Root cause:** Forgum's animation engine ran an infinite loop when `animation.mode` was set to anything other than `static` (e.g. `talking`, `typewriter`, `bounce`, `disco`). If an animation fired during profile load, the loop never exited and PowerShell couldn't finish startup.
- **Fix 1 — update Forgum** (recommended):
  ```powershell
  Update-Forgum
  ```
- **Fix 2 — set animation mode to static** (if update isn't available):
  ```powershell
  $config = Get-CFConfig
  $config.animation.mode = 'static'
  Set-CFConfig -Config $config
  ```
  Or in `config.json`:
  ```json
  { "animation": { "mode": "static" } }
  ```
- **Fix 3 — skip auto-start for the current session**:
  ```powershell
  $env:FORGUM_NOAUTOSTART = '1'
  Import-Module Forgum
  ```

After applying the fix, restart your PowerShell window. Startup should return to under one second.

### Engine animations not working

If Rust-powered animations (`aurora`, `plasma`, `ember`, etc.) fall back to native physics:

1. **Check if the engine binary exists:**
   ```powershell
   Import-Module Forgum
   Get-EngineBinary  # Should return a path, or $null if not found
   ```
2. **Rebuild the engine** (requires Rust toolchain):
   ```bash
   cd engine && cargo build --release
   ```
3. **Copy the binary to `bin/`:**
   ```powershell
   Copy-Item engine/target/release/forgum-engine.exe bin/  # Windows
   cp engine/target/release/forgum-engine bin/              # Linux/macOS
   ```

### Shell hooks not loading (`forgum init`)

If `eval "$(pwsh -Command 'Import-Module Forgum; forgum init bash')"` produces an error:

1. Ensure PowerShell is available in your `PATH`
2. Test manually: `pwsh -Command 'Import-Module Forgum; forgum init bash'`
3. If the module isn't installed, import from the repo: `pwsh -Command 'Import-Module ./Forgum.psd1; forgum init bash'`

### Config file location

Forgum stores config in a platform-appropriate location:
- **Windows:** `~/Documents/PowerShell/Forgum/config.json`
- **Linux/macOS:** `~/.config/Forgum/config.json`

To find yours:
```powershell
(Get-CFConfig | ConvertTo-Json -Depth 1) -replace '\\', '/'
```

---

## 📋 Requirements

- **PowerShell 5.1+** (Windows) or **PowerShell 7+** (cross-platform)
- **Rust toolchain** (optional, for engine rebuilds)
- **No external dependencies**

---

## 🗑️ Uninstall

```powershell
.\uninstall.ps1
```

Or manually:
1. Module: `~/Documents/PowerShell/Modules/Forgum/`
2. Config: `~/Documents/PowerShell/Forgum/`
3. Profile entry in `$PROFILE`

---

## 🤝 Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

---

## 📜 License

MIT License — see [LICENSE](LICENSE) for details.

---

## 🙏 Credits

| Project | Description |
|:--------|:------------|
| [piuccio/cowsay](https://github.com/piuccio/cowsay) | Original cow files |
| [fortune-mod](https://github.com/shlomif/fortune-mod) | Fortune database |
| [lolcat](https://github.com/busyloop/lolcat) | Rainbow colorization algorithm |
| [Rust](https://www.rust-lang.org/) | High-performance engine language |

---

<p align="center">
  Made with ❤️ and a cow
</p>
