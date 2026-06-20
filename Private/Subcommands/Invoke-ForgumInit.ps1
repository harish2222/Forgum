function Invoke-ForgumInit {
    [CmdletBinding()]
    param([string[]]$Arguments = @())

    $parsed = Parse-ForgumArguments -Arguments $Arguments

    if ($parsed.Help) {
        Get-HelpMessage -Command 'init'
        return
    }

    $shell = if ($parsed.Text.Count -gt 0) { $parsed.Text[0] } elseif ($parsed.Options.ContainsKey('shell')) { $parsed.Options['shell'] } else { '' }

    if (-not $shell) {
        $shell = Get-ForgumShell
        Write-Host "Auto-detected shell: $shell"
    }

    $binaryPath = Get-EngineBinary
    if ($binaryPath) {
        & $binaryPath init $shell
    } else {
        Write-Host (Get-ForgumShellHook -Shell $shell)
    }
}
