function Invoke-FadeInAnimation {
    <#
    .SYNOPSIS
        Cow fades in line by line with progressive brightness.
    .DESCRIPTION
        Lines appear from top to bottom, each starting dim and brightening
        to full intensity. Creates a cinematic fade-in effect using ANSI
        brightness codes. Each line reaches full brightness before the next
        starts appearing.
    #>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'Message')]
    param(
        [Parameter(Mandatory)]
        [string]$CowOutput,

        [string]$Message = '',

        [ValidateRange(1, 10)]
        [int]$Speed = 2,

        [ValidateRange(5, 60)]
        [int]$Duration = 12
    )

    $lines = $CowOutput -split "`n"
    $totalLines = $lines.Count
    $esc = [char]27

    # Guard against empty input
    if ($totalLines -eq 0) { return $CowOutput }

    # ANSI brightness levels (dim to bright)
    $brightnessLevels = @(
        "${esc}[2m",       # Dim
        "${esc}[2;1m",     # Dim + bold hint
        "${esc}[1m",       # Bold (normal brightness)
        "${esc}[22m"       # Reset bold/dim
    )

    $framesPerLine = [Math]::Max(1, [Math]::Floor($Duration / $totalLines))
    $sb = [System.Text.StringBuilder]::new($CowOutput.Length * 3)

    $currentLine = 0

    for ($frame = 0; $frame -lt $Duration; $frame++) {
        [void]$sb.Clear()

        for ($i = 0; $i -lt $totalLines; $i++) {
            if ($i -gt 0) { [void]$sb.AppendLine() }

            if ($i -lt $currentLine) {
                # Fully visible lines
                [void]$sb.Append($lines[$i])
            }
            elseif ($i -eq $currentLine) {
                # Currently fading in — pick brightness based on sub-progress
                $subProgress = ($frame - ($currentLine * $framesPerLine)) / [double]$framesPerLine
                $level = [Math]::Min([Math]::Floor($subProgress * $brightnessLevels.Count), $brightnessLevels.Count - 1)

                if ($level -lt $brightnessLevels.Count - 1) {
                    [void]$sb.Append($brightnessLevels[$level])
                    [void]$sb.Append($lines[$i])
                    [void]$sb.Append("${esc}[0m")
                } else {
                    [void]$sb.Append($lines[$i])
                }
            }
            else {
                # Not yet visible — show blank line of spaces
                $padLen = if ($lines[$i].Length -gt 0) { $lines[$i].Length } else { 1 }
                [void]$sb.Append(' ' * $padLen)
            }
        }

        try {
            if ($frame -gt 0 -and [Console]::CursorTop -ge $totalLines) {
                [Console]::SetCursorPosition(0, [Console]::CursorTop - $totalLines)
            }
            Write-Host $sb.ToString() -NoNewline
        } catch {
            Write-Host $sb.ToString()
        }

        if (($frame + 1) % $framesPerLine -eq 0 -and $currentLine -lt $totalLines) {
            $currentLine++
        }

        $sleepMs = [Math]::Max(10, [Math]::Floor(100 / $Speed))
        Start-Sleep -Milliseconds $sleepMs
    }

    # Final frame — full brightness
    [void]$sb.Clear()
    for ($i = 0; $i -lt $totalLines; $i++) {
        if ($i -gt 0) { [void]$sb.AppendLine() }
        [void]$sb.Append($lines[$i])
    }

    try {
        if ([Console]::CursorTop -ge $totalLines) {
            [Console]::SetCursorPosition(0, [Console]::CursorTop - $totalLines)
        }
        Write-Host $sb.ToString() -NoNewline
    } catch {
        Write-Host $sb.ToString()
    }

    Write-Host ""
    return $CowOutput
}

