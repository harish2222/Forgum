@{
    RootModule        = 'Forgum.psm1'
    ModuleVersion     = '2.0.0'
    GUID              = 'f7e6b3a1-2d84-4c9f-a5e0-1b3d7c8f9e2a'
    Author            = 'HKDEVS'
    CompanyName       = 'HKDEVS'
    Copyright         = '(c) 2026 HKDEVS. All rights reserved.'
    Description       = 'Cross-platform cowsay + fortune + lolcat PowerShell module with 107 animal cows, rainbow colors, animations, and multi-shell integration.'
    PowerShellVersion = '5.1'
    FunctionsToExport = @(
        'forgum'

    )
    CmdletsToExport   = @()
    VariablesToExport  = @()
    AliasesToExport    = @('forgum-show', 'forgum-setup')
    PrivateData       = @{
        PSData = @{
            Tags         = @('cowsay', 'fortune', 'lolcat', 'ascii', 'fun', 'cross-platform', 'terminal')
            LicenseUri   = 'https://github.com/harish2222/Forgum/blob/main/LICENSE'
            ProjectUri   = 'https://github.com/harish2222/Forgum'
            IconUri      = 'https://raw.githubusercontent.com/harish2222/Forgum/main/icon.png'
            ReleaseNotes = @'
## v2.0.0
- Feature: Unified CLI — single `forgum` command with subcommands: run, config, gallery, preview, update, toggle, animate, eyes, init, live, daemon, help
- Feature: `forgum init <shell>` generates native shell hooks for bash, zsh, fish, and PowerShell
- Feature: `forgum help [command]` provides comprehensive help for every command and argument
- Feature: Rust engine background rendering — animations run independently while shell stays usable
- Feature: Cross-platform native shell hooks via Get-ForgumShellHook
- Breaking: Module exports only `forgum` — all other functions are now Private
- Fix: All subcommand help returns via pipeline (not Write-Host) for testability
- Fix: forgum.ps1 switch routing for PowerShell dash-stripped params
- Fix: Invoke-Cowsay validation rejects empty config values gracefully
- Fix: Get-ForgumShellHook single-quoted templates avoid PowerShell subexpression interpretation
- Test: 130/130 tests passing across 8 test files

## v1.0.9
- UX: Implemented "Clean Profile" region-based modification for PowerShell profiles
- UX: Automatic cleanup of old Forgum snippets in profile
- Maintenance: Removed all redundant agent artifacts and local test scripts from repository
- Hardening: Reached absolute zero-warning baseline

## v1.0.8
- Hardening: Resolved 100% of PSScriptAnalyzer linting warnings
- Hardening: Standardized UTF-8 BOM encoding for cross-platform PowerShell compatibility
- Hardening: Implemented `SupportsShouldProcess` for all state-changing functions
- Feature: Refined `-NonInteractive` and `-Force` support in setup scripts for CI/CD
- Perf: Optimized animation loops by removing unused variables and parameters
- Quality: Reached zero-warning baseline for industry-standard quality

## v1.0.7
- Feature: Interactive setup wizard integrated into installers
- Feature: New `Invoke-ForgumSetup` (forgum-setup) command for re-configuration
- Feature: Secure auto-update mechanism via `Update-Forgum`
- Fix: Robust bubble alignment engine (handles tabs, zero-width chars, ANSI)
- Fix: Standardized "FORGUM" ASCII banners across all scripts
- Test: Expanded benchmark suite with 34 tests and visual regression

## v1.0.6
- Security: path traversal prevention in Read-CowFile (validates resolved paths stay in Cows dir)
- Security: Set-CFConfig temp file race condition fix (New-TemporaryFile)
- Bug: auto-start no longer overwrites user config on disk (in-memory only)
- Bug: Set-CFConfig -WhatIf no longer invalidates cache
- Bug: Invoke-Forgum ValidateLength(2,2) on Eyes/Tongue parameters
- Bug: Talking.ps1 returns $CowOutput consistently
- Bug: Blink.ps1 $BlinkRate parameter now actually affects timing
- Bug: Wave.ps1 guards against no-balloon case
- Bug: FadeIn.ps1 guards against zero totalLines division
- Bug: Get-CFConfig null check (was falsy check)
- Performance: Dissolve.ps1 O(n) with List[int/string] (was O(n^2) with array +=)
- Other: Dynamic.ps1 path resolution and balloon style consistency
- Other: Format-CowMessage handles words longer than MaxWidth
- CI: all 6 jobs green across macOS/Linux/Windows, pwsh 5.1 + 7.4

## v1.0.5
- Inno Setup installer for winget compatibility (EXE, no admin required)
- One-liner install via /VERYSILENT flag
- CI builds both ZIP and Setup.exe for releases
- Winget manifests corrected (InstallerType: inno)

## v1.0.4
- Complete sample configurations for all platforms (PowerShell, Bash, Zsh, Fish, Git-Bash)
- Wiki documentation: Sample-Configs.md with 9 use cases across 5 shells
- Platform-specific integration guides with full code blocks
- Package manager manifest validation tests
- Documentation existence tests
- Security harness tests (no Invoke-Expression, safe config paths, safe cow files)
- Proof of legitimacy documentation for package manager reviewers
- Winget submission (PR #387476)
- Scoop submission (PR #18034)
- Fixed Show-FortuneCow function not defined in setup.ps1 generated profiles
- Fixed double output bug in Invoke-Forgum -Lolcat
- Fixed duplicate tab completion blocks in profile.ps1
- Fixed missing parameter names in cowpreview/cowgallery functions
- Fixed lolcat toggle not displaying current state
- Moved package manager docs from hidden .agent/ to visible package-managers/
- Updated all documentation with platform-specific samples
- Expanded test suite with security and package manager coverage
'@
        }
    }
}
