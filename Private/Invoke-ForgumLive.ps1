function Invoke-ForgumLive {
    <#
    .SYNOPSIS
        Launches the live showcase mode.
    .DESCRIPTION
        Cycles through animation effects with sample text.
    .PARAMETER Duration
        Seconds to run (default: 5).
    #>
    [CmdletBinding()]
    param(
        [int]$Duration = 5
    )

    Invoke-LiveShow -Duration $Duration
}
