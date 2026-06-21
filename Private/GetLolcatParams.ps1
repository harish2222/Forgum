function GetLolcatParams {
    <#
    .SYNOPSIS
        Returns resolved lolcat frequency and spread from config.
    .DESCRIPTION
        Centralizes the lolcat parameter fallback logic used by run, cowsay, and export.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    param()

    $config = GetConfig
    $freq = if ($config.lolcat.frequency -and $config.lolcat.frequency -ge 0.01) { $config.lolcat.frequency } else { 0.1 }
    $spread = if ($config.lolcat.spread -and $config.lolcat.spread -ge 0.1) { $config.lolcat.spread } else { 3.0 }

    return @{
        Frequency = $freq
        Spread    = $spread
        Truecolor = $config.lolcat.truecolor
    }
}
