function Invoke-ForgumHelp {
    [CmdletBinding()]
    param([string[]]$Arguments = @())

    if ($Arguments.Count -gt 0) {
        Get-HelpMessage -Command $Arguments[0]
    } else {
        Get-HelpMessage -Command 'root'
    }
}
