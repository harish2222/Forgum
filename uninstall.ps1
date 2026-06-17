<#
.SYNOPSIS
    Uninstalls Forgum module.
.DESCRIPTION
    Removes the module, config, and shell integration.
.EXAMPLE
    .\uninstall.ps1
#>

[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
param()

Write-Host ""
Write-Host "  Forgum Uninstaller" -ForegroundColor Cyan
Write-Host ""

# Remove module
$installDir = Join-Path ([Environment]::GetFolderPath('MyDocuments')) "PowerShell\Modules\Forgum"
if (-not $installDir -or -not (Test-Path $installDir)) {
    $installDir = Join-Path $HOME "Documents/PowerShell/Modules/Forgum"
}
if (-not $installDir -or -not (Test-Path $installDir)) {
    $installDir = Join-Path $HOME ".local/share/powershell/Modules/Forgum"
}
if (Test-Path $installDir) {
    Remove-Item $installDir -Recurse -Force
    Write-Host "  Removed module: $installDir" -ForegroundColor Green
}

# Remove config
$configDir = Join-Path ([Environment]::GetFolderPath('MyDocuments')) "PowerShell\Forgum"
if (Test-Path $configDir) {
    Remove-Item $configDir -Recurse -Force
    Write-Host "  Removed config: $configDir" -ForegroundColor Green
}

# Remove from profile
$profilePath = $PROFILE.CurrentUserAllHosts
if (Test-Path $profilePath) {
    $content = Get-Content $profilePath -Raw
    if ($content -match 'Forgum') {
        # Remove region-based blocks first
        $newContent = $content -replace '(?s)\r?\n*\s*# region FORGUM.*?# endregion FORGUM\r?\n*', "`n"
        # Remove legacy scattered blocks
        $newContent = $newContent -replace '(?s)\r?\n*# Forgum Startup Fortune Cow.*?Show-FortuneCow\r?\n}', ''
        $newContent = $newContent -replace '(?s)\r?\n*# Forgum Aliases.*?function cow-animate.*?}', ''
        $newContent = $newContent -replace '(?s)\r?\n*# Forgum Tab Completion.*?Register-ArgumentCompleter.*?}', ''
        $newContent = $newContent -replace '(?s)\r?\n*# Forgum\r?\nImport-Module Forgum -ErrorAction SilentlyContinue\r?\n*', ''
        # Fallback: remove any remaining Forgum import line
        $newContent = $newContent -replace '(?s)\r?\n*Import-Module Forgum[^\n]*\r?\n*', ''
        Set-Content -Path $profilePath -Value $newContent.TrimEnd() -Encoding utf8NoBOM
        Write-Host "  Removed from PowerShell profile" -ForegroundColor Green
    }
}

# Remove from bash/zsh/fish
$homeDir = if ($env:USERPROFILE) { $env:USERPROFILE } else { $HOME }
foreach ($file in @("$homeDir/.bashrc", "$homeDir/.zshrc", "$homeDir/.config/fish/config.fish")) {
    if (Test-Path $file) {
        $content = Get-Content $file -Raw
        if ($content -match 'Forgum') {
            # Remove Forgum blocks (bash/zsh style and fish style)
            $newContent = $content -replace '(?s)\r?\n*# Forgum.*?^fi\r?\n?', ''
            $newContent = $newContent -replace '(?s)\r?\n*# Forgum.*?^end\r?\n?', ''
            $newContent = $newContent -replace '(?s)\r?\n*# Forgum.*?pwsh.*?Forgum.*?\r?\n?', ''
            Set-Content -Path $file -Value $newContent.TrimEnd()
            Write-Host "  Removed from $file" -ForegroundColor Green
        }
    }
}

Write-Host ""
Write-Host "  Forgum uninstalled successfully!" -ForegroundColor Green
Write-Host ""
