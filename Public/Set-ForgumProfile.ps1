function Set-ForgumProfile {
    <#
    .SYNOPSIS
        Updates the PowerShell profile with Forgum integration blocks.
    .DESCRIPTION
        Consolidates Forgum startup hooks, aliases, and tab completion into
        a managed region within the user's PowerShell profile.
    .PARAMETER FortuneOnStartup
        Include the random cow + fortune invocation on shell start.
    .PARAMETER AddAliases
        Include helpful aliases like cowconfig, cowpreview.
    .PARAMETER AddCompletion
        Include tab completion for Invoke-Cowsay cow files.
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [bool]$FortuneOnStartup = $true,
        [bool]$AddAliases = $true,
        [bool]$AddCompletion = $true
    )

    $profilePath = $PROFILE.CurrentUserAllHosts
    if (-not $profilePath) { $profilePath = $PROFILE.CurrentUser }
    
    if (-not $profilePath) {
        Write-Warning "No valid PowerShell profile path found."
        return
    }

    $profileDir = Split-Path $profilePath -Parent
    if (-not (Test-Path $profileDir)) {
        if ($PSCmdlet.ShouldProcess("Create profile directory $profileDir", "Create Directory")) {
            New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
        }
    }
    
    $existingProfile = if (Test-Path $profilePath) { Get-Content $profilePath -Raw } else { '' }
    
    $blockLines = [System.Collections.Generic.List[string]]::new()
    $blockLines.Add("# region FORGUM")
    $blockLines.Add("# This section is managed by Forgum. Manually editing may affect its ability to update.")
    $blockLines.Add("`$env:FORGUM_NOAUTOSTART = '1'")
    $blockLines.Add("Import-Module Forgum -ErrorAction SilentlyContinue")
    
    if ($FortuneOnStartup) {
        $blockLines.Add("")
        $blockLines.Add("if (-not `$global:FORGUM_STARTUP_DONE) {")
        $blockLines.Add("    `$global:FORGUM_STARTUP_DONE = `$true")
        $blockLines.Add("    if (Get-Command Invoke-Forgum -ErrorAction Ignore) { Invoke-Forgum }")
        $blockLines.Add("}")
    }
    
    $blockLines.Add("# endregion FORGUM")
    
    $forgumBlock = ($blockLines -join "`r`n")
    
    $cleanedProfile = $existingProfile
    $cleanedProfile = $cleanedProfile -replace '(?s)\r?\n# Forgum Startup Fortune Cow.*?Show-FortuneCow\r?\n}', ''
    $cleanedProfile = $cleanedProfile -replace '(?s)\r?\n# Forgum Aliases.*?function cow-animate.*?}', ''
    $cleanedProfile = $cleanedProfile -replace '(?s)\r?\n# Forgum Tab Completion.*?Register-ArgumentCompleter.*?}', ''
    $cleanedProfile = $cleanedProfile -replace '(?s)\r?\n# Forgum\r?\nImport-Module Forgum -ErrorAction SilentlyContinue', ''
    $cleanedProfile = $cleanedProfile -replace '(?s)\r?\n# region FORGUM.*?# endregion FORGUM\r?\n?', ''
    
    if ($cleanedProfile -match '(?s)# region FORGUM.*?# endregion FORGUM') {
        $escapedBlock = $forgumBlock -replace '\$', '$$$$'
        $newProfile = $cleanedProfile -replace '(?s)# region FORGUM.*?# endregion FORGUM', $escapedBlock
        Write-Verbose "Updated Forgum block in profile"
    } else {
        $newProfile = $cleanedProfile.Trim() + "`r`n`r`n" + $forgumBlock
        Write-Verbose "Added Forgum block to profile"
    }
    
    if ($PSCmdlet.ShouldProcess("Profile $profilePath", "Update Forgum Settings")) {
        if (Test-Path $profilePath) {
            $backupPath = "$profilePath.bak.$(Get-Date -Format 'yyyyMMddHHmmss')"
            Copy-Item -Path $profilePath -Destination $backupPath -Force
        }
        Set-Content -Path $profilePath -Value $newProfile.Trim() -Force -Encoding utf8NoBOM
        Write-Host "Profile updated successfully: $profilePath" -ForegroundColor Green
    }
}
