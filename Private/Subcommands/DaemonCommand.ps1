function DaemonCommand {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
    param([string[]]$Arguments = @())

    $parsed = ParseForgumArguments -Arguments $Arguments

    if ($parsed.Help) {
        GetHelpMessage -Command 'daemon'
        return
    }

    $action = if ($parsed.Text.Count -gt 0) { $parsed.Text[0].ToLower() } else { 'start' }

    switch ($action) {
        'start' { StartDaemon }
        'stop'  { StopDaemon }
        default {
            "Unknown action: $action"
            "Usage: forgum daemon start|stop"
        }
    }
}
