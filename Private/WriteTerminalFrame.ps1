function WriteTerminalFrame {
    <#
    .SYNOPSIS
        Renders a single frame to the terminal with flicker-free cursor management.
    .DESCRIPTION
        Moves the cursor up if a previous frame count is provided and clears each
        line before writing the new frame. Falls back to standard output if not a TTY.
    #>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$Frame,

        [Parameter()]
        [int]$PreviousLineCount = 0,

        [Parameter()]
        [switch]$ForceTTY
    )

    process {
        $esc = [char]27
        # [Console]::IsOutputRedirected can throw in non-interactive hosts
        # (e.g. some CI runners, test harnesses). Treat any exception as "not a TTY".
        $isOutputRedirected = $true
        try {
            $isOutputRedirected = [Console]::IsOutputRedirected
        } catch {
            $isOutputRedirected = $true
        }
        $isTTY = [bool]$ForceTTY -or (-not $isOutputRedirected)

        # 1. Reset cursor if needed
        if ($isTTY -and $PreviousLineCount -gt 0) {
            # Move cursor up N lines: ESC[<N>A
            Write-Host -NoNewline "$($esc)[$($PreviousLineCount)A"
        }

        # 2. Split frame into lines for individual clearing
        $lines = $Frame -split "`r?`n"

        # 3. Write each line, combining "clear line" and content into a single
        #    Write-Host call. Splitting them into two Write-Host calls causes
        #    visible flicker on some terminals because the clear sequence is
        #    flushed separately from the line content.
        if ($isTTY) {
            $combined = for ($i = 0; $i -lt $lines.Count; $i++) {
                # ESC[2K = clear entire line, then line content, then newline.
                # On the last line we still emit the newline so subsequent output
                # starts on a fresh line.
                "$($esc)[2K$($lines[$i])`n"
            }
            Write-Host -NoNewline ($combined -join '')
        }
        else {
            # Fallback for CI/redirected output: just emit the frame as-is.
            Write-Output ($lines -join "`n")
        }
    }
}
