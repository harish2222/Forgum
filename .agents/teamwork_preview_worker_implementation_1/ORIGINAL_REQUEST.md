## 2026-06-17T01:10:22Z

Your task is to implement the cross-platform and cross-architecture matrix testing requirements:

1. **PowerShell Wrapper Script Refactoring:**
   Modify `Public/Show-CFAnimation.ps1` to detect the platform OS and CPU architecture.
   - Detect OS using `$IsWindows`, `$IsMacOS`, or defaults.
   - Detect architecture using `$env:PROCESSOR_ARCHITECTURE` (on Windows) or `[System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture` (on Unix).
   - If architecture is ARM64/Arm64:
     - On Windows: resolve binary to `forgum-core-arm64.exe`
     - On Linux: resolve binary to `forgum-core-arm64`
   - If architecture is x86_64/X64:
     - On Windows: resolve binary to `forgum-core.exe`
     - On Linux: resolve binary to `forgum-core`
   - On macOS: resolve binary to `forgum-core-mac` (the Universal binary).
   - Include a fallback check: if the architecture-specific binary name is not found in the `bin/` folder, check for the generic names (`forgum-core.exe` or `forgum-core` at the `bin/` root) to preserve compatibility with native local development builds.

2. **Pester Test Refactoring:**
   Modify the binary name resolution in `Tests/Forgum.Tests.ps1` (under `Describe "Show-CFAnimation Cross-Platform Wrapper"`) to use the exact same OS and architecture resolution logic as `Show-CFAnimation.ps1`. This ensures Pester executes the right binary in the CI runner.

3. **CI Matrix Testing Expansion:**
   Modify `.github/workflows/ci.yml`:
   - Expand the matrix compilation and testing to support cross-compiling and executing the six target triples:
     1. `x86_64-pc-windows-msvc`
     2. `aarch64-pc-windows-msvc`
     3. `x86_64-unknown-linux-gnu`
     4. `aarch64-unknown-linux-gnu`
     5. `x86_64-apple-darwin`
     6. `aarch64-apple-darwin`
   - Refactor the `test` job to build and upload these targets as artifacts under descriptive target names (e.g. `forgum-core-x86_64-pc-windows-msvc`, etc.).
     - On `windows-latest`, build both MSVC targets (`rustup target add aarch64-pc-windows-msvc` and `cargo build --release --target aarch64-pc-windows-msvc`).
     - On `ubuntu-latest`, install cross-linker `gcc-aarch64-linux-gnu` and cross-compile `aarch64-unknown-linux-gnu` target (`CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_LINKER=aarch64-linux-gnu-gcc cargo build --release --target ...`).
     - On `macos-latest`, add and compile both target architectures.
   - Refactor test verification steps in the `test` job:
     - On `ubuntu-latest`, install `qemu-user-static` and `binfmt-support`. Verify the `aarch64` binary runs without panic (e.g. `--version`). Run Pester tests which will automatically run the native/emulated binaries.
     - On `macos-latest`, run Pester tests.
     - On `windows-latest`, run Pester tests for x64.
   - Refactor the `build` release packaging job to run on `macos-latest` (to access `lipo`), download all target artifacts, and package them as follows:
     - `bin/forgum-core.exe` (Windows x64)
     - `bin/forgum-core-arm64.exe` (Windows ARM64)
     - `bin/forgum-core` (Linux x64)
     - `bin/forgum-core-arm64` (Linux ARM64)
     - `bin/forgum-core-mac` (Universal macOS binary merged using `lipo -create -output ...`).

4. **Verify Implementation:**
   - Verify that your changes compile successfully and that existing/updated tests pass.
   - Document the steps you took and the test results in `D:\Projects\Forgum\.agents\teamwork_preview_worker_implementation_1\handoff.md`.
