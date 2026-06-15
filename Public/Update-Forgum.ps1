function Update-Forgum {
    <#
    .SYNOPSIS
        Checks for and applies updates to Forgum.
    #>
    [CmdletBinding()]
    param()

    Write-Host "Checking for Forgum updates..." -ForegroundColor Cyan
    
    try {
        $releaseUrl = "https://api.github.com/repos/harish2222/Forgum/releases/latest"
        $release = Invoke-RestMethod -Uri $releaseUrl -UseBasicParsing
        $latestVersion = $release.tag_name -replace '^v',''
        
        $currentVersion = (Get-Module Forgum -ListAvailable)[0].Version.ToString()
        
        if ([version]$latestVersion -gt [version]$currentVersion) {
            Write-Host "Update available! v$currentVersion -> v$latestVersion" -ForegroundColor Yellow
            
            # Detect install method
            $installPath = (Get-Module Forgum -ListAvailable)[0].ModuleBase
            if ($installPath -match 'scoop') {
                Write-Host "[Scoop Install Detected] Run 'scoop update forgum' to upgrade." -ForegroundColor Magenta
                return
            }
            if ($installPath -match 'WindowsApps' -or (Get-Command winget -ErrorAction SilentlyContinue)) {
                # Rough winget detection, advise standard winget flow just in case
                Write-Host "Run 'winget upgrade HKDEVS.Forgum' to upgrade via Winget, or press Y to force standalone update." -ForegroundColor Magenta
                $choice = Read-Host "Force standalone update? (y/N)"
                if ($choice -notmatch '^[yY]') { return }
            }
            
            Write-Host "Downloading and installing v$latestVersion..." -ForegroundColor Cyan
            $installScriptUrl = "https://raw.githubusercontent.com/harish2222/Forgum/main/install.ps1"
            iex ((New-Object System.Net.WebClient).DownloadString($installScriptUrl)) -Silent
            Write-Host "Update complete! Restart your shell to use the new version." -ForegroundColor Green
        } else {
            Write-Host "You are on the latest version (v$currentVersion)." -ForegroundColor Green
        }
    } catch {
        Write-Warning "Failed to check for updates: $_"
    }
}
