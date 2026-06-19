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

Once installed, the primary way to interact with Forgum is through the `forgum` command.

```powershell
# Display a random fortune with a random character in rainbow colors
forgum -Lolcat

# Open the interactive configuration menu
forgum config
```

---

## 🎨 Primary Commands

### 1. Generating ASCII Art
Use `forgum` directly for message generation with specific characters.

```powershell
# Display a custom message using the 'dragon' character
forgum "System systems operational." -Cow dragon

# Use the 'kitty' character
forgum "Observation recorded." -Cow kitty
```

### 2. Configuration Management
The `forgum config` command is the recommended way to persistently update your preferences visually. For quick toggles from the terminal:

```powershell
# Change the default character animation mode
forgum animate bounce

# Set custom eyes globally
forgum eyes "@@"

# Toggle global rainbow colorization
forgum toggle
```

### 3. Character Gallery
Explore the full library of 107 characters:

```powershell
# View a random sample of characters
forgum gallery -Count 3

# Preview a specific character
forgum preview ghost "Boo!"
```

---

## 🛠 Advanced Customization

### Character Moods
Modify the visual state of your character using eye presets:

```powershell
# Stoned mood
forgum "Processing..." -Eyes **

# Dead mood
forgum "Critical Error." -Eyes xx

# Paranoia mood
forgum "Unauthorized access detected." -Eyes @@
```

### Rainbow Colorization (Lolcat)
Toggle global colorization or adjust the frequency:

```powershell
# Toggle global lolcat state
forgum toggle

# Adjust color frequency via configuration
Set-Forgum -RainbowFrequency 0.05
```

---

## ❓ Frequently Asked Questions

**"How do I see all available characters?"**
Execute `Get-CFCow` to retrieve the complete inventory of character templates.

**"How do I enable startup greetings?"**
Startup behavior is managed during initial installation or via `forgumSetup`. To enable it manually, ensure `Import-Module Forgum` is present in your `$PROFILE`.

**"Is this compatible with non-PowerShell environments?"**
Yes. Forgum provides integration samples for Bash, Zsh, Fish, and tmux. Refer to the [Sample Configs](Sample-Configs.md) documentation for details.

---

## ❤️ Conclusion

Forgum is designed to be a lightweight, secure, and performant addition to your terminal workflow. For detailed technical specifications, refer to the [API Reference](../docs/API-Reference.md).
