# Changelog

All notable changes to Forgum will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.2] - 2026-06-19

### Added
- **`forgum` CLI router** — Single entry point for all features (e.g. `forgum gallery`, `forgum update`).
- **Silent Auto-Update** — Non-blocking background daily update checker.
- **TUI & Setup Wizard Updates** — Added configuration toggles for the daily auto-update.
- **Structured Helper Commands** — Added `Show-CFCowGallery`, `Show-CFCowPreview`, `Toggle-CFLolcat`, etc., with native PowerShell documentation.

### Fixed
- **CI Workflows** — Removed flaky QEMU arm64 cross-compilation tests in `ci.yml` that were blocking releases.
- **Profile Integration** — Cleaned up `setup.ps1` to prevent multiple dirty imports in the `$PROFILE`.

## [1.1.1] - 2026-06-17

### Fixed

- **Critical: PowerShell startup hang** — `forgum-core.exe` ran an infinite animation loop when `animation.mode` was not `static`, blocking terminal startup indefinitely
  - Binary now respects `--mode` flag; `--once` flag renders one frame and exits
  - Non-TTY output (piped/CI) defaults to 1 frame instead of infinite
  - Binary never enters alternate screen or raw mode when piped
- **`Show-CFAnimation.ps1`** — passes `--once` to binary, joins `Object[]` output into `[string]` for lolcat compatibility; `dynamic`, `talking`, `typewriter` now route to PowerShell animation functions (`Private/Animation/*.ps1`) instead of being sent to the Rust binary which has no arm for them
- **`Forgum.psm1`** — rewritten: lazy VT init (skips `Add-Type` when non-TTY), preserves caller's `$ErrorActionPreference`/`$ProgressPreference` via `OnRemove`, forces `animation.mode = 'static'` for auto-start regardless of config, skips auto-start in non-interactive/redirected/ServerRemoteHost sessions
- **`Invoke-LiveShow.ps1`** — try/catch on `[Console]::KeyAvailable` (throws in redirected sessions)
- **`Invoke-ForgumLive.ps1`** — CPU spin fix (sleep between key polls), Spacebar/Space key compat
- **`Update-Forgum.ps1`** — GitHub API auth headers, pre-release version cast to `[version]`, zipball download instead of re-running installer
- **`Invoke-ForgumSetup.ps1`** — `-NonInteractive`/`-Force` passthrough
- **`Format-Lolcat.ps1`** — WT_SESSION truecolor detection, ECMA-48 colon subparam stripping
- **`Dynamic.ps1`** — `hasConsole` flag to avoid VT calls in non-TTY, `Duration = 0` early exit
- **`Write-TerminalFrame.ps1`** — try/catch cursor position (fails in redirected sessions)
- **`Get-ConfigPath.ps1`** — PS7 vs 5.1 path resolution
- **`Set-Forgum.ps1`** — `ValidateSet` verified for all 11 animation modes
- **`Forgum.psd1`** — version 1.1.1, updated ReleaseNotes

### Changed

- **`install.ps1`** — PSVersion comparison uses `[version]` object, git clone uses `GIT_TERMINAL_PROMPT=0` and `-c core.askPass=echo` to prevent hang on credential prompts
- **`install.sh`** — bashrc injection comment documents `animation.mode = "static"` requirement, uninstall section references `uninstall.ps1`
- **`setup.ps1`** — default animation mode changed from `dynamic` to `static`
- **`uninstall.ps1`** — handles region-based profile blocks (`# region FORGUM...# endregion FORGUM`), `$HOME` fallback when `MyDocuments` is unavailable, bash/zsh/fish block cleanup improved

### CI

- **`.github/workflows/ci.yml`** — pinned `cargo-audit 0.21.1` and `cargo-mutants 24.11.0`, fixed single-quote `${{ }}` interpolation in `build` job, added `concurrency` + `permissions` + `continue-on-error` on mutation test, lowered perf-gate from 15s to 5s

## [1.1.0] - 2026-06-15

### Added

- **Profile Customization Functions**
  - `cowconfig` - Quick config access with dot notation
  - `cowpreview` - Preview cows with custom text
  - `cowgallery` - Browse random cows
  - `lolcat-toggle` - Toggle rainbow colors
  - `cow-animate` - Switch animation modes
  - `cow-eyes` - Set cow eyes with presets

- **Documentation**
  - Comprehensive customization guide in README
  - Advanced contributor customization methods
  - Custom cow file creation guide
  - Animation mode extension guide
  - Shell wrapper examples
  - Tab completion setup
  - VS Code integration examples

### Changed

- Updated README with ghost-writing style
- Enhanced CONTRIBUTING.md with customization methods
- Improved profile integration with tab completion

## [1.0.9] - 2026-06-14

### Changed
- Implemented "Clean Profile" region-based modification for PowerShell profiles
- Automatic cleanup of old Forgum snippets in profile
- Removed all redundant agent artifacts and local test scripts from repository
- Reached absolute zero-warning baseline

## [1.0.8] - 2026-06-14

### Changed
- Resolved 100% of PSScriptAnalyzer linting warnings
- Standardized UTF-8 BOM encoding for cross-platform PowerShell compatibility
- Implemented `SupportsShouldProcess` for all state-changing functions
- Refined `-NonInteractive` and `-Force` support in setup scripts for CI/CD
- Optimized animation loops by removing unused variables and parameters
- Reached zero-warning baseline for industry-standard quality

## [1.0.7] - 2026-06-14

### Added
- Interactive setup wizard integrated into installers
- New `Invoke-ForgumSetup` (forgum-setup) command for re-configuration
- Secure auto-update mechanism via `Update-Forgum`

### Fixed
- Robust bubble alignment engine (handles tabs, zero-width chars, ANSI)
- Standardized "FORGUM" ASCII banners across all scripts

### Changed
- Expanded benchmark suite with 34 tests and visual regression

## [1.0.6] - 2026-06-14

### Security
- Path traversal prevention in `Read-CowFile` (validates resolved paths stay in Cows dir)
- `Set-CFConfig` temp file race condition fix (New-TemporaryFile)

### Fixed
- Auto-start no longer overwrites user config on disk (in-memory only)
- `Set-CFConfig -WhatIf` no longer invalidates cache
- `Invoke-Forgum` `ValidateLength(2,2)` on Eyes/Tongue parameters
- `Talking.ps1` returns `$CowOutput` consistently
- `Blink.ps1` `$BlinkRate` parameter now actually affects timing
- `Wave.ps1` guards against no-balloon case
- `FadeIn.ps1` guards against zero totalLines division
- `Get-CFConfig` null check (was falsy check)

### Performance
- `Dissolve.ps1` O(n) with `List[int/string]` (was O(n^2) with `array +=`)

### Changed
- `Dynamic.ps1` path resolution and balloon style consistency
- `Format-CowMessage` handles words longer than MaxWidth
- CI: all 6 jobs green across macOS/Linux/Windows, pwsh 5.1 + 7.4

## [1.0.5] - 2026-06-13

### Added
- Inno Setup installer (Forgum-v1.0.5-Setup.exe) for silent install
- CI workflow: build-installer job compiles Inno Setup on Windows
- Release artifacts: both ZIP and Setup.exe attached to GitHub releases
- One-liner install: `& "$env:TEMP\Forgum-v1.0.5-Setup.exe" /VERYSILENT /SUPPRESSMSGBOXES`

### Changed
- Module version bumped to 1.0.5

## [1.0.4] - 2026-06-13

### Added
- Complete sample configurations for all platforms (PowerShell, Bash, Zsh, Fish, Git-Bash)
- Wiki documentation: Sample-Configs.md with 9 use cases across 5 shells
- Platform-specific integration guides with full code blocks
- Package manager manifest validation tests
- Documentation existence tests
- Security harness tests (no Invoke-Expression, safe config paths, safe cow files)
- Proof of legitimacy documentation

### Fixed
- Show-FortuneCow function not defined in setup.ps1 generated profiles
- Double output bug in Invoke-Forgum -Lolcat
- Duplicate tab completion blocks in profile.ps1
- Missing parameter names in cowpreview/cowgallery functions
- Lolcat toggle not displaying current state

### Changed
- Moved package manager docs from hidden .agent/ to visible package-managers/
- Updated all documentation with platform-specific samples
- Expanded test suite with security and package manager coverage

## [1.0.0] - 2026-06-12

### Added

- **Core Features**
  - `Invoke-Cowsay` - Display ASCII cow with custom message
  - `Invoke-Forgum` - Combine cowsay + fortune + optional lolcat
  - `Get-Fortune` - Get random fortune from database
  - `Get-CFCow` - List available cows or read specific cow
  - `Get-CFConfig` / `Set-CFConfig` - Configuration management
  - `Show-CFAnimation` - Animated display modes

- **Cow Collection**
  - 190 cow files ported from piuccio/cowsay
  - Support for custom cow files
  - Cow mode presets (borg, dead, greedy, paranoia, stoned, tired, wasted, youthful)
  - Random cow selection

- **Fortune System**
  - Fortune database with thousands of quotes
  - Support for custom fortune databases
  - Cached parsing for performance

- **Lolcat Rainbow**
  - Truecolor (24-bit) support
  - 256-color fallback
  - Configurable frequency and spread
  - ANSI escape passthrough

- **Animation Modes**
  - Static (instant display)
  - Typewriter (character-by-character)
  - Talking (mouth movement simulation)

- **Multi-Shell Integration**
  - Bash wrapper (`Forgum.sh`)
  - Zsh wrapper with completions (`Forgum.zsh`)
  - Fish wrapper (`Forgum.fish`)
  - PowerShell native support

- **tmux/rmux Integration**
  - Status bar fortune display
  - Configurable pane and refresh

- **Configuration**
  - JSON-based config file
  - Platform-appropriate locations
  - Environment variable override (`Forgum_CONFIG`)
  - Atomic file writes (prevents corruption)
  - Config caching with TTL

- **Installation**
  - Fun PowerShell installer with ASCII art
  - Fun bash/zsh/fish installer
  - Automatic dependency checking
  - Shell profile integration
  - One-liner install commands

- **Testing**
  - 66 Pester tests
  - Module loading tests
  - Config system tests
  - Fortune system tests
  - Cow system tests
  - Lolcat colorization tests
  - Animation system tests
  - Security tests
  - Edge case tests

- **Documentation**
  - Comprehensive README
  - API documentation
  - Contributing guidelines
  - Changelog
  - License (MIT)

### Performance

- Cow file caching (avoids repeated disk reads)
- Fortune database caching
- Config caching with 30-second TTL
- `StringBuilder`-based string operations (O(n) vs O(n²))
- `List[T]` instead of array concatenation

### Security

- No `Invoke-Expression` on user input
- Input validation on all parameters
- Atomic config file writes
- Proper error handling with try/catch
