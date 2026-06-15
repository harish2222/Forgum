function Invoke-BounceAnimation {
    <#
    .SYNOPSIS
        Cow drops in from above with realistic bounce physics.
    .DESCRIPTION
        Simulates gravity and elasticity — cow falls from above the viewport,
        hits the "ground", bounces back up with decreasing height.
        Each bounce loses energy, creating a natural settling effect.
        Uses cursor repositioning for smooth frame-over-frame rendering.
    #>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'Message')]
    param(
        [Parameter(Mandatory)]
        [string]$CowOutput,

        [string]$Message = '',

        [ValidateRange(1, 20)]
        [int]$Duration = 3,

        [ValidateRange(10, 100)]
        [int]$Speed = 40
    )

    $lines = $CowOutput -split "`n"
    $cowHeight = $lines.Count

    # Calculate bounce physics
    $gravity = 0.8
    $damping = 0.55
    $startOffset = -$cowHeight - 3
    $groundY = 0

    $positions = [System.Collections.Generic.List[int]]::new()

    # Simulate physics
    $y = [double]$startOffset
    $vy = 0.0
    $bounces = 0

    while ($bounces -lt $Duration) {
        $vy += $gravity
        $y += $vy

        if ($y -ge $groundY) {
            $y = $groundY
            $vy = -$vy * $damping
            $bounces++
            if ([Math]::Abs($vy) -lt 0.5) { break }
        }

        $positions.Add([int]$y)
    }
    $positions.Add($groundY)

    $sb = [System.Text.StringBuilder]::new($CowOutput.Length * 2)

    foreach ($pos in $positions) {
        [void]$sb.Clear()

        # Print blank lines above cow for positioning
        $blankLines = [Math]::Max(0, $pos)
        for ($b = 0; $b -lt $blankLines; $b++) {
            [void]$sb.AppendLine()
        }

        # Add cow lines
        foreach ($line in $lines) {
            [void]$sb.AppendLine($line)
        }

        try {
            if ($positions.IndexOf($pos) -gt 0) {
                $totalHeight = $blankLines + $cowHeight
                if ([Console]::CursorTop -ge $totalHeight) {
                    [Console]::SetCursorPosition(0, [Console]::CursorTop - $totalHeight)
                }
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

