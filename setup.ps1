<#
.SYNOPSIS
    Forgum Shell Setup - Configure terminal integration interactively.
.DESCRIPTION
    Configures Fortune cow on startup, lolcat, cow file, animation, aliases, and tab completion.
    Supports -NonInteractive for package managers (winget/scoop).
.PARAMETER NonInteractive
    Skip all prompts, use defaults (fortune=yes, lolcat=yes, cow=default, animation=static, aliases=yes, completion=yes).
.PARAMETER Force
    Overwrite existing config without asking.
.PARAMETER NoProfile
    Don't modify PowerShell profile.
.EXAMPLE
    .\setup.ps1
    .\setup.ps1 -NonInteractive -Force
#>

[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
param(
    [switch]$NonInteractive,
    [switch]$Force,
    [switch]$NoProfile
)

#Requires -Version 5.1

$FigletBanner = @"
  _____ ___  ____   ____ _   _ __  __ 
 |  ___/ _ \|  _ \ / ___| | | |  \/  |
 | |_ | | | | |_) | |  _| | | | |\/| |
 |  _|| |_| |  _ <| |_| | |_| | |  | |
 |_|   \___/|_| \_\\____|\___/|_|  |_|
"@

function Show-Banner {
    Write-Host ""
    Write-Host $FigletBanner -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Shell Setup Wizard" -ForegroundColor Magenta
    Write-Host ""
}

function Show-Section {
    param([string]$Title)
    Write-Host ""
    Write-Host "  ── $Title ──" -ForegroundColor Yellow
    Write-Host ""
}

function Get-UserChoice {
    param(
        [string]$Prompt,
        [bool]$Default
    )
    $defaultStr = if ($Default) { "Y/n" } else { "y/N" }
    Write-Host "  $Prompt " -NoNewline -ForegroundColor White
    Write-Host "[$defaultStr]: " -NoNewline -ForegroundColor DarkGray
    
    if ($NonInteractive) {
        Write-Host $(if ($Default) { "yes" } else { "no" }) -ForegroundColor Green
        return $Default
    }
    
    $response = Read-Host
    if ([string]::IsNullOrWhiteSpace($response)) { return $Default }
    return $response -match '^[yY]'
}

function Get-UserSelection {
    param(
        [string]$Prompt,
        [string[]]$Options,
        [string]$Default
    )
    Write-Host "  $Prompt" -ForegroundColor White
    for ($i = 0; $i -lt $Options.Count; $i++) {
        $marker = if ($Options[$i] -eq $Default) { " *" } else { "  " }
        Write-Host "    $($i + 1)$marker $($Options[$i])" -ForegroundColor Cyan
    }
    
    if ($NonInteractive) {
        $defaultIdx = [Array]::IndexOf($Options, $Default) + 1
        Write-Host "  Selection [$defaultIdx]: $Default" -ForegroundColor Green
        return $Default
    }
    
    $idx = Read-Host "  Selection [1-$($Options.Count)]"
    if ([string]::IsNullOrWhiteSpace($idx)) { return $Default }
    $num = 0
    if ([int]::TryParse($idx, [ref]$num) -and $num -ge 1 -and $num -le $Options.Count) {
        return $Options[$num - 1]
    }
    return $Default
}

# ── Main ──
Show-Banner

# Check if Forgum is installed
$forgumPath = Join-Path ([Environment]::GetFolderPath('MyDocuments')) "PowerShell\Modules\Forgum\Forgum.psd1"
if (-not (Test-Path $forgumPath)) {
    $forgumPath = Join-Path $PSScriptRoot "Forgum.psd1"
    if (-not (Test-Path $forgumPath)) {
        Write-Host "  ERROR: Forgum module not found." -ForegroundColor Red
        Write-Host "  Run install.ps1 first, then run this script." -ForegroundColor Yellow
        exit 1
    }
}

try {
    Import-Module $forgumPath -Force -ErrorAction Stop
} catch {
    Write-Host "  ERROR: Failed to load Forgum module: $_" -ForegroundColor Red
    exit 1
}

try {
    $config = Get-CFConfig
} catch {
    Write-Host "  ERROR: Failed to load config: $_" -ForegroundColor Red
    exit 1
}
Write-Host "  Forgum module loaded successfully!" -ForegroundColor Green

# ── Toggle 1: Fortune Cow on Startup ──
Show-Section "Fortune Cow on Startup"
$fortuneOnStartup = Get-UserChoice "Show cow with fortune on terminal startup?" $true

# ── Toggle 2: Lolcat Rainbow ──
Show-Section "Lolcat Rainbow Colors"
$lolcatEnabled = Get-UserChoice "Enable rainbow lolcat colors by default?" $true

# ── Toggle 3: Default Cow File ──
Show-Section "Default Cow File"
$cowFiles = Get-CFCow | Select-Object -First 20
$cowOptions = @('default') + ($cowFiles | Where-Object { $_ -ne 'default' } | Select-Object -First 9)
$defaultCow = Get-UserSelection "Choose default cow:" $cowOptions "default"

# ── Toggle 4: Animation Mode ──
Show-Section "Animation Mode"
$animMode = Get-UserSelection "Choose animation mode:" @('static', 'talking', 'typewriter') "static"

# ── Toggle 5: Shell Aliases ──
Show-Section "Shell Aliases"
$addAliases = Get-UserChoice "Add quick aliases (cowconfig, cowpreview, cowgallery, etc.)?" $true

# ── Toggle 6: Tab Completion ──
Show-Section "Tab Completion"
$addCompletion = Get-UserChoice "Add tab completion for Forgum commands?" $true

# ── Apply Config ──
Show-Section "Applying Configuration"

$config.lolcat.enabled = $lolcatEnabled
$config.cow.file = $defaultCow
$config.animation.mode = $animMode
Set-CFConfig -Config $config
Write-Host "  Config saved" -ForegroundColor Green

# ── Update Profile ──
if (-not $NoProfile) {
    Show-Section "Updating PowerShell Profile"
    $profilePath = $PROFILE.CurrentUserAllHosts
    if (-not $profilePath) { $profilePath = $PROFILE.CurrentUser }
    
    if ($profilePath) {
        $profileDir = Split-Path $profilePath -Parent
        if (-not (Test-Path $profileDir)) {
            New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
        }
        
        $existingProfile = if (Test-Path $profilePath) { Get-Content $profilePath -Raw } else { '' }
        $newContent = $existingProfile
        
        # Add Import-Module Forgum
        if ($newContent -notmatch 'Import-Module\s+Forgum') {
            $newContent += "`n`n# Forgum`nImport-Module Forgum -ErrorAction SilentlyContinue"
            Write-Host "  Added Import-Module Forgum" -ForegroundColor Green
        }
        
        # Add Fortune Cow on Startup
        if ($fortuneOnStartup -and $newContent -notmatch 'Show-FortuneCow') {
            $startupBlock = @"

# Forgum Startup Fortune Cow
function Show-FortuneCow {
    if (Get-Command Invoke-Forgum -ErrorAction Ignore) {
        `$cowText = Invoke-Forgum -Lolcat
        if (`$cowText) { [Console]::WriteLine(`$cowText) }
    } elseif (Get-Command Invoke-Cowsay -ErrorAction Ignore) {
        `$fortune = if (Get-Command Get-Fortune -ErrorAction Ignore) { Get-Fortune -ErrorAction SilentlyContinue } else { '' }
        `$randomCow = (Get-CFCow | Get-Random).Name
        if (`$fortune) {
            `$null = Invoke-Cowsay -Text `$fortune -CowFile `$randomCow -Lolcat
        } else {
            `$null = Invoke-Cowsay -Text "Moo!" -CowFile `$randomCow -Lolcat
        }
    }
}
Set-Alias cowfortune Show-FortuneCow

if (-not `$global:FORGUM_STARTUP_DONE) {
    `$global:FORGUM_STARTUP_DONE = `$true
    Show-FortuneCow
}
"@
            $newContent += $startupBlock
            Write-Host "  Added startup fortune cow" -ForegroundColor Green
        }
        
        # Add Aliases
        if ($addAliases -and $newContent -notmatch 'function cowconfig') {
            $aliasBlock = @"

# Forgum Aliases
function cowconfig { Get-CFConfig | ConvertTo-Json -Depth 4 }
function cowpreview { param([string]`$Cow='default',[string]`$Text='Hello!') Invoke-Cowsay -Text `$Text -CowFile `$Cow }
function cowgallery { param([int]`$Count=5) Get-CFCow | Get-Random -Count `$Count | ForEach-Object { Invoke-Cowsay -Text (Get-Fortune) -CowFile `$_ } }
function lolcat-toggle { `$c = Get-CFConfig; `$c.lolcat.enabled = -not `$c.lolcat.enabled; Set-CFConfig -Config `$c; if (`$c.lolcat.enabled) { Write-Host "Lolcat: ON" -ForegroundColor Green } else { Write-Host "Lolcat: OFF" -ForegroundColor Yellow } }
function cow-animate { param([ValidateSet('static','talking','typewriter')]`$Mode) `$c = Get-CFConfig; `$c.animation.mode = `$Mode; Set-CFConfig -Config `$c; Write-Host "Animation: `$Mode" }
"@
            $newContent += $aliasBlock
            Write-Host "  Added shell aliases" -ForegroundColor Green
        }
        
        # Add Tab Completion
        if ($addCompletion -and $newContent -notmatch 'Register-ArgumentCompleter') {
            $completionBlock = @"

# Forgum Tab Completion
Register-ArgumentCompleter -CommandName Invoke-Cowsay -ParameterName CowFile -ScriptBlock {
    param(`$commandName, `$parameterName, `$wordToComplete, `$commandAst, `$fakeBoundParameters)
    Get-CFCow | Where-Object { `$_ -like "*`$wordToComplete*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new(`$_, `$_, 'ParameterValue', `$_)
    }
}
"@
            $newContent += $completionBlock
            Write-Host "  Added tab completion" -ForegroundColor Green
        }
        
        # Backup profile before modifying
        if (Test-Path $profilePath) {
            $backupPath = "$profilePath.bak.$(Get-Date -Format 'yyyyMMddHHmmss')"
            Copy-Item -Path $profilePath -Destination $backupPath -Force
        }
        
        Set-Content -Path $profilePath -Value $newContent -Force
        Write-Host "  Profile updated: $profilePath" -ForegroundColor Green
    }
}

# ── Summary ──
Show-Section "Setup Complete!"
Write-Host ""
Write-Host "  Settings applied:" -ForegroundColor White
Write-Host "    Fortune on startup: $fortuneOnStartup" -ForegroundColor Cyan
Write-Host "    Lolcat rainbow:     $lolcatEnabled" -ForegroundColor Cyan
Write-Host "    Default cow:        $defaultCow" -ForegroundColor Cyan
Write-Host "    Animation mode:     $animMode" -ForegroundColor Cyan
Write-Host "    Shell aliases:      $addAliases" -ForegroundColor Cyan
Write-Host "    Tab completion:     $addCompletion" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Restart your terminal to see changes." -ForegroundColor Yellow
Write-Host "  Run 'Invoke-Forgum' to test!" -ForegroundColor Green
Write-Host ""
