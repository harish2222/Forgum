function Invoke-WiggleAnimation {
    <#
    .SYNOPSIS
        Cow wiggles left and right playfully.
    .DESCRIPTION
        Each frame shifts the cow 1-2 characters left or right,
        creating a wobbling/wiggling effect. The cow oscillates
        with decreasing amplitude, like something settling into place.
        Uses cursor repositioning for smooth rendering.
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

        [ValidateRange(1, 5)]
        [int]$Amplitude = 2
    )

    $lines = $CowOutput -split "`n"

    # Generate wiggle pattern: oscillating offsets with damping
    $offsets = [System.Collections.Generic.List[int]]::new()
    $direction = 1
    $currentAmp = $Amplitude

    for ($i = 0; $i -lt $Duration; $i++) {
        $offsets.Add([int]($currentAmp * $direction))

        # Reverse direction every 2 frames
        if ($i % 2 -eq 1) {
            $direction *= -1
            # Decrease amplitude every full cycle
            if ($direction -gt 0) {
                $currentAmp = [Math]::Max(0, $currentAmp - 1)
            }
        }
    }

    $sb = [System.Text.StringBuilder]::new($CowOutput.Length * 2)

    for ($frame = 0; $frame -lt $Duration; $frame++) {
        [void]$sb.Clear()
        $offset = $offsets[$frame]
        $pad = if ($offset -ge 0) { ' ' * $offset } else { '' }
        $negPad = if ($offset -lt 0) { ' ' * [Math]::Abs($offset) } else { '' }

        for ($i = 0; $i -lt $lines.Count; $i++) {
            if ($i -gt 0) { [void]$sb.AppendLine() }
            if ($offset -ge 0) {
                [void]$sb.Append($pad).Append($lines[$i])
            } else {
                # Shift right (pad left with spaces, trim right)
                $shifted = $lines[$i]
                if ($shifted.Length -gt [Math]::Abs($offset)) {
                    $shifted = $shifted.Substring([Math]::Abs($offset))
                }
                [void]$sb.Append($shifted).Append($negPad)
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

        Start-Sleep -Milliseconds 80
    }

    # Final frame — centered
    [void]$sb.Clear()
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($i -gt 0) { [void]$sb.AppendLine() }
        [void]$sb.Append($lines[$i])
    }

    try {
        if ([Console]::CursorTop -ge $lines.Count) {
            [Console]::SetCursorPosition(0, [Console]::CursorTop - $lines.Count)
        }
        Write-Host $sb.ToString() -NoNewline
    } catch {
        Write-Host $sb.ToString()
    }

    Write-Host ""
    return $CowOutput
}

