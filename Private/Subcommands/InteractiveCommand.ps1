function InteractiveCommand {
    [CmdletBinding()]
    param([string[]]$Arguments = @())

    $parsed = ParseForgumArguments -Arguments $Arguments

    if ($parsed.Help) {
        GetHelpMessage -Command 'interactive'
        return
    }

    InvokeForgumTUI
}
