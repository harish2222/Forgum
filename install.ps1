<#
.SYNOPSIS
    Forgum Installer - Fun installation like oh-my-zsh!
.DESCRIPTION
    Installs Forgum with a fun, interactive experience.
    Checks for dependencies and installs them automatically.
.EXAMPLE
    .\install.ps1
    # One-liner install:
    pwsh -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/harish2222/Forgum/main/install.ps1'))"
#>

[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
param(
    [switch]$Silent
)

#Requires -Version 5.1

# ASCII Art Banner
function Show-Banner {
    Write-Host ""
    Write-Host "  _____ ___  ____   ____ _   _ __  __ " -ForegroundColor Cyan
    Write-Host " |  ___/ _ \|  _ \ / ___| | | |  \/  |" -ForegroundColor Cyan
    Write-Host " | |_ | | | | |_) | |  _| | | | |\/| |" -ForegroundColor Cyan
    Write-Host " |  _|| |_| |  _ <| |_| | |_| | |  | |" -ForegroundColor Cyan
    Write-Host " |_|   \___/|_| \_\\____|\___/|_|  |_|" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  The fun way to get your daily fortune!" -ForegroundColor Magenta
    Write-Host ""
}

function Show-Progress {
    param([int]$Current, [int]$Total)
    $pct = [math]::Floor($Current * 100 / $Total)
    $filled = [math]::Floor($Current * 50 / $Total)
    $bar = ("█" * $filled) + ("░" * (50 - $filled))
    Write-Host "`r  [$bar] $pct%" -NoNewline -ForegroundColor Green
}

function Test-CommandExists {
    param([string]$Command)
    $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

# Main
Show-Banner

Write-Host "  Checking dependencies..." -ForegroundColor White
Write-Host ""

# Check PowerShell version
if ($PSVersionTable.PSVersion -ge [version]'5.1') {
    Write-Host "  PowerShell $($PSVersionTable.PSVersion) found" -ForegroundColor Green
} else {
    Write-Host "  PowerShell 5.1+ required. Current: $($PSVersionTable.PSVersion)" -ForegroundColor Red
    exit 1
}

# Check Git
if (Test-CommandExists git) {
    Write-Host "  Git found" -ForegroundColor Green
} else {
    Write-Host "  Git not found (optional but recommended)" -ForegroundColor Yellow
}

# Check Pester
if (Get-Module -ListAvailable -Name Pester) {
    Write-Host "  Pester found" -ForegroundColor Green
} else {
    Write-Host "  Pester not found (optional, needed for tests)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "  Installing Forgum..." -ForegroundColor White
Write-Host ""

# Determine install directory
$installDir = Join-Path ([Environment]::GetFolderPath('MyDocuments')) "PowerShell\Modules\Forgum"
$configDir = Join-Path ([Environment]::GetFolderPath('MyDocuments')) "PowerShell\Forgum"

# Create directories
if (-not (Test-Path $installDir)) {
    New-Item -ItemType Directory -Path $installDir -Force | Out-Null
}
Show-Progress 10 100

# Compile Rust engine if cargo is available
$sourceDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path $MyInvocation.MyCommand.Path -Parent }
$rustDir = Join-Path $sourceDir "engine"
$binDir = Join-Path $sourceDir "bin"
if (Test-CommandExists cargo) {
    if (Test-Path $rustDir) {
        Write-Host "  Compiling Rust animation engine..." -ForegroundColor Cyan
        $origDir = Get-Location
        Set-Location $rustDir
        cargo build --release --quiet
        Set-Location $origDir
        if (-not (Test-Path $binDir)) { New-Item -ItemType Directory -Path $binDir -Force | Out-Null }
        $exeName = if ($IsWindows -or ($PSVersionTable.PSVersion.Major -lt 6)) { "forgum-engine.exe" } else { "forgum-engine" }
        $compiledPath = Join-Path $rustDir "target/release/$exeName"
        if (Test-Path $compiledPath) {
            Copy-Item -Path $compiledPath -Destination (Join-Path $binDir $exeName) -Force
        }
    }
}
$moduleItems = @("Forgum.psd1", "Forgum.psm1", "Public", "Private", "Data", "bin", "LICENSE", "README.md")

if (Test-CommandExists git) {
    if (Test-Path (Join-Path $sourceDir '.git')) {
        # Running from cloned repo
        foreach ($item in $moduleItems) {
            $path = Join-Path $sourceDir $item
            if (Test-Path $path) { Copy-Item -Path $path -Destination $installDir -Recurse -Force }
        }
    } else {
        # Download from GitHub
        Write-Host ""
        Write-Host "  Downloading from GitHub..." -ForegroundColor Cyan
        $tempDir = Join-Path ([System.IO.Path]::GetTempPath()) "Forgum_$(Get-Random)"
        $env:GIT_TERMINAL_PROMPT = '0'
        git -c core.askPass=echo clone --depth 1 https://github.com/harish2222/Forgum.git $tempDir 2>$null
        foreach ($item in $moduleItems) {
            $path = Join-Path $tempDir $item
            if (Test-Path $path) { Copy-Item -Path $path -Destination $installDir -Recurse -Force }
        }
        Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
} else {
    foreach ($item in $moduleItems) {
        $path = Join-Path $sourceDir $item
        if (Test-Path $path) { Copy-Item -Path $path -Destination $installDir -Recurse -Force }
    }
}
Show-Progress 50 100

# Create config directory
if (-not (Test-Path $configDir)) {
    New-Item -ItemType Directory -Path $configDir -Force | Out-Null
}
Show-Progress 70 100

# Setup PowerShell profile integration
$profilePath = $PROFILE.CurrentUserAllHosts
if ($profilePath) {
    $profileDir = Split-Path $profilePath -Parent
    if (-not (Test-Path $profileDir)) {
        New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
    }

    $importLine = "Import-Module Forgum -ErrorAction SilentlyContinue"
    $existingProfile = if (Test-Path $profilePath) { Get-Content $profilePath -Raw } else { '' }

    if ($existingProfile -notmatch 'Forgum') {
        $separator = if ($existingProfile.Length -gt 0) { "`n`n" } else { '' }
        Add-Content -Path $profilePath -Value "${separator}# Forgum`n$importLine"
        Write-Host "  Added to PowerShell profile" -ForegroundColor Green
    }
}

# Run setup
$setupScript = Join-Path $installDir "setup.ps1"
if (-not (Test-Path $setupScript)) {
    $setupScript = Join-Path $sourceDir "setup.ps1"
}

if ($Silent) {
    Write-Host "  Running setup (silent mode)..." -ForegroundColor White
    if (Test-Path $setupScript) {
        & $setupScript -NonInteractive -Force
    }
} else {
    Write-Host "  Starting interactive setup..." -ForegroundColor Cyan
    if (Test-Path $setupScript) {
        & $setupScript
    }
}

Show-Progress 90 100

# Verify
try {
    Import-Module $installDir\Forgum.psd1 -Force -ErrorAction Stop
} catch {
    Write-Host ""
    Write-Host "  Warning: Module loaded but verification had issues" -ForegroundColor Yellow
}
Show-Progress 100 100

Write-Host ""
Write-Host ""
Write-Host "  Installation complete!" -ForegroundColor Green
Write-Host ""
Write-Host "  Quick Start:" -ForegroundColor White
Write-Host "    forgum                   # Show a cow with a fortune" -ForegroundColor Green
Write-Host "    forgum cowsay 'Hello'    # Show a cow with custom text" -ForegroundColor Green
Write-Host "    forgum list              # List available cow templates" -ForegroundColor Green
Write-Host "    forgum interactive       # Open interactive config menu" -ForegroundColor Green
Write-Host ""
Write-Host "  Configuration:" -ForegroundColor White
Write-Host "    forgum config show       # View current config" -ForegroundColor Green
Write-Host "    forgum config path       # Show config file path" -ForegroundColor Green
Write-Host ""
Write-Host "  Enable rainbow colors:" -ForegroundColor Yellow
Write-Host "    forgum toggle --lolcat" -ForegroundColor Yellow
Write-Host ""
Write-Host "  Fortune favors the bold! Enjoy your cows!" -ForegroundColor Magenta
Write-Host ""
