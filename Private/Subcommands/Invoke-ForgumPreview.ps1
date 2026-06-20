function Invoke-ForgumPreview {
    [CmdletBinding()]
    param([string[]]$Arguments = @())

    $parsed = Parse-ForgumArguments -Arguments $Arguments

    if ($parsed.Help) {
        Get-HelpMessage -Command 'preview'
        return
    }

    $cow = if ($parsed.Text.Count -gt 0) { $parsed.Text[0] } else { 'default' }
    $text = if ($parsed.Text.Count -gt 1) { $parsed.Text[1] } else { 'Hello World' }

    Show-CFCowPreview -CowFile $cow -Text $text
}
