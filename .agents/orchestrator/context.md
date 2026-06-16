# Project Context: Forgum Multi-Platform Testing

## System Environment
- OS: Windows (user's environment)
- Shell: PowerShell / pwsh
- Target Platforms: Windows, Ubuntu/Linux, macOS
- Target Architectures: x86_64, aarch64 (ARM64)

## Architecture Overview
- **PowerShell Module (`Forgum.psd1`/`Forgum.psm1`)**: Serves as the user-facing entry point and CLI wrapper.
- **Rust Core (`forgum-core`)**: A high-performance CLI tool written in Rust to handle terminal manipulation, 60fps dynamic animations, scaling, and double buffering.
- **Dependencies**: None external, uses raw ANSI and cross-platform native calls (e.g., via `crossterm`/`ratatui` in Rust).
- **Test Runner**: Pester 5 for PowerShell wrapper and integration tests, Cargo for Rust unit tests.

## Current Workflow Setup (`ci.yml`)
- Run PSScriptAnalyzer for static code analysis.
- Validate module manifest and check for expected data files (cows, fortunes, animation scripts).
- Run Rust tests (`cargo test`).
- Build Rust binary for release.
- Run Pester tests on the built binary across `windows-latest`, `ubuntu-latest`, and `macos-latest` for pwsh 7.4 (and pwsh 5.1 on Windows).
- Run performance gate.
- Package and release on tag creation.

## Requirements mapping
- **Matrix Testing**: Expand current `ci.yml` matrix.
- **Architecture Simulation**: Ensure cross-compilation and verification steps for multiple architectures (e.g., x86_64 and ARM64/aarch64).
