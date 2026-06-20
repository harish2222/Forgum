function Invoke-ForgumLiveHandler {
    [CmdletBinding()]
    param([string[]]$Arguments = @())

    $parsed = Parse-ForgumArguments -Arguments $Arguments

    if ($parsed.Help) {
        Get-HelpMessage -Command 'live'
        return
    }

    $duration = 5
    if ($parsed.Options.ContainsKey('duration')) {
        $parsedInt = 0
        if ([int]::TryParse($parsed.Options['duration'], [ref]$parsedInt) -and $parsedInt -gt 0) {
            $duration = $parsedInt
        }
    }

    Invoke-ForgumLive -Duration $duration
}
