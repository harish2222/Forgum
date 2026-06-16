# Forgum Rust Animation Core Integration and Cross-Compilation Analysis

This report documents the exploration and analysis of the cross-platform Rust binary integration, CI compilation workflow, and validation strategies for multiple architectures on the Forgum project.

---

## 1. Pester Tests & Rust Binary Execution

### Pester Test Location
The Pester test suite references and executes the compiled Rust binary in:
- **File Path:** `Tests/Forgum.Tests.ps1`
- **Block:** `Describe "Show-CFAnimation Cross-Platform Wrapper" -Tag 'Wrapper'`
- **Test Cases (Lines 444–462):**
  - `It "invokes real Rust binary when present on supported OS"`: Verifies that when the binary is present at `$binPath`, invoking `Show-CFAnimation` does not throw an exception (running for 60 frames in a CI environment and exiting).
  - `It "falls back to static output if binary is missing"`: Mocks `Test-Path` for `forgum-core` to return `$false` and asserts that the wrapper successfully falls back to returning the static cow ASCII output string.

### Binary Path Resolution in PowerShell
In `Public/Show-CFAnimation.ps1` (lines 27–28), the binary path is resolved relative to the module root at runtime:
```powershell
$binName = if ($IsWindows -or ($PSVersionTable.PSVersion.Major -lt 6)) { "forgum-core.exe" } else { "forgum-core" }
$binPath = Join-Path (Split-Path $PSScriptRoot -Parent) "bin\$binName"
```
- **Windows (and PowerShell 5.1):** Looks for `bin/forgum-core.exe`.
- **Non-Windows (macOS & Linux in PowerShell 6+):** Looks for `bin/forgum-core`.

#### ⚠️ Critical Discrepancy Found (macOS Naming Mismatch)
In `.github/workflows/ci.yml` (lines 334–336), the macOS binary is packaged with a suffix `-mac`:
```powershell
if (Test-Path "bin_artifacts/forgum-core-macos-latest") {
  Copy-Item -Path "bin_artifacts/forgum-core-macos-latest/forgum_core" -Destination "$binDir/forgum-core-mac" -ErrorAction SilentlyContinue
}
```
However, the PowerShell wrapper code (`Public/Show-CFAnimation.ps1`) expects the binary on macOS to be named `forgum-core`. This mismatch causes macOS users who download the pre-packaged release zip to fail to load the binary, falling back to static animation output with a warning message.

### Supported Arguments
In `Public/Show-CFAnimation.ps1`, the binary is executed using the call operator `&`:
```powershell
$CowOutput | & $binPath --message $Message --mode $mode
```
According to `src-rust/src/main.rs`, the CLI uses `clap` for argument parsing and expects:
- **`cow_text` via Stdin:** The raw cow ASCII graphic is piped in via standard input (`stdin`). If `stdin` is not redirected, the binary defaults to a hardcoded standard cow.
- **`--message` / `-m` (Optional):** Mapped to standard input message text (e.g. for talking animation text rendering).
- **`--mode` (Optional, Default: `"slide"`):** Selects the active animation mode.
- **`-h` / `--help`:** Display help.
- **`-V` / `--version`:** Display version info.

---

## 2. Current CI Matrix (Platforms & Architectures)

In `.github/workflows/ci.yml`, the compilation and unit testing of the Rust codebase occurs in the `test` job under the following matrix:

```yaml
    strategy:
      fail-fast: false
      matrix:
        os: [windows-latest, ubuntu-latest, macos-latest]
        pwsh: ['7.4']
        include:
          - os: windows-latest
            pwsh: '5.1'
```

Because compilation is executed via a simple native `cargo build --release` command on each runner host, it generates binaries targeting the host's native OS and architecture:
1. **`windows-latest`** (x86_64 runner) -> target `x86_64-pc-windows-msvc` (packaged as `forgum-core.exe`).
2. **`ubuntu-latest`** (x86_64 runner) -> target `x86_64-unknown-linux-gnu` (packaged as `forgum-core`).
3. **`macos-latest`** (Apple Silicon M-series ARM64 runner) -> target `aarch64-apple-darwin` (packaged as `forgum-core-mac`).

*Note:* No multi-architecture cross-compilation is currently performed in the CI.

---

## 3. Recommended CI Matrix Expansion Plan

To build and verify both `x86_64` (Intel/AMD) and `aarch64` (ARM64) architectures across Windows, macOS, and Linux, the CI matrix should be expanded. We can parameterize the matrix with both the host OS and the target compilation triple.

### Proposed Matrix Configurations

| Platform | Runner OS (`os`) | Target Architecture | Rust Target Triple (`target`) |
|---|---|---|---|
| **Windows** | `windows-latest` | `x86_64` | `x86_64-pc-windows-msvc` |
| **Windows** | `windows-latest` | `aarch64` | `aarch64-pc-windows-msvc` |
| **Linux** | `ubuntu-latest` | `x86_64` | `x86_64-unknown-linux-gnu` |
| **Linux** | `ubuntu-latest` | `aarch64` | `aarch64-unknown-linux-gnu` (or `musl` variant) |
| **macOS** | `macos-latest` | `x86_64` | `x86_64-apple-darwin` |
| **macOS** | `macos-latest` | `aarch64` | `aarch64-apple-darwin` |

*Note:* macOS targets can be compiled separately and combined into a single universal binary using Apple's `lipo` tool, resolving the architecture distribution complexity.

---

## 4. Cargo Cross-Compilation Tooling

We can achieve cross-compilation validation using standard toolchains:

### macOS (`x86_64` and `aarch64`)
Xcode on macOS supports compiling for both architectures natively out-of-the-box. We do not need a third-party tool.
```bash
# Add targets
rustup target add x86_64-apple-darwin aarch64-apple-darwin

# Build both targets
cargo build --release --target x86_64-apple-darwin
cargo build --release --target aarch64-apple-darwin

# Combine into a single Universal Binary
lipo -create -output bin/forgum-core-mac \
  src-rust/target/x86_64-apple-darwin/release/forgum_core \
  src-rust/target/aarch64-apple-darwin/release/forgum_core
```
This solves the macOS architecture naming mismatch. A single binary `forgum-core-mac` can be shipped and will run natively on both Intel and Apple Silicon machines.

### Windows (ARM64)
The MSVC build tools on Windows runners support compiling for ARM64 natively.
```powershell
# Add target
rustup target add aarch64-pc-windows-msvc

# Compile to ARM64
cargo build --release --target aarch64-pc-windows-msvc
```

### Linux (ARM64)
Cross-compiling for Linux AArch64 requires an ARM64 GNU linker. There are two primary approaches:

#### Option A: Native Toolchain + APT Packages (Recommended for simplicity)
Install the `aarch64-linux-gnu` cross-compiler tools directly on the runner.
```yaml
      - name: Install ARM64 Linker
        run: |
          sudo apt-get update
          sudo apt-get install -y gcc-aarch64-linux-gnu g++-aarch64-linux-gnu
      
      - name: Add Rust Target
        run: rustup target add aarch64-unknown-linux-gnu
        
      - name: Build
        env:
          CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_LINKER: aarch64-linux-gnu-gcc
        run: cd src-rust && cargo build --release --target aarch64-unknown-linux-gnu
```

#### Option B: Containerized Cross-Compilation using `cross`
`cross` wraps compilation inside a container configured with target linkers.
```yaml
      - name: Install Cargo-Cross
        run: cargo install cross --git https://github.com/cross-rs/cross
        
      - name: Build with Cross
        run: cd src-rust && cross build --release --target aarch64-unknown-linux-gnu
```

---

## 5. Non-Native Execution & Simulation Verification

To ensure that the compiled binaries function correctly and do not throw runtime crashes on non-native architectures, we can implement verification checks:

### 1. macOS (Universal / Rosetta 2)
Because the `macos-latest` runner runs on ARM64 macOS hardware, it can run the `aarch64` binary natively. With Rosetta 2 (installed on GitHub runners), it can also execute `x86_64` macOS binaries natively via dynamic binary translation.
- **Verification commands:**
  ```bash
  # Verify native ARM64 binary execution
  ./src-rust/target/aarch64-apple-darwin/release/forgum_core --version
  
  # Verify x86_64 binary execution via Rosetta
  ./src-rust/target/x86_64-apple-darwin/release/forgum_core --version
  ```

### 2. Linux (QEMU Emulation)
On x86_64 Linux runners, we can register QEMU user-space emulation (`qemu-user-static`) to run ARM64 binaries transparently:
- **Setup:**
  ```bash
  sudo apt-get update
  sudo apt-get install -y qemu-user-static binfmt-support
  ```
- **Execution:**
  Since `qemu-user-static` registers handler triggers, executing the ARM64 binary works directly:
  ```bash
  ./src-rust/target/aarch64-unknown-linux-gnu/release/forgum_core --version
  ```
  *(Note: If dynamic link errors occur, direct it to the dynamic linker library path: `qemu-aarch64 -L /usr/aarch64-linux-gnu ./src-rust/target/aarch64-unknown-linux-gnu/release/forgum_core --version`)*.

### 3. Windows (ARM64)
GitHub Windows runners run on x86_64 and do not support executing ARM64 Windows binaries under simulation. For Windows `aarch64-pc-windows-msvc`, we can only verify successful compilation in the pipeline. Execution verification requires a native ARM64 runner.

---

## 6. Environment and Runner Specifics

Key software versions and environment constraints configured in the current project:
- **PowerShell (Pester):**
  - **Pester Version:** Configured to require Pester **v5.7.0 to v5.99.99** (Major version 5).
  - Pester 5 has a distinct lifecycle model (`BeforeAll`, `Context`, `It`) which differs from Pester 4. Custom test blocks must conform to Pester 5 standards.
- **PowerShell Versions:**
  - Tested on **PowerShell 7.4** (cross-platform on Linux, macOS, Windows).
  - Tested on **PowerShell 5.1** (legacy engine on Windows).
- **Rust Toolchain:**
  - Standard stable channel is used (`dtolnay/rust-toolchain@stable`).
  - **Edition:** Rust 2021 Edition (`src-rust/Cargo.toml`).
  - **Dependencies:** Uses `crossterm` (0.27) for raw-mode rendering, `clap` (4.4) for derivation parser logic, and `image` (0.24).
- **CI Safety Checks:**
  - `cargo mutants` runs mutation testing specifically on `src/engine.rs` to detect gaps in unit test coverage.
  - `cargo audit` checks for security vulnerabilities in cargo dependencies.
  - The binary contains a check for the environment variable `CI`. If `CI` is set, the animation loop automatically exits after 60 frames to prevent hanging the runner.
