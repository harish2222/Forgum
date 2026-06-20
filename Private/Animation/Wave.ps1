function Invoke-WaveAnimation {
    <#
    .SYNOPSIS
        Fortune text appears word by word with rainbow color wave.
    .DESCRIPTION
        Words reveal one at a time with a delay, each word colored
        with a shifting rainbow offset. Creates a dynamic, flowing
        reveal effect. The cow stays static while the fortune "flows"
        into existence. Uses cursor repositioning for smooth rendering.
    #>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'Message')]
    param(
        [Parameter(Mandatory)]
        [string]$CowOutput,

        [string]$Message = '',

        [ValidateRange(10, 500)]
        [int]$Speed = 80
    )

    $esc = [char]27
    $lines = $CowOutput -split "`r?`n"

    # Find the balloon lines (containing ||) to identify where text is
    $balloonStart = -1
    $balloonEnd = -1
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match '\|\|' -and $balloonStart -eq -1) {
            $balloonStart = $i
        }
        if ($lines[$i] -match '\|\|') {
            $balloonEnd = $i
        }
    }

    # Extract words from the Message (fortune text)
    if ([string]::IsNullOrEmpty($Message)) {
        return $CowOutput
    }

    # No balloon detected — return original output
    if ($balloonStart -eq -1) {
        return $CowOutput
    }

    $words = $Message -split '\s+' | Where-Object { $_.Length -gt 0 }

    # Build word appearance schedule: which word appears at which frame
    $totalFrames = $words.Count

    $sb = [System.Text.StringBuilder]::new($CowOutput.Length * 3)

    for ($frame = 0; $frame -le $totalFrames; $frame++) {
        [void]$sb.Clear()

        for ($i = 0; $i -lt $lines.Count; $i++) {
            if ($i -gt 0) { [void]$sb.AppendLine() }

            if ($frame -eq 0) {
                # First frame: show balloon without text
                if ($i -ge $balloonStart -and $i -le $balloonEnd) {
                    # Show empty balloon interior
                    if ($lines[$i] -match '^\s*\|\|\s*(.*?)\s*\|\|\s*$') {
                        [void]$sb.Append("  || ")
                        [void]$sb.Append(' ' * $Matches[1].Length)
                        [void]$sb.Append(" ||")
                    } else {
                        [void]$sb.Append($lines[$i])
                    }
                } else {
                    [void]$sb.Append($lines[$i])
                }
            }
            else {
                # Show words revealed so far with rainbow coloring
                if ($i -ge $balloonStart -and $i -le $balloonEnd) {
                    if ($lines[$i] -match '^\s*\|\|\s*(.*?)\s*\|\|\s*$') {
                        $innerWidth = $Matches[1].Length
                        $visibleWords = $words[0..([Math]::Min($frame - 1, $words.Count - 1))]
                        $text = $visibleWords -join ' '
                        if ($text.Length -gt $innerWidth) {
                            $text = $text.Substring($text.Length - $innerWidth)
                        }
                        $pad = ' ' * [Math]::Max(0, $innerWidth - $text.Length)

                        # Apply rainbow to visible text
                        $coloredText = [System.Text.StringBuilder]::new()
                        for ($c = 0; $c -lt $text.Length; $c++) {
                            $colorIdx = $c + ($i * 3)
                            $freq = 0.15 * $colorIdx
                            $r = [int]([Math]::Sin($freq) * 127 + 128)
                            $g = [int]([Math]::Sin($freq + 2.094) * 127 + 128)
                            $b = [int]([Math]::Sin($freq + 4.189) * 127 + 128)
                            $r = [Math]::Max(0, [Math]::Min(255, $r))
                            $g = [Math]::Max(0, [Math]::Min(255, $g))
                            $b = [Math]::Max(0, [Math]::Min(255, $b))
                            [void]$coloredText.Append("${esc}[38;2;${r};${g};${b}m${text[$c]}${esc}[39m")
                        }

                        [void]$sb.Append("  || ")
                        [void]$sb.Append($coloredText.ToString())
                        [void]$sb.Append("${esc}[0m$pad ||")
                    } else {
                        [void]$sb.Append($lines[$i])
                    }
                } else {
                    [void]$sb.Append($lines[$i])
                }
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

        Start-Sleep -Milliseconds $Speed
    }

    Write-Host ""
    return $CowOutput
}

