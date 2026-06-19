# Forgum Wiki

**Welcome to Forgum!** This wiki will teach you everything you need to know to use Forgum, from simple installation to advanced customization.

## What is Forgum?

Forgum is a fun PowerShell tool that shows your terminal a cow saying a random quote (fortune) with optional rainbow colors. Think of it as a little friend that lives in your terminal and greets you with wisdom every time you open it.

## Quick Links

| Guide | Description |
|:------|:------------|
| [Getting Started](Getting-Started) | Install and run in 2 minutes |
| [PowerShell Integration](PowerShell-Integration) | Make Forgum part of your PowerShell profile |
| [Bash & Zsh Integration](Bash-Zsh-Integration) | Use Forgum from Bash or Zsh shells |
| [Fish Integration](Fish-Integration) | Use Forgum from Fish shell |
| [tmux Integration](tmux-Integration) | Show fortunes in your tmux status bar |
| [Configuration](Configuration) | Change how Forgum looks and behaves |
| [Custom Cows](Custom-Cows) | Create your own cow drawings |
| [Custom Fortunes](Custom-Fortunes) | Add your own quotes |
| [Sample Configs](PowerShell-Integration#sample-configurations-copy-paste-ready) | Ready-to-use startup configs for all shells |
| [Troubleshooting](Troubleshooting) | Fix common problems |

## What You Can Do

```powershell
# Show a cow with a random fortune
forgum

# Show your own message
forgum -Text "Hello World!"

# Get just a fortune (no cow)
Get-Fortune

# See all 107 cow characters
Get-CFCow

# Enable rainbow colors
Set-CFConfig -Config @{ lolcat = @{ enabled = $true } }
forgum
```

## Requirements

- **Windows**: PowerShell 5.1 or newer (comes pre-installed)
- **Mac/Linux**: PowerShell 7 or newer
- **No other software needed** — Forgum is pure PowerShell

---

**Next:** [Getting Started →](Getting-Started)
