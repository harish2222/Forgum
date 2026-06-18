function Switch-CFLolcat {
    <#
    .SYNOPSIS
        Toggles lolcat rainbow colors on or off.

    .DESCRIPTION
        Quickly flips the configuration setting for lolcat coloring
        between enabled and disabled.

    .EXAMPLE
        Switch-CFLolcat
        Toggles the lolcat setting and displays the new status.

    .EXAMPLE
        lolcat-toggle
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
    param()

    $config = Get-CFConfig
    if (-not $config) {
        Write-Error "Could not retrieve Forgum configuration."
        return
    }

    $config.lolcat.enabled = -not $config.lolcat.enabled
    Set-CFConfig -Config $config

    $status = if ($config.lolcat.enabled) { "ON" } else { "OFF" }
    $color = if ($config.lolcat.enabled) { "Green" } else { "Yellow" }
    Write-Host "Lolcat: $status" -ForegroundColor $color
}
