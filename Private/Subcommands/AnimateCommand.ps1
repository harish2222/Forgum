function AnimateCommand {
    [CmdletBinding()]
    param([string[]]$Arguments = @())

    $parsed = ParseForgumArguments -Arguments $Arguments

    if ($parsed.Help) {
        GetHelpMessage -Command 'animate'
        return
    }

    $mode = if ($parsed.Text.Count -gt 0) { $parsed.Text[0] } elseif ($parsed.Options.ContainsKey('mode')) { $parsed.Options['mode'] } else { '' }

    if ($mode) {
        SetCowAnimate -Mode $mode
    } else {
        SetCowAnimate
    }
}
