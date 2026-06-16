# Target Compilation Triples Support Analysis

This report analyzes the current GitHub Actions CI configuration for Forgum and details the exact changes needed to build, package, and release `forgum-core` binaries for six target compilation triples.

---

## 1. Examination of the Current CI Configuration

### Current Pipeline Overview
The existing `.github/workflows/ci.yml` is structured as follows:
- **`security-audit`**: Runs `cargo audit`, `cargo mutants`, and `PSScriptAnalyzer`.
- **`lint`**: Performs static analysis on PowerShell files.
- **`validate`**: Validates the module manifest, module exports, cow templates, and animations.
- **`test`**: Runs integration and Pester tests on a matrix (`windows-latest`, `ubuntu-latest`, `macos-latest`). During this step, the Rust core binary is compiled natively on each host platform and uploaded as `forgum-core-${{ matrix.os }}`.
- **`perf-gate`**: Re-builds the Rust binary on `windows-latest` and measures execution time to ensure startup remains under `15.0s`.
- **`build`**: Runs on GitHub tags matching `v*`. It downloads the three host binaries from the `test` job and packages them into the root of `bin/` inside the final ZIP package:
  - `bin/forgum-core.exe` (Windows x64)
  - `bin/forgum-core` (Linux x64)
  - `bin/forgum-core-mac` (macOS - depends on the architecture of the runner used)

### Current Limitations
1. **Architecture Suffix Mismatch**: The macOS binary is uploaded as `forgum-core-mac`, but the wrapper loader in `Public/Show-CFAnimation.ps1` expects it to be named `forgum-core`.
2. **Missing ARM64 Support**: The current pipeline does not build or package binaries for ARM64 architectures (`aarch64`) on Windows, Linux, or macOS.

---

## 2. Target Compilation Triples
The target compilation triples to introduce are:
1. `x86_64-pc-windows-msvc` (Windows x64)
2. `aarch64-pc-windows-msvc` (Windows ARM64)
3. `x86_64-unknown-linux-gnu` (Linux x64)
4. `aarch64-unknown-linux-gnu` (Linux ARM64)
5. `x86_64-apple-darwin` (macOS Intel)
6. `aarch64-apple-darwin` (macOS Apple Silicon)

---

## 3. Proposed YAML Structural Changes

We introduce a new parallel CI job, `build-binaries`, that runs on a matrix to compile all six target triples.

### Option A: dedicated `build-binaries` matrix job
This job executes in parallel with the tests. The `build` packaging job then depends on it and packages the results.

```yaml
  build-binaries:
    needs: [lint, validate, security-audit]
    runs-on: ${{ matrix.os }}
    strategy:
      fail-fast: false
      matrix:
        include:
          - target: x86_64-pc-windows-msvc
            os: windows-latest
            binary_name: forgum_core.exe
            artifact_name: forgum-core-x86_64-pc-windows-msvc
          - target: aarch64-pc-windows-msvc
            os: windows-latest
            binary_name: forgum_core.exe
            artifact_name: forgum-core-aarch64-pc-windows-msvc
          - target: x86_64-unknown-linux-gnu
            os: ubuntu-latest
            binary_name: forgum_core
            artifact_name: forgum-core-x86_64-unknown-linux-gnu
          - target: aarch64-unknown-linux-gnu
            os: ubuntu-latest
            binary_name: forgum_core
            artifact_name: forgum-core-aarch64-unknown-linux-gnu
          - target: x86_64-apple-darwin
            os: macos-latest
            binary_name: forgum_core
            artifact_name: forgum-core-x86_64-apple-darwin
          - target: aarch64-apple-darwin
            os: macos-latest
            binary_name: forgum_core
            artifact_name: forgum-core-aarch64-apple-darwin
    name: Compile Rust (${{ matrix.target }})
    steps:
      - uses: actions/checkout@v4

      - name: Setup Rust
        uses: dtolnay/rust-toolchain@stable
        with:
          targets: ${{ matrix.target }}

      - name: Install Cross Compiler (Linux ARM64)
        if: matrix.target == 'aarch64-unknown-linux-gnu'
        run: |
          sudo apt-get update
          sudo apt-get install -y gcc-aarch64-linux-gnu g++-aarch64-linux-gnu

      - name: Build Binary
        run: |
          cd src-rust
          cargo build --release --target ${{ matrix.target }}
        shell: bash
        env:
          CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_LINKER: aarch64-linux-gnu-gcc

      - name: Upload Binary Artifact
        uses: actions/upload-artifact@v4
        with:
          name: ${{ matrix.artifact_name }}
          path: src-rust/target/${{ matrix.target }}/release/${{ matrix.binary_name }}
          if-no-files-found: error
```

---

## 4. Recommendations for Naming and Packaging

We recommend organizing the binary artifacts into **architecture-specific directories** under `bin/`. This allows keeping the binary filenames uniform (matching the OS conventions), while supporting backwards-compatibility for local manual compilations.

### Recommended Directory Structure for the Release Zip
```
Forgum/
├── Forgum.psd1
├── Forgum.psm1
├── bin/
│   ├── win-x64/forgum-core.exe
│   ├── win-arm64/forgum-core.exe
│   ├── linux-x64/forgum-core
│   ├── linux-arm64/forgum-core
│   └── osx/forgum-core               <-- macOS Universal Binary (x86_64 + ARM64 merged)
├── Public/
├── Private/
├── Data/
└── ...
```

### Strategy 1: Universal macOS Binary Packaging (Recommended)
This approach runs the `build` (packaging) job on `macos-latest` to access Xcode's `lipo` utility, merging macOS Intel and Apple Silicon binaries into a single fat binary.

#### YAML Modification for `build` Job (Strategy 1):
```yaml
  build:
    needs: [test, perf-gate, build-binaries]
    if: startsWith(github.ref, 'refs/tags/v')
    runs-on: macos-latest
    name: Build and Package Release
    permissions:
      contents: write
    steps:
      - uses: actions/checkout@v4

      - name: Get version from tag
        id: version
        run: echo "tag=${GITHUB_REF#refs/tags/v}" >> $GITHUB_OUTPUT

      - name: Download Rust binaries
        uses: actions/download-artifact@v4
        with:
          path: bin_artifacts

      - name: Create release package
        shell: pwsh
        run: |
          $version = '${{ steps.version.outputs.tag }}'
          $stagingDir = Join-Path $env:RUNNER_TEMP "Forgum-v$version"
          New-Item -ItemType Directory -Path $stagingDir -Force | Out-Null
          
          # Copy module files
          Copy-Item -Path "./${{ env.MODULE_NAME }}.psd1" -Destination $stagingDir
          Copy-Item -Path "./${{ env.MODULE_NAME }}.psm1" -Destination $stagingDir
          Copy-Item -Path "./Private" -Destination $stagingDir -Recurse
          Copy-Item -Path "./Public" -Destination $stagingDir -Recurse
          Copy-Item -Path "./Data" -Destination $stagingDir -Recurse
          Copy-Item -Path "./LICENSE" -Destination $stagingDir
          Copy-Item -Path "./README.md" -Destination $stagingDir
          Copy-Item -Path "./install.ps1" -Destination $stagingDir
          Copy-Item -Path "./install.sh" -Destination $stagingDir
          Copy-Item -Path "./uninstall.ps1" -Destination $stagingDir
          
          # Setup bin directory with compiled artifacts
          $binDir = Join-Path $stagingDir "bin"
          New-Item -ItemType Directory -Path $binDir -Force | Out-Null
          
          # Create subdirectory structures
          $winX64Dir = New-Item -ItemType Directory -Path (Join-Path $binDir "win-x64") -Force | Out-Null
          $winArm64Dir = New-Item -ItemType Directory -Path (Join-Path $binDir "win-arm64") -Force | Out-Null
          $linuxX64Dir = New-Item -ItemType Directory -Path (Join-Path $binDir "linux-x64") -Force | Out-Null
          $linuxArm64Dir = New-Item -ItemType Directory -Path (Join-Path $binDir "linux-arm64") -Force | Out-Null
          $osxDir = New-Item -ItemType Directory -Path (Join-Path $binDir "osx") -Force | Out-Null

          # Copy Windows binaries
          Copy-Item -Path "bin_artifacts/forgum-core-x86_64-pc-windows-msvc/forgum_core.exe" -Destination (Join-Path $binDir "win-x64/forgum-core.exe") -Force
          Copy-Item -Path "bin_artifacts/forgum-core-aarch64-pc-windows-msvc/forgum_core.exe" -Destination (Join-Path $binDir "win-arm64/forgum-core.exe") -Force

          # Copy Linux binaries
          Copy-Item -Path "bin_artifacts/forgum-core-x86_64-unknown-linux-gnu/forgum_core" -Destination (Join-Path $binDir "linux-x64/forgum-core") -Force
          Copy-Item -Path "bin_artifacts/forgum-core-aarch64-unknown-linux-gnu/forgum_core" -Destination (Join-Path $binDir "linux-arm64/forgum-core") -Force

          # Create macOS Universal Binary using lipo
          $x64MacPath = "bin_artifacts/forgum-core-x86_64-apple-darwin/forgum_core"
          $arm64MacPath = "bin_artifacts/forgum-core-aarch64-apple-darwin/forgum_core"
          $universalMacPath = Join-Path $binDir "osx/forgum-core"
          
          Write-Host "Creating macOS Universal Binary..."
          lipo -create -output $universalMacPath $x64MacPath $arm64MacPath
          
          # Create zip
          $zipPath = Join-Path $env:RUNNER_TEMP "Forgum-v$version.zip"
          Compress-Archive -Path "$stagingDir/*" -DestinationPath $zipPath -Force
          
          Write-Host "Package created: $zipPath"
          Copy-Item $zipPath ./Forgum-v$version.zip

      - name: Upload build artifact
        uses: actions/upload-artifact@v4
        with:
          name: Forgum-v${{ steps.version.outputs.tag }}
          path: Forgum-v*.zip

      - name: Create GitHub Release
        uses: softprops/action-gh-release@v3
        with:
          name: "Forgum v${{ steps.version.outputs.tag }}"
          generate_release_notes: true
          files: Forgum-v*.zip
```

---

### Strategy 2: Standalone Platform Directories (Alternative)
This approach keeps the `build` (packaging) job running on `ubuntu-latest` to save macOS GitHub action minutes. However, macOS users will have separate `osx-x64` and `osx-arm64` directories, and the PowerShell loader must detect architecture for macOS as well.

#### YAML Modification for `build` Job (Strategy 2):
```yaml
  build:
    needs: [test, perf-gate, build-binaries]
    if: startsWith(github.ref, 'refs/tags/v')
    runs-on: ubuntu-latest
    name: Build and Package Release
    permissions:
      contents: write
    steps:
      - uses: actions/checkout@v4

      - name: Get version from tag
        id: version
        run: echo "tag=${GITHUB_REF#refs/tags/v}" >> $GITHUB_OUTPUT

      - name: Download Rust binaries
        uses: actions/download-artifact@v4
        with:
          path: bin_artifacts

      - name: Create release package
        shell: pwsh
        run: |
          $version = '${{ steps.version.outputs.tag }}'
          $stagingDir = Join-Path $env:RUNNER_TEMP "Forgum-v$version"
          New-Item -ItemType Directory -Path $stagingDir -Force | Out-Null
          
          # Copy module files
          Copy-Item -Path "./${{ env.MODULE_NAME }}.psd1" -Destination $stagingDir
          Copy-Item -Path "./${{ env.MODULE_NAME }}.psm1" -Destination $stagingDir
          Copy-Item -Path "./Private" -Destination $stagingDir -Recurse
          Copy-Item -Path "./Public" -Destination $stagingDir -Recurse
          Copy-Item -Path "./Data" -Destination $stagingDir -Recurse
          Copy-Item -Path "./LICENSE" -Destination $stagingDir
          Copy-Item -Path "./README.md" -Destination $stagingDir
          Copy-Item -Path "./install.ps1" -Destination $stagingDir
          Copy-Item -Path "./install.sh" -Destination $stagingDir
          Copy-Item -Path "./uninstall.ps1" -Destination $stagingDir
          
          # Setup bin directory with compiled artifacts
          $binDir = Join-Path $stagingDir "bin"
          New-Item -ItemType Directory -Path $binDir -Force | Out-Null
          
          # Create subdirectory structures
          $winX64Dir = New-Item -ItemType Directory -Path (Join-Path $binDir "win-x64") -Force | Out-Null
          $winArm64Dir = New-Item -ItemType Directory -Path (Join-Path $binDir "win-arm64") -Force | Out-Null
          $linuxX64Dir = New-Item -ItemType Directory -Path (Join-Path $binDir "linux-x64") -Force | Out-Null
          $linuxArm64Dir = New-Item -ItemType Directory -Path (Join-Path $binDir "linux-arm64") -Force | Out-Null
          $osxX64Dir = New-Item -ItemType Directory -Path (Join-Path $binDir "osx-x64") -Force | Out-Null
          $osxArm64Dir = New-Item -ItemType Directory -Path (Join-Path $binDir "osx-arm64") -Force | Out-Null

          # Copy binaries
          Copy-Item -Path "bin_artifacts/forgum-core-x86_64-pc-windows-msvc/forgum_core.exe" -Destination (Join-Path $binDir "win-x64/forgum-core.exe") -Force
          Copy-Item -Path "bin_artifacts/forgum-core-aarch64-pc-windows-msvc/forgum_core.exe" -Destination (Join-Path $binDir "win-arm64/forgum-core.exe") -Force
          Copy-Item -Path "bin_artifacts/forgum-core-x86_64-unknown-linux-gnu/forgum_core" -Destination (Join-Path $binDir "linux-x64/forgum-core") -Force
          Copy-Item -Path "bin_artifacts/forgum-core-aarch64-unknown-linux-gnu/forgum_core" -Destination (Join-Path $binDir "linux-arm64/forgum-core") -Force
          Copy-Item -Path "bin_artifacts/forgum-core-x86_64-apple-darwin/forgum_core" -Destination (Join-Path $binDir "osx-x64/forgum-core") -Force
          Copy-Item -Path "bin_artifacts/forgum-core-aarch64-apple-darwin/forgum_core" -Destination (Join-Path $binDir "osx-arm64/forgum-core") -Force

          # Create zip
          $zipPath = Join-Path $env:RUNNER_TEMP "Forgum-v$version.zip"
          Compress-Archive -Path "$stagingDir/*" -DestinationPath $zipPath -Force
          
          Write-Host "Package created: $zipPath"
          Copy-Item $zipPath ./Forgum-v$version.zip

      - name: Upload build artifact
        uses: actions/upload-artifact@v4
        with:
          name: Forgum-v${{ steps.version.outputs.tag }}
          path: Forgum-v*.zip

      - name: Create GitHub Release
        uses: softprops/action-gh-release@v3
        with:
          name: "Forgum v${{ steps.version.outputs.tag }}"
          generate_release_notes: true
          files: Forgum-v*.zip
```

---

## 5. Wrapper Loader Resolution Upgrades

To support either packaging layout, `Public/Show-CFAnimation.ps1` should be upgraded to load binaries from architecture-specific subdirectories, falling back to any binary found directly under `bin/` (ensuring compatibility with local builds from source).

### Recommended Wrapper Logic Modification
```powershell
    $binDir = Join-Path (Split-Path $PSScriptRoot -Parent) "bin"
    $binName = if ($IsWindows -or ($PSVersionTable.PSVersion.Major -lt 6)) { "forgum-core.exe" } else { "forgum-core" }
    
    # 1. Check if the binary exists directly in bin/ (e.g. from local source compilation)
    $binPath = Join-Path $binDir $binName
    
    if (-not (Test-Path $binPath)) {
        # 2. Resolve architecture-specific subdirectory path
        $osDir = if ($IsWindows -or ($PSVersionTable.PSVersion.Major -lt 6)) {
            $arch = $env:PROCESSOR_ARCHITECTURE
            if ($arch -eq 'ARM64') { "win-arm64" } else { "win-x64" }
        } elseif ($IsMacOS) {
            # Check if using Universal Binary (Strategy 1) or architecture subfolders (Strategy 2)
            if (Test-Path (Join-Path $binDir "osx/$binName")) {
                "osx"
            } else {
                $arch = [System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture
                if ($arch -eq 'Arm64') { "osx-arm64" } else { "osx-x64" }
            }
        } else {
            $arch = [System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture
            if ($arch -eq 'Arm64') { "linux-arm64" } else { "linux-x64" }
        }
        $binPath = Join-Path $binDir "$osDir\$binName"
    }
```
This logic guarantees that both pre-compiled release artifacts and local native compilations will work seamlessly across all platforms.
