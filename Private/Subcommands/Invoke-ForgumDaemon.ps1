function Invoke-ForgumDaemon {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
    param([string[]]$Arguments = @())

    $parsed = Parse-ForgumArguments -Arguments $Arguments

    if ($parsed.Help) {
        Get-HelpMessage -Command 'daemon'
        return
    }

    $action = if ($parsed.Text.Count -gt 0) { $parsed.Text[0].ToLower() } else { 'start' }

    switch ($action) {
        'start' { Start-ForgumDaemon }
        'stop'  { Stop-ForgumDaemon }
        default {
            Write-Host "Unknown action: $action"
            Write-Host "Usage: forgum daemon start|stop"
        }
    }
}
