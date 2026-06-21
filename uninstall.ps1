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

Write-Host "`n  Forgum Uninstaller`n" -ForegroundColor Cyan

# Remove module
$installDir = Join-Path ([Environment]::GetFolderPath('MyDocuments')) "PowerShell\Modules\Forgum"
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

# Remove from PowerShell profile
$profilePath = $PROFILE.CurrentUserAllHosts
if (-not $profilePath) { $profilePath = $PROFILE.CurrentUser }
if ($profilePath -and (Test-Path $profilePath)) {
    $content = Get-Content $profilePath -Raw
    if ($content -match 'Forgum') {
        $newContent = $content -replace '(?s)\r?\n*# region FORGUM.*?# endregion FORGUM\r?\n*', "`n"
        $newContent = $newContent -replace '(?s)\r?\n*# Forgum Startup Fortune Cow.*?Show-FortuneCow\r?\n}', ''
        $newContent = $newContent -replace '(?s)\r?\n*# Forgum Aliases.*?function cow-animate.*?}', ''
        $newContent = $newContent -replace '(?s)\r?\n*# Forgum Tab Completion.*?Register-ArgumentCompleter.*?}', ''
        $newContent = $newContent -replace '(?s)\r?\n*# Forgum\r?\nImport-Module Forgum -ErrorAction SilentlyContinue\r?\n*', ''
        $newContent = $newContent -replace '(?s)\r?\n*Import-Module Forgum[^\n]*\r?\n*', ''
        Set-Content -Path $profilePath -Value $newContent.TrimEnd() -Encoding UTF8 -Force
        Write-Host "  Removed from PowerShell profile" -ForegroundColor Green
    }
}

# Remove from bash/zsh/fish
$homeDir = if ($env:USERPROFILE) { $env:USERPROFILE } else { $HOME }
foreach ($file in @("$homeDir/.bashrc", "$homeDir/.zshrc", "$homeDir/.config/fish/config.fish")) {
    if (Test-Path $file) {
        $content = Get-Content $file -Raw
        if ($content -match 'Forgum') {
            $newContent = $content -replace '(?s)\r?\n*# Forgum.*?^fi\r?\n?', ''
            $newContent = $newContent -replace '(?s)\r?\n*# Forgum.*?^end\r?\n?', ''
            $newContent = $newContent -replace '(?s)\r?\n*# Forgum.*?pwsh.*?Forgum.*?\r?\n?', ''
            Set-Content -Path $file -Value $newContent.TrimEnd()
            Write-Host "  Removed from $file" -ForegroundColor Green
        }
    }
}

Write-Host "`n  Forgum uninstalled.`n" -ForegroundColor Green
