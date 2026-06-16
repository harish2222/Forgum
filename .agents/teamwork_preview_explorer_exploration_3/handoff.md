# Handoff Report: macOS Binary Name Mismatch Investigation

## 1. Observation
In `.github/workflows/ci.yml` (line 335), the macOS binary is packaged with the name `forgum-core-mac`:
```yaml
          if (Test-Path "bin_artifacts/forgum-core-macos-latest") {
            Copy-Item -Path "bin_artifacts/forgum-core-macos-latest/forgum_core" -Destination "$binDir/forgum-core-mac" -ErrorAction SilentlyContinue
          }
```
However, in `Public/Show-CFAnimation.ps1` (line 27), the PowerShell wrapper only distinguishes between Windows and non-Windows systems:
```powershell
    $binName = if ($IsWindows -or ($PSVersionTable.PSVersion.Major -lt 6)) { "forgum-core.exe" } else { "forgum-core" }
```
Additionally, `Tests/Forgum.Tests.ps1` (line 446) mirrors the wrapper's name-resolution logic:
```powershell
        $binName = if ($IsWindows -or ($PSVersionTable.PSVersion.Major -lt 6)) { "forgum-core.exe" } else { "forgum-core" }
```
Running `Invoke-Pester -Path ./Tests/Forgum.Tests.ps1` completes successfully (42 Passed, 1 Inconclusive due to missing local binary).

---

## 2. Logic Chain
1. **Package Target Mismatch:** The macOS artifact is packaged as `forgum-core-mac`, but the wrapper looks for `forgum-core` on macOS (since macOS is non-Windows).
2. **Execution Failure:** On macOS, the wrapper fails the `Test-Path $binPath` check. It outputs a warning: `"WARNING: forgum-core not found, falling back to static"`.
3. **Correct Platform Check:** To resolve this, we can utilize `$IsMacOS`, which is a built-in automatic variable available in PowerShell Core (6+). Because macOS only runs PowerShell Core, `$IsMacOS` will reliably evaluate to `$true` on macOS.
4. **Impact Analysis:** 
   - Windows returns `$true` for `$IsWindows` (or `$PSVersionTable.PSVersion.Major -lt 6`), selecting `"forgum-core.exe"`.
   - Linux returns `$false` for `$IsWindows`, `$false` for version check, and `$false` for `$IsMacOS`, selecting `"forgum-core"`.
   - macOS returns `$false` for `$IsWindows`, `$false` for version check, and `$true` for `$IsMacOS`, selecting `"forgum-core-mac"`.
5. **No Regression:** Therefore, this adjustment retains the correct paths on Windows and Linux while fixing the path resolution on macOS.

---

## 3. Caveats
- No caveats. The proposed changes are localized, standard PowerShell conventions, and have no side effects on configuration or formatting logic.

---

## 4. Conclusion
The macOS binary mismatch is caused by the wrapper and the test suite targeting `forgum-core` instead of `forgum-core-mac` on macOS. Modifying both `Public/Show-CFAnimation.ps1` and `Tests/Forgum.Tests.ps1` to include `elseif ($IsMacOS) { "forgum-core-mac" }` resolves the issue without breaking Windows or Linux functionality.

---

## 5. Verification Method
After applying the changes to `Public/Show-CFAnimation.ps1` and `Tests/Forgum.Tests.ps1`:
1. Run the project Pester test suite to ensure no regressions:
   ```powershell
   Invoke-Pester -Path ./Tests/Forgum.Tests.ps1
   ```
2. In a macOS environment containing the built binary:
   - Verify that `$binDir/forgum-core-mac` is successfully targeted by running:
     ```powershell
     Show-CFAnimation -CowOutput "moo" -Message "test"
     ```
   - Confirm it runs the Rust binary rather than falling back to legacy static mode.
