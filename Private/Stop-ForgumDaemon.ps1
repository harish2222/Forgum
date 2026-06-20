function Stop-ForgumDaemon {
    <#
    .SYNOPSIS
        Stops the background animation daemon.
    .DESCRIPTION
        Finds and stops the forgum-engine daemon process.
    #>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    param()

    $procs = Get-Process -Name 'forgum-engine*' -ErrorAction SilentlyContinue
    if ($procs) {
        $procs | Stop-Process -Force -ErrorAction SilentlyContinue
        Write-Host "Forgum daemon stopped."
    } else {
        Write-Host "No forgum daemon is running."
    }
}
