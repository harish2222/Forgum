function Invoke-ForgumSetup {
    <#
    .SYNOPSIS
        Re-run the interactive configuration wizard for Forgum.
    #>
    [CmdletBinding()]
    [Alias('forgum-setup')]
    param()
    
    $setupScript = Join-Path (Split-Path $PSScriptRoot -Parent) "setup.ps1"
    if (Test-Path $setupScript) {
        & $setupScript
    } else {
        Write-Warning "Setup script not found at $setupScript"
    }
}
