# Contributing to Forgum

Thank you for your interest in contributing! This document provides guidelines and instructions for contributing.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [How to Contribute](#how-to-contribute)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Pull Request Process](#pull-request-process)
- [Adding Cows](#adding-cows)
- [Customization Methods](#customization-methods)
- [Reporting Bugs](#reporting-bugs)

## Code of Conduct

- Be respectful and inclusive
- Welcome newcomers and help them learn
- Focus on constructive feedback
- Accept responsibility for mistakes

## Getting Started

1. Fork the repository on GitHub
2. Clone your fork locally:
   ```powershell
   git clone https://github.com/YOUR_USERNAME/Forgum.git
   cd Forgum
   ```
3. Create a feature branch:
   ```powershell
   git checkout -b feature/my-feature
   ```
4. Make your changes
5. Run tests
6. Commit and push
7. Create a Pull Request

## Development Setup

### Prerequisites

- PowerShell 5.1+ (Windows) or PowerShell 7+ (cross-platform)
- Git
- Pester (for tests)

### Quick Start

```powershell
# Import the module in development mode
Import-Module ./Forgum/Forgum.psd1 -Force

# Run tests
Import-Module Pester
Invoke-Pester -Path ./Tests/CLI.Tests.ps1
```

### Project Structure

```
Forgum/
├── Forgum.psd1              # Module manifest
├── Forgum.psm1              # Module entry point
├── Public/                  # Exported functions
│   └── forgum.ps1           # Unified CLI router
├── Private/                 # Internal functions
│   ├── Get-HelpMessage.ps1
│   ├── Parse-ForgumArguments.ps1
│   ├── CrossPlatform.ps1
│   ├── Get-ConfigPath.ps1
│   ├── Get-CFConfig.ps1
│   ├── Set-CFConfig.ps1
│   ├── Get-CFCow.ps1
│   ├── Get-Fortune.ps1
│   ├── Invoke-Cowsay.ps1
│   ├── Show-CFAnimation.ps1
│   ├── Set-Forgum.ps1
│   ├── Format-CowMessage.ps1
│   ├── Format-Lolcat.ps1
│   ├── Get-EngineBinary.ps1
│   ├── Get-ForgumShellHook.ps1
│   ├── Subcommands/
│   │   ├── Invoke-ForgumRun.ps1
│   │   └── Invoke-ForgumConfig.ps1
│   └── Animation/
│       ├── Static.ps1
│       ├── Talking.ps1
│       ├── Typewriter.ps1
│       ├── Dynamic.ps1
│       ├── PhysicsCow.ps1
│       └── Invoke-Engine.ps1
├── engine/                  # Rust binary source (forgum-engine)
├── bin/                     # Compiled engine binaries
├── Data/
│   ├── Cows/                # 107 .cow files
│   ├── Fortunes/            # Fortune database
│   └── Templates/           # Default config
├── Tests/                   # Pester tests
├── install.ps1              # PowerShell installer
├── install.sh               # Bash installer
└── uninstall.ps1            # Uninstaller
```

## How to Contribute

### Types of Contributions

- **Bug fixes** - Fix issues in existing functionality
- **New features** - Add new capabilities
- **New cows** - Add new cow ASCII art files
- **Documentation** - Improve docs, add examples
- **Performance** - Optimize existing code
- **Tests** - Add or improve test coverage

### Easy First Issues

Look for issues tagged `good-first-issue` on GitHub.

## Coding Standards

### PowerShell Style Guide

```powershell
# Use Approved Verbs
function Get-Something { }    # ✓
function Fetch-Something { }  # ✗

# Use CmdletBinding
function Get-Something {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )
}

# Use meaningful parameter names
function Get-Fortune {
    [CmdletBinding()]
    param(
        [ValidateNotNullOrEmpty()]
        [string]$Database = 'fortunes'
    )
}

# Include comment-based help
<#
.SYNOPSIS
    Brief description.
.DESCRIPTION
    Detailed description.
.PARAMETER Name
    Parameter description.
.EXAMPLE
    Get-Something -Name "test"
#>
```

### Performance Guidelines

- Use `StringBuilder` for string concatenation in loops
- Cache expensive operations (file reads, config loads)
- Use `List[T]` instead of array `+=` in loops

### Security Guidelines

- Never use `Invoke-Expression` on user input
- Validate all parameters
- Use `ValidateNotNullOrEmpty()` and `ValidatePattern()` where appropriate
- Handle errors gracefully with try/catch

## Testing

### Running Tests

```powershell
# Run all tests (130 tests across 8 files)
Import-Module ./Forgum.psd1 -Force
Invoke-Pester -Path ./Tests/

# Run specific test suites
Invoke-Pester -Path ./Tests/CLI.Tests.ps1              # 31 tests — unified CLI routing
Invoke-Pester -Path ./Tests/Engine.Tests.ps1            # 14 tests — Rust engine integration
Invoke-Pester -Path ./Tests/CrossPlatform.Tests.ps1     # 14 tests — cross-platform detection
Invoke-Pester -Path ./Tests/Forgum.Tests.ps1            # 40 tests — core features
Invoke-Pester -Path ./Tests/Comprehensive.Tests.ps1     # 12 tests — comprehensive feature coverage
Invoke-Pester -Path ./Tests/LiveShow.Tests.ps1          #  3 tests — live show mode
Invoke-Pester -Path ./Tests/Visual.Tests.ps1            #  4 tests — visual rendering
Invoke-Pester -Path ./Tests/Ghost.Tests.ps1             # 11 tests — ghostwriting/edge cases

# Run with detailed output
Invoke-Pester -Path ./Tests/CLI.Tests.ps1 -Verbose

# Run specific test
Invoke-Pester -Path ./Tests/CLI.Tests.ps1 -TestName "renders cow with message"
```

### Test Architecture

**130 tests** across 8 files. Key patterns:

#### `InModuleScope Forgum { }` — Required for Private functions

Pester cannot call module-internal functions directly. Wrap all private function calls:

```powershell
It "reads config" {
    InModuleScope Forgum {
        $config = Get-CFConfig
        $config | Should -Not -BeNullOrEmpty
    }
}
```

Without this wrapper, calls like `Get-CFConfig` fail with "command not found" because the function is Private (not exported).

#### Stream capture — `6>&1` for cow output

`Write-Host` and `Write-Information` go to stream 6 (Information), not stdout. To capture cow output in tests:

```powershell
It "renders cow" {
    InModuleScope Forgum {
        $result = forgum -Text "test" 6>&1
        $result | Should -BeLike "*test*"
    }
}
```

Using `2>&1` only captures stderr — it will miss cow output entirely.

#### Engine binary tests — inconclusive when binary missing

Engine tests (Engine.Tests.ps1) are **inconclusive** (not failed) when `forgum-engine` is not in `bin/`. This is expected in development environments. To make them pass:

```powershell
cd engine && cargo build --release
Copy-Item engine/target/release/forgum-engine.exe bin/
```

#### Config isolation — always use `$testConfigPath`

Tests that modify config must use a temporary path to avoid corrupting the real config:

```powershell
BeforeAll {
    $testConfigPath = Join-Path $TestDrive 'test-config.json'
    # ... write test config to $testConfigPath
}
```

### Writing Tests

```powershell
Describe "Function Name" {
    BeforeEach {
        Import-Module $modulePath -Force
    }

    It "does something" {
        $result = Get-Something -Parameter "value"
        $result | Should Not BeNullOrEmpty
    }

    It "throws for invalid input" {
        $threw = $false
        try { Get-Something -Parameter "" } catch { $threw = $true }
        $threw | Should Be $true
    }
}
```

### Test Coverage

Aim for:
- All public functions tested
- Edge cases covered
- Error conditions tested
- Security scenarios tested
- All private function tests wrapped in `InModuleScope Forgum { }`
- Cow output captured with `6>&1`

## Pull Request Process

1. **Before submitting:**
   - Run all tests and ensure they pass
   - Follow coding standards
   - Update documentation if needed
   - Add tests for new functionality

2. **PR description should include:**
   - Summary of changes
   - Related issue number
   - Testing done
   - Any breaking changes

3. **Review process:**
   - At least one maintainer approval required
   - All tests must pass
   - No merge conflicts
   - Documentation updated

## Adding Cows

To add a new cow:

1. Create a `.cow` file in `Data/Cows/`
2. Follow the Perl .cow format:
   ```perl
   $the_cow = <<EOC;
         \\   ^__^
          \\  (oo)\\_______
             (__)\\       )\\/\\
                 ||----w |
                 ||     ||
   EOC
   ```
3. Use `$eyes`, `$tongue`, `$thoughts` for customizable parts
4. Test with: `forgum -Text "Test" -CowFile 'your-cow'`
5. Add to test suite

## Customization Methods

### Adding Custom Cow Files

Create your own `.cow` file in `Data/Cows/`:

```perl
$the_cow = <<EOC;
        \\   ^__^
         \\  (oo)\\_______
            (__)\\       )\\/\\
                ||----w |
                ||     ||
EOC
```

**Template Variables:**
- `$eyes` - Two-character eye string (default: `oo`)
- `$tongue` - Two-character tongue string (default: `  `)
- `$thoughts` - Thought bubble character (default: `\`)

### Creating Custom Animation Modes

Add a new animation in `Private/Animation/`:

```powershell
# Private/Animation/MyCustom.ps1
function Invoke-MyCustomAnimation {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$CowOutput,
        [string]$Message,
        [hashtable]$Config
    )

    # Your animation logic here
    # Write output using Write-Host or Write-Information
}
```

**Extending PhysicsCow Animations:**

Forgum uses `Invoke-PhysicsCow` (the `physics` mode) to map cows to physics-based procedural animations based on the Cow Animation Manifesto.
To assign an engine to a cow or tweak properties:
1. Edit `Data/Cows/animations.json`.
2. Add an entry mapping the `.cow` file name (e.g. `duck.cow`) to `base`, `particles`, and `speed`.
3. If you want to add a new `baseEngine` (e.g., `Spin`), implement it within the `switch ($baseEngine)` block in `Private/Animation/PhysicsCow.ps1`.

Register in `Show-CFAnimation.ps1`:

```powershell
switch ($Config.animation.mode) {
    'static'    { Invoke-StaticAnimation @params }
    'talking'   { Invoke-TalkingAnimation @params }
    'typewriter'{ Invoke-TypewriterAnimation @params }
    'mycustom'  { Invoke-MyCustomAnimation @params }
}
```

### Extending the Config Schema

1. Add default values in `Data/Templates/default-config.json`:
   ```json
   {
     "mySection": {
       "myOption": "defaultValue"
     }
   }
   ```

2. Access in your functions:
   ```powershell
   $config = Get-CFConfig
   $myValue = $config.mySection.myOption
   ```

3. Update with:
   ```powershell
   Set-CFConfig -Config $config
   ```

### Adding Custom Fortune Databases

1. Create a new fortune file in `Data/Fortunes/`:
   ```
   Fortune 1
   %
   Fortune 2
   %
   Fortune 3
   ```

2. Access it:
   ```powershell
   Get-Fortune -Database 'mydatabase'
   ```

### Creating Shell Wrappers

**Bash wrapper:**
```bash
#!/bin/bash
# Save as /usr/local/bin/Forgum
pwsh -Command "Import-Module Forgum; forgum"
```

**Fish wrapper:**
```fish
# Save as ~/.config/fish/functions/Forgum.fish
function Forgum
    pwsh -Command "Import-Module Forgum; forgum"
end
```

**Zsh wrapper:**
```bash
# Save as ~/.zshrc function
Forgum() {
    pwsh -Command "Import-Module Forgum; forgum"
}
```

### Adding Tab Completion

Add to your profile:
```powershell
# Cow file tab completion
Register-ArgumentCompleter -Native -CommandName forgum -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    $cows = Get-CFCow | Where-Object { $_ -like "$wordToComplete*" }
    $cows | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new(
            $_, $_, 'ParameterValue', $_
        )
    }
}
```

### Custom Output Formats

Create custom output formatters:

```powershell
function Format-CowJson {
    param([string]$CowOutput, [string]$Message)

    @{
        message = $Message
        cow = $CowOutput
        timestamp = Get-Date -Format 'o'
    } | ConvertTo-Json
}
```

### Integration with Other Tools

**VS Code task:**
```json
{
    "label": "Show Fortune",
    "type": "shell",
    "command": "pwsh -Command \"Import-Module Forgum; forgum\""
}
```

**Windows Terminal profile:**
```json
{
    "commandline": "pwsh -NoExit -Command \"Import-Module Forgum; Show-FortuneCow\"",
    "name": "Cowsay Fortune"
}
```

## Reporting Bugs

1. Check existing issues first
2. Create a new issue with:
   - Clear title
   - Steps to reproduce
   - Expected behavior
   - Actual behavior
   - PowerShell version
   - OS information

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

## Questions?

Open an issue or start a discussion on GitHub.

---

## Agentic Model Coding Guidelines (for automated agents)

This repository also contains agent-facing instruction files (e.g., `CLAUDE.md`). If you are an automated coding agent:

- Read the relevant source/doc files before editing (no blind changes).
- Prefer editing existing files over creating new ones.
- Do not add secrets/credentials or environment-specific `.env` files.
- Keep changes focused; run the test suite after code edits.
- Avoid writing generated artifacts into repo roots; place new scripts/docs under appropriate directories (e.g., `/scripts`, `/docs`).
