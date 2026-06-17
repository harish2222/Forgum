# Handoff Report

## 1. Observation
*   **File**: `Public/Show-CFAnimation.ps1` (Lines 41, 44)
    *   *Code snippet*:
        ```powershell
        $binPath = Join-Path (Split-Path $PSScriptRoot -Parent) "bin\$binName"
        ...
        $fallbackPath = Join-Path (Split-Path $PSScriptRoot -Parent) "bin\$fallbackName"
        ```
    *   *Issue*: The use of a backslash (`\`) in `"bin\$binName"` and `"bin\$fallbackName"` works on Windows, but on Linux and macOS, it treats the backslash as a literal character in the file name (e.g. `bin\forgum-core`). As a result, `Test-Path` returns `$false` on Unix platforms, causing `Show-CFAnimation` to always fall back to legacy static rendering, completely bypassing the compiled Rust binary.
*   **File**: `Tests/Forgum.Tests.ps1` (Line 477)
    *   *Code snippet*:
        ```powershell
        Mock Test-Path { return $false } -ParameterFilter { $Path -like "*forgum-core*" }
        ```
    *   *Issue*: The `Mock` command does not specify the `-ModuleName Forgum` parameter. Because the mock is defined in the script scope rather than the module scope, the calls to `Test-Path` inside `Show-CFAnimation` (which resides inside the `Forgum` module session state) are not mocked. The test passes only because the binary is physically absent during testing, causing the real `Test-Path` to return `$false`. If the binary were present in the repository, the test would fail.
*   **File**: `.github/workflows/ci.yml` (Lines 21-28)
    *   *Code snippet*:
        ```yaml
        cargo install cargo-audit
        ...
        cargo install cargo-mutants
        ```
    *   *Issue*: Compiling `cargo-audit` and `cargo-mutants` from source on every CI run adds ~10–15 minutes of unnecessary compilation overhead. Caching or using action installers (e.g., `taiki-e/install-action`) would download pre-built binaries in seconds.
*   **File**: `.github/workflows/ci.yml` (Lines 181-184)
    *   *Code snippet*:
        ```yaml
        cargo build --release --target aarch64-pc-windows-msvc
        ```
    *   *Issue*: The Windows ARM64 build is executed twice (once on the `pwsh: 7.4` matrix configuration and once on `pwsh: 5.1`). Since ARM64 is not executable on the x86_64 test runner and the binary artifact is only uploaded in the `pwsh: 7.4` job, compiling the ARM64 binary in the `pwsh: 5.1` job is redundant.
*   **File**: `.github/workflows/ci.yml` (Lines 446-447)
    *   *Code snippet*:
        ```yaml
        Compress-Archive -Path "$stagingDir/*" -DestinationPath $zipPath -Force
        ```
    *   *Issue*: PowerShell's `Compress-Archive` does not preserve Unix permission bits (specifically execution permissions, `chmod +x`). When users download and unpack the release zip on macOS or Linux, they will receive "permission denied" errors when invoking the binaries.

## 2. Logic Chain
1.  **Platform Resolution**: On Unix (Linux/macOS), the file system treats the backslash (`\`) as a literal character in filenames instead of a directory separator. Constructing `$binPath` using `"bin\$binName"` yields `/path/to/Forgum/bin\forgum-core` which does not match the actual folder structure. This causes `Test-Path` inside the function to fail, forcing the runtime to fall back to legacy static mode.
2.  **Test Isolation Gap**: Because Pester executes module tests in the module's session state, mocking global cmdlets (like `Test-Path`) without specifying `-ModuleName <ModuleName>` fails to intercept calls originating from inside module functions. The test passes only because the physical absence of the binary returns `$false` natively.
3.  **CI Inefficiencies & Packaging Bugs**:
    *   Building the ARM64 Windows binary in the `pwsh: 5.1` test runner serves no purpose, since it is not tested and the build artifacts are discarded (only uploaded on `pwsh: 7.4`).
    *   Using `Compress-Archive` strip Unix file permissions, leading to user friction upon deployment.
    *   Compiling CLI tooling on every build runs against optimization practices.

## 3. Caveats
*   Local command execution was skipped due to a permission timeout in the runtime environment. Findings are based on rigorous static code review and logic analysis.
*   The actual behavior of `Compress-Archive` with execution permissions on older PowerShell/macOS runner versions has been analyzed based on standard cross-platform PowerShell behavior.

## 4. Conclusion
**Verdict**: **REQUEST_CHANGES** (Reject)
*   The implementation contains a critical platform resolution bug that prevents the module from executing the compiled Rust engine on Linux and macOS.
*   The test suite contains a scope validation bug that masks the platform bug in tests.
*   The CI pipeline has significant build inefficiencies and a packaging bug that strips Unix executable permissions.

## 5. Verification Method
1.  **Verify Platform Bug**:
    *   In a Unix environment (or Linux terminal), run the command:
        ```powershell
        Join-Path "/home" "bin\forgum-core"
        ```
    *   Note that it outputs `/home/bin\forgum-core` rather than `/home/bin/forgum-core`.
2.  **Verify Test Isolation**:
    *   Modify `Tests/Forgum.Tests.ps1` to place a dummy file at `bin/forgum-core`.
    *   Run Pester tests and observe that `falls back to static output if binary is missing` fails because the mock is ignored.
3.  **Verify Packaging Permission loss**:
    *   Inspect a release `.zip` generated by the workflow on macOS and note the missing executable flags on the binaries when extracted.

---

## Appendix: Quality Review

**Verdict**: REQUEST_CHANGES

### Findings

#### [Critical] Finding 1: Broken Unix Path Resolution
*   **Where**: `Public/Show-CFAnimation.ps1` (Lines 41, 44)
*   **Why**: Path separators are hardcoded as backslashes (`\`), which prevents resolution of binary paths on Linux/macOS.
*   **Suggestion**: Use forward slash `/` in `Join-Path` or specify separate segments:
    ```powershell
    $binPath = Join-Path (Split-Path $PSScriptRoot -Parent) "bin" $binName
    ```
    Or use `[IO.Path]::Combine()`.

#### [Major] Finding 2: Ineffective Test Mock
*   **Where**: `Tests/Forgum.Tests.ps1` (Line 477)
*   **Why**: `Mock Test-Path` is declared without `-ModuleName Forgum`, meaning the cmdlet is not mocked within the module context.
*   **Suggestion**: Add `-ModuleName Forgum` to the `Mock` call:
    ```powershell
    Mock Test-Path { return $false } -ModuleName Forgum -ParameterFilter { $Path -like "*forgum-core*" }
    ```

#### [Major] Finding 3: Executable Permissions Lost in Zip Packaging
*   **Where**: `.github/workflows/ci.yml` (Line 447)
*   **Why**: `Compress-Archive` strips Unix permissions.
*   **Suggestion**: Use standard Unix `zip` command in the macOS build runner:
    ```bash
    zip -r ../Forgum-v$version.zip .
    ```

#### [Minor] Finding 4: Redundant ARM64 Compilations
*   **Where**: `.github/workflows/ci.yml` (Lines 181-184)
*   **Why**: ARM64 Windows binaries are built under the `pwsh: 5.1` job, which is a duplicate of the build done on `pwsh: 7.4` and cannot be tested or uploaded.
*   **Suggestion**: Skip the ARM64 build on `pwsh: 5.1`.

#### [Minor] Finding 5: Tooling Installation Slows Down CI
*   **Where**: `.github/workflows/ci.yml` (Lines 21-28)
*   **Why**: `cargo install` of audit and mutants compiles from source, wasting ~15 minutes of runner time.
*   **Suggestion**: Use `taiki-e/install-action` or similar pre-built options.

---

## Appendix: Adversarial Review

**Overall risk assessment**: MEDIUM (due to regression in Linux/macOS binary usage and broken packaging).

### Challenges

#### [High] Challenge 1: Silent Fallback Masking Failures
*   **Assumption challenged**: Assuming that tests verify binary execution.
*   **Attack scenario**: If the Rust binary is corrupted, missing, or fails to resolve, the module silently falls back to legacy mode and outputs plain text. The user gets no indication of the failure, and the test suite reports 100% success.
*   **Blast radius**: High. Users expecting animated output will get static text with no logs or visible warnings (unless they manually check for warnings).
*   **Mitigation**: Modify the tests to explicitly inspect the output formatting/coloring when running in binary mode, or assert that a warning is *not* emitted when the binary is expected to run.

#### [Medium] Challenge 2: Shell/Terminal Compatibility of the Call Operator
*   **Assumption challenged**: Assuming `$CowOutput | & $binPath --message $Message --mode $mode` works identically across all shells.
*   **Attack scenario**: In PowerShell 5.1, executing native binaries with pipe redirection sometimes buffers output or handles encoding incorrectly (e.g., converting UTF-8 to ANSI).
*   **Blast radius**: Medium. Special character corruption in fortune messages.
*   **Mitigation**: Standardize output encoding via `[Console]::OutputEncoding` in the module entry points.
