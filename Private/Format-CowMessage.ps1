function Format-CowMessage {
    <#
    .SYNOPSIS
        Formats text into a speech balloon with word wrapping.
    .DESCRIPTION
        Wraps text at MaxWidth characters and renders it inside a
        speech balloon with clean ASCII borders.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string]$Text,

        [ValidateRange(20, 200)]
        [int]$MaxWidth = 60
    )

    # 1. Pre-process text
    # Expand tabs to 4 spaces
    $Text = $Text -replace "`t", "    "
    # Strip ANSI escape codes
    $Text = $Text -replace "\x1B\[[0-9;]*[a-zA-Z]", ""
    # Strip zero-width characters (using literal character codes for absolute certainty)
    $zeroWidthChars = [char]0x200B, [char]0x200C, [char]0x200D, [char]0xFEFF
    foreach ($c in $zeroWidthChars) {
        $Text = $Text.Replace([string]$c, "")
    }
    $Text = $Text -replace "`r`n", "`n"

    # 2. Word wrap
    $lines = [System.Collections.Generic.List[string]]::new()
    $paragraphs = $Text -split '\n'

    foreach ($paragraph in $paragraphs) {
        if ([string]::IsNullOrWhiteSpace($paragraph)) {
            $lines.Add('')
            continue
        }

        $words = $paragraph -split ' '
        $currentLine = ""

        foreach ($word in $words) {
            if ($word.Length -eq 0) {
                # Preserve multiple spaces
                if ($currentLine.Length -gt 0) { $currentLine += " " }
                continue
            }

            # Handle long words
            while ($word.Length -gt $MaxWidth) {
                if ($currentLine.Length -gt 0) {
                    $lines.Add($currentLine)
                    $currentLine = ""
                }
                $lines.Add($word.Substring(0, $MaxWidth))
                $word = $word.Substring($MaxWidth)
            }

            if ($currentLine.Length -eq 0) {
                $currentLine = $word
            }
            elseif ($currentLine.Length + 1 + $word.Length -le $MaxWidth) {
                $currentLine += " " + $word
            }
            else {
                $lines.Add($currentLine)
                $currentLine = $word
            }
        }
        if ($currentLine.Length -gt 0) {
            $lines.Add($currentLine)
        }
    }

    if ($lines.Count -eq 0) {
        $lines.Add('')
    }

    # 3. Calculate max width (minimum 11 for standard cow thought pointer)
    $maxLength = 11
    foreach ($line in $lines) {
        if ($line.Length -gt $maxLength) { $maxLength = $line.Length }
    }

    # 4. Render balloon
    # All lines will have length: 2 (indent) + 2 (||) + 1 (space) + $maxLength + 1 (space) + 2 (||) = $maxLength + 8
    $result = [System.Collections.Generic.List[string]]::new($lines.Count + 2)
    $borderHashes = '#' * ($maxLength + 4)
    $topLine = "  $borderHashes" # Total length: 2 + ($maxLength + 4) = $maxLength + 6? No.
    # Wait, if side line is $maxLength + 8.
    # Top line should be "  " (2) + hashes (N).
    # So N should be $maxLength + 6.
    $borderHashes = '#' * ($maxLength + 6)
    $borderLine = "  $borderHashes"

    $result.Add($borderLine)
    foreach ($line in $lines) {
        $pad = ' ' * ($maxLength - $line.Length)
        $result.Add("  || $line$pad ||")
    }
    $result.Add($borderLine)

    return ($result -join "`n")
}
