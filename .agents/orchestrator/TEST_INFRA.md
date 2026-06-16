# E2E Test Infra: Forgum Dynamic Animation Engine

## Test Philosophy
- Opaque-box, requirement-driven. Verify that the dynamic animation engine compiles, loads the correct architecture-specific binary, and executes panic-free across all CI matrix platforms.
- Methodology: 4-tier test case design (Feature Coverage, Boundary/Corner Cases, Cross-Feature Combinations, Real-World Workloads).

## Feature Inventory
| # | Feature | Source Requirement | Tier 1 | Tier 2 | Tier 3 | Tier 4 |
|---|---------|---------------------|:------:|:------:|:------:|:------:|
| 1 | Binary Resolution | R1: Cross-Platform | 5      | 5      | ✓      | ✓      |
| 2 | Argument & Stdin Parsing | R1, R2: Exec verification | 5      | 5      | ✓      | ✓      |
| 3 | Execution Correctness | R2: Cross-Architecture | 5      | 5      | ✓      | ✓      |

## Test Case Design (Tiers 1-4)

### Tier 1: Feature Coverage (≥5 per feature)
1. **Binary Resolution**:
   - T1.BR.1: Resolve Windows x86_64 binary name on Windows (`forgum-core.exe`).
   - T1.BR.2: Resolve Windows ARM64 binary name on Windows (`forgum-core-arm64.exe`) if running on ARM64.
   - T1.BR.3: Resolve Linux x86_64 binary name on Linux (`forgum-core`).
   - T1.BR.4: Resolve Linux ARM64 binary name on Linux (`forgum-core-arm64`) if running on ARM64.
   - T1.BR.5: Resolve macOS Universal binary name on macOS (`forgum-core-mac`).
2. **Arguments & Stdin Parsing**:
   - T1.ARG.1: Stdin piping: Cow ASCII piped successfully.
   - T1.ARG.2: Message option `--message` / `-m` successfully parsed.
   - T1.ARG.3: Animation mode option `--mode` successfully parsed.
   - T1.ARG.4: Version argument `--version` returns correct version.
   - T1.ARG.5: Help argument `--help` prints usage.
3. **Execution Correctness**:
   - T1.EXEC.1: Executing native binary returns exit code 0.
   - T1.EXEC.2: Executing binary in CI automatically exits after 60 frames (via `CI` env variable check).
   - T1.EXEC.3: Executing with non-existent animation mode falls back gracefully.
   - T1.EXEC.4: Executing under emulation (QEMU on Linux) behaves identically to native.
   - T1.EXEC.5: Fallback to legacy static output if binary is missing.

### Tier 2: Boundary & Corner Cases (≥5 per feature)
1. **Inputs & Boundaries**:
   - T2.BND.1: Empty stdin (returns default cow).
   - T2.BND.2: Extremely long message (1000+ characters) to ensure no buffer overflow.
   - T2.BND.3: Executing in a small/constrained terminal window (e.g. 5x5 characters).
   - T2.BND.4: Executing in a completely headless/non-interactive terminal environment.
   - T2.BND.5: Invalid character encodings in message text.

### Tier 3: Cross-Feature Combinations
1. **Interactions**:
   - T3.COMB.1: Mode `disco` + large cow graphic + long message.
   - T3.COMB.2: Mode `bounce` + empty message + custom cow graphic.
   - T3.COMB.3: Mode `talking` + `-m` message + short cow graphic.

### Tier 4: Real-World Workload Testing
1. **Scenarios**:
   - T4.WORK.1: Integration with `Get-Fortune` (pipe fortune directly to `Show-CFAnimation`).
   - T4.WORK.2: Multi-run stress test: invoke the dynamic animation 50 times sequentially.
   - T4.WORK.3: PowerShell profile startup test: load module and invoke animation inside a background task.
