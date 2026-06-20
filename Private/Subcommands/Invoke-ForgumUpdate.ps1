function Invoke-ForgumUpdate {
    [CmdletBinding()]
    param([string[]]$Arguments = @())

    $parsed = Parse-ForgumArguments -Arguments $Arguments

    if ($parsed.Help) {
        Get-HelpMessage -Command 'update'
        return
    }

    $params = @{}
    if ($parsed.Flags.ContainsKey('force')) { $params.Force = $true }
    if ($parsed.Flags.ContainsKey('check')) { $params.CheckOnly = $true }

    Update-Forgum @params
}
