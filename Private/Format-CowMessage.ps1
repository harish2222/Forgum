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
    # Strip zero-width characters (using literal chars for maximum compatibility)
    $zeroWidthChars = "[" + [char]0x200B + [char]0x200C + [char]0x200D + [char]0xFEFF + "]"
    $Text = $Text -replace $zeroWidthChars, ""
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
                if ($currentLine.Length -gt 0) { $lines.Add($currentLine) }
                $lines.Add($word.Substring(0, $MaxWidth))
                $word = $word.Substring($MaxWidth)
                $currentLine = ""
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
        if ($currentLine.Length -gt 0) { $lines.Add($currentLine) }
    }
    if ($lines.Count -eq 0) { $lines.Add('') }

    # 3. Calculate max width (minimum 11 for thought pointer)
    $maxLength = 11
    foreach ($line in $lines) {
        if ($line.Length -gt $maxLength) { $maxLength = $line.Length }
    }

    # 4. Render balloon
    # Mid line format: "  || " (5) + line (maxLength) + " ||" (3) = maxLength + 8 total chars
    # Top line format: "  " (2) + hashes (H)
    # To align: 2 + H = maxLength + 8 => H = maxLength + 6
    
    $result = [System.Collections.Generic.List[string]]::new($lines.Count + 2)
    $borderHashes = '#' * ($maxLength + 6)
    $topLine = "  $borderHashes"
    
    $result.Add($topLine)
    foreach ($line in $lines) {
        $pad = ' ' * ($maxLength - $line.Length)
        $result.Add("  || $line$pad ||")
    }
    $result.Add($topLine)

    return ($result -join "`n")
}
