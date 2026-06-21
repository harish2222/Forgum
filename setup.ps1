<#
.SYNOPSIS
    Forgum Shell Setup - Configure terminal integration.
.DESCRIPTION
    Configures fortune cow on startup, lolcat, cow file, animation, and profile.
    Reads/writes config.json directly — no module function dependencies.
.PARAMETER NonInteractive
    Skip all prompts, use defaults.
.PARAMETER Force
    Overwrite existing config without asking.
#>
[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
param(
    [switch]$NonInteractive,
    [switch]$Force,
    [switch]$NoProfile,
    [switch]$DisableAutoUpdate
)

$ErrorActionPreference = 'Stop'

# ── Config paths ──
$configDir = Join-Path ([Environment]::GetFolderPath('MyDocuments')) "PowerShell\Forgum"
$configPath = Join-Path $configDir "config.json"
$installDir = Join-Path ([Environment]::GetFolderPath('MyDocuments')) "PowerShell\Modules\Forgum"
$defaultConfig = Join-Path $installDir "Data\Templates\default-config.json"
$cowsDir = Join-Path $installDir "Data\Cows"

function Load-Config {
    if (Test-Path $configPath) {
        try { return Get-Content $configPath -Raw | ConvertFrom-Json } catch { }
    }
    if (Test-Path $defaultConfig) {
        return Get-Content $defaultConfig -Raw | ConvertFrom-Json
    }
    return $null
}

function Save-Config($cfg) {
    if (-not (Test-Path $configDir)) { New-Item -ItemType Directory -Path $configDir -Force | Out-Null }
    $cfg | ConvertTo-Json -Depth 20 | Set-Content -Path $configPath -Encoding UTF8 -Force
}

function Get-Choice([string]$Prompt, [bool]$Default) {
    $tag = if ($Default) { "Y/n" } else { "y/N" }
    Write-Host "  $Prompt " -NoNewline -ForegroundColor White
    Write-Host "[$tag]: " -NoNewline -ForegroundColor DarkGray
    if ($NonInteractive) { $r = if ($Default) { "yes" } else { "no" }; Write-Host $r -ForegroundColor Green; return $Default }
    $resp = Read-Host
    if ([string]::IsNullOrWhiteSpace($resp)) { return $Default }
    return $resp -match '^[yY]'
}

function Get-Selection([string]$Prompt, [string[]]$Options, [string]$Default) {
    Write-Host "  $Prompt" -ForegroundColor White
    for ($i = 0; $i -lt $Options.Count; $i++) {
        $m = if ($Options[$i] -eq $Default) { " *" } else { "  " }
        Write-Host "    $($i + 1)$m $($Options[$i])" -ForegroundColor Cyan
    }
    if ($NonInteractive) { Write-Host "  Selection: $Default" -ForegroundColor Green; return $Default }
    $idx = Read-Host "  Selection [1-$($Options.Count)]"
    if ([string]::IsNullOrWhiteSpace($idx)) { return $Default }
    $n = 0
    if ([int]::TryParse($idx, [ref]$n) -and $n -ge 1 -and $n -le $Options.Count) { return $Options[$n - 1] }
    return $Default
}

# ── Main ──
Write-Host "`n  Forgum Setup Wizard`n" -ForegroundColor Cyan

$config = Load-Config
if (-not $config) {
    Write-Host "  ERROR: Cannot find default config at $defaultConfig" -ForegroundColor Red
    return
}

# Check existing profile
$profilePath = $PROFILE.CurrentUserAllHosts
if (-not $profilePath) { $profilePath = $PROFILE.CurrentUser }
if ((Test-Path $profilePath) -and (Get-Content $profilePath -Raw) -match '# region FORGUM') {
    if (-not (Get-Choice "Forgum already configured. Change settings?" $false) -and -not $Force) {
        Write-Host "  Keeping existing config." -ForegroundColor Green; return
    }
}

# Collect choices
$fStart = Get-Choice "Show cow on startup?" $true
$lolcat = Get-Choice "Enable rainbow lolcat?" $true

$cows = if (Test-Path $cowsDir) {
    Get-ChildItem $cowsDir -Filter "*.cow" | ForEach-Object { [System.IO.Path]::GetFileNameWithoutExtension($_.Name) }
} else { @('default') }
$cowOpts = @('default') + ($cows | Where-Object { $_ -ne 'default' } | Select-Object -First 9)
$cow = Get-Selection "Default cow:" $cowOpts "default"
$anim = Get-Selection "Animation mode:" @('static','dynamic','talking','typewriter','bounce','wave') "static"
$autoUpd = -not $DisableAutoUpdate.IsPresent
$autoUpd = Get-Choice "Daily auto-update check?" $autoUpd

# Apply config
$config.lolcat.enabled = $lolcat
$config.cow.file = $cow
$config.animation.mode = $anim
$config.update.autoCheck = $autoUpd
Save-Config $config
Write-Host "`n  Config saved." -ForegroundColor Green

# Update profile
if (-not $NoProfile -and $profilePath) {
    $dir = Split-Path $profilePath -Parent
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory $dir -Force | Out-Null }
    $existing = if (Test-Path $profilePath) { Get-Content $profilePath -Raw } else { '' }

    $block = @(
        "# region FORGUM",
        "`$env:FORGUM_NOAUTOSTART = '1'",
        "Import-Module Forgum -ErrorAction SilentlyContinue"
    )
    if ($fStart) {
        $block += ""
        $block += "if (-not `$global:FORGUM_STARTUP_DONE) {"
        $block += "    `$global:FORGUM_STARTUP_DONE = `$true"
        $block += "    if (Get-Command forgum -ErrorAction Ignore) { forgum 2>&1 | Out-Host }"
        $block += "}"
    }
    $block += "# endregion FORGUM"
    $forgumBlock = ($block -join "`r`n")

    $cleaned = $existing
    $cleaned = $cleaned -replace '(?s)\r?\n# Forgum Startup Fortune Cow.*?Show-FortuneCow\r?\n}', ''
    $cleaned = $cleaned -replace '(?s)\r?\n# Forgum Aliases.*?function cow-animate.*?}', ''
    $cleaned = $cleaned -replace '(?s)\r?\n# Forgum Tab Completion.*?Register-ArgumentCompleter.*?}', ''
    $cleaned = $cleaned -replace '(?s)\r?\n# Forgum\r?\nImport-Module Forgum -ErrorAction SilentlyContinue', ''
    $cleaned = $cleaned -replace '(?s)\r?\n# region FORGUM.*?# endregion FORGUM\r?\n?', ''

    if ($cleaned -match '(?s)# region FORGUM.*?# endregion FORGUM') {
        $escaped = $forgumBlock -replace '\$', '$$$$'
        $newProfile = $cleaned -replace '(?s)# region FORGUM.*?# endregion FORGUM', $escaped
        Write-Host "  Updated Forgum block in profile" -ForegroundColor Green
    } else {
        $newProfile = $cleaned.Trim() + "`r`n`r`n" + $forgumBlock
        Write-Host "  Added Forgum block to profile" -ForegroundColor Green
    }

    if (Test-Path $profilePath) {
        $backup = "$profilePath.bak.$(Get-Date -Format 'yyyyMMddHHmmss')"
        Copy-Item $profilePath $backup -Force
    }
    Set-Content $profilePath $newProfile.Trim() -Force -Encoding UTF8
    Write-Host "  Profile: $profilePath" -ForegroundColor Green
}

Write-Host "`n  Settings: startup=$fStart lolcat=$lolcat cow=$cow anim=$anim`n" -ForegroundColor Cyan
Write-Host "  Restart terminal, then run 'forgum' to test.`n" -ForegroundColor Yellow
