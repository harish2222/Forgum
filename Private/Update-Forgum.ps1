function Update-Forgum {
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
        Write-Host "Current version: $currentVersion"
        Write-Host "Check GitHub for latest version: https://github.com/harish2222/Forgum/releases"
        return
    }

    if ($Force) {
        Write-Host "Force-updating Forgum (current: $currentVersion)..." -ForegroundColor Cyan
    } else {
        Write-Host "Updating Forgum (current: $currentVersion)..." -ForegroundColor Cyan
    }
    Write-Host "Run: iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/harish2222/Forgum/main/install.ps1'))" -ForegroundColor Yellow
    Write-Host "Or: Update-Module Forgum" -ForegroundColor Yellow
}
