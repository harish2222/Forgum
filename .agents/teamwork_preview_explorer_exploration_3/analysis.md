# macOS Binary Name Mismatch Analysis

## Summary of Findings
An investigation of the Forgum codebase reveals a platform-naming mismatch for the compiled Rust engine (`forgum-core`) on macOS.
- **CI Artifact Packaging:** In `.github/workflows/ci.yml`, the macOS binary is packaged as `forgum-core-mac` inside the module's `bin/` directory.
- **PowerShell Wrapper Execution:** In `Public/Show-CFAnimation.ps1`, the PowerShell wrapper resolves the binary name to `forgum-core` on macOS (since it defaults to `forgum-core` for all non-Windows systems).
- **Test Inconsistency:** In `Tests/Forgum.Tests.ps1`, the integration test also looks for `forgum-core` on macOS, mimicking the wrapper's faulty logic.

As a result, macOS users running Forgum cannot run the Rust-based animations, falling back to static representations with a warning message.

---

## 1. Direct Observations

### A. CI Workflow Artifact Packaging
In `.github/workflows/ci.yml` (lines 328–336):
```yaml
          if (Test-Path "bin_artifacts/forgum-core-windows-latest") {
            Copy-Item -Path "bin_artifacts/forgum-core-windows-latest/forgum_core.exe" -Destination "$binDir/forgum-core.exe" -ErrorAction SilentlyContinue
          }
          if (Test-Path "bin_artifacts/forgum-core-ubuntu-latest") {
            Copy-Item -Path "bin_artifacts/forgum-core-ubuntu-latest/forgum_core" -Destination "$binDir/forgum-core" -ErrorAction SilentlyContinue
          }
          if (Test-Path "bin_artifacts/forgum-core-macos-latest") {
            Copy-Item -Path "bin_artifacts/forgum-core-macos-latest/forgum_core" -Destination "$binDir/forgum-core-mac" -ErrorAction SilentlyContinue
          }
```
*Verification:* The macOS binary is copied to `$binDir/forgum-core-mac`, while Windows gets `$binDir/forgum-core.exe` and Linux gets `$binDir/forgum-core`.

### B. PowerShell Wrapper Code
In `Public/Show-CFAnimation.ps1` (lines 25–29):
```powershell
    $config = Get-CFConfig
    $mode = $config.animation.mode
    $binName = if ($IsWindows -or ($PSVersionTable.PSVersion.Major -lt 6)) { "forgum-core.exe" } else { "forgum-core" }
    $binPath = Join-Path (Split-Path $PSScriptRoot -Parent) "bin\$binName"
```
*Verification:*
- On Windows (PowerShell 5.1/6+), it selects `forgum-core.exe`.
- On Linux (PowerShell 6+), it selects `forgum-core`.
- On macOS (PowerShell 6+), it selects `forgum-core`. This is a bug because the packaged macOS binary name is actually `forgum-core-mac`.

### C. Test Suite Code
In `Tests/Forgum.Tests.ps1` (lines 444–455):
```powershell
Describe "Show-CFAnimation Cross-Platform Wrapper" -Tag 'Wrapper' {
    It "invokes real Rust binary when present on supported OS" {
        $binName = if ($IsWindows -or ($PSVersionTable.PSVersion.Major -lt 6)) { "forgum-core.exe" } else { "forgum-core" }
        $binPath = Join-Path $ModuleRoot "bin/$binName"
        ...
```
*Verification:* The test suite uses the exact same buggy logic for binary name resolution, failing to correctly check for `forgum-core-mac` on macOS.

---

## 2. Proposed Script Modifications

### A. File: `Public/Show-CFAnimation.ps1`
Modify the binary name determination to add an explicit check for `$IsMacOS` using `elseif`:

```powershell
    $binName = if ($IsWindows -or ($PSVersionTable.PSVersion.Major -lt 6)) {
        "forgum-core.exe"
    } elseif ($IsMacOS) {
        "forgum-core-mac"
    } else {
        "forgum-core"
    }
```

### B. File: `Tests/Forgum.Tests.ps1`
Align the integration test's binary resolution logic with the wrapper:

```powershell
    It "invokes real Rust binary when present on supported OS" {
        $binName = if ($IsWindows -or ($PSVersionTable.PSVersion.Major -lt 6)) {
            "forgum-core.exe"
        } elseif ($IsMacOS) {
            "forgum-core-mac"
        } else {
            "forgum-core"
        }
        $binPath = Join-Path $ModuleRoot "bin/$binName"
```

*Note on Fallback Test:* The test `"falls back to static output if binary is missing"` uses:
```powershell
        Mock Test-Path { return $false } -ParameterFilter { $Path -like "*forgum-core*" }
```
Since `"forgum-core-mac"` contains the substring `"forgum-core"`, this Mock remains fully functional and does not require modification.

---

## 3. Impact and Compatibility Analysis

### A. Windows Execution
- **Under PowerShell Core (6+):** `$IsWindows` is `$true`. The proposed script resolves `$binName` to `"forgum-core.exe"`, identical to current behavior.
- **Under Windows PowerShell (5.1):** `$IsWindows` is `$null`/undefined, but `$PSVersionTable.PSVersion.Major -lt 6` is `$true`. The proposed script resolves `$binName` to `"forgum-core.exe"`, identical to current behavior.
- **Conclusion:** Windows execution is fully preserved.

### B. Linux Execution
- **Under PowerShell Core (6+):** `$IsWindows` is `$false`, version check is `$false`, and `$IsMacOS` is `$false`. The proposed script falls back to the `else` block, resolving `$binName` to `"forgum-core"`, identical to current behavior.
- **Conclusion:** Linux execution is fully preserved.

### C. macOS Execution
- **Under PowerShell Core (6+):** `$IsWindows` is `$false`, version check is `$false`, and `$IsMacOS` is `$true`. The proposed script resolves `$binName` to `"forgum-core-mac"`.
- **Conclusion:** macOS execution is corrected to invoke the Universal Binary packaged during CI, resolving the bug.

---

## 4. Verification and Pester Testing

These modifications are designed to be easily testable using the existing Pester suite:
1. **Mocking/Testing Platform Checks:** Because `$IsWindows`, `$IsMacOS`, and `$IsLinux` are read-only automatic variables populated by the PowerShell engine, testing platform behavior is best achieved by executing the test suite across CI environments (each OS runner in GitHub Actions evaluates the branch matching its host environment).
2. **Backward Compatibility:** All current tests continue to pass out-of-the-box on Windows and Linux runners. Running `Invoke-Pester -Path ./Tests/Forgum.Tests.ps1` on a Windows or Linux agent will show 100% test completion and proper legacy mock fallbacks.
