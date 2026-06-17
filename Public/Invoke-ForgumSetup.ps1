function Invoke-ForgumSetup {
    <#
    .SYNOPSIS
        Re-run the interactive configuration wizard for Forgum.
    .PARAMETER NonInteractive
        Forwarded to setup.ps1. Skip all prompts and use defaults.
    .PARAMETER Force
        Forwarded to setup.ps1. Overwrite existing config without asking.
    .PARAMETER NoProfile
        Forwarded to setup.ps1. Do not modify the PowerShell profile.
    .EXAMPLE
        forgum-setup
        forgum-setup -NonInteractive -Force
    #>
    [CmdletBinding()]
    [Alias('forgum-setup')]
    param(
        [switch]$NonInteractive,
        [switch]$Force,
        [switch]$NoProfile
    )

    $setupScript = Join-Path (Split-Path $PSScriptRoot -Parent) 'setup.ps1'
    if (-not (Test-Path $setupScript)) {
        Write-Warning "Setup script not found at $setupScript"
        return
    }

    # Build a splat so we only forward switches the caller actually set.
    $forward = @{}
    if ($PSBoundParameters.ContainsKey('NonInteractive')) { $forward.NonInteractive = $NonInteractive }
    if ($PSBoundParameters.ContainsKey('Force'))          { $forward.Force = $Force }
    if ($PSBoundParameters.ContainsKey('NoProfile'))      { $forward.NoProfile = $NoProfile }

    if ($forward.Count -gt 0) {
        & $setupScript @forward
    } else {
        & $setupScript
    }
}
