function Invoke-LiveShow {
    <#
    .SYNOPSIS
        Internal helper for the Forgum Live Showcase.
    .DESCRIPTION
        Manages the show loop: selects cows/fortunes, applies animations,
        and renders frames using Write-TerminalFrame. Shared by Invoke-ForgumLive
        and startup modes.
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

    $startTime = [DateTime]::UtcNow
    $lastLineCount = 0

    while ($true) {
        # Check overall duration
        if ($Duration -gt 0 -and ([DateTime]::UtcNow - $startTime).TotalSeconds -ge $Duration) {
            break
        }

        # 1. Selection
        $cowName = $allCows | Get-Random
        $fortune = Get-Fortune -Database $Config.fortune.database
        $mode = $animationModes | Get-Random

        # 2. Preparation
        $cowParams = @{
            Text = $fortune
            CowFile = $cowName
        }
        $baseCow = Invoke-Cowsay @cowParams

        # 3. Animation / Render Loop
        $frames = 40
        $delay = 50 # ms for smoother feel

        for ($f = 0; $f -lt $frames; $f++) {
            # Check for keys for real-time interaction
            if ([Console]::KeyAvailable) {
                return @{ Status = 'Interrupt'; LastLineCount = $lastLineCount }
            }

            # Apply effective state
            $useAnimation = $Toggles.Animation
            $useLolcat = $Toggles.Lolcat

            $currentFrame = $baseCow

            if ($useAnimation) {
                # Animation Mode Logic
                switch ($mode) {
                    'wiggle' {
                        $offset = [int]([Math]::Sin($f * 0.5) * 3) + 3
                        $indent = ' ' * $offset
                        $currentFrame = ($currentFrame -split "`n" | ForEach-Object { "$indent$_" }) -join "`n"
                    }
                    'bounce' {
                        $offset = [int]([Math]::Abs([Math]::Sin($f * 0.2) * 5))
                        $newlines = "`n" * $offset
                        $currentFrame = "$newlines$currentFrame"
                    }
                    'wave' {
                        # Wave simulation: slight vertical shift per line
                        $lines = $currentFrame -split "`n"
                        $newLines = for ($i = 0; $i -lt $lines.Count; $i++) {
                            $offset = [int]([Math]::Sin(($f + $i) * 0.3) * 2) + 2
                            (' ' * $offset) + $lines[$i]
                        }
                        $currentFrame = $newLines -join "`n"
                    }
                    'dissolve' {
                        # Dissolve: random character replacement (noisy effect)
                        if ($f -lt 10) {
                            $chars = $currentFrame.ToCharArray()
                            for ($i = 0; $i -lt $chars.Length; $i++) {
                                if ($chars[$i] -ne ' ' -and $chars[$i] -ne "`n" -and (Get-Random -Maximum 10) -lt (10 - $f)) {
                                    $chars[$i] = '.'
                                }
                            }
                            $currentFrame = New-Object string($chars, 0, $chars.Length)
                        }
                    }
                    'fade-in' {
                        # Fade in doesn't really work well with just Write-TerminalFrame without color
                        # But we can simulate by showing more lines
                        $lines = $currentFrame -split "`n"
                        $visibleCount = [Math]::Min($lines.Count, [int]($f * ($lines.Count / 20)))
                        if ($visibleCount -lt $lines.Count) {
                            $currentFrame = ($lines[0..$visibleCount] -join "`n")
                        }
                    }
                    'disco' {
                        # Disco: Just vary the seed for lolcat (handled below)
                    }
                }
            }

            if ($useLolcat) {
                $lolcatParams = @{
                    Text = $currentFrame
                    Seed = if ($mode -eq 'disco') { $f * 10 } else { $f }
                }
                $currentFrame = Format-Lolcat @lolcatParams
            }

            # Render
            Write-TerminalFrame -Frame $currentFrame -PreviousLineCount $lastLineCount
            $lastLineCount = ($currentFrame -split "`n").Count

            Start-Sleep -Milliseconds $delay
        }

        if ($RunOnce) {
            break
        }
        
        # Brief pause between cows
        Start-Sleep -Milliseconds 500
    }

    return @{ Status = 'Complete'; LastLineCount = $lastLineCount }
}
