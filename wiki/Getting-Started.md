# Getting Started

This guide will help you install Forgum and see your first cow in under 2 minutes.

## Step 1: Install Forgum

### Option A: One-Click Install (Recommended)

Copy and paste this into your terminal:

**PowerShell (Windows/Mac/Linux):**
```powershell
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/harish2222/Forgum/main/install.ps1'))
```

**Bash/Zsh (Mac/Linux):**
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/harish2222/Forgum/main/install.sh)
```

### Option B: Manual Install

If you prefer to do it yourself:

```powershell
# 1. Download the code
git clone https://github.com/harish2222/Forgum.git

# 2. Import it
Import-Module ./Forgum/Forgum.psd1
```

## Step 2: See Your First Cow!

Type this and press Enter:

```powershell
Invoke-Forgum
```

You should see something like this:

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

**Congratulations!** You just used Forgum!

## Step 3: Try Different Things

```powershell
# Your own message
Invoke-Cowsay -Text "I love Forgum!"

# A different cow
Invoke-Cowsay -Text "Tux says hi!" -CowFile 'tux'

# A thinking cow
Invoke-Forgum -Think

# Just a fortune (no cow)
Get-Fortune
```

## What Just Happened?

1. **Install** — Forgum was downloaded and set up on your computer
2. **Import** — PowerShell loaded Forgum so you can use its commands
3. **Run** — You told Forgum to show a cow with a fortune

## Quick Config for Your Shell

Pick your shell below to see a quick startup config.

### PowerShell

Add to your PowerShell profile (`$PROFILE`):

```powershell
Import-Module Forgum -ErrorAction SilentlyContinue
Invoke-Forgum
```

### Bash / Zsh

Add to your `~/.bashrc` or `~/.zshrc`:

```bash
forgum() {
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Invoke-Forgum"
}
forgum
```

### Fish

Add to your `~/.config/fish/config.fish`:

```fish
function forgum
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Invoke-Forgum"
end
forgum
```

## What's New in v1.1.0

- **Profile Customization Functions**: `cowconfig`, `cowpreview`, `cowgallery`, `lolcat-toggle`, `cow-animate`, `cow-eyes`
- **Customization Guides**: Custom cow creation, animation extension, shell wrapper examples
- **VS Code & Tab Completion**: New integration recipes in the README

See [Sample-Configs](Sample-Configs) for ready-to-use configuration examples across all platforms.

## Next Steps

- [PowerShell Integration](PowerShell-Integration) — Make Forgum start automatically
- [Configuration](Configuration) — Change how it looks
- [Custom Cows](Custom-Cows) — Draw your own cows
- [Sample-Configs](Sample-Configs) — Ready-to-use shell configurations

---

**Back:** [Home](Home) | **Next:** [PowerShell Integration →](PowerShell-Integration)
