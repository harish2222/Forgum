<#
.SYNOPSIS
    Forgum Shell Setup - Configure terminal integration interactively.
.DESCRIPTION
    Configures Fortune cow on startup, lolcat, cow file, animation, aliases, and tab completion.
    Supports -NonInteractive for package managers (winget/scoop).
.PARAMETER NonInteractive
    Skip all prompts, use defaults (fortune=yes, lolcat=yes, cow=default, animation=dynamic, aliases=yes, completion=yes).
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
        [bool]$Default,
        [switch]$NonInteractive
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
        [string]$Default,
        [switch]$NonInteractive
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
if (-not (Get-Command Get-CFConfig -ErrorAction SilentlyContinue)) {
    $forgumPath = Join-Path ([Environment]::GetFolderPath('MyDocuments')) "PowerShell\Modules\Forgum\Forgum.psd1"
    if (-not (Test-Path $forgumPath)) {
        $forgumPath = Join-Path $PSScriptRoot "Forgum.psd1"
        if (-not (Test-Path $forgumPath)) {
            Write-Host "  ERROR: Forgum module not found." -ForegroundColor Red
            Write-Host "  Run install.ps1 first, then run this script." -ForegroundColor Yellow
            return
        }
    }

    try {
        Import-Module $forgumPath -Force -ErrorAction Stop
    } catch {
        Write-Host "  ERROR: Failed to load Forgum module: $_" -ForegroundColor Red
        return
    }
    Write-Host "  Forgum module loaded successfully!" -ForegroundColor Green
}

try {
    $config = Get-CFConfig
} catch {
    Write-Host "  ERROR: Failed to load config: $_" -ForegroundColor Red
    return
}

# Check for existing profile config
$profilePath = $PROFILE.CurrentUserAllHosts
if (-not $profilePath) { $profilePath = $PROFILE.CurrentUser }
if (Test-Path $profilePath) {
    $existingProfile = Get-Content $profilePath -Raw
    if ($existingProfile -match '# region FORGUM') {
        Show-Section "Existing Configuration Detected"
        $changeExisting = Get-UserChoice "Forgum is already configured. Do you want to change your settings?" $false -NonInteractive:$NonInteractive
        if (-not $changeExisting) {
            Write-Host "  Keeping existing configuration. Setup complete." -ForegroundColor Green
            return
        }
    }
}

# ── Toggle 1: Fortune Cow on Startup ──
Show-Section "Fortune Cow on Startup"
$fortuneOnStartup = Get-UserChoice "Show cow with fortune on terminal startup?" $true -NonInteractive:$NonInteractive

# ── Toggle 2: Lolcat Rainbow ──
Show-Section "Lolcat Rainbow Colors"
$lolcatEnabled = Get-UserChoice "Enable rainbow lolcat colors by default?" $true -NonInteractive:$NonInteractive

# ── Toggle 3: Default Cow File ──
Show-Section "Default Cow File"
$cowFiles = Get-CFCow | Select-Object -First 20
$cowOptions = @('default') + ($cowFiles | Where-Object { $_ -ne 'default' } | Select-Object -First 9)
$defaultCow = Get-UserSelection -Prompt "Choose default cow:" -Options $cowOptions -Default "default" -NonInteractive:$NonInteractive

# ── Toggle 4: Animation Mode ──
Show-Section "Animation Mode"
$animMode = Get-UserSelection -Prompt "Choose animation mode:" -Options @('dynamic', 'talking', 'typewriter') -Default "dynamic" -NonInteractive:$NonInteractive

# ── Toggle 5: Shell Aliases ──
Show-Section "Shell Aliases"
$addAliases = Get-UserChoice "Add quick aliases (cowconfig, cowpreview, cowgallery, etc.)?" $true -NonInteractive:$NonInteractive

# ── Toggle 6: Tab Completion ──
Show-Section "Tab Completion"
$addCompletion = Get-UserChoice "Add tab completion for Forgum commands?" $true -NonInteractive:$NonInteractive

# ── Apply Config ──
Show-Section "Applying Configuration"

$config.lolcat.enabled = $lolcatEnabled
$config.cow.file = $defaultCow
$config.animation.mode = $animMode
Set-CFConfig -Config $config -Confirm:$(-not $Force)
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
        
        # Build the new consolidated block
        $blockLines = [System.Collections.Generic.List[string]]::new()
        $blockLines.Add("# region FORGUM")
        $blockLines.Add("# This section is managed by Forgum. Manually editing may affect its ability to update.")
        $blockLines.Add("`$env:FORGUM_NOAUTOSTART = '1'")
        $blockLines.Add("Import-Module Forgum -ErrorAction SilentlyContinue")
        
        if ($fortuneOnStartup) {
            $blockLines.Add("")
            $blockLines.Add("function Show-FortuneCow {")
            $blockLines.Add("    if (Get-Command Invoke-Forgum -ErrorAction Ignore) {")
            $blockLines.Add("        `$cowText = Invoke-Forgum -Lolcat")
            $blockLines.Add("        if (`$cowText) { Write-Host `$cowText }")
            $blockLines.Add("    }")
            $blockLines.Add("}")
            $blockLines.Add("Set-Alias cowfortune Show-FortuneCow")
            $blockLines.Add("if (-not `$global:FORGUM_STARTUP_DONE) {")
            $blockLines.Add("    `$global:FORGUM_STARTUP_DONE = `$true")
            $blockLines.Add("    Show-FortuneCow")
            $blockLines.Add("}")
        }
        
        if ($addAliases) {
            $blockLines.Add("")
            $blockLines.Add("# Forgum Aliases")
            $blockLines.Add("function cowconfig { Get-CFConfig | ConvertTo-Json -Depth 4 }")
            $blockLines.Add("function cowpreview { param([string]`$Cow='default',[string]`$Text='Hello!') Invoke-Cowsay -Text `$Text -CowFile `$Cow }")
            $blockLines.Add("function cowgallery { param([int]`$Count=5) Get-CFCow | Get-Random -Count `$Count | ForEach-Object { Invoke-Cowsay -Text (Get-Fortune) -CowFile `$_ } }")
            $blockLines.Add("function lolcat-toggle { `$c = Get-CFConfig; `$c.lolcat.enabled = -not `$c.lolcat.enabled; Set-CFConfig -Config `$c; if (`$c.lolcat.enabled) { Write-Host `"Lolcat: ON`" -ForegroundColor Green } else { Write-Host `"Lolcat: OFF`" -ForegroundColor Yellow } }")
        }
        
        if ($addCompletion) {
            $blockLines.Add("")
            $blockLines.Add("# Forgum Tab Completion")
            $blockLines.Add("Register-ArgumentCompleter -CommandName Invoke-Cowsay -ParameterName CowFile -ScriptBlock {")
            $blockLines.Add("    param(`$commandName, `$parameterName, `$wordToComplete, `$commandAst, `$fakeBoundParameters)")
            $blockLines.Add("    Get-CFCow | Where-Object { `$_ -like `"*`$wordToComplete*`" } | ForEach-Object {")
            $blockLines.Add("        [System.Management.Automation.CompletionResult]::new(`$_, `$_, 'ParameterValue', `$_)")
            $blockLines.Add("    }")
            $blockLines.Add("}")
        }
        $blockLines.Add("# endregion FORGUM")
        
        $forgumBlock = ($blockLines -join "`r`n")
        
        # Clean up old scattered blocks if they exist
        $cleanedProfile = $existingProfile
        $cleanedProfile = $cleanedProfile -replace '(?s)\r?\n# Forgum Startup Fortune Cow.*?Show-FortuneCow\r?\n}', ''
        $cleanedProfile = $cleanedProfile -replace '(?s)\r?\n# Forgum Aliases.*?function cow-animate.*?}', ''
        $cleanedProfile = $cleanedProfile -replace '(?s)\r?\n# Forgum Tab Completion.*?Register-ArgumentCompleter.*?}', ''
        $cleanedProfile = $cleanedProfile -replace '(?s)\r?\n# Forgum\r?\nImport-Module Forgum -ErrorAction SilentlyContinue', ''
        
        # Replace existing region if found, otherwise append
        if ($cleanedProfile -match '(?s)# region FORGUM.*?# endregion FORGUM') {
            $newProfile = $cleanedProfile -replace '(?s)# region FORGUM.*?# endregion FORGUM', $forgumBlock
            Write-Host "  Updated Forgum block in profile" -ForegroundColor Green
        } else {
            $newProfile = $cleanedProfile.Trim() + "`r`n`r`n" + $forgumBlock
            Write-Host "  Added Forgum block to profile" -ForegroundColor Green
        }
        
        # Backup profile before modifying
        if (Test-Path $profilePath) {
            $backupPath = "$profilePath.bak.$(Get-Date -Format 'yyyyMMddHHmmss')"
            Copy-Item -Path $profilePath -Destination $backupPath -Force
        }
        
        Set-Content -Path $profilePath -Value $newProfile.Trim() -Force
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

