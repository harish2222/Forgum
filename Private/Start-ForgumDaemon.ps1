function Start-ForgumDaemon {
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

    $binary = Get-EngineBinary
    if ($binary) {
        Start-Process -FilePath $binary -ArgumentList '--daemon' -NoNewWindow -ErrorAction SilentlyContinue
        Write-Host "Forgum daemon started."
    } else {
        Write-Warning "forgum-engine not found. Cannot start daemon."
    }
}
