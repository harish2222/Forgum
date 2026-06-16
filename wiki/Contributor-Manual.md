# Forgum Contributor Manual

Welcome to the Forgum project! This manual details the internal architecture to help contributors understand how the system works and how to extend it.

## Hybrid Architecture Overview

Forgum uses a hybrid architecture, combining the flexibility and deep OS integration of PowerShell with the raw performance of a Rust core (`forgum-core`).

### 1. The PowerShell Wrapper (`Forgum.psm1`)

The PowerShell module acts as the user-facing API and configuration manager.

*   **Config and Data Parsing:** PowerShell is responsible for loading the user's `config.json`, reading `.cow` template files from disk, and querying the `fortunes.txt` database.
*   **State Management:** PowerShell handles caching mechanisms to prevent unnecessary disk I/O on subsequent runs within the same session.
*   **Pipeline Coordination:** When advanced rendering or animation is required, the PowerShell wrapper prepares the final text payload and streams it to the Rust core.

### 2. The Rust Core (`forgum-core`)

The Rust executable (`forgum-core`) is optimized for heavy text processing, color generation (lolcat), and high-framerate terminal animations.

*   **Standard Input (stdin):** The core is designed to be invoked as a subprocess. It receives the prepared ASCII text payload from PowerShell via `stdin`.
*   **Double-Buffering Algorithm:** For smooth animations (like scrolling or fading), `forgum-core` implements a double-buffered rendering loop. It constructs the next terminal frame in memory while displaying the current one, then performs a minimal diff update to the terminal screen. This prevents flickering.
*   **Dynamic Scaling Logic Fallback (900x900px):** For specialized visual modes or edge cases where terminal dimensions are misreported, the engine includes a fallback dynamic scaling logic assuming a maximum viewport coordinate space of 900x900 "pixels" (mapping characters to a logical grid). This ensures animations remain bounded and don't corrupt the terminal state.

## Getting Started

1.  Modify the PowerShell logic in `Private/` or `Public/`.
2.  If modifying performance-critical rendering, update the Rust source inside `src-rust/`.
3.  Ensure you run `Invoke-Pester -Path ./Tests/Forgum.Tests.ps1` before submitting a PR.

## Testing Standard
This project uses a Pester Permutation Matrix generating over 384 tests to ensure every combination of Cow, Eyes, Tongue, and Animation works flawlessly. Rust tests ensure ANSI integrity and double-buffering logic.
