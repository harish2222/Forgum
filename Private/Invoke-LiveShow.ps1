function Invoke-LiveShow {
    <#
    .SYNOPSIS
        Internal helper for the Forgum Live Showcase.
    .DESCRIPTION
        Manages the show loop: selects cows/fortunes, applies animations,
        and renders via Rust animation engine.
    .PARAMETER RunOnce
        If set, performs exactly one cow/fortune animation and exits.
    .PARAMETER Duration
        Total duration to run in seconds. If 0, runs indefinitely (unless RunOnce).
    .PARAMETER Config
        Optional configuration object.
    .PARAMETER Toggles
        Hashtable containing real-time toggles (Lolcat, Animation).
    #>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
    param(
        [switch]$RunOnce,
        [double]$Duration = 0,
        [PSObject]$Config,
        [hashtable]$Toggles = @{ Lolcat = $true; Animation = $true }
    )

    if ($null -eq $Config) {
        $Config = Get-CFConfig
    }

    $allCows = Get-CFCow
    $animationModes = @('wave', 'bounce', 'dissolve', 'fade-in', 'wiggle', 'disco')
    $lastLineCount = 0

    # When Animation is enabled we call the Rust engine with Duration=0 (loop forever)
    # and therefore we DO NOT run an additional PowerShell loop.
    if ($Toggles.Animation) {
        $cowName = $allCows | Get-Random
        $fortune = Get-Fortune -Database $Config.fortune.database
        $mode = $animationModes | Get-Random

        $baseCow = Invoke-Cowsay -Text $fortune -CowFile $cowName

        $engineEffect = switch ($mode) {
            'wiggle'   { 'aurora' }
            'bounce'   { 'ember' }
            'wave'     { 'glitch' }
            'dissolve' { 'shatter' }
            'fade-in'  { 'neon-pulse' }
            'disco'    { 'plasma' }
            default     { 'plasma' }
        }

        $cowText = $baseCow
        if ($Toggles.Lolcat) {
            $lolSeed = Get-Random -Maximum 10001
            $cowText = Format-Lolcat -Text $cowText -Seed $lolSeed
        }

        $fullText = $fortune
        if ($cowText) { $fullText = "$fortune`n$cowText" }
        $payload = @{
            type       = 'render'
            effect     = $engineEffect
            cow_text   = $fullText
            background = $false
            duration   = 0
            fps        = 30
        } | ConvertTo-Json -Depth 5 -Compress
        $result = $payload | Invoke-Engine
        if ($null -eq $result) {
            Write-Host $fortune
            Write-Host $cowText
        }

        $lastLineCount = ($cowText -split "`n").Count
        return @{ Status = 'Complete'; LastLineCount = $lastLineCount }
    }

    # Animation disabled: run a short static-ish render repeatedly until RunOnce/Duration ends.
    $startTime = [DateTime]::UtcNow
    while ($true) {
        if ($Duration -gt 0 -and ([DateTime]::UtcNow - $startTime).TotalSeconds -ge $Duration) {
            break
        }

        $cowName = $allCows | Get-Random
        $fortune = Get-Fortune -Database $Config.fortune.database
        $mode = $animationModes | Get-Random

        $baseCow = Invoke-Cowsay -Text $fortune -CowFile $cowName

        # All legacy modes map to plasma effect for the engine
        $engineEffect = 'plasma'

        $cowText = $baseCow
        if ($Toggles.Lolcat) {
            $lolSeed = Get-Random -Maximum 10001
            $cowText = Format-Lolcat -Text $cowText -Seed $lolSeed
        }

        $fullText = $fortune
        if ($cowText) { $fullText = "$fortune`n$cowText" }
        $payload = @{
            type       = 'render'
            effect     = $engineEffect
            cow_text   = $fullText
            background = $false
            duration   = 250
            fps        = 1
        } | ConvertTo-Json -Depth 5 -Compress
        $result = $payload | Invoke-Engine
        if ($null -eq $result) {
            Write-Host $fortune
            Write-Host $cowText
        }

        $lastLineCount = ($cowText -split "`n").Count

        if ($RunOnce) { break }
        Start-Sleep -Milliseconds 500
    }

    return @{ Status = 'Complete'; LastLineCount = $lastLineCount }
}
