function Set-Forgum {
    <#
    .SYNOPSIS
        Sets Forgum configuration options persistently.
    .DESCRIPTION
        Updates the global config.json with new settings for animations, cows, and colors.
    .PARAMETER Animation
        The animation mode to use.
    .PARAMETER Cow
        The name of the cow character file.
    .PARAMETER Eyes
        Two-character string for the cow's eyes.
    .PARAMETER Lolcat
        Enable or disable rainbow colors.
    .PARAMETER RandomCow
        Enable or disable random cow selection on startup.
    .PARAMETER RainbowFrequency
        Sets the frequency of the rainbow colors.
    .EXAMPLE
        Set-Forgum -Animation bounce -Cow dragon
    .EXAMPLE
        Set-Forgum -Lolcat $true -RainbowFrequency 0.2
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateSet('static', 'talking', 'typewriter', 'slide-in', 'bounce', 'dissolve', 'fade-in', 'blink', 'wiggle', 'wave', 'disco', 'dynamic')]
        [string]$Animation,

        [Parameter()]
        [string]$Cow,

        [Parameter()]
        [string]$Eyes,

        [Parameter()]
        [bool]$Lolcat,

        [Parameter()]
        [bool]$RandomCow,

        [Parameter()]
        [double]$RainbowFrequency
    )

    $config = Get-CFConfig
    if ($PSBoundParameters.ContainsKey('Animation'))        { $config.animation.mode = $Animation }
    if ($PSBoundParameters.ContainsKey('Cow'))              { $config.cow.file = $Cow }
    if ($PSBoundParameters.ContainsKey('Eyes'))             { $config.cow.eyes = $Eyes }
    if ($PSBoundParameters.ContainsKey('Lolcat'))           { $config.lolcat.enabled = $Lolcat }
    if ($PSBoundParameters.ContainsKey('RandomCow'))        { $config.cow.random = $RandomCow }
    if ($PSBoundParameters.ContainsKey('RainbowFrequency')) { $config.lolcat.frequency = $RainbowFrequency }

    Set-CFConfig -Config $config
    Write-Host "Forgum configuration updated successfully." -ForegroundColor Green
}
