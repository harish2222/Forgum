function Toggle-CFLolcat {
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

    $config = Get-CFConfig
    $config.lolcat.enabled = -not $config.lolcat.enabled
    Set-CFConfig -Config $config
    $state = if ($config.lolcat.enabled) { 'ON' } else { 'OFF' }
    Write-Host "Lolcat: $state"
}
