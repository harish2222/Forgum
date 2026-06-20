function Invoke-PhysicsCow {
    <#
    .SYNOPSIS
        Applies physics-based animations based on cow manifesto.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$CowOutput,

        [Parameter()]
        [int]$Duration = 30,

        [Parameter()]
        [string]$CowName = 'default'
    )

    $fps = 20
    $totalFrames = $Duration
    if ($totalFrames -lt 1) { $totalFrames = 30 }
    $delayMs = [int](1000 / $fps)

    # Convert typical file paths to short cow names.
    $cowBase = [System.IO.Path]::GetFileName($CowName)

    $moduleRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
    $jsonPath = Join-Path $moduleRoot "Data/Cows/animations.json"
    if (-not (Test-Path $jsonPath)) {
        $jsonPath = Join-Path (Split-Path $PSScriptRoot -Parent) "Data/Cows/animations.json"
        if (-not (Test-Path $jsonPath)) {
            $jsonPath = Join-Path $PSScriptRoot "Data/Cows/animations.json"
        }
    }
    $animConfig = @{}
    if (Test-Path $jsonPath) {
        try {
            $jsonContent = Get-Content $jsonPath -Raw -ErrorAction Stop
            $json = ConvertFrom-Json $jsonContent -ErrorAction Stop
            
            # Match cow file name
            $key = $cowBase
            if (-not $key.EndsWith('.cow')) { $key = "$key.cow" }
            if ($json.PSObject.Properties.Match($key).Count -gt 0) {
                $animConfig = $json.$key
            } else {
                # Try fallback without extension
                $key = $cowBase.Replace('.cow', '')
                if ($json.PSObject.Properties.Match($key).Count -gt 0) {
                    $animConfig = $json.$key
                }
            }
        } catch {
            Write-Verbose "Forgum: Could not load animations.json: $_"
        }
    }
    
    $baseEngine = "Breathe"
    $particles = $null
    $speedMultiplier = 1.0

    if ($null -ne $animConfig.base) { $baseEngine = $animConfig.base }
    if ($null -ne $animConfig.particles) { $particles = $animConfig.particles }
    if ($null -ne $animConfig.speed) { $speedMultiplier = $animConfig.speed }

    $lines = $CowOutput -split "`r?`n"
    
    $bubbleLines = @()
    $cowLines = @()
    $lastHashLine = -1
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match '^\s*#+\s*$') {
            $lastHashLine = $i
        }
    }
    
    if ($lastHashLine -ge 0) {
        $bubbleLines = $lines[0..$lastHashLine]
        if ($lastHashLine + 1 -lt $lines.Count) {
            $cowLines = $lines[($lastHashLine + 1)..($lines.Count - 1)]
        }
    } else {
        $cowLines = $lines
    }

    $height = $cowLines.Count
    $width = 0
    foreach ($line in $cowLines) {
        $clean = $line -replace '\x1b\[[0-9;]*m', ''
        if ($clean.Length -gt $width) { $width = $clean.Length }
    }
    
    $canvas = [System.Collections.Generic.List[string]]::new()
    foreach ($line in $cowLines) {
        $clean = $line -replace '\x1b\[[0-9;]*m', ''
        if ($clean.Length -lt $width) {
            $canvas.Add($clean + (' ' * ($width - $clean.Length)))
        } else {
            $canvas.Add($clean)
        }
    }

    $sb = [System.Text.StringBuilder]::new()
    $esc = [char]27

    # Hide cursor
    if (-not [Console]::IsOutputRedirected) {
        try { Write-Host -NoNewline "$esc[?25l" } catch {}
    }

    # State for particles
    $particleList = [System.Collections.Generic.List[PSCustomObject]]::new()
    # State for dissolve
    $dissolveMap = [System.Collections.Generic.List[PSCustomObject]]::new()
    if ($baseEngine -eq 'Dissolve') {
        for ($y = 0; $y -lt $height; $y++) {
            for ($x = 0; $x -lt $width; $x++) {
                if ($canvas[$y][$x] -ne ' ') {
                    $dissolveMap.Add([PSCustomObject]@{ X = $x; Y = $y; Char = $canvas[$y][$x]; VelX = ((Get-Random -Min -10 -Max 11) / 10.0); VelY = ((Get-Random -Min -5 -Max 5) / 10.0) })
                }
            }
        }
    }

    $isInteractive = -not [Console]::IsOutputRedirected

    try {
        $frame = 0
        while ($true) {
            [void]$sb.Clear()
            
            $fSpeed = $frame * $speedMultiplier * 0.3

            # 1. Base transform on canvas
            $renderCanvas = [System.Collections.Generic.List[char[]]]::new()
            for ($y = 0; $y -lt $height; $y++) {
                $renderCanvas.Add($canvas[$y].ToCharArray())
            }

            $offsetX = 0
            $offsetY = 0

            switch ($baseEngine) {
                'Squish' {
                    # Bounces and squishes at the bottom like jelly
                    $t = $fSpeed * 0.5
                    $offsetY = [int]([Math]::Abs([Math]::Sin($t)) * 4)
                    $isSquished = ($offsetY -lt 1)
                    if ($isSquished) {
                        for ($y=0; $y -lt $height; $y++) {
                            # Expand width at bottom when squished
                            $squishFactor = [int]($y / $height * 2)
                            $newLine = ""
                            $chars = $renderCanvas[$y]
                            for ($x=0; $x -lt $chars.Length; $x++) {
                                $newLine += $chars[$x]
                                if ($chars[$x] -eq ' ' -and $x % 2 -eq 0 -and $newLine.Length -lt $width + $squishFactor) { $newLine += ' ' }
                            }
                            $renderCanvas[$y] = $newLine.PadRight($width, ' ').Substring(0, $width).ToCharArray()
                        }
                    }
                }
                'Liquid' {
                    # Sine wave ripple effect across the Y axis (water surface)
                    for ($y=0; $y -lt $height; $y++) {
                        $shift = [int]([Math]::Round([Math]::Sin($y * 0.4 + $fSpeed * 0.5) * 2.0))
                        if ($shift -gt 0) {
                            $pad = ' ' * $shift
                            $str = $pad + (-join $renderCanvas[$y])
                            $renderCanvas[$y] = $str.Substring(0, $width).ToCharArray()
                        } elseif ($shift -lt 0) {
                            $pad = ' ' * (-$shift)
                            $str = (-join $renderCanvas[$y]).Substring(-$shift) + $pad
                            $renderCanvas[$y] = $str.PadRight($width, ' ').ToCharArray()
                        }
                    }
                }
                'Fly' {
                    # Lissajous curve figure-8 flying pattern with wing flapping
                    $offsetY = [int]([Math]::Round([Math]::Sin($fSpeed * 1.0) * 2.0))
                    $offsetX = [int]([Math]::Round([Math]::Sin($fSpeed * 0.5) * 4.0))
                    if ([int]$fSpeed % 4 -lt 2) {
                        for ($y=0; $y -lt $height; $y++) {
                            for ($x=0; $x -lt $width; $x++) {
                                if ($renderCanvas[$y][$x] -eq '>') { $renderCanvas[$y][$x] = '<' }
                                elseif ($renderCanvas[$y][$x] -eq '<') { $renderCanvas[$y][$x] = '>' }
                                elseif ($renderCanvas[$y][$x] -eq '/') { $renderCanvas[$y][$x] = '\' }
                                elseif ($renderCanvas[$y][$x] -eq '\') { $renderCanvas[$y][$x] = '/' }
                            }
                        }
                    }
                }
                'Breathe' {
                    # Complex expansion and contraction imitating organic lung movement
                    $expand = [Math]::Sin($fSpeed * 0.3)
                    $offsetY = [int]([Math]::Round($expand * 0.5)) # Chest rises
                    if ($expand -gt 0.5) {
                        for ($y=0; $y -lt $height; $y++) {
                            $newLine = ""
                            $chars = $renderCanvas[$y]
                            for ($x=0; $x -lt $chars.Length; $x++) {
                                $newLine += $chars[$x]
                                if ($chars[$x] -ne ' ' -and $x % 3 -eq 0 -and $newLine.Length -lt $width) {
                                    $newLine += ' '
                                }
                            }
                            $renderCanvas[$y] = $newLine.PadRight($width, ' ').Substring(0, $width).ToCharArray()
                        }
                    }
                }
                'Abduction' {
                    # UFO tractor beam pulling the cow up and slowly vaporizing edges
                    $offsetY = -([int]($fSpeed * 0.2) % $height)
                    $vaporizeLimit = [int]($fSpeed * 0.1)
                    for ($y=0; $y -lt $height; $y++) {
                        for ($x=0; $x -lt $width; $x++) {
                            if ($x -lt $vaporizeLimit -or $x -gt ($width - $vaporizeLimit)) {
                                if ((Get-Random -Max 10) -lt 4) { $renderCanvas[$y][$x] = ' ' }
                            }
                        }
                    }
                }
                'Talk' {
                    $isMouthOpen = ([int]$fSpeed % 2 -eq 0)
                    for ($y=0; $y -lt $height; $y++) {
                        for ($x=0; $x -lt $width; $x++) {
                            if ($renderCanvas[$y][$x] -eq '_' -and $isMouthOpen) { 
                                $renderCanvas[$y][$x] = 'o'
                                # Spawn text bubbles floating up
                                if ((Get-Random -Max 10) -gt 7) {
                                    $particleList.Add([PSCustomObject]@{ X = $x; Y = $y-1; Char = [char](Get-Random -Min 97 -Max 122); Life = 8 })
                                }
                            }
                            if ($renderCanvas[$y][$x] -eq '-' -and $isMouthOpen) { $renderCanvas[$y][$x] = 'O' }
                        }
                    }
                }
                'Sway' {
                    $swayAmt = [int]([Math]::Round([Math]::Sin($fSpeed * 0.4) * 3.0))
                    for ($y=0; $y -lt $height; $y++) {
                        # Elastic sway that bows in the middle
                        $dist = [Math]::Abs($y - ($height/2))
                        $shift = [int](($height - $dist) / $height * $swayAmt)
                        if ($shift -gt 0) {
                            $pad = ' ' * $shift
                            $str = $pad + (-join $renderCanvas[$y])
                            $renderCanvas[$y] = $str.Substring(0, $width).ToCharArray()
                        } elseif ($shift -lt 0) {
                            $pad = ' ' * (-$shift)
                            $str = (-join $renderCanvas[$y]).Substring(-$shift) + $pad
                            $renderCanvas[$y] = $str.PadRight($width, ' ').ToCharArray()
                        }
                    }
                }
                'Matrix' {
                    # Cyberpunk falling digital rain replacing cow characters
                    for ($y=0; $y -lt $height; $y++) {
                        for ($x=0; $x -lt $width; $x++) {
                            if ($renderCanvas[$y][$x] -ne ' ') {
                                if ((Get-Random -Max 100) -lt 15) {
                                    $renderCanvas[$y][$x] = [char](Get-Random -Min 33 -Max 126)
                                }
                            }
                        }
                    }
                    if ((Get-Random -Max 10) -lt 2) { $offsetY = (Get-Random -Min -1 -Max 2) }
                }
                'Fire' {
                    # Burns the cow from the bottom up!
                    $burnLine = $height - [int]($fSpeed * 0.2) % $height
                    for ($y = $burnLine; $y -lt $height; $y++) {
                        for ($x = 0; $x -lt $width; $x++) {
                            if ($renderCanvas[$y][$x] -ne ' ') {
                                $fireChars = @('^', '*', '.', 'x', '~')
                                $renderCanvas[$y][$x] = $fireChars[(Get-Random -Max $fireChars.Length)]
                                if ((Get-Random -Max 10) -gt 6) {
                                    $particleList.Add([PSCustomObject]@{ X = $x; Y = $y-1; Char = '^'; Life = 5 })
                                }
                            }
                        }
                    }
                }
                'Particles' {
                    # No base transform
                }
                'Pulse' {
                    # No base transform (handled in final render)
                }
            }

            # Prepare final frame array
            $finalFrame = [System.Collections.Generic.List[char[]]]::new()
            for ($i = 0; $i -lt $height; $i++) { $finalFrame.Add((' ' * $width).ToCharArray()) }

            if ($baseEngine -eq 'Dissolve') {
                foreach ($p in $dissolveMap) {
                    $p.X += $p.VelX
                    $p.Y += $p.VelY
                    $p.VelY += 0.1 # Gravity
                    $px = [int][Math]::Round($p.X)
                    $py = [int][Math]::Round($p.Y)
                    if ($px -ge 0 -and $px -lt $width -and $py -ge 0 -and $py -lt $height) {
                        $finalFrame[$py][$px] = $p.Char
                    }
                }
            } else {
                for ($y = 0; $y -lt $height; $y++) {
                    $srcY = $y - $offsetY
                    if ($srcY -ge 0 -and $srcY -lt $height) {
                        for ($x = 0; $x -lt $width; $x++) {
                            $srcX = $x - $offsetX
                            if ($srcX -ge 0 -and $srcX -lt $width) {
                                $finalFrame[$y][$x] = $renderCanvas[$srcY][$srcX]
                            }
                        }
                    }
                }
            }

            # Spawn config-driven particles
            if ($null -ne $particles -and $particles -ne '') {
                if ((Get-Random -Max 100) -lt 30) {
                    $px = Get-Random -Max $width
                    $py = if ($particles -eq 'Bubbles') { $height - 1 } else { Get-Random -Max $height }
                    $pc = if ($particles -eq 'Fire') { '*' } elseif ($particles -eq 'Zzz') { 'z' } elseif ($particles -eq 'Stars') { '+' } elseif ($particles -eq 'Glitch') { [char](Get-Random -Min 33 -Max 126) } else { 'o' }
                    if ($particles -eq 'Zzz' -and (Get-Random -Max 10) -lt 3) { $pc = 'Z' }
                    $particleList.Add([PSCustomObject]@{ X = $px; Y = $py; Char = $pc; Life = 10 })
                }
            }

            # Always clean up and render particles (including those spawned by Talk/Fire effects)
            $newParticles = [System.Collections.Generic.List[PSCustomObject]]::new()
            foreach ($p in $particleList) {
                if ($particles -eq 'Bubbles') { $p.Y -= 0.5; $p.X += (Get-Random -Min -1 -Max 2) }
                elseif ($particles -eq 'Fire') { $p.Y -= 0.8; $p.X += (Get-Random -Min -1 -Max 2) }
                elseif ($particles -eq 'Zzz') { $p.Y -= 0.3; $p.X += 0.5 }
                elseif ($particles -eq 'Stars') { $p.X -= 1.0 }
                elseif ($particles -eq 'Glitch') { $p.Y += (Get-Random -Min -1 -Max 2); $p.X += (Get-Random -Min -1 -Max 2) }
                else { $p.Y += 1.0 }

                $p.Life--
                if ($p.Life -gt 0 -and $p.Y -ge 0 -and $p.Y -lt $height -and $p.X -ge 0 -and $p.X -lt $width) {
                    $newParticles.Add($p)
                    $ix = [int][Math]::Round($p.X)
                    $iy = [int][Math]::Round($p.Y)
                    if ($ix -ge 0 -and $ix -lt $width -and $iy -ge 0 -and $iy -lt $height) {
                        $finalFrame[$iy][$ix] = $p.Char
                    }
                }
            }
            $particleList = $newParticles

            # Render to StringBuilder with Pulse/Pulse effect if required
            foreach ($bLine in $bubbleLines) {
                [void]$sb.AppendLine($bLine)
            }
            for ($y = 0; $y -lt $height; $y++) {
                for ($x = 0; $x -lt $width; $x++) {
                    $c = $finalFrame[$y][$x]
                    if ($baseEngine -eq 'Pulse' -and $c -ne ' ') {
                        $freq = 0.2 * ($x + $y + $fSpeed)
                        $r = [int]([Math]::Sin($freq) * 127 + 128)
                        $g = [int]([Math]::Sin($freq + 2) * 127 + 128)
                        $b = [int]([Math]::Sin($freq + 4) * 127 + 128)
                        [void]$sb.Append("${esc}[38;2;${r};${g};${b}m${c}${esc}[0m")
                    } else {
                        [void]$sb.Append($c)
                    }
                }
                [void]$sb.AppendLine()
            }

            $frameStr = $sb.ToString().TrimEnd("`r", "`n")
            
            $totalHeight = $height + $bubbleLines.Count
            $prevLines = if ($frame -eq 0) { 0 } else { $totalHeight }
            Write-TerminalFrame -Frame $frameStr -PreviousLineCount $prevLines
            
            Start-Sleep -Milliseconds $delayMs
            
            $frame++
            if (-not $isInteractive -and $frame -ge $totalFrames) { break }
            if ($isInteractive -and [Console]::KeyAvailable) {
                while ([Console]::KeyAvailable) { $null = [Console]::ReadKey($true) }
                break
            }
        }

        # Removed clear logic so the final animation frame stays on screen
    } finally {
        if (-not [Console]::IsOutputRedirected) {
            try { Write-Host -NoNewline "$esc[?25h" } catch {}
        }
    }

    return ""
}
