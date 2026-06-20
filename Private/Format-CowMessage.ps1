function Format-CowMessage {
    <#
    .SYNOPSIS
        Formats a message into a cowsay speech balloon.
    .DESCRIPTION
        Wraps text in the || bordered balloon format.
    .PARAMETER Text
        The message text to format.
    .PARAMETER MaxWidth
        Maximum width for word wrapping (default 60).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [string]$Text,

        [int]$MaxWidth = 60
    )

    $Text = $Text -replace "`t", '    '
    $Text = $Text -replace '\x1b\[[0-9;]*[a-zA-Z]', ''
    $Text = $Text -replace '[\u200B\u200C\u200D\uFEFF]', ''

    $lines = @()
    $paragraphs = $Text -split "`n"

    foreach ($para in $paragraphs) {
        if ([string]::IsNullOrWhiteSpace($para)) {
            $lines += ''
            continue
        }

        $words = $para -split '\s+'
        $currentLine = ''

        foreach ($word in $words) {
            if ($currentLine.Length -eq 0) {
                $currentLine = $word
            } elseif (($currentLine.Length + 1 + $word.Length) -le $MaxWidth) {
                $currentLine = "$currentLine $word"
            } else {
                $lines += $currentLine
                $currentLine = $word
            }
        }

        if ($currentLine.Length -gt 0) {
            $lines += $currentLine
        }
    }

    if ($lines.Count -eq 0) {
        $lines = @('')
    }

    $maxLineLength = ($lines | ForEach-Object { $_.Length } | Measure-Object -Maximum).Maximum
    if ($maxLineLength -lt 11) { $maxLineLength = 11 }

    $border = '  ' + ('#' * ($maxLineLength + 8))
    $result = @($border)

    foreach ($line in $lines) {
        $padded = $line.PadRight($maxLineLength)
        $result += "  ||  $padded  ||"
    }

    $result += $border

    return ($result -join "`n")
}
