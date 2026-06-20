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
    $cowsPath = Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) 'Data' 'Cows'
    $cowNames = Get-ChildItem -Path $cowsPath -Filter '*.cow' -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty BaseName

    if (-not $cowNames -or $cowNames.Count -eq 0) {
        return "No cows available"
    }

    $startTime = [DateTime]::UtcNow
    $endTime = $startTime.AddSeconds($Duration)
    $frameDelay = 50
    $lastCycle = $startTime
    $currentOutput = ''
    $firstRun = $true
    $output = ''

    $hasConsole = $false
    try {
        $null = [Console]::CursorTop
        $hasConsole = $true
    } catch {
        $hasConsole = $false
    }

    try {
        while ($Duration -le 0 -or [DateTime]::UtcNow -lt $endTime) {
            $now = [DateTime]::UtcNow
            $shouldCycle = ($now - $lastCycle).TotalSeconds -ge $CycleInterval -or $firstRun

            if ($hasConsole) {
                $keyPressed = $false
                try {
                    $keyPressed = [Console]::KeyAvailable
                } catch {
                    $keyPressed = $false
                }
                if ($keyPressed) {
                    try { $null = [Console]::ReadKey($true) } catch {
                        Write-Verbose "Non-critical error ignored"
                    }
                    return $output
                }
            }

            if ($shouldCycle) {
                $cowName = $cowNames | Get-Random
                $fortune = Get-Fortune
                $currentOutput = Invoke-Cowsay -Text $fortune -CowFile $cowName
                $lastCycle = $now
                $firstRun = $false
            }

            $output = $currentOutput

            if ($config.lolcat.enabled) {
                $freq = if ($config.lolcat.frequency -and $config.lolcat.frequency -ge 0.01) { $config.lolcat.frequency } else { 0.1 }
                $spread = if ($config.lolcat.spread -and $config.lolcat.spread -ge 0.1) { $config.lolcat.spread } else { 3.0 }
                $output = Format-Lolcat -Text $output -Frequency $freq -Spread $spread -Truecolor $config.lolcat.truecolor
            }

            if ($hasConsole) {
                $lineCount = ($currentOutput -split "`r?`n").Count
                $esc = [char]27
                $preamble = ''
                for ($lc = 0; $lc -lt $lineCount; $lc++) {
                    $preamble += "$($esc)[2K"
                    if ($lc -lt ($lineCount - 1)) {
                        $preamble += "$($esc)[1A"
                    }
                }
                $preamble += "`r"
                Write-Host -NoNewline ($preamble + $output)
            }
            else {
                Write-Host $output
            }

            Start-Sleep -Milliseconds $frameDelay
        }
    }
    finally {
        if ($hasConsole) {
            try { Write-Host "" } catch {
                Write-Verbose "Non-critical error ignored"
            }
        }
    }

    return $output
}
