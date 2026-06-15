function Update-Forgum {
    <#
    .SYNOPSIS
        Checks for and applies updates to Forgum.
    .PARAMETER Force
        Force a standalone update, skipping manual confirmation if an installer (Scoop/Winget) is detected.
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [switch]$Force
    )

    Write-Host "Checking for Forgum updates..." -ForegroundColor Cyan
    
    try {
        $releaseUrl = "https://api.github.com/repos/harish2222/Forgum/releases/latest"
        $release = Invoke-RestMethod -Uri $releaseUrl -UseBasicParsing
        $latestVersion = $release.tag_name -replace '^v',''
        
        # Get current version robustly from module context or loaded module
        $module = $ExecutionContext.SessionState.Module
        if (-not $module -or $module.Name -ne 'Forgum') {
            $module = Get-Module Forgum -ErrorAction SilentlyContinue | Select-Object -First 1
        }
        
        if (-not $module) {
            Write-Warning "Forgum module not found in current session. Cannot determine current version."
            return
        }
        
        $currentVersion = $module.Version.ToString()
        $installPath = $module.ModuleBase
        
        if ([version]$latestVersion -gt [version]$currentVersion) {
            Write-Host "Update available! v$currentVersion -> v$latestVersion" -ForegroundColor Yellow
            
            # Detect install method
            if ($installPath -match 'scoop' -and -not $Force) {
                Write-Host "[Scoop Install Detected] Run 'scoop update forgum' to upgrade." -ForegroundColor Magenta
                Write-Host "Use -Force to override and run standalone update." -ForegroundColor Gray
                return
            }
            
            if (($installPath -match 'WindowsApps' -or (Get-Command winget -ErrorAction SilentlyContinue)) -and -not $Force) {
                Write-Host "Winget or WindowsApps detected. Prefer 'winget upgrade HKDEVS.Forgum'." -ForegroundColor Magenta
                $choice = Read-Host "Force standalone update instead? (y/N)"
                if ($choice -notmatch '^[yY]') { return }
            }
            
            Write-Host "Downloading and installing v$latestVersion..." -ForegroundColor Cyan
            $installScriptUrl = "https://raw.githubusercontent.com/harish2222/Forgum/main/install.ps1"
            
            $tempFile = Join-Path ([System.IO.Path]::GetTempPath()) "install_forgum_$(Get-Date -Format 'yyyyMMddHHmmss').ps1"
            try {
                Invoke-WebRequest -Uri $installScriptUrl -OutFile $tempFile -UseBasicParsing
                # Execute downloaded script with -Silent flag
                & $tempFile -Silent
                Write-Host "Update complete! Restart your shell to use the new version." -ForegroundColor Green
            }
            finally {
                if (Test-Path $tempFile) {
                    Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
                }
            }
        } else {
            Write-Host "You are on the latest version (v$currentVersion)." -ForegroundColor Green
        }
    } catch {
        Write-Warning "Failed to check for updates: $_"
    }
}
