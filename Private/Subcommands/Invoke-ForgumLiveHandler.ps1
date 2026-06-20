function Invoke-ForgumLiveHandler {
    [CmdletBinding()]
    param([string[]]$Arguments = @())

    $parsed = Parse-ForgumArguments -Arguments $Arguments

    if ($parsed.Help) {
        Get-HelpMessage -Command 'live'
        return
    }

    $duration = if ($parsed.Options.ContainsKey('duration')) { [int]$parsed.Options['duration'] } else { 5 }

    Invoke-ForgumLive -Duration $duration
}
