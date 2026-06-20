function Set-CFCowAnimate {
    <#
    .SYNOPSIS
        Sets the default animation mode.
    .PARAMETER Mode
        Animation mode to set (e.g. static, aurora, plasma).
    #>
    [CmdletBinding()]
    param(
        [string]$Mode = ''
    )

    $config = Get-CFConfig

    if ($Mode) {
        $config.animation.mode = $Mode
        Set-CFConfig -Config $config
        Write-Host "Animation mode: $Mode"
    } else {
        Write-Host "Current animation mode: $($config.animation.mode)"
    }
}
