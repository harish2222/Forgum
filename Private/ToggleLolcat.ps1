function ToggleLolcat {
    <#
    .SYNOPSIS
        Toggles the lolcat (rainbow) enabled setting.
    .DESCRIPTION
        Reads the current config, flips lolcat.enabled, saves, and reports.
    #>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
    param()

    $config = GetConfig
    $config.lolcat.enabled = -not $config.lolcat.enabled
    SetConfig -Config $config -Confirm:$false
    $state = if ($config.lolcat.enabled) { 'ON' } else { 'OFF' }
    "Lolcat: $state"
}
