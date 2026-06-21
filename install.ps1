<#
.SYNOPSIS
    Forgum Installer — installs module and runs setup.
.DESCRIPTION
    Copies module files to PowerShell\Modules\Forgum, then runs setup wizard.
    After install, open a new terminal and forgum appears automatically.
.EXAMPLE
    .\install.ps1
    .\install.ps1 -Silent    # use defaults, no prompts
#>
[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
param([switch]$Silent)

$ErrorActionPreference = 'Stop'
$installDir = Join-Path ([Environment]::GetFolderPath('MyDocuments')) "PowerShell\Modules\Forgum"
$sourceDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path $MyInvocation.MyCommand.Path -Parent }

Write-Host "`n  Forgum Installer v1.1.2`n" -ForegroundColor Cyan

# ── Build Rust engine ──
$buildScript = Join-Path $sourceDir "Scripts\build-engine.ps1"
if (Test-Path $buildScript) {
    Write-Host "  Checking engine dependencies and building..." -ForegroundColor Cyan
    $result = & $buildScript -Quiet
    if ($result -eq $false) {
        Write-Host "  Engine build failed. Module will work without animations." -ForegroundColor Yellow
    }
} elseif (Test-Path "$sourceDir\engine\Cargo.toml") {
    Write-Host "  Build script not found, attempting cargo build directly..." -ForegroundColor Yellow
    $hasCargo = Get-Command cargo -ErrorAction SilentlyContinue
    if ($hasCargo) {
        Write-Host "  Building Rust engine..." -ForegroundColor Cyan
        Push-Location "$sourceDir\engine"
        try { cargo build --release --quiet 2>&1 | Out-Null } catch { Write-Host "  Engine build failed (non-fatal)" -ForegroundColor Yellow }
        Pop-Location
        $binDir = Join-Path $sourceDir "bin"
        if (-not (Test-Path $binDir)) { New-Item -ItemType Directory -Path $binDir -Force | Out-Null }
        $exe = if ($IsWindows -or $PSVersionTable.PSVersion.Major -lt 6) { "forgum-engine.exe" } else { "forgum-engine" }
        $src = Join-Path "$sourceDir\engine\target\release" $exe
        if (Test-Path $src) { Copy-Item $src (Join-Path $binDir $exe) -Force; Write-Host "  Engine built." -ForegroundColor Green }
    }
}

# ── Clean install — copy ONLY module files ──
if (Test-Path $installDir) { Remove-Item $installDir -Recurse -Force }
New-Item -ItemType Directory -Path $installDir -Force | Out-Null

foreach ($f in @("Forgum.psd1","Forgum.psm1","LICENSE","README.md")) {
    $s = Join-Path $sourceDir $f
    if (Test-Path $s) { Copy-Item $s $installDir -Force }
}
foreach ($d in @("Public","Data","bin")) {
    $s = Join-Path $sourceDir $d
    if (Test-Path $s) { Copy-Item $s (Join-Path $installDir $d) -Recurse -Force }
}
# Copy Private — exclude nested Private subdirectories from stale installs
$privateSrc = Join-Path $sourceDir "Private"
$privateDst = Join-Path $installDir "Private"
New-Item -ItemType Directory -Path $privateDst -Force | Out-Null
Get-ChildItem $privateSrc -File | ForEach-Object { Copy-Item $_.FullName $privateDst -Force }
foreach ($sub in @("Animation","Subcommands")) {
    $subSrc = Join-Path $privateSrc $sub
    if (Test-Path $subSrc) { Copy-Item $subSrc (Join-Path $privateDst $sub) -Recurse -Force }
}

# Verify
$required = @(
    "$installDir\Forgum.psd1",
    "$installDir\Data\Fortunes\fortunes.txt",
    "$installDir\Private\GetFortune.ps1",
    "$installDir\Public\forgum.ps1"
)
$missing = $required | Where-Object { -not (Test-Path $_) }
if ($missing) {
    Write-Host "  ERROR: Missing files:" -ForegroundColor Red
    $missing | ForEach-Object { Write-Host "    $_" -ForegroundColor Red }
    return
}
Write-Host "  Module installed to: $installDir" -ForegroundColor Green

# ── Run setup wizard (handles all interactive questions + profile) ──
$setup = Join-Path $sourceDir "setup.ps1"
if (-not (Test-Path $setup)) { $setup = Join-Path $installDir "setup.ps1" }
if (Test-Path $setup) {
    Write-Host ""
    if ($Silent) { & $setup -NonInteractive -Force }
    else { & $setup }
} else {
    Write-Host "  WARNING: setup.ps1 not found, skipping configuration" -ForegroundColor Yellow
}

Write-Host "`n  Restart your terminal. Forgum will appear automatically.`n" -ForegroundColor Yellow
