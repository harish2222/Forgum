function UpdateCommand {
    [CmdletBinding()]
    param([string[]]$Arguments = @())

    $parsed = ParseForgumArguments -Arguments $Arguments

    if ($parsed.Help) {
        GetHelpMessage -Command 'update'
        return
    }

    $params = @{}
    if ($parsed.Flags.ContainsKey('force')) { $params.Force = $true }
    if ($parsed.Flags.ContainsKey('check')) { $params.CheckOnly = $true }

    UpdateForgum @params
}
