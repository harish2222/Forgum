function Invoke-Forgum {
    <#
    .SYNOPSIS
        Combines cowsay + fortune + optional lolcat in one command.
    .DESCRIPTION
        Gets a random fortune, renders it with a cow, optionally applies
        rainbow colorization, and displays with the configured animation.
    .PARAMETER Think
        Use thinking bubble instead of speech bubble.
    .PARAMETER CowFile
        Override the cow file from config.
    .PARAMETER Eyes
        Override the eye characters from config.
    .PARAMETER Tongue
        Override the tongue characters from config.
    .PARAMETER Lolcat
        Enable rainbow lolcat colorization for this invocation.
        Overrides the lolcat configuration setting.
    .EXAMPLE
        Invoke-Forgum
        Shows a cow with a random fortune.
    .EXAMPLE
        Invoke-Forgum -Lolcat
        Shows a rainbow-colored cow with a random fortune.
    .EXAMPLE
        Invoke-Forgum -Think -CowFile 'tux'
        Shows tux thinking a fortune.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [switch]$Animate,

        [switch]$Think,

        [ValidateNotNullOrEmpty()]
        [string]$CowFile,

        [ValidateNotNullOrEmpty()]
        [ValidateLength(2,2)]
        [string]$Eyes,

        [ValidateLength(2,2)]
        [string]$Tongue,

        [switch]$Lolcat,

        [switch]$Background
    )

    $config = Get-CFConfig

    if ($Animate) {
        # One-off live show animation
        $null = Invoke-LiveShow -RunOnce -Config $config
        return ""
    }

    $fortune = Get-Fortune -Database $config.fortune.database

    $effectiveCowFile = $CowFile
    if (-not $effectiveCowFile) {
        if ($config.cow.random) {
            $cowsPath = Join-Path (Split-Path $PSScriptRoot -Parent) 'Data/Cows'
            $cowFiles = Get-ChildItem -Path $cowsPath -Filter '*.cow' -ErrorAction SilentlyContinue
            if ($cowFiles) { $effectiveCowFile = ($cowFiles | Get-Random).BaseName }
        } else {
            $effectiveCowFile = if ($config.cow.file) { $config.cow.file } else { 'default' }
        }
    }

    $cowParams = @{ Text = $fortune; CowFile = $effectiveCowFile }
    if ($Eyes)    { $cowParams.Eyes    = $Eyes }
    if ($Tongue)  { $cowParams.Tongue  = $Tongue }
    
    # 50% chance to be a thought bubble if not specified
    if ($Think -or (Get-Random -Max 100) -lt 50) { $cowParams.Thoughts = 'o' }

    # Determine effective lolcat: explicit switch OR config setting
    $useLolcat = $Lolcat -or $config.lolcat.enabled

    # Determine effective animation mode
    $useAnimation = $config.animation.mode -and $config.animation.mode -ne 'static'

    # Render cow WITHOUT lolcat so animation can modify it
    $cowOutput = Invoke-Cowsay @cowParams

    # Apply animation if configured (works with or without lolcat)
    if ($useAnimation) {
        $animationParams = @{
            CowOutput = $cowOutput
            Message   = $fortune
            CowName   = $effectiveCowFile
        }
        if ($Background -or $config.animation.background) { $animationParams.Background = $true }
        $cowOutput = Show-CFAnimation @animationParams
    }

    # Apply lolcat colorization after animation
    if ($useLolcat) {
        $lolcatParams = @{
            Text      = $cowOutput
            Frequency = $config.lolcat.frequency
            Spread    = if ($config.lolcat.spread) { $config.lolcat.spread } else { 3.0 }
            Seed      = if ($config.lolcat.seed) { $config.lolcat.seed } else { 0 }
            Duration  = if ($config.lolcat.duration) { $config.lolcat.duration } else { 12 }
            Speed     = if ($config.lolcat.speed) { $config.lolcat.speed } else { 20.0 }
        }
        if ($config.lolcat.truecolor) { $lolcatParams.Truecolor = $true }
        if ($config.lolcat.invert)    { $lolcatParams.Invert    = $true }
        if ($config.lolcat.animate)   { $lolcatParams.Animate   = $true }
        $cowOutput = Format-Lolcat @lolcatParams
    }

    return $cowOutput
}