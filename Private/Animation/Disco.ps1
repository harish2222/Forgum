function Invoke-DiscoAnimation {
    <#
    .SYNOPSIS
        Cow displayed with rapidly cycling rainbow colors (disco effect).
    .DESCRIPTION
        Each frame recolors every character of the cow with a different
        hue, creating a psychedelic party effect. Colors shift rapidly
        through the spectrum. The cow appears to "dance" with color.
        Uses cursor repositioning for smooth, flicker-free animation.
    #>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'Message')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    param(
        [Parameter(Mandatory)]
        [string]$CowOutput,

        [string]$Message = '',

        [ValidateRange(10, 200)]
        [int]$Speed = 80,

        [ValidateRange(5, 60)]
        [int]$Duration = 20
    )

    $esc = [char]27
    $lines = $CowOutput -split "`r?`n"
    $sb = [System.Text.StringBuilder]::new($CowOutput.Length * 10)

    for ($frame = 0; $frame -lt $Duration; $frame++) {
        [void]$sb.Clear()
        $hueShift = $frame * 25

        # Pre-compute 360-entry RGB lookup table (O(1) per char instead of HSV-to-RGB each time)
        $rgbTable = [string[]]::new(360)
        for ($h = 0; $h -lt 360; $h++) {
            $hi = $h / 60.0
            $f = $hi - [Math]::Floor($hi)
            $q = 255 * (1 - $f)
            $t = 255 * $f
            $r = 0; $g = 0; $b = 0
            switch ([int][Math]::Floor($hi) % 6) {
                0 { $r = 255; $g = [int]$t; $b = 0 }
                1 { $r = [int]$q; $g = 255; $b = 0 }
                2 { $r = 0; $g = 255; $b = [int]$t }
                3 { $r = 0; $g = [int]$q; $b = 255 }
                4 { $r = [int]$t; $g = 0; $b = 255 }
                5 { $r = 255; $g = 0; $b = [int]$q }
            }
            $rgbTable[$h] = "${r};${g};${b}"
        }

        for ($i = 0; $i -lt $lines.Count; $i++) {
            if ($i -gt 0) { [void]$sb.AppendLine() }

            $line = $lines[$i]
            for ($c = 0; $c -lt $line.Length; $c++) {
                $char = $line[$c]

                # Skip spaces for performance
                if ($char -eq ' ') {
                    [void]$sb.Append(' ')
                    continue
                }

                # Calculate hue based on position and frame â€” O(1) lookup
                $hueIndex = (($c * 15) + $hueShift + ($i * 40)) % 360
                [void]$sb.Append("${esc}[38;2;${rgbTable[$hueIndex]}m${char}${esc}[39m")
            }
        }

        [void]$sb.Append("${esc}[0m")

        try {
            if ($frame -gt 0 -and [Console]::CursorTop -ge $lines.Count) {
                [Console]::SetCursorPosition(0, [Console]::CursorTop - $lines.Count)
            }
            Write-Host $sb.ToString() -NoNewline
        } catch {
            Write-Host $sb.ToString()
        }

        Start-Sleep -Milliseconds $Speed
    }

    Write-Host ""
    return $CowOutput
}
