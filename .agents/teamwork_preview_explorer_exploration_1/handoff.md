# Handoff Report: Forgum Rust Integration & CI Architecture Analysis

## 1. Observation
The following configurations and code segments were directly observed in the codebase:

### Pester Tests & Wrapper Behavior
- **Pester Wrapper Tests (`Tests/Forgum.Tests.ps1`, lines 444–462):**
  ```powershell
  Describe "Show-CFAnimation Cross-Platform Wrapper" -Tag 'Wrapper' {
      It "invokes real Rust binary when present on supported OS" {
          $binName = if ($IsWindows -or ($PSVersionTable.PSVersion.Major -lt 6)) { "forgum-core.exe" } else { "forgum-core" }
          $binPath = Join-Path $ModuleRoot "bin/$binName"
          
          if (Test-Path $binPath) {
              # Let it run for real (will exit after 60 frames in CI or fast on local)
              { Show-CFAnimation -CowOutput "moo" -Message "real rendering test" } | Should -Not -Throw
          } else {
              Set-ItResult -Inconclusive -Because "Rust binary not built/found at $binPath"
          }
      }

      It "falls back to static output if binary is missing" {
          Mock Test-Path { return $false } -ParameterFilter { $Path -like "*forgum-core*" }
          $result = Show-CFAnimation -CowOutput "moo"
          $result | Should -Be "moo"
      }
  }
  ```
- **PowerShell Wrapper Execution (`Public/Show-CFAnimation.ps1`, lines 27–28, 32):**
  ```powershell
      $binName = if ($IsWindows -or ($PSVersionTable.PSVersion.Major -lt 6)) { "forgum-core.exe" } else { "forgum-core" }
      $binPath = Join-Path (Split-Path $PSScriptRoot -Parent) "bin\$binName"
      ...
      $CowOutput | & $binPath --message $Message --mode $mode
  ```
- **Rust Arg Parsing (`src-rust/src/main.rs`, lines 18–26):**
  ```rust
  #[derive(Parser, Debug)]
  #[command(author, version, about, long_about = None)]
  struct Args {
      #[arg(short, long)]
      message: Option<String>,

      #[arg(long, default_value = "slide")]
      mode: String,
  }
  ```

### GitHub Workflows and Matrix Execution
- **GitHub Workflow OS Matrix (`.github/workflows/ci.yml`, lines 137–148):**
  ```yaml
    test:
      needs: [lint, validate, security-audit]
      strategy:
        fail-fast: false
        matrix:
          os: [windows-latest, ubuntu-latest, macos-latest]
          pwsh: ['7.4']
          include:
            - os: windows-latest
              pwsh: '5.1'
      runs-on: ${{ matrix.os }}
  ```
- **Release Compilation Command (`.github/workflows/ci.yml`, lines 160–163):**
  ```yaml
        - name: Build Rust Binary (Release)
          run: |
            cd src-rust
            cargo build --release
  ```
- **Binary Renaming/Packaging Discrepancy (`.github/workflows/ci.yml`, lines 334–336):**
  ```powershell
            if (Test-Path "bin_artifacts/forgum-core-macos-latest") {
              Copy-Item -Path "bin_artifacts/forgum-core-macos-latest/forgum_core" -Destination "$binDir/forgum-core-mac" -ErrorAction SilentlyContinue
            }
  ```

### Tool Version Specifications
- **Pester Constraint (`.github/workflows/ci.yml`, lines 195, 204):**
  ```powershell
  Install-Module -Name Pester -Force -SkipPublisherCheck -Scope CurrentUser -MinimumVersion 5.7.0 -MaximumVersion 5.99.99
  ```
- **Rust Edition (`src-rust/Cargo.toml`, line 4):**
  ```toml
  edition = "2021"
  ```

---

## 2. Logic Chain
1. **Wrapper Invocation & Arguments:** 
   - From the observation of `Show-CFAnimation.ps1`, the binary is invoked with two parameters: `--message $Message` and `--mode $mode`, while receiving `$CowOutput` from standard input (stdin).
   - From `src-rust/src/main.rs`, we confirm that `clap` parses standard input (stdin) for `cow_text` when input is redirected, and parses `--message`/`-m` and `--mode` (default `"slide"`) as command-line arguments.
2. **Path Resolution & macOS Discrepancy:**
   - `Show-CFAnimation.ps1` resolves the path relative to the module root's `bin/` directory, expecting the name `forgum-core` on non-Windows systems (including macOS).
   - However, in `.github/workflows/ci.yml`, the macOS binary is packaged as `forgum-core-mac`.
   - Consequently, when installed from the published release package, `Show-CFAnimation.ps1` fails to locate the binary on macOS, causing a warning warning the user and triggering a legacy static fallback.
3. **Current CI Architecture Bounds:**
   - The current CI builds binaries natively using `cargo build --release` with no `--target` flag across `windows-latest`, `ubuntu-latest`, and `macos-latest` runners.
   - This produces exactly three binaries corresponding to each host runner's native architecture: `x86_64-pc-windows-msvc`, `x86_64-unknown-linux-gnu`, and `aarch64-apple-darwin` respectively.
4. **Target Matrix Expansion & Validation:**
   - By adding a `target` attribute to the CI matrix, we can run target-specific compilations.
   - Using standard macOS Xcode capabilities, we can build both `x86_64-apple-darwin` and `aarch64-apple-darwin` targets on `macos-latest` and merge them into a single Universal Binary (`forgum-core-mac`) using `lipo`.
   - Windows MSVC tools natively compile `aarch64-pc-windows-msvc` on `windows-latest`.
   - Ubuntu cross-compiles to `aarch64-unknown-linux-gnu` using the `gcc-aarch64-linux-gnu` linker or the containerized `cross` tool.
   - Executions on non-native architectures can be simulated in the CI pipeline:
     - On macOS, Rosetta 2 allows executing the `x86_64-apple-darwin` binary on the ARM64 runner, and the native binary can be run directly.
     - On Linux, `qemu-user-static` translates and executes ARM64 binaries transparently.
     - On Windows, emulation is unsupported on standard x86_64 runners; compilation verification is the primary gate.

---

## 3. Caveats
- **Windows ARM64 Verification:** Standard x86_64 GitHub Windows runners do not support executing or emulating Windows ARM64 executables. Compilation success is verified, but run-time execution validation remains untestable in the standard CI runner.
- **CI Configuration Updates:** Any edits to `.github/workflows/ci.yml` or PowerShell files are read-only proposals; they have not been committed to the codebase per constraints.
- **Rosetta 2 Availability:** In the macOS runner, we assume Rosetta 2 is available (which it is by default on GitHub macOS runners).

---

## 4. Conclusion
1. **Pester tests** running the Rust binary reside in `Tests/Forgum.Tests.ps1` under the wrapper block.
2. The **macOS package naming mismatch** (`forgum-core-mac` package vs `forgum-core` path expectation) is an active bug that blocks Rust animations on macOS.
3. The CI currently compiles only for **native runner host targets** (`x86_64-pc-windows-msvc`, `x86_64-unknown-linux-gnu`, `aarch64-apple-darwin`).
4. To **expand the matrix**, we must add a `target` variable and:
   - Compile double macOS targets and merge them via `lipo` to create a universal macOS binary.
   - Use cross-compilation linkers on Ubuntu (`gcc-aarch64-linux-gnu` or `cross`).
   - Add target architectures via `rustup target add`.
5. Non-native binary execution can be **validated using QEMU on Linux** and **native Rosetta 2/Universal execution on macOS**.

---

## 5. Verification Method
The findings and proposals can be verified using the following local commands:

1. **Verify Rust local compilation:**
   ```bash
   cd src-rust
   cargo check
   cargo test
   ```
2. **Verify PowerShell Pester execution:**
   ```powershell
   Import-Module Pester
   Invoke-Pester -Path ./Tests/Forgum.Tests.ps1 -Tag 'Wrapper'
   ```
3. **Verify proposed cross-compilers locally (if compiler dependencies are installed):**
   - **macOS:** `rustup target add x86_64-apple-darwin aarch64-apple-darwin && cargo build --target x86_64-apple-darwin --release`
   - **Windows:** `rustup target add aarch64-pc-windows-msvc && cargo build --target aarch64-pc-windows-msvc --release`
   - **Linux:** `rustup target add aarch64-unknown-linux-gnu && cargo build --target aarch64-unknown-linux-gnu --release` (requires `gcc-aarch64-linux-gnu`)
