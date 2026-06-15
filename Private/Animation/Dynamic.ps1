function Invoke-DynamicAnimation {
    <#
    .SYNOPSIS
        Cycles through random animals and fortunes continuously.
    .DESCRIPTION
        Picks a random cow and random fortune, displays with a brief
        transition animation, then cycles to the next pair. Runs for
        the configured duration.
    .PARAMETER Duration
        Total animation duration in seconds (default 10).
    .PARAMETER CycleInterval
        Seconds between each cow/fortune change (default 3).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
    param(
        [double]$Duration = 10,
        [double]$CycleInterval = 3
    )

    $config = Get-CFConfig
    $moduleRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
    $cowsPath = Join-Path $moduleRoot 'Data\Cows'
    $fortunesPath = Join-Path $moduleRoot 'Data\Fortunes\fortunes.txt'
    
    $cowFiles = Get-ChildItem -Path $cowsPath -Filter '*.cow' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName
    $fortunes = Get-Content $fortunesPath -Raw -ErrorAction SilentlyContinue
    $fortuneList = if ($fortunes) { $fortunes -split '(?m)^%\s*$' | Where-Object { $_.Trim() } } else { @() }

    if (-not $cowFiles -or -not $fortuneList) {
        return "No cows or fortunes available"
    }

    $startTime = [DateTime]::UtcNow
    $endTime = $startTime.AddSeconds($Duration)
    $frameDelay = 50
    $lastCycle = $startTime
    $currentCow = ''
    $currentFortune = ''
    $firstRun = $true
    $output = ''

    # Detect if we have a real console for cursor manipulation
    $hasConsole = $true
    try {
        $null = [Console]::CursorTop
    } catch {
        $hasConsole = $false
    }

    try {
        while ([DateTime]::UtcNow -lt $endTime) {
            $now = [DateTime]::UtcNow
            $shouldCycle = ($now - $lastCycle).TotalSeconds -ge $CycleInterval -or $firstRun

            if ($shouldCycle) {
                $currentCow = Get-Content ($cowFiles | Get-Random) -Raw
                $currentFortune = $fortuneList | Get-Random
                $lastCycle = $now
                $firstRun = $false
            }

            $cowLines = $currentCow -split "`r?`n"
            $fortuneLines = $currentFortune.Trim() -split "`r?`n"
            
            $maxWidth = ($cowLines | Measure-Object -Property Length -Maximum).Maximum
            $fortuneLines | ForEach-Object { if ($_.Length -gt $maxWidth) { $maxWidth = $_.Length } }
            $balloonWidth = [math]::Max($maxWidth, 40)

            $top = '  ' + ('#' * ($balloonWidth + 4))
            $bottom = '  ' + ('#' * ($balloonWidth + 4))
            $balloon = @()
            $balloon += $top
            foreach ($line in $fortuneLines) {
                $pad = $balloonWidth - $line.Length
                $balloon += "  || $line$(' ' * $pad) ||"
            }
            $balloon += $bottom
            $balloon += $cowLines

            $output = $balloon -join "`n"
            
            if ($config.lolcat.enabled) {
                $lolcatParams = @{
                    Text      = $output
                    Truecolor = $config.lolcat.truecolor
                    Animate   = $config.lolcat.animate
                }
                $output = Format-Lolcat @lolcatParams
            }

            if ($hasConsole) {
                try {
                    $cursorPos = [Console]::CursorTop
                    if ($cursorPos -gt 0) {
                        [Console]::SetCursorPosition(0, $cursorPos - $balloon.Count)
                    }
                } catch {
                    Write-Verbose "DynamicAnimation: Failed to set cursor position: $_"
                }
            }
            Write-Host $output -NoNewline

            Start-Sleep -Milliseconds $frameDelay
        }
    }
    finally {
        Write-Host ""
    }

    return $output
}
