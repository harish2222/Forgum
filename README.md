<h1 align="center">
  <img src="assets/forgum_banner.jpeg" alt="Forgum Banner" width="100%">
</h1>

<p align="center">
  <b style="color: #FF9A3C;">fortune</b> + <b style="color: #FFD93D;">cow</b> + <b style="color: #6BCB77;">rainbow</b> = <b style="color: #4D96FF;">joy</b>
</p>

<p align="center">
  <a href="https://github.com/harish2222/Forgum/releases"><img src="https://img.shields.io/badge/version-1.1.1-blue?style=for-the-badge" alt="Version"></a>
  <a href="https://github.com/harish2222/Forgum"><img src="https://img.shields.io/badge/powershell-5.1+-blueviolet?style=for-the-badge&logo=powershell&logoColor=white" alt="PowerShell"></a>
  <a href="https://github.com/harish2222/Forgum/blob/main/LICENSE"><img src="https://img.shields.io/badge/license-MIT-green?style=for-the-badge" alt="License"></a>
  <a href="https://github.com/harish2222/Forgum/actions"><img src="https://img.shields.io/badge/tests-102%20passing-brightgreen?style=for-the-badge" alt="Tests"></a>
  <a href="#-meet-the-cows"><img src="https://img.shields.io/badge/cows-106-orange?style=for-the-badge" alt="Cows"></a>
  <a href="#-rainbow"><img src="https://img.shields.io/badge/rainbow-lolcat-pink?style=for-the-badge" alt="Lolcat"></a>
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

## ⚡ Performance

Forgum is engineered for speed. It features a sophisticated script-scoped caching system and optimized string builders to ensure your terminal stays snappy.

- **Load Time**: < 100ms (PowerShell 7.4) / < 300ms (PowerShell 5.1)
- **Execution**: Sub-millisecond text processing.
- **Regression Gate**: Every commit is benchmarked. If performance drops by even 5%, the build fails. *Unbreakable speed standards.*

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
Invoke-Forgum -Lolcat

# See the full 106-cow gallery (random sample)
cowgallery -Count 3
```

---

## 🐄 Meet the Cows

Forgum comes packed with **106 unique characters**. Whether you want a friendly kitty, a wise dragon, or a tuxedo-wearing penguin, we've got you covered.

**Some of our favorites:**
- 🐉 **Dragon**: For when you feel legendary.
- 🐧 **Tux**: The classic Linux mascot.
- 🐱 **Kitty**: Cute, cuddly, and judgmental.
- 🐋 **Whale**: For big ideas.
- 👻 **Ghost**: Spooky terminal vibes.
- 🦖 **Stegosaurus**: A blast from the past.

*Run `Get-CFCow` to see the full list of names!*

---

## ✨ Features

- **106 ASCII Cows**: A massive library of characters.
- **Truecolor Rainbow**: 24-bit color support for stunning visuals.
- **19 Animation Modes**: From legacy "bounce" to flagship Rust-powered "aurora", "plasma", and "neon-pulse" with React-inspired mathematical blending.
- **Lightning Fast Engine**: A differential ANSI framebuffer renderer built in Rust, integrated seamlessly via PowerShell.
- **Cross-Shell Support**: Works in PowerShell, Bash, Zsh, Fish, and tmux.
- **Highly Configurable**: Control everything from word-wrap to eye style.

---

## 📖 Documentation

- **[User Guide](wiki/User-Guide.md)**: New to the command line? Start here for a fun, jargon-free guide!
- **[Installation Guide](wiki/Installation.md)**: Detailed steps for every platform.
- **[Configuration](wiki/Configuration.md)**: How to tweak every setting.
- **[API Reference](#-api-reference)**: For developers and scripters.

---

## 🛠 API Reference

```powershell
Invoke-Cowsay -Text "Hello" [-CowFile <name>] [-Eyes <chars>] [-Tongue <chars>] [-Thoughts <char>]
```

| Parameter | Default | Description |
|:----------|:--------|:------------|
| `Text` | `''` | Message to display |
| `CowFile` | `'default'` | Cow file name (without `.cow`) |
| `Eyes` | `'oo'` | Two-character eye string |
| `Tongue` | `'  '` | Two-character tongue string |
| `Thoughts` | `'\'` | Thought bubble character |

### `Invoke-Forgum`

```powershell
Invoke-Forgum [-Think] [-CowFile <name>] [-Eyes <chars>] [-Tongue <chars>]
```

### `Get-Fortune`

```powershell
Get-Fortune [-Database <name>]
```

### `Get-CFCow`

```powershell
Get-CFCow [-Name <cowname>]
```

### `Set-Forgum`

```powershell
Set-Forgum [-Animation <mode>] [-Cow <name>] [-Eyes <chars>] [-Lolcat <bool>] [-RandomCow <bool>] [-RainbowFrequency <double>]
```

### `Get-CFConfig` / `Set-CFConfig`

```powershell
# Get config object
$config = Get-CFConfig

# Set complete config object
Set-CFConfig -Config $config
```

### `Show-CFAnimation`

```powershell
Show-CFAnimation -CowOutput <string> [-Message <string>]
```

* `Show-CFAnimation`: Takes a `CowOutput` (string block) and animates it with `-Effect` or default physics. Supports `-Background` to run animations without stealing focus or blocking the terminal prompt.
* `Invoke-Engine`: Low-level wrapper around the Rust `forgum-engine` executable. Plumbs JSON payloads over `stdin` and handles the raw async/sync execution logic.

**Available Flagship Modes:** `aurora`, `plasma`, `ember`, `liquid-chrome`, `shatter`, `portal`, `glitch`, `neon-pulse`
**Available Legacy Modes:** `static`, `talking`, `typewriter`, `dynamic`, `procedural`, `physics` (and variants)

---

## ⚙️ Configuration

### Configuration
You can customize Forgum by editing its configuration file. Run `Get-CFConfig` to see your current settings and file path.

```json
{
  "animation": { "mode": "random", "background": true, "speed": 20, "duration": 12, "spread": 3.0, "blinkRate": 0.2, "amplitude": 2 },
  "cow": { "file": "default", "random": false, "mode": null, "eyes": "oo", "tongue": "  " },
  "fortune": { "database": "fortunes", "offensive": false },
  "lolcat": { "enabled": false, "truecolor": true, "frequency": 0.1 },
  "output": { "wordWrap": true, "maxWidth": 60, "noWrap": false },
  "startup": { "enabled": true, "command": "Invoke-Forgum" },
  "shell": { "integration": "auto" }
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

### Animation Modes

| Mode | Description |
|:-----|:------------|
| `static` | Instant display (default, recommended for startup) |
| `talking` | Simulates mouth movement |
| `typewriter` | Types character by character |
| `slide-in` | Cow slides in from the left, column by column |
| `bounce` | Cow drops in with realistic bounce physics |
| `dissolve` | Cow materializes character by character randomly |
| `fade-in` | Cow fades in line by line with brightness |
| `blink` | Cow eyes blink periodically |
| `wiggle` | Cow wiggles left and right playfully |
| `wave` | Fortune text appears word by word with rainbow |
| `disco` | Cow cycles through rainbow colors (party mode) |
| `physics` | Procedural personality-driven animations (Breathe, Float, Glitch, etc.) based on the Cow Animation Manifesto |

> **Note:** Non-`static` animation modes are for interactive use only. The module automatically forces `static` mode during startup to prevent terminal hangs.
>
> **Dispatch:** `dynamic`, `talking`, and `typewriter` are rendered by PowerShell animation functions in `Private/Animation/`. The Rust binary (`forgum-core.exe`) handles `static`, `slide`, `bounce`, `wave`, `wiggle`, `fade-in`, `dissolve`, and `disco`.

---

## Shell Integration

### Bash / Zsh / Fish

```bash
# Add to ~/.bashrc or ~/.zshrc
fortune | cowsay -f $( cowsay -l | shuf -n1 )

# Or use PowerShell module from bash
pwsh -Command "Import-Module Forgum; Invoke-Forgum"
```

### tmux Status Bar

```bash
# Add to ~/.tmux.conf
set -g status-right "#(pwsh -Command 'Import-Module Forgum; Get-Fortune' 2>/dev/null)"
set -g status-interval 300
```

### PowerShell Profile

```powershell
# Add to $PROFILE
Import-Module Forgum
Invoke-Forgum  # Show fortune on shell start
```

---

## Customization

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
  Invoke-Cowsay -Text $Text -CowFile $Cow
}

# Random cow gallery
function cowgallery {
  param([int]$Count = 5)
  Get-CFCow | Get-Random -Count $Count | ForEach-Object {
    Invoke-Cowsay -Text (Get-Fortune) -CowFile $_.Name
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
  param([ValidateSet('static','talking','typewriter')]$Mode)
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

## Known Issues

### PowerShell startup hangs for 30+ seconds

**Fixed in v1.1.1.** If you are still experiencing this issue, update to the latest version.

If PowerShell appears to hang on startup after adding `Import-Module Forgum` (or any `Invoke-Forgum*` command) to your profile, the cause is almost always an animation loop:

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

---

## Requirements

- **PowerShell 5.1+** (Windows) or **PowerShell 7+** (cross-platform)
- **No external dependencies**

---

## Uninstall

```powershell
.\uninstall.ps1
```

Or manually:
1. Module: `~/Documents/PowerShell/Modules/Forgum/`
2. Config: `~/Documents/PowerShell/Forgum/`
3. Profile entry in `$PROFILE`

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

---

## License

MIT License — see [LICENSE](LICENSE) for details.

---

## Credits

| Project | Description |
|:--------|:------------|
| [piuccio/cowsay](https://github.com/piuccio/cowsay) | Original cow files |
| [fortune-mod](https://github.com/shlomif/fortune-mod) | Fortune database |
| [lolcat](https://github.com/busyloop/lolcat) | Rainbow colorization algorithm |

---

<p align="center">
  Made with ❤️ and a cow
</p>
