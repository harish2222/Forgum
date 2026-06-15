function Invoke-BlinkAnimation {
    <#
    .SYNOPSIS
        Cow eyes blink periodically while displaying.
    .DESCRIPTION
        Shows the cow with normal eyes, then periodically replaces them
        with closed-eye characters (- -) for a natural blink effect.
        Creates a living, breathing feel. Uses cursor repositioning
        for smooth frame transitions without screen flicker.
    #>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'Message')]
    param(
        [Parameter(Mandatory)]
        [string]$CowOutput,

        [string]$Message = '',

        [ValidateRange(1, 100)]
        [int]$Duration = 15,

        [ValidateRange(0.05, 0.8)]
        [double]$BlinkRate = 0.2
    )

    $lines = $CowOutput -split "`n"

    # Find lines containing eye patterns (parenthesized 2-char expressions)
    $eyeLineIndices = @()
    $originalEyeLines = @()

    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match '\([^)]{2}\)') {
            $eyeLineIndices += $i
            $originalEyeLines += $lines[$i]
        }
    }

    # Create closed-eye versions (replace eyes with dashes)
    $closedEyeLines = @()
    foreach ($line in $originalEyeLines) {
        $closedEyeLines += ($line -replace '\(([^)]{2})\)', '(- -)')
    }

    $sb = [System.Text.StringBuilder]::new($CowOutput.Length * 2)

    for ($frame = 0; $frame -lt $Duration; $frame++) {
        [void]$sb.Clear()

        # Determine if this frame is a blink based on BlinkRate
        $blinkInterval = [Math]::Max(2, [Math]::Floor(1.0 / $BlinkRate))
        $isBlink = ($frame % $blinkInterval -eq 3 -and $frame -ge 3)

        for ($i = 0; $i -lt $lines.Count; $i++) {
            if ($i -gt 0) { [void]$sb.AppendLine() }

            $eyeIdx = -1
            for ($e = 0; $e -lt $eyeLineIndices.Count; $e++) {
                if ($eyeLineIndices[$e] -eq $i) { $eyeIdx = $e; break }
            }

            if ($eyeIdx -ge 0 -and $isBlink) {
                [void]$sb.Append($closedEyeLines[$eyeIdx])
            } else {
                [void]$sb.Append($lines[$i])
            }
        }

        try {
            if ($frame -gt 0 -and [Console]::CursorTop -ge $lines.Count) {
                [Console]::SetCursorPosition(0, [Console]::CursorTop - $lines.Count)
            }
            Write-Host $sb.ToString() -NoNewline
        } catch {
            Write-Host $sb.ToString()
        }

        Start-Sleep -Milliseconds 200
    }

    Write-Host ""
    return $CowOutput
}
