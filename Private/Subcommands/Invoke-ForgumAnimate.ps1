function Invoke-ForgumAnimate {
    [CmdletBinding()]
    param([string[]]$Arguments = @())

    $parsed = Parse-ForgumArguments -Arguments $Arguments

    if ($parsed.Help) {
        Get-HelpMessage -Command 'animate'
        return
    }

    $mode = if ($parsed.Text.Count -gt 0) { $parsed.Text[0] } elseif ($parsed.Options.ContainsKey('mode')) { $parsed.Options['mode'] } else { '' }

    if ($mode) {
        Set-CFCowAnimate -Mode $mode
    } else {
        Set-CFCowAnimate
    }
}
