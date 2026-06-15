function Write-TerminalFrame {
    <#
    .SYNOPSIS
        Renders a single frame to the terminal with flicker-free cursor management.
    .DESCRIPTION
        Moves the cursor up if a previous frame count is provided and clears each
        line before writing the new frame. Falls back to standard output if not a TTY.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$Frame,

        [Parameter()]
        [int]$PreviousLineCount = 0
    )

    process {
        $esc = [char]27
        $isTTY = -not [Console]::IsOutputRedirected

        # 1. Reset cursor if needed
        if ($isTTY -and $PreviousLineCount -gt 0) {
            # Move cursor up N lines: ESC[<N>A
            Write-Host -NoNewline "$($esc)[$($PreviousLineCount)A"
        }

        # 2. Split frame into lines for individual clearing
        $lines = $Frame -split "`r?`n"

        # 3. Write each line with Clear Line sequence
        foreach ($line in $lines) {
            if ($isTTY) {
                # Clear line: ESC[2K, then write content
                Write-Host -NoNewline "$($esc)[2K$line`n"
            }
            else {
                # Fallback for CI/redirected output
                Write-Host $line
            }
        }
    }
}
