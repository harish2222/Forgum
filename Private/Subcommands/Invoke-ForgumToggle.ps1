function Invoke-ForgumToggle {
    [CmdletBinding()]
    param([string[]]$Arguments = @())

    $parsed = Parse-ForgumArguments -Arguments $Arguments

    if ($parsed.Help) {
        Get-HelpMessage -Command 'toggle'
        return
    }

    Toggle-CFLolcat
}
