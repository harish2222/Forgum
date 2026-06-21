function UpdateForgum {
    <#
    .SYNOPSIS
        Updates Forgum to the latest version.
    .PARAMETER Force
        Force update even if up-to-date.
    .PARAMETER CheckOnly
        Only check if update is available.
    #>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    param(
        [switch]$Force,
        [switch]$CheckOnly
    )

    $manifest = Test-ModuleManifest -Path (Join-Path (Split-Path $PSScriptRoot -Parent) 'Forgum.psd1') -ErrorAction SilentlyContinue
    $currentVersion = if ($manifest) { $manifest.Version.ToString() } else { 'unknown' }

    if ($CheckOnly) {
        "Current version: $currentVersion"
        "Check GitHub for latest version: https://github.com/harish2222/Forgum/releases"
        return
    }

    if ($Force) {
        "Force-updating Forgum (current: $currentVersion)..."
    } else {
        "Updating Forgum (current: $currentVersion)..."
    }
    "Run: iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/harish2222/Forgum/main/install.ps1'))"
    "Or: Update-Module Forgum"
}
