function LiveCommand {
    [CmdletBinding()]
    param([string[]]$Arguments = @())

    $parsed = ParseForgumArguments -Arguments $Arguments

    if ($parsed.Help) {
        GetHelpMessage -Command 'live'
        return
    }

    $duration = 5
    if ($parsed.Options.ContainsKey('duration')) {
        $parsedInt = 0
        if ([int]::TryParse($parsed.Options['duration'], [ref]$parsedInt) -and $parsedInt -gt 0) {
            $duration = $parsedInt
        }
    }

    InvokeForgumLive -Duration $duration
}
