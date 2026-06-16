# Forgum Contributor Manual

Welcome to the Forgum project! This manual details the internal architecture to help contributors understand how the system works and how to extend it.

## Architecture Overview

Forgum is a pure PowerShell module optimized for performance, security, and cross-platform compatibility.

### 1. Module Structure (`Forgum.psm1`)

The root module dots-sources functions from the `Public/` and `Private/` directories.

*   **Public Functions**: Exported cmdlets intended for end-user interaction (e.g., `Invoke-Forgum`, `Set-Forgum`).
*   **Private Functions**: Internal helper functions for text formatting, color generation, and animation logic.
*   **Initialization**: Handles Virtual Terminal (VT) processing setup on Windows to ensure 24-bit color support.

### 2. State & Caching

Forgum utilizes a script-scoped caching system (`$script:CowFileCache`, `$script:FortuneCache`) to minimize disk I/O.

*   **Configuration**: The configuration is managed as a JSON object, cached in memory with a Time-To-Live (TTL) to ensure responsiveness while allowing for external updates.
*   **Atomic Writes**: Updates to the configuration file use temporary files and atomic move operations to prevent data corruption.

### 3. Rendering Engine

The rendering engine is built using `[System.Text.StringBuilder]` for efficient string manipulation.

*   **Colorization**: The `Format-Lolcat.ps1` logic implements a high-performance rainbow colorization algorithm compatible with ANSI truecolor.
*   **Animation**: Animations are coordinated through `Show-CFAnimation.ps1`, which utilizes frame-based rendering and precise timing loops.

## Getting Started

1.  Modify functions in `Private/` or `Public/`.
2.  Follow the **Coding Style** mandates in `GEMINI.md`: strict typing, validation attributes, and comprehensive help blocks.
3.  Ensure all changes are verified with the Pester test suite.

## Testing Standard

Forgum maintains a high-coverage test suite using Pester 5.
*   **Comprehensive Tests**: `Tests/Comprehensive.Tests.ps1` validates the Permutation Matrix (Cow × Eyes × Animation).
*   **Security Checks**: Automated audits ensure no use of `Invoke-Expression` and validate safe path resolution.
*   **Benchmark Suite**: Every release is benchmarked to ensure zero performance regression.
