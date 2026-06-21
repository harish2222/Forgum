function InvokeForgumLive {
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

    InvokeLiveShow -Duration $Duration
}
