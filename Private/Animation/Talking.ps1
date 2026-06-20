function Invoke-TalkingAnimation {
    <#
    .SYNOPSIS
        Animates cow with mouth movement (eye replacement).
    .DESCRIPTION
        Cycles through mouth characters (o, O, 0, O) to simulate talking.
        Only replaces the first occurrence of the eye pattern, not all 'o' chars.
    #>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'Message')]
    param(
        [Parameter(Mandatory)]
        [string]$CowOutput,

        [string]$Message = '',

        [ValidateRange(1, 100)]
        [int]$Duration = 12
    )

    $mouthFrames = @('o', 'O', '0', 'O')
    $cowLines = $CowOutput -split "`r?`n"

    # Find the eye line (contains the mouth pattern in default cow)
    $eyeLineIndex = -1
    for ($i = 0; $i -lt $cowLines.Count; $i++) {
        if ($cowLines[$i] -match '\\.*\([^)]{2}\)') {
            $eyeLineIndex = $i
            break
        }
    }

    $sb = [System.Text.StringBuilder]::new($CowOutput.Length * 2)

    for ($frame = 0; $frame -lt $Duration; $frame++) {
        [void]$sb.Clear()
        $mouth = $mouthFrames[$frame % $mouthFrames.Length]

        for ($i = 0; $i -lt $cowLines.Count; $i++) {
            if ($i -gt 0) { [void]$sb.AppendLine() }

            $line = $cowLines[$i]
            if ($i -eq $eyeLineIndex) {
                # Replace the eye pattern with the current mouth frame
                $line = $line -replace '\(([^)]{2})\)', "($mouth$mouth)"
            }
            [void]$sb.Append($line)
        }

        try {
            if ($frame -gt 0 -and [Console]::CursorTop -ge $cowLines.Count) {
                [Console]::SetCursorPosition(0, [Console]::CursorTop - $cowLines.Count)
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
