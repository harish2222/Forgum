<#
.SYNOPSIS
    Build the Forgum Rust engine with automatic dependency installation.
.DESCRIPTION
    Checks Rust toolchain, installs it if missing (cross-platform),
    validates all deps, and rebuilds the forgum-engine binary.
.PARAMETER SkipDeps
    Skip dependency checks.
.PARAMETER Quiet
    Suppress informational output.
.PARAMETER NoInstall
    Never auto-install Rust - fail if missing.
#>
[CmdletBinding()]
param(
    [switch]$SkipDeps,
    [switch]$Quiet,
    [switch]$NoInstall
)

$ErrorActionPreference = 'Stop'
$root = if ($PSScriptRoot) { Split-Path $PSScriptRoot -Parent } else { Split-Path $MyInvocation.MyCommand.Path -Parent }
$engineDir = Join-Path $root "engine"
$binDir = Join-Path $root "bin"
$onWindows = $IsWindows -or ($PSVersionTable.PSVersion.Major -lt 6)
$onMacOS = $IsMacOS
$onLinux = $IsLinux
$exeName = if ($onWindows) { "forgum-engine.exe" } else { "forgum-engine" }

function Write-Status {
    param([string]$Message, [string]$Color = 'Cyan')
    if (-not $Quiet) { Write-Host "  $Message" -ForegroundColor $Color }
}

function Write-Ok { param([string]$Message) Write-Status "  $Message" 'Green' }
function Write-Warn { param([string]$Message) Write-Status "  $Message" 'Yellow' }
function Write-Fail { param([string]$Message) Write-Status "  $Message" 'Red' }

# Step 1: Check / Install Rust toolchain
if (-not $SkipDeps) {
    Write-Status "`nChecking dependencies..." 'White'

    $needRust = $false
    $needCargo = $false

    # rustc
    $rustc = Get-Command rustc -ErrorAction SilentlyContinue
    if ($rustc) {
        $ver = & rustc --version 2>&1
        Write-Ok "rustc: $ver"
    } else {
        $needRust = $true
        Write-Warn "rustc not found"
    }

    # cargo
    $cargo = Get-Command cargo -ErrorAction SilentlyContinue
    if ($cargo) {
        $ver = & cargo --version 2>&1
        Write-Ok "cargo: $ver"
    } else {
        $needCargo = $true
        Write-Warn "cargo not found"
    }

    # Auto-install Rust if missing
    if (($needRust -or $needCargo) -and -not $NoInstall) {
        Write-Status "`nInstalling Rust toolchain..." 'Yellow'

        if ($onWindows) {
            # Windows: try winget first, then rustup-init.exe
            $winget = Get-Command winget -ErrorAction SilentlyContinue
            if ($winget) {
                Write-Status "Installing via winget..." 'Cyan'
                & winget install --id Rustlang.Rustup --accept-package-agreements --accept-source-agreements 2>&1 | Out-Null
            } else {
                Write-Status "Downloading rustup-init.exe..." 'Cyan'
                $rustupInit = Join-Path $env:TEMP "rustup-init.exe"
                try {
                    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
                    Invoke-WebRequest -Uri "https://win.rustup.rs/x86_64" -OutFile $rustupInit -UseBasicParsing
                    Write-Status "Running rustup-init (default toolchain)..." 'Cyan'
                    & $rustupInit -y --default-toolchain stable 2>&1 | Out-Null
                } catch {
                    Write-Fail "Failed to download rustup-init.exe: $_"
                    Write-Status "Manual install: https://rustup.rs" 'Yellow'
                    return $false
                }
            }
        } else {
            # macOS / Linux: curl rustup
            Write-Status "Installing via rustup (curl)..." 'Cyan'
            try {
                $env:RUSTUP_HOME = Join-Path $HOME ".rustup"
                $env:CARGO_HOME = Join-Path $HOME ".cargo"
                & sh -c "curl -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable" 2>&1 | Out-Null
            } catch {
                Write-Fail "Failed to install Rust: $_"
                Write-Status "Manual install: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh" 'Yellow'
                return $false
            }
        }

        # Refresh PATH to pick up cargo/rustc
        $cargoHome = if ($env:CARGO_HOME) { $env:CARGO_HOME } else { Join-Path $HOME ".cargo" }
        $cargoBin = Join-Path $cargoHome "bin"
        if ($env:PATH -notlike "*$cargoBin*") {
            $env:PATH = "$cargoBin$([System.IO.Path]::PathSeparator)$env:PATH"
        }

        # Re-check
        $rustc = Get-Command rustc -ErrorAction SilentlyContinue
        $cargo = Get-Command cargo -ErrorAction SilentlyContinue
        if ($rustc -and $cargo) {
            Write-Ok "Rust installed: $(& rustc --version 2>&1)"
            Write-Ok "Cargo installed: $(& cargo --version 2>&1)"
        } else {
            Write-Fail "Rust installation completed but rustc/cargo still not in PATH"
            Write-Status "Try opening a new terminal, or add $cargoBin to PATH" 'Yellow'
            return $false
        }
    } elseif (($needRust -or $needCargo) -and $NoInstall) {
        Write-Fail "`nRust toolchain missing and --NoInstall specified"
        Write-Status "Install manually: https://rustup.rs" 'Yellow'
        return $false
    }

    # C compiler check
    if ($onWindows) {
        $msvc = Get-Command cl.exe -ErrorAction SilentlyContinue
        $gcc = Get-Command gcc.exe -ErrorAction SilentlyContinue
        if ($msvc) {
            Write-Ok "C compiler (MSVC cl.exe)"
        } elseif ($gcc) {
            Write-Ok "C compiler (gcc)"
        } else {
            $rustup = Get-Command rustup -ErrorAction SilentlyContinue
            if ($rustup) {
                $rustHost = & rustup show 2>&1 | Select-String 'host:' | ForEach-Object { ($_ -split 'host:\s+')[-1] }
                if ($rustHost -match 'msvc') {
                    Write-Warn "MSVC toolchain - install Visual Studio Build Tools if build fails"
                } else {
                    Write-Ok "GNU toolchain (gcc)"
                }
            }
        }
    } else {
        $cc = Get-Command cc -ErrorAction SilentlyContinue
        $gcc = Get-Command gcc -ErrorAction SilentlyContinue
        $clang = Get-Command clang -ErrorAction SilentlyContinue
        if ($cc -or $gcc -or $clang) {
            Write-Ok "C compiler found"
        } else {
            Write-Warn "No C compiler - install build-essential (apt) or Xcode CLI tools (macOS)"
            if ($onLinux) {
                Write-Status "  sudo apt-get install -y build-essential" 'DarkGray'
            } elseif ($onMacOS) {
                Write-Status "  xcode-select --install" 'DarkGray'
            }
        }
    }

    # Engine source
    $cargoToml = Join-Path $engineDir "Cargo.toml"
    if (-not (Test-Path $cargoToml)) {
        Write-Fail "Engine source not found: $cargoToml"
        return $false
    }
    Write-Ok "Engine source found"
}

# Step 2: Build engine
Write-Status "`nBuilding forgum-engine (release)..." 'White'

if (-not (Test-Path $engineDir)) {
    Write-Fail "Engine directory not found: $engineDir"
    return $false
}

Push-Location $engineDir
try {
    $prevEAP = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    $buildOutput = & cargo build --release 2>&1
    $exitCode = $LASTEXITCODE
    $ErrorActionPreference = $prevEAP

    if ($exitCode -ne 0) {
        Write-Fail "Build FAILED (exit code $exitCode)"
        $buildOutput | ForEach-Object {
            if ($_ -is [System.Management.Automation.ErrorRecord]) {
                Write-Status "  $($_.Exception.Message)" 'Red'
            } else {
                Write-Status "  $_" 'Red'
            }
        }
        return $false
    }

    $warnings = ($buildOutput | Where-Object { $_ -isnot [System.Management.Automation.ErrorRecord] } | Select-String 'warning\[').Count
    if ($warnings -gt 0) {
        Write-Warn "Build warnings: $warnings"
    }

    Write-Ok "Build succeeded"
} finally {
    Pop-Location
}

# Step 3: Copy binary to bin/
Write-Status "`nInstalling binary..." 'White'

$srcBin = Join-Path $engineDir "target/release/$exeName"
if (-not (Test-Path $srcBin)) {
    Write-Fail "Binary not found: $srcBin"
    return $false
}

if (-not (Test-Path $binDir)) {
    New-Item -ItemType Directory -Path $binDir -Force | Out-Null
}

$dstBin = Join-Path $binDir $exeName
Copy-Item $srcBin $dstBin -Force
if (-not $onWindows) { chmod +x $dstBin 2>/dev/null }

$sizeMB = [math]::Round((Get-Item $dstBin).Length / 1MB, 2)
Write-Ok "Installed: $dstBin ($sizeMB MB)"

# Step 4: Verify binary
Write-Status "`nVerifying binary..." 'White'

try {
    $verOutput = & $dstBin --version 2>&1 | Select-Object -First 1
    if ($verOutput) {
        Write-Ok "Version: $verOutput"
    } else {
        $helpOutput = & $dstBin --help 2>&1 | Select-Object -First 1
        if ($helpOutput) { Write-Ok "Responsive: $helpOutput" }
        else { Write-Warn "Binary started but no output (may still work)" }
    }
} catch {
    Write-Warn "Verification failed: $_"
}

Write-Ok "`nEngine build complete!"
return $true
