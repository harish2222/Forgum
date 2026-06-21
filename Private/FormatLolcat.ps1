function FormatLolcat {
    <#
    .SYNOPSIS
        Applies rainbow coloring to text.
    .DESCRIPTION
        Adds ANSI color codes to create a lolcat rainbow effect.
    .PARAMETER Text
        The text to colorize.
    .PARAMETER Frequency
        Color frequency (default: 0.1).
    .PARAMETER Spread
        Color spread (default: 3.0).
    .PARAMETER Seed
        Random seed (default: random).
    .PARAMETER Truecolor
        Use truecolor (24-bit) ANSI codes.
    .PARAMETER Invert
        Invert foreground/background colors.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$Text,

        [double]$Frequency = 0.1,
        [double]$Spread = 3.0,
        [int]$Seed = 0,
        [switch]$Truecolor,
        [switch]$Invert
    )

    process {
        if ($Seed -eq 0) {
            $Seed = Get-Random -Minimum 0 -Maximum 256
        }

        $lines = $Text -split "`n"
        $outputLines = @()
        $lineIndex = 0

        foreach ($line in $lines) {
            $chars = $line.ToCharArray()
            $coloredChars = @()
            $charIndex = 0

            foreach ($ch in $chars) {
                if ($ch -eq [char]27) {
                    $coloredChars += $ch
                    continue
                }

                $colorIndex = $Seed + $charIndex / $Spread
                $freq = $Frequency * $colorIndex
                $r = [Math]::Min(255, [Math]::Max(0, [int]([Math]::Sin($freq) * 127 + 128)))
                $g = [Math]::Min(255, [Math]::Max(0, [int]([Math]::Sin($freq + 2.094) * 127 + 128)))
                $b = [Math]::Min(255, [Math]::Max(0, [int]([Math]::Sin($freq + 4.189) * 127 + 128)))

                if ($Truecolor) {
                    if ($Invert) {
                        $coloredChars += "`e[48;2;$r;$g;${b}m$ch`e[49m"
                    } else {
                        $coloredChars += "`e[38;2;$r;$g;${b}m$ch`e[39m"
                    }
                } else {
                    $r6 = [Math]::Min(5, [int]($r / 51))
                    $g6 = [Math]::Min(5, [int]($g / 51))
                    $b6 = [Math]::Min(5, [int]($b / 51))
                    $colorIndex256 = 16 + 36 * $r6 + 6 * $g6 + $b6
                    if ($Invert) {
                        $coloredChars += "`e[48;5;${colorIndex256}m$ch`e[49m"
                    } else {
                        $coloredChars += "`e[38;5;${colorIndex256}m$ch`e[39m"
                    }
                }

                $charIndex++
            }

            $outputLines += ($coloredChars -join '')
            $lineIndex++
        }

        return ($outputLines -join "`n")
    }
}
