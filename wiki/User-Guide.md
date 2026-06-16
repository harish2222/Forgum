# 🐄 User Guide

Welcome to **Forgum**, the cross-platform terminal experience for PowerShell. This guide provides an overview of how to use and customize your Forgum installation to enhance your terminal environment.

---

## 🌟 Core Concepts

Forgum integrates three classic terminal utilities into a cohesive, highly-performant module:
1. **ASCII Art Engine**: A modern implementation of `cowsay` with 107 characters.
2. **Fortune Database**: A curated collection of quotes, wisdom, and humorous observations.
3. **Lolcat Rendering**: 24-bit truecolor rainbow colorization for any terminal output.
4. **Animation Engine**: High-framerate terminal animations including bounce, dissolve, and fade effects.

---

## 🚀 Quick Start

Once installed, the primary way to interact with Forgum is through the `Invoke-Forgum` command.

```powershell
# Display a random fortune with a random character in rainbow colors
Invoke-Forgum -Lolcat
```

---

## 🎨 Primary Commands

### 1. Generating ASCII Art
Use `Invoke-Cowsay` for direct message generation with specific characters.

```powershell
# Display a custom message using the 'dragon' character
Invoke-Cowsay -Text "System systems operational." -CowFile dragon

# Use the 'kitty' character
Invoke-Cowsay -Text "Observation recorded." -CowFile kitty
```

### 2. Configuration Management
The `Set-Forgum` command is the recommended way to persistently update your preferences.

```powershell
# Persistently set the default character and animation mode
Set-Forgum -Cow dragon -Animation bounce

# Enable global rainbow colorization and set custom eyes
Set-Forgum -Lolcat $true -Eyes "@@"
```

### 3. Character Gallery
Explore the full library of 107 characters:

```powershell
# List all character names
Get-CFCow

# View a random sample of characters
cowgallery -Count 3
```

---

## 🛠 Advanced Customization

### Character Moods
Modify the visual state of your character using eye presets:

```powershell
# Stoned mood
Invoke-Cowsay -Text "Processing..." -Eyes **

# Dead mood
Invoke-Cowsay -Text "Critical Error." -Eyes xx

# Paranoia mood
Invoke-Cowsay -Text "Unauthorized access detected." -Eyes @@
```

### Rainbow Colorization (Lolcat)
Toggle global colorization or adjust the frequency:

```powershell
# Toggle global lolcat state
lolcat-toggle

# Adjust color frequency via configuration
Set-Forgum -RainbowFrequency 0.05
```

---

## ❓ Frequently Asked Questions

**"How do I see all available characters?"**
Execute `Get-CFCow` to retrieve the complete inventory of character templates.

**"How do I enable startup greetings?"**
Startup behavior is managed during initial installation or via `Invoke-ForgumSetup`. To enable it manually, ensure `Import-Module Forgum` is present in your `$PROFILE`.

**"Is this compatible with non-PowerShell environments?"**
Yes. Forgum provides integration samples for Bash, Zsh, Fish, and tmux. Refer to the [Sample Configs](Sample-Configs.md) documentation for details.

---

## ❤️ Conclusion

Forgum is designed to be a lightweight, secure, and performant addition to your terminal workflow. For detailed technical specifications, refer to the [API Reference](../docs/API-Reference.md).
