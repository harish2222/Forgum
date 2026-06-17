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

    # Detect if we have a real console for cursor manipulation.
    # [Console]::CursorTop throws on redirected stdout / non-interactive hosts,
    # so wrap the probe in try/catch and fall back to a non-TTY path.
    $hasConsole = $false
    try {
        $null = [Console]::CursorTop
        $hasConsole = $true
    } catch {
        $hasConsole = $false
    }

    # Early-exit if Duration is zero / negative (caller wants one cycle only).
    if ($Duration -le 0) {
        $Duration = 0
    }

    try {
        while ($Duration -le 0 -or [DateTime]::UtcNow -lt $endTime) {
            $now = [DateTime]::UtcNow
            $shouldCycle = ($now - $lastCycle).TotalSeconds -ge $CycleInterval -or $firstRun

            # Check for keypress so user can bail out of the live animation.
            # Wrapped in try/catch because [Console]::KeyAvailable throws on
            # redirected stdin (e.g. when piped from another command).
            if ($hasConsole) {
                $keyPressed = $false
                try {
                    $keyPressed = [Console]::KeyAvailable
                } catch {
                    $keyPressed = $false
                }
                if ($keyPressed) {
                    try {
                        $null = [Console]::ReadKey($true)
                    } catch {
                        # ignore - we're exiting anyway
                    }
                    return $output
                }
            }

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

            # Render with explicit cursor positioning so we don't accumulate
            # frames on screen. Each frame is preceded by a cursor-up + clear-line
            # for every line we previously wrote. The whole thing is one Write-Host
            # call to minimise flicker.
            if ($hasConsole) {
                $lineCount = $balloon.Count
                $esc = [char]27
                $preamble = ''
                for ($lc = 0; $lc -lt $lineCount; $lc++) {
                    $preamble += "$($esc)[2K"   # clear entire line
                    if ($lc -lt ($lineCount - 1)) {
                        $preamble += "$($esc)[1A"  # move up one line
                    }
                }
                $preamble += "`r"               # carriage return to column 0
                Write-Host -NoNewline ($preamble + $output)
            }
            else {
                # Redirected / non-interactive: just emit the frame with a newline.
                Write-Host $output
            }

            Start-Sleep -Milliseconds $frameDelay
        }
    }
    finally {
        if ($hasConsole) {
            try { Write-Host "" } catch {}
        }
    }

    return $output
}
