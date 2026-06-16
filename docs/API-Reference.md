# Forgum API Reference

This document provides a comprehensive reference for all public functions exposed by the Forgum PowerShell module.

## `Invoke-Cowsay`

Generates an ASCII art cow saying the provided text.

### Parameters
*   `-Text` (`[string]`): The message the cow will say. Required.
*   `-Cow` (`[string]`): The name of the cow to use (e.g., `default`, `tux`, `dragon`). Default: `default`.
*   `-Eyes` (`[string]`): Custom eye characters (must be exactly 2 characters). Default: `oo`.
*   `-Tongue` (`[string]`): Custom tongue characters (must be exactly 2 characters). Default: `  `.
*   `-Thoughts` (`[string]`): The thought bubble character (usually `\` or `o`). Default: `\`.
*   `-Wrap` (`[int]`): Column width to wrap the text. Default: 40.

### Examples
```powershell
# Basic usage
Invoke-Cowsay -Text "Hello, World!"

# Using a different cow and custom eyes
Invoke-Cowsay -Text "I am a Linux penguin" -Cow "tux" -Eyes "=="
```

## `Invoke-Forgum`

The main entry point for the combined Forgum experience (Fortune + Cowsay + Lolcat).

### Parameters
*   `-Lolcat` (`[switch]`): Apply rainbow colors to the output.
*   `-Animation` (`[string]`): Specify an animation mode (e.g., `scroll`, `fade`).
*   `-Text` (`[string]`): Override the fortune with custom text.
*   `-Cow` (`[string]`): The name of the cow to use. If not specified, uses the configured default or randomizes.

### Examples
```powershell
# Default behavior (Random fortune + Default cow)
Invoke-Forgum

# Rainbow colored fortune with a specific cow
Invoke-Forgum -Lolcat -Cow "dragon"

# Custom text with rainbow colors
Invoke-Forgum -Text "Stay awesome!" -Lolcat
```

## `Get-Fortune`

Retrieves a random fortune from the internal database.

### Parameters
None.

### Examples
```powershell
# Get a single fortune
Get-Fortune
```

## `Get-CFCow`

Lists available ASCII cows or retrieves the raw template for a specific cow.

### Parameters
*   `-Name` (`[string]`): The specific cow name to retrieve. If omitted, returns a list of all available cow names.

### Examples
```powershell
# List all cows
Get-CFCow

# Get raw template for 'ghost'
Get-CFCow -Name "ghost"
```

## `Set-Forgum`

The easiest way to update your Forgum configuration persistently.

### Parameters
*   `-Animation` (`[string]`): Sets the animation mode. (e.g. `static`, `talking`, `typewriter`, `bounce`, etc.)
*   `-Cow` (`[string]`): Sets the default cow character.
*   `-Eyes` (`[string]`): Sets the default eye character for the cow.
*   `-Lolcat` (`[bool]`): Enables or disables rainbow colorization globally.
*   `-RandomCow` (`[bool]`): Enables or disables random cow selection on startup.
*   `-RainbowFrequency` (`[double]`): Adjusts the frequency of rainbow colors (0.01 to 1.0).

### Examples
```powershell
# Set dragon as default cow with talking animation
Set-Forgum -Cow dragon -Animation talking

# Enable lolcat and set eyes to 'XX'
Set-Forgum -Lolcat $true -Eyes "XX"
```

## `Get-CFConfig`

Retrieves the current Forgum configuration settings.

### Parameters
None.

### Examples
```powershell
# Display current configuration
$config = Get-CFConfig
$config.DefaultCow
```

## `Set-CFConfig`

Updates the Forgum configuration.

### Parameters
*   `-Config` (`[hashtable]`): A hashtable containing the configuration keys and values to update. Required.

### Examples
```powershell
# Change the default cow and enable Lolcat globally
$newConfig = @{ DefaultCow = "tux"; EnableLolcat = $true }
Set-CFConfig -Config $newConfig
```

## `Show-CFAnimation`

Applies an animation effect to the provided text.

### Parameters
*   `-Text` (`[string]`): The ASCII art or text to animate. Required.
*   `-Mode` (`[string]`): The animation style. Supported values depend on configuration (e.g., `Scroll`, `Fade`, `Typewriter`). Default: `None`.

### Examples
```powershell
# Scroll animation
$cowText = Invoke-Cowsay -Text "Watch me move!"
Show-CFAnimation -Text $cowText -Mode "Scroll"
```
