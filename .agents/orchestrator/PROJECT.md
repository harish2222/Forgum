# Project: Forgum Dynamic Animation Engine Cross-Platform & Cross-Architecture Testing

## Architecture
- **GitHub Actions Workflows**: `.github/workflows/ci.yml` triggers on pushes to main and pull requests, handling lint, validate, security audit, testing, and packaging.
- **PowerShell Module Wrapper**: Located in `Public/` and `Private/`. Invokes the compiled Rust binary located in `bin/forgum-core.exe` (on Windows) or `bin/forgum-core` (on Unix-like systems).
- **Rust Animation Core**: Located in `src-rust/`. Compiles to the high-performance dynamic rendering CLI utility.

## Milestones
| # | Name | Scope | Dependencies | Status | Conversation ID |
|---|------|-------|-------------|--------|-----------------|
| 1 | Exploration | Explore current codebase, Rust dynamic animation engine, Pester test cases, and existing CI configuration. | None | DONE | 301bc020-05ad-473d-b5dd-8eb155d81d16, 45544eed-ff51-4078-83ba-e8ca0b053d10, cd950ac6-e3cd-4eae-ae21-8f9d0cb42783 |
| 2 | Test Spec & Target Prep | Design comprehensive E2E test spec and target architectures cross-compilation pipeline. | M1 | DONE | None |
| 3 | CI Workflows Expansion | Refactor `.github/workflows/ci.yml` to support multi-platform matrix runs across OSs. | M2 | IN_PROGRESS | b78f6ac8-6306-476d-a8f8-7fecf1b02d1d |
| 4 | Arch Simulation & Exec | Implement cross-architecture verification steps in CI (using Cargo cross-compilation & simulation). | M3 | IN_PROGRESS | b78f6ac8-6306-476d-a8f8-7fecf1b02d1d |
| 5 | E2E Testing Validation | Run and verify that Pester successfully runs the compiled Rust binaries on all CI runner platforms. | M4 | IN_PROGRESS | b78f6ac8-6306-476d-a8f8-7fecf1b02d1d |
| 6 | Forensic Audit & Hardening | Audit the codebase to ensure integrity and run adversarial test scenarios. | M5 | PLANNED | TBD |

## Interface Contracts
### PowerShell Wrapper ↔ Rust Core (`forgum-core`)
- The PowerShell wrapper calls the Rust binary with arguments: `--cow_text <string>`, `--message <string>`, `--mode <string>`.
- The Rust binary handles terminal size checking, double buffering, ANSI diff calculations, and frame pacing.
- The Rust binary must run panic-free and return exit code 0 on successful completion.

## Code Layout
- `.github/workflows/ci.yml` - GitHub Actions workflow
- `src-rust/` - Rust source code (`main.rs`, `engine.rs`, `terminal.rs`)
- `Tests/` - Pester test cases (`Forgum.Tests.ps1`, `Comprehensive.Tests.ps1`, etc.)
- `Public/` - Public PowerShell commands (`Show-CFAnimation.ps1`, etc.)
