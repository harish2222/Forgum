function Show-CFAnimation {
    <#
    .SYNOPSIS
        Displays cow output with the configured animation mode.
    .DESCRIPTION
        Dispatches to the appropriate animation function based on config.
        Modes handled by Rust binary: aurora, ember, shatter, plasma, liquid-chrome, portal, glitch, neon-pulse.
        Modes handled by PowerShell: talking, typewriter, dynamic, procedural, physics.
    .PARAMETER CowOutput
        The rendered cow string to animate.
    .PARAMETER Message
        The original message text (used by some animations).
    .PARAMETER CowName
        The name of the cow file (used by physics animation).
    .PARAMETER Background
        Run animation in background mode (overlay only, no raw mode).
    .EXAMPLE
        Show-CFAnimation -CowOutput $cow -Message "Hello"
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [string]$CowOutput,

        [string]$Message = '',

        [string]$CowName = '',

        [string]$Mode = '',

        [PSCustomObject]$Config = $null,

        [switch]$Background
    )

    if (-not $Config) { $Config = Get-CFConfig }
    if ([string]::IsNullOrEmpty($Mode)) { $Mode = $Config.animation.mode }
    $duration = if ($Config.animation.duration) { $Config.animation.duration } else { 12 }

    # If the mode is literally 'random' or not specified properly, pick a random engine mode
    if ($Mode -eq 'random' -or $null -eq $Mode -or $Mode -eq '') {
        $availableEffects = @('aurora', 'ember', 'shatter', 'plasma', 'liquid-chrome', 'portal', 'glitch', 'neon-pulse')
        $Mode = $availableEffects | Get-Random
    }

    # PowerShell-native animation modes — these handle their own rendering
    $psModes = @('talking', 'typewriter', 'dynamic', 'procedural', 'physics')
    if ($Mode -in $psModes) {
        switch ($Mode) {
            'talking'    { return (Invoke-TalkingAnimation -CowOutput $CowOutput -Message $Message -Duration $duration) }
            'typewriter' { return (Invoke-TypewriterAnimation -CowOutput $CowOutput -Message $Message) }
            'dynamic'    { return (Invoke-DynamicAnimation -Duration $duration -CycleInterval $Config.animation.cycleInterval) }
            'procedural' { return (Invoke-ProceduralAnimation -CowOutput $CowOutput -Duration $duration) }
            'physics'    {
                $effCow = if ($CowName) { $CowName } else { $Config.cow.file }
                return (Invoke-PhysicsCow -CowOutput $CowOutput -Duration $duration -CowName $effCow)
            }
        }
    }

    # Rust binary animation modes (the flagship effects)
    $engineModes = @('aurora', 'plasma', 'ember', 'liquid-chrome', 'shatter', 'portal', 'glitch', 'neon-pulse')
    if ($Mode -in $engineModes) {
        $engineParams = @{
            Message     = $Message
            CowTemplate = ($CowOutput -split "`r?`n")
            Effect      = $Mode
            Fps         = 30
            Duration    = $duration
            Background  = $Background.IsPresent
        }
        $success = Invoke-Engine @engineParams
        if ($success) { return "" }
        Write-Warning "forgum-engine failed or not found. Falling back to native physics."
        $Mode = 'physics'
        return (Invoke-PhysicsCow -CowOutput $CowOutput -Duration $duration)
    }

    # Legacy static/rust modes — use Rust binary if available, else static
    $isWin = $IsWindows -or ($PSVersionTable.PSVersion.Major -lt 6) -or ($env:OS -eq 'Windows_NT')
    $isMac = $IsMacOS

    if ($isWin) {
        $arch = $env:PROCESSOR_ARCHITECTURE
        $binName = if ($arch -eq 'ARM64' -or $arch -eq 'Arm64') { "forgum-core-arm64.exe" } else { "forgum-core.exe" }
    } elseif ($isMac) {
        $binName = "forgum-core-mac"
    } else {
        $arch = [System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture.ToString()
        $binName = if ($arch -eq 'Arm64' -or $arch -eq 'ARM64') { "forgum-core-arm64" } else { "forgum-core" }
    }

    $binPath = Join-Path (Split-Path $PSScriptRoot -Parent) "bin\$binName"
    if (-not (Test-Path $binPath)) {
        $fallbackName = if ($isWin) { "forgum-core.exe" } else { "forgum-core" }
        $fallbackPath = Join-Path (Split-Path $PSScriptRoot -Parent) "bin\$fallbackName"
        if (Test-Path $fallbackPath) {
            $binPath = $fallbackPath
        }
    }

    if (Test-Path $binPath) {
        $isAutoStart = $script:IsAutoStart
        $frames = $duration
        if (-not $frames -or $frames -lt 1) { $frames = 30 }

        $binArgs = @('--message', $Message, '--mode', $Mode, '--fps', '15')
        if ($isAutoStart) {
            $binArgs += '--once'
        } else {
            $binArgs += '--frames'
            $binArgs += "$frames"
        }
        if ([Console]::IsOutputRedirected) {
            $binArgs += '--plain'
        }

        $rendered = $CowOutput | & $binPath @binArgs 2>&1
        if ($null -eq $rendered) { return $CowOutput }
        return ($rendered -join "`n")
    } else {
        Write-Warning "forgum-core not found, falling back to static"
        return $CowOutput
    }
}
