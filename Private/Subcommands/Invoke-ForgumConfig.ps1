function Invoke-ForgumConfig {
    [CmdletBinding()]
    param([string[]]$Arguments = @())

    $parsed = Parse-ForgumArguments -Arguments $Arguments

    if ($parsed.Help) {
        Get-HelpMessage -Command 'config'
        return
    }

    Invoke-ForgumTUI
}
