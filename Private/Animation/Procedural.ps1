function Invoke-ProceduralAnimation {
    <#
    .SYNOPSIS
        Applies procedural mathematical effects to a cow output.
    .DESCRIPTION
        Takes any multiline cow string and applies procedural effects
        like Snow, Matrix, Breathe, or ColorWave.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$CowOutput,

        [Parameter()]
        [int]$Duration = 30,

        [Parameter()]
        [ValidateSet('Snow', 'Matrix', 'Breathe', 'ColorWave', 'Random')]
        [string]$Effect = 'Random'
    )

    if ($Effect -eq 'Random') {
        $effects = @('Snow', 'Matrix', 'Breathe', 'ColorWave')
        $Effect = $effects | Get-Random
    }

    $lines = $CowOutput -split "`r?`n"
    $height = $lines.Count
    $width = 0
    foreach ($line in $lines) {
        $clean = $line -replace '\x1b\[[0-9;]*m', ''
        if ($clean.Length -gt $width) { $width = $clean.Length }
    }
    
    $canvas = [System.Collections.Generic.List[string]]::new()
    foreach ($line in $lines) {
        $clean = $line -replace '\x1b\[[0-9;]*m', ''
        if ($clean.Length -lt $width) {
            $canvas.Add($clean + (' ' * ($width - $clean.Length)))
        } else {
            $canvas.Add($clean)
        }
    }

    $fps = 15
    $totalFrames = $Duration
    if ($totalFrames -lt 1) { $totalFrames = 30 }
    $delayMs = [int](1000 / $fps)

    $sb = [System.Text.StringBuilder]::new()
    $esc = [char]27

    # State variables
    $snowflakes = [System.Collections.Generic.List[PSCustomObject]]::new()
    $matrixCols = [System.Collections.Generic.List[PSCustomObject]]::new()
    for ($i = 0; $i -lt $width; $i++) {
        $matrixCols.Add([PSCustomObject]@{
            Pos = Get-Random -Minimum (-$height) -Maximum 0
            Speed = Get-Random -Minimum 1 -Maximum 3
            Char = [char](Get-Random -Minimum 33 -Maximum 126)
        })
    }

    # Hide cursor
    if (-not [Console]::IsOutputRedirected) {
        try { Write-Host -NoNewline "$esc[?25l" } catch {}
    }

    try {
        for ($frame = 0; $frame -lt $totalFrames; $frame++) {
            [void]$sb.Clear()

            switch ($Effect) {
                'Snow' {
                    if ((Get-Random -Minimum 0 -Maximum 100) -lt 40) {
                        $spawnMax = [Math]::Max(1, $width - 1)
                        $snowflakes.Add([PSCustomObject]@{ X = (Get-Random -Minimum 0 -Maximum $spawnMax); Y = 0 })
                    }

                    $newSnow = [System.Collections.Generic.List[PSCustomObject]]::new()
                    foreach ($sf in $snowflakes) {
                        $sf.Y++
                        if ($sf.Y -lt $height) { $newSnow.Add($sf) }
                    }
                    $snowflakes = $newSnow

                    for ($y = 0; $y -lt $height; $y++) {
                        $lineChars = $canvas[$y].ToCharArray()
                        foreach ($sf in $snowflakes) {
                            if ($sf.Y -eq $y -and $sf.X -lt $lineChars.Length) {
                                if ($lineChars[$sf.X] -eq ' ') {
                                    $lineChars[$sf.X] = '*'
                                }
                            }
                        }
                        [void]$sb.AppendLine(-join $lineChars)
                    }
                }
                'Matrix' {
                    for ($i = 0; $i -lt $width; $i++) {
                        if ((Get-Random -Minimum 0 -Maximum 10) -lt 2) {
                            $matrixCols[$i].Char = [char](Get-Random -Minimum 33 -Maximum 126)
                        }
                        if ($frame % $matrixCols[$i].Speed -eq 0) {
                            $matrixCols[$i].Pos++
                            if ($matrixCols[$i].Pos -ge $height) {
                                $matrixCols[$i].Pos = Get-Random -Minimum (-$height) -Maximum 0
                            }
                        }
                    }

                    for ($y = 0; $y -lt $height; $y++) {
                        $lineChars = $canvas[$y].ToCharArray()
                        for ($x = 0; $x -lt $width; $x++) {
                            if ($lineChars[$x] -eq ' ') {
                                if ($matrixCols[$x].Pos -eq $y) {
                                    $char = $matrixCols[$x].Char
                                    [void]$sb.Append("${esc}[38;2;150;255;150m$char${esc}[0m")
                                    continue
                                } elseif ($y -lt $matrixCols[$x].Pos -and $y -gt ($matrixCols[$x].Pos - 5)) {
                                    $char = [char](Get-Random -Minimum 33 -Maximum 126)
                                    [void]$sb.Append("${esc}[38;2;0;100;0m$char${esc}[0m")
                                    continue
                                }
                            }
                            [void]$sb.Append($lineChars[$x])
                        }
                        [void]$sb.AppendLine()
                    }
                }
                'Breathe' {
                    $scale = 1.0 + 0.15 * [Math]::Sin($frame * 0.2)
                    for ($y = 0; $y -lt $height; $y++) {
                        $lineStr = $canvas[$y].TrimEnd()
                        $newLine = ""
                        for ($x = 0; $x -lt $lineStr.Length; $x++) {
                            $newLine += $lineStr[$x]
                            if ($scale -gt 1.05 -and $lineStr[$x] -eq ' ' -and $x % 3 -eq 0) {
                                $newLine += ' '
                            }
                        }
                        [void]$sb.AppendLine($newLine)
                    }
                }
                'ColorWave' {
                    for ($y = 0; $y -lt $height; $y++) {
                        $lineChars = $canvas[$y].ToCharArray()
                        for ($x = 0; $x -lt $width; $x++) {
                            $char = $lineChars[$x]
                            if ($char -ne ' ') {
                                $freq = 0.1 * ($x + $y + $frame)
                                $r = [int]([Math]::Sin($freq) * 127 + 128)
                                $g = [int]([Math]::Sin($freq + 2.094) * 127 + 128)
                                $b = [int]([Math]::Sin($freq + 4.188) * 127 + 128)
                                [void]$sb.Append("${esc}[38;2;${r};${g};${b}m${char}${esc}[0m")
                            } else {
                                [void]$sb.Append($char)
                            }
                        }
                        [void]$sb.AppendLine()
                    }
                }
            }

            $frameStr = $sb.ToString().TrimEnd("`r", "`n")
            
            $prevLines = if ($frame -eq 0) { 0 } else { $height }
            Write-TerminalFrame -Frame $frameStr -PreviousLineCount $prevLines
            
            Start-Sleep -Milliseconds $delayMs
        }

        # Instead of leaving it on screen, clear it so the final output replaces it cleanly
        if (-not [Console]::IsOutputRedirected -and $height -gt 0) {
            Write-Host -NoNewline "$esc[$($height)A$esc[J"
        }
    } finally {
        # Show cursor
        if (-not [Console]::IsOutputRedirected) {
            try { Write-Host -NoNewline "$esc[?25h" } catch {}
        }
    }

    return $CowOutput
}
