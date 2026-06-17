function Format-Lolcat {
    <#
    .SYNOPSIS
        Applies rainbow colorization to text (lolcat algorithm).
    .DESCRIPTION
        Direct port of busyloop/lolcat Ruby implementation.
        Uses sine-wave color generation with proper ANSI escape passthrough.
        Supports truecolor (24-bit) and 256-color fallback.
    .PARAMETER Text
        The text to colorize.
    .PARAMETER Frequency
        Rainbow frequency (default: 0.1). Higher = faster color cycling.
    .PARAMETER Spread
        Rainbow spread (default: 3.0). Higher = wider rainbow bands.
    .PARAMETER Seed
        Rainbow seed offset (default: 0). 0 = random. Use for reproducible rainbows.
    .PARAMETER Truecolor
        Use 24-bit truecolor. Falls back to 256-color if not supported.
    .PARAMETER Invert
        Invert foreground and background colors.
    .PARAMETER Animate
        Enable animation mode (psychedelic effect).
    .PARAMETER Duration
        Animation duration in frames (default: 12).
    .PARAMETER Speed
        Animation speed (default: 20.0).
    .NOTES
        Based on busyloop/lolcat (BSD-3-Clause) - https://github.com/busyloop/lolcat
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Text,

        [ValidateRange(0.01, 10.0)]
        [double]$Frequency = 0.1,

        [ValidateRange(0.1, 50.0)]
        [double]$Spread = 3.0,

        [ValidateRange(0, 10000)]
        [int]$Seed = 0,

        [switch]$Truecolor,

        [switch]$Invert,

        [switch]$Animate,

        [ValidateRange(1, 100)]
        [int]$Duration = 12,

        [ValidateRange(0.1, 100.0)]
        [double]$Speed = 20.0
    )

    # Detect truecolor support
    # Only auto-detect if caller didn't explicitly set -Truecolor.
    # Multiple fallbacks: COLORTERM, Windows Terminal session, 256-color capable
    # xterm-style emulators (most modern terminals advertise 24-bit there too).
    if ($PSBoundParameters.ContainsKey('Truecolor')) {
        $useTruecolor = $Truecolor
    } else {
        $colorTerm = "$env:COLORTERM"
        $term      = "$env:TERM"
        $useTruecolor = ($colorTerm -in @('truecolor', '24bit')) `
            -or (-not [string]::IsNullOrEmpty($env:WT_SESSION)) `
            -or ($term -eq 'xterm-256color') `
            -or ($term -like '*-256color')
    }

    # Initialize seed (0 = random, like upstream)
    $os = if ($Seed -eq 0) { Get-Random -Minimum 0 -Maximum 256 } else { $Seed }

    $lines = $Text -split "`n"
    $output = [System.Collections.Generic.List[string]]::new($lines.Count)

    foreach ($line in $lines) {
        if ($Animate) {
            # Animation mode: render multiple frames with shifting offset
            $output.Add((Format-LolcatAnimateLine -Line $line -Frequency $Frequency -Spread $Spread -Truecolor:$useTruecolor -Invert:$Invert -Duration $Duration -StartOffset ([ref]$os)))
        } else {
            # Plain mode: single pass
            $output.Add((Format-LolcatLine -Line $line -Frequency $Frequency -Spread $Spread -Truecolor:$useTruecolor -Invert:$Invert -Offset $os))
            $os++
        }
    }

    return ($output -join "`n")
}

function Format-LolcatLine {
    <#
    .SYNOPSIS
        Colorizes a single line using the lolcat sine-wave algorithm.
    #>
    [CmdletBinding()]
    param(
        [string]$Line,
        [double]$Frequency,
        [double]$Spread,
        [bool]$Truecolor,
        [bool]$Invert,
        [int]$Offset
    )

    $esc = [char]27
    $sb = [System.Text.StringBuilder]::new($Line.Length * 20)

    for ($i = 0; $i -lt $Line.Length; $i++) {
        $char = $Line[$i]

        # Pass through ANSI escape sequences unchanged
        if ([int][char]$char -eq 27) {
            [void]$sb.Append($char)
            # Consume the rest of the CSI sequence.
            # ECMA-48 CSI structure: ESC [ <params> <intermediates> <final>
            #   - params:    0x30-0x3F  (digits, ';', and ':' for sub-parameters)
            #   - intermdts: 0x20-0x2F  (space, '!', '"', '#', ..., '/')
            #   - final:     0x40-0x7E  (typically '@' or 'A'-'z')
            # We must keep consuming until we hit the final byte. The previous
            # implementation only broke on [A-Za-z] which still works for the
            # final byte, but we make the range explicit so colons / digits /
            # intermediate characters cannot accidentally terminate the sequence.
            for ($j = $i + 1; $j -lt $Line.Length; $j++) {
                [void]$sb.Append($Line[$j])
                $code = [int][char]$Line[$j]
                if ($code -ge 0x40 -and $code -le 0x7E) {
                    $i = $j
                    break
                }
            }
            continue
        }

        # Skip carriage returns
        if ([int][char]$char -eq 13) {
            [void]$sb.Append($char)
            continue
        }

        # Calculate rainbow color using sine waves (upstream algorithm)
        $colorIndex = [int]($Offset + $i / $Spread)
        $freq = $Frequency * $colorIndex

        $red   = [int]([Math]::Sin($freq) * 127 + 128)
        $green = [int]([Math]::Sin($freq + 2.0943951023931953) * 127 + 128)  # 2PI/3
        $blue  = [int]([Math]::Sin($freq + 4.1887902047863905) * 127 + 128)  # 4PI/3

        # Clamp values to valid range
        $red   = [Math]::Max(0, [Math]::Min(255, $red))
        $green = [Math]::Max(0, [Math]::Min(255, $green))
        $blue  = [Math]::Max(0, [Math]::Min(255, $blue))

        if ($Truecolor) {
            if ($Invert) {
                # Invert: use color as background, default foreground
                [void]$sb.Append("${esc}[48;2;${red};${green};${blue}m${char}${esc}[49m")
            } else {
                [void]$sb.Append("${esc}[38;2;${red};${green};${blue}m${char}${esc}[39m")
            }
        } else {
            # 256-color fallback
            $r6 = [Math]::Floor($red / 255 * 5)
            $g6 = [Math]::Floor($green / 255 * 5)
            $b6 = [Math]::Floor($blue / 255 * 5)
            $color256 = 16 + 36 * $r6 + 6 * $g6 + $b6

            if ($Invert) {
                [void]$sb.Append("${esc}[48;5;${color256}m${char}${esc}[49m")
            } else {
                [void]$sb.Append("${esc}[38;5;${color256}m${char}${esc}[39m")
            }
        }
    }

    [void]$sb.Append("${esc}[0m")
    return $sb.ToString()
}

function Format-LolcatAnimateLine {
    <#
    .SYNOPSIS
        Renders an animated line with shifting rainbow offset.
    #>
    [CmdletBinding()]
    param(
        [string]$Line,
        [double]$Frequency,
        [double]$Spread,
        [bool]$Truecolor,
        [bool]$Invert,
        [int]$Duration,
        [ref]$StartOffset
    )

    $sb = [System.Text.StringBuilder]::new($Line.Length * $Duration * 20)
    $realOffset = $StartOffset.Value

    for ($frame = 0; $frame -lt $Duration; $frame++) {
        $StartOffset.Value = $realOffset + $frame * $Spread
        $frameOutput = Format-LolcatLine -Line $Line -Frequency $Frequency -Spread $Spread -Truecolor $Truecolor -Invert $Invert -Offset $StartOffset.Value
        [void]$sb.Append($frameOutput)
        if ($frame -lt $Duration - 1) {
            [void]$sb.Append("`r")
        }
    }

    $StartOffset.Value = $realOffset
    return $sb.ToString()
}
