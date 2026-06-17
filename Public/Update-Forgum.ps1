function Update-Forgum {
    <#
    .SYNOPSIS
        Checks for and applies updates to Forgum.
    .PARAMETER Force
        Force a standalone update, skipping manual confirmation if an installer (Scoop/Winget) is detected.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
    param(
        [Parameter()]
        [switch]$Force
    )

    Write-Host "Checking for Forgum updates..." -ForegroundColor Cyan
    
    # GitHub requires a User-Agent and (for v3) an Accept header that opts into
    # the vnd.github+json content type. Without these the request can be
    # rate-limited or return HTML on unauthenticated calls.
    $ghHeaders = @{
        'Accept'     = 'application/vnd.github+json'
        'User-Agent' = 'Forgum-Updater'
    }

    try {
        $releaseUrl = "https://api.github.com/repos/harish2222/Forgum/releases/latest"
        $release = Invoke-RestMethod -Uri $releaseUrl -Headers $ghHeaders -UseBasicParsing
        $latestVersion = ($release.tag_name -replace '^v','')

        # Some pre-release tags (e.g. v1.2.0-beta.1) cannot be cast to [version]
        # and would throw a terminating error. Strip any pre-release suffix and
        # fall back to a string compare if the cast still fails.
        $latestComparable = $null
        $cleanTag = ($latestVersion -split '-' | Select-Object -First 1)
        try {
            $latestComparable = [version]$cleanTag
        } catch {
            Write-Warning "Could not parse latest version '$latestVersion' as a SemVer number; skipping update."
            return
        }
        
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
        
        if ($latestComparable -gt [version]$currentVersion) {
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
            
            if ($PSCmdlet.ShouldProcess("v$latestVersion", "Install Forgum Update")) {
                Write-Host "Downloading and installing v$latestVersion..." -ForegroundColor Cyan

                # Download the source zipball from the release. The previous
                # implementation downloaded install.ps1 and ran the full
                # installer, which overwrites the user's $PROFILE. The safer
                # standalone path is to unzip the module files into the existing
                # install location and leave the profile untouched.
                $zipUrl = $release.zipball_url
                if (-not $zipUrl) {
                    # Fall back to the first .zip asset on the release.
                    $zipAsset = $release.assets | Where-Object { $_.name -like '*.zip' } | Select-Object -First 1
                    $zipUrl = $zipAsset.browser_download_url
                }
                if (-not $zipUrl) {
                    Write-Warning "No downloadable archive found for release v$latestVersion."
                    return
                }

                $tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) "forgum_update_$(Get-Date -Format 'yyyyMMddHHmmss')"
                $null = New-Item -ItemType Directory -Path $tempRoot -Force
                $zipPath = Join-Path $tempRoot 'forgum.zip'
                try {
                    Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -UseBasicParsing
                    Expand-Archive -Path $zipPath -DestinationPath $tempRoot -Force

                    # GitHub zipball extracts into a single top-level folder
                    # named like 'harish2222-Forgum-<sha>'. Locate it.
                    $extractedRoot = Get-ChildItem -Path $tempRoot -Directory |
                        Where-Object { $_.Name -like '*Forgum*' } |
                        Select-Object -First 1
                    if (-not $extractedRoot) {
                        Write-Warning "Could not locate extracted module folder in $tempRoot."
                        return
                    }

                    # Copy module files into the existing install path. Use
                    # -Recurse -Force so individual files are overwritten but
                    # user-added files outside the module payload are preserved.
                    Copy-Item -Path (Join-Path $extractedRoot.FullName '*') `
                              -Destination $installPath `
                              -Recurse -Force

                    Write-Host "Update complete! Restart your shell to use the new version." -ForegroundColor Green
                }
                finally {
                    if (Test-Path $tempRoot) {
                        Remove-Item $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
                    }
                }
            }
        } else {
            Write-Output "You are on the latest version (v$currentVersion)."
        }
    } catch {
        Write-Warning "Failed to check for updates: $_"
    }
}
