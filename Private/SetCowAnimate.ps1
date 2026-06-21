function SetCowAnimate {
    <#
    .SYNOPSIS
        Sets the default animation mode.
    .PARAMETER Mode
        Animation mode to set (e.g. static, aurora, plasma).
    #>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    param(
        [string]$Mode = ''
    )

    $config = GetConfig

    if ($Mode) {
        $config.animation.mode = $Mode
        SetConfig -Config $config -Confirm:$false
        "Animation mode: $Mode"
    } else {
        "Current animation mode: $($config.animation.mode)"
    }
}
