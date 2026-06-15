function Invoke-SlideInAnimation {
    <#
    .SYNOPSIS
        Cow slides in from the left, revealing columns progressively.
    .DESCRIPTION
        Creates a horizontal wipe effect — each frame reveals one more column
        of the cow from left to right, like a curtain being pulled aside.
        Uses cursor repositioning for smooth, flicker-free animation.
    #>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'Message')]
    param(
        [Parameter(Mandatory)]
        [string]$CowOutput,

        [string]$Message = '',

        [ValidateRange(1, 30)]
        [int]$Speed = 2,

        [ValidateRange(1, 60)]
        [int]$Duration = 0
    )

    $lines = $CowOutput -split "`n"
    $maxLen = 0
    foreach ($line in $lines) {
        if ($line.Length -gt $maxLen) { $maxLen = $line.Length }
    }

    # Pad all lines to equal length
    $paddedLines = [System.Collections.Generic.List[string]]::new($lines.Count)
    foreach ($line in $lines) {
        $paddedLines.Add($line.PadRight($maxLen))
    }

    $totalCols = $maxLen
    if ($Duration -gt 0) {
        $Speed = [Math]::Max(1, [Math]::Floor($totalCols / $Duration))
    }

    $revealed = 0
    $sb = [System.Text.StringBuilder]::new($CowOutput.Length * 2)

    while ($revealed -le $totalCols) {
        [void]$sb.Clear()

        for ($i = 0; $i -lt $paddedLines.Count; $i++) {
            if ($i -gt 0) { [void]$sb.AppendLine() }
            if ($revealed -ge $totalCols) {
                [void]$sb.Append($paddedLines[$i])
            } else {
                $visible = $paddedLines[$i].Substring(0, [Math]::Min($revealed, $paddedLines[$i].Length))
                [void]$sb.Append($visible)
            }
        }

        try {
            if ($revealed -gt 0 -and [Console]::CursorTop -ge $paddedLines.Count) {
                [Console]::SetCursorPosition(0, [Console]::CursorTop - $paddedLines.Count)
            }
            Write-Host $sb.ToString() -NoNewline
        } catch {
            Write-Host $sb.ToString()
        }

        $revealed += $Speed
        Start-Sleep -Milliseconds 30
    }

    Write-Host ""
    return $CowOutput
}

