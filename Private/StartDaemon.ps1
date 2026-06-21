function StartDaemon {
    <#
    .SYNOPSIS
        Starts the background animation daemon.
    .DESCRIPTION
        Launches the Rust engine in daemon mode for background rendering.
    #>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    param()

    $binary = GetEngineBinary
    if ($binary) {
        Start-Process -FilePath $binary -ArgumentList '--daemon' -NoNewWindow -ErrorAction SilentlyContinue
        "Forgum daemon started."
    } else {
        "forgum-engine not found. Cannot start daemon."
    }
}
