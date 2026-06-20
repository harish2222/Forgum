function Invoke-ForgumTUI {
    <#
    .SYNOPSIS
        Launches the interactive configuration TUI.
    .DESCRIPTION
        Opens an interactive terminal UI for editing Forgum configuration.
    #>
    [CmdletBinding()]
    param()

    Write-Host "=== Forgum Configuration ===" -ForegroundColor Cyan
    $config = Get-CFConfig
    Write-Host ($config | ConvertTo-Json -Depth 4)
    Write-Host ""
    Write-Host "Edit config.json directly to change settings." -ForegroundColor Yellow
    $path = Get-ConfigPath
    Write-Host "Config path: $path"
}
