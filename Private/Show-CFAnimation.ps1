function Show-CFAnimation {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [string]$CowOutput,

        [string]$Mode = '',

        [object]$Config = $null,

        [switch]$Background
    )

    if (-not $Config) { $Config = Get-CFConfig }
    if ([string]::IsNullOrEmpty($Mode)) { $Mode = $Config.animation.mode }
    if ([string]::IsNullOrEmpty($Mode)) { $Mode = 'static' }
    $duration = if ($Config.animation.duration) { $Config.animation.duration } else { 150 }
    $fps = if ($Config.animation.fps) { $Config.animation.fps } else { 30 }

    $flagshipEffects = @('aurora', 'plasma', 'ember', 'liquid-chrome', 'shatter', 'portal', 'glitch', 'neon-pulse', 'physics')
    $baseStyles = @('breathe', 'liquid', 'sway', 'bounce', 'fly', 'fire', 'matrix', 'pulse', 'dissolve')

    if ($Mode -eq 'static' -or $Mode -eq '') {
        return $CowOutput
    }

    if ($Mode -eq 'random') {
        $effect = 'random'
    } elseif ($Mode -eq 'dynamic') {
        $effect = 'dynamic'
    } elseif ($Mode -in $flagshipEffects) {
        $effect = $Mode
    } elseif ($Mode -in $baseStyles) {
        $effect = $Mode
    } else {
        $effect = 'aurora'
    }

    $payload = @{
        type       = 'render'
        effect     = $effect
        cow_text   = $CowOutput
        background = $Background.IsPresent
        duration   = $duration
        fps        = $fps
    } | ConvertTo-Json -Depth 5 -Compress

    $result = $payload | Invoke-Engine

    if ($null -ne $result -and $result -ne '') {
        return $result
    }
    return $CowOutput
}
