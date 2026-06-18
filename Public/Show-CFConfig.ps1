function Show-CFConfig {
    <#
    .SYNOPSIS
        Displays the current Forgum configuration as formatted JSON.

    .DESCRIPTION
        Reads your local configuration file and outputs it in an easy-to-read
        JSON format. Useful for debugging or verifying settings.

    .EXAMPLE
        Show-CFConfig

    .EXAMPLE
        cowconfig
    #>
    [CmdletBinding()]
    param()

    $config = Get-CFConfig
    if (-not $config) {
        Write-Error "Could not retrieve Forgum configuration."
        return
    }

    $config | ConvertTo-Json -Depth 4
}
