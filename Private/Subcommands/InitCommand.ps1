function InitCommand {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
    param([string[]]$Arguments = @())

    $parsed = ParseForgumArguments -Arguments $Arguments

    if ($parsed.Help) {
        GetHelpMessage -Command 'init'
        return
    }

    $shell = if ($parsed.Text.Count -gt 0) { $parsed.Text[0] } elseif ($parsed.Options.ContainsKey('shell')) { $parsed.Options['shell'] } else { '' }

    if (-not $shell) {
        $shell = GetShell
        "Auto-detected shell: $shell"
    }

    $binaryPath = GetEngineBinary
    if ($binaryPath) {
        & $binaryPath init $shell
    } else {
        GetForgumShellHook -Shell $shell
    }
}
