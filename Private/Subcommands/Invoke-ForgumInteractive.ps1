function Invoke-ForgumInteractive {
    [CmdletBinding()]
    param([string[]]$Arguments = @())

    $parsed = Parse-ForgumArguments -Arguments $Arguments

    if ($parsed.Help) {
        Get-HelpMessage -Command 'interactive'
        return
    }

    Invoke-ForgumTUI
}
