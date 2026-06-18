function Set-CFCowAnimate {
    <#
    .SYNOPSIS
        Sets the global cow animation mode.

    .DESCRIPTION
        Updates your Forgum configuration to use the specified animation mode.
        If no mode is provided, it displays the current animation mode.

    .PARAMETER Mode
        The animation mode to set (e.g., static, dynamic, talking, typewriter, rainbow).

    .EXAMPLE
        Set-CFCowAnimate -Mode talking
        Sets the animation mode to talking.

    .EXAMPLE
        cow-animate typewriter
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
    param(
        [Parameter(Position = 0)]
        [ValidateSet('static', 'dynamic', 'talking', 'typewriter', 'rainbow', 'fade', 'bounce', 'pulse', 'slide', 'blink', 'scroll')]
        [string]$Mode
    )

    $config = Get-CFConfig
    if (-not $config) {
        Write-Error "Could not retrieve Forgum configuration."
        return
    }

    if (-not $Mode) {
        Write-Host "Current animation: $($config.animation.mode)" -ForegroundColor Cyan
        return
    }

    $config.animation.mode = $Mode
    Set-CFConfig -Config $config
    Write-Host "Animation set to: $Mode" -ForegroundColor Green
}
