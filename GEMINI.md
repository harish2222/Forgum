# Forgum Project Context

## Project Overview
Forgum is a cross-platform PowerShell module that combines the functionality of **cowsay**, **fortune**, and **lolcat** into a single, configurable terminal experience. It provides 107 ASCII animal "cows", a database of fortunes, truecolor rainbow text generation, and various animation modes. 

**Key Characteristics:**
*   **Language:** PowerShell (5.1+ for Windows, 7.4+ cross-platform).
*   **Core Dependencies:** None (zero external dependencies).
*   **Design Philosophy:** Fast (uses caching and `StringBuilder`), Secure (no `Invoke-Expression`, strict validation), and Fun.
*   **Integration:** Supports PowerShell native profiles, as well as wrappers/configurations for Bash, Zsh, Fish, and tmux.

## Directory Structure
*   **`Forgum.psd1` / `Forgum.psm1`:** The module manifest and root entry point.
*   **`Public/`:** Exported functions available to the user (e.g., `Invoke-Cowsay`, `Invoke-Forgum`, `Get-Fortune`, `Set-CFConfig`).
*   **`Private/`:** Internal functions handling logic like reading files, formatting text, and animations.
*   **`Data/`:** Contains the raw resources:
    *   `Cows/`: 107 `.cow` template files.
    *   `Fortunes/`: The `fortunes.txt` database.
    *   `Templates/`: Default JSON configuration schema.
*   **`Tests/`:** Pester test suite (`Forgum.Tests.ps1`).
*   **`installer/` & `package-managers/`:** Assets for distribution via Winget, Scoop, and Inno Setup.

## Building and Running

### Development Setup
1.  Clone the repository.
2.  Import the module locally to test changes:
    ```powershell
    Import-Module ./Forgum/Forgum.psd1 -Force
    ```

### Core Commands
*   **Show a cow saying a fortune with rainbow colors:** `Invoke-Forgum -Lolcat`
*   **Show a specific message:** `Invoke-Cowsay -Text "Hello World"`
*   **Get a fortune:** `Get-Fortune`
*   **Manage Configuration:** `Get-CFConfig` and `Set-CFConfig -Config $config`

## Development Conventions & Architecture

### Coding Style
*   **CmdletBinding:** Always use `[CmdletBinding()]` for public functions to support `-Verbose` and other common parameters.
*   **Strong Typing & Validation:** Use `[string]`, `[int]`, etc., and leverage validation attributes like `[ValidateNotNullOrEmpty()]`, `[ValidateLength()]`, and `[ValidateSet()]` rigorously to ensure security.
*   **Help Blocks:** Include standard comment-based help (`.SYNOPSIS`, `.DESCRIPTION`, `.PARAMETER`, `.EXAMPLE`) for all public functions.

### Performance Standards
*   **String Manipulation:** Use `[System.Text.StringBuilder]` for building strings in loops or doing multiple replacements, rather than `+=` or `-replace` chaining on large strings.
*   **Collections:** Use `[System.Collections.Generic.List[T]]` instead of array addition (`+=`) in loops to avoid O(n²) overhead.
*   **Caching:** The module relies on script-scoped caching (`$script:CowFileCache`, `$script:FortuneCache`, `$script:ConfigCache`) to avoid repetitive disk I/O. Be mindful of cache invalidation when modifying related logic.

### Security Mandates
*   **Never use `Invoke-Expression`** on user-provided input.
*   Prevent path traversal vulnerabilities when reading files from the `Data/` directory.

### Testing
*   The project uses **Pester 5**.
*   Run tests via:
    ```powershell
    Import-Module Pester
    Invoke-Pester -Path ./Tests/Forgum.Tests.ps1
    ```
*   Ensure all new features or bug fixes are accompanied by relevant tests in `Tests/Forgum.Tests.ps1`. Tests should cover typical use cases, edge cases (empty strings), and validation logic.

### Configuration System
*   Configuration is stored as JSON in platform-specific locations (e.g., `~/Documents/PowerShell/Forgum/config.json` on Windows).
*   Updates to configuration must be atomic and handle concurrent writes gracefully (e.g., using `New-TemporaryFile`).

### Installer Architecture
Forgum uses a 3-stage installation model to support standalone and package manager installs:
1. **Download/Extract:** `install.ps1` (or `install.sh`) handles pulling the module into the system's PowerShell modules directory.
2. **Configuration:** `setup.ps1` runs interactively (or silently with `-NonInteractive -Force` for package managers like winget/scoop) to set default behaviors.
3. **Profile Update:** Also handled by `setup.ps1`, injects `Import-Module`, startup commands (e.g., `Show-FortuneCow`), tab completion, and aliases into the user's PowerShell profile.

## Contribution Guidelines
When contributing, ensure adherence to the `CONTRIBUTING.md` guidelines. Focus on maintaining the performance and security standards outlined above. If adding new features (like new animation modes), ensure they integrate cleanly with the existing `Show-CFAnimation.ps1` router and the configuration schema. Always verify compatibility with both PowerShell 5.1 (Windows) and PowerShell 7.4+ (Cross-Platform) as enforced by CI.