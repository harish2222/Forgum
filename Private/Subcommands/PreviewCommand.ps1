function PreviewCommand {
    [CmdletBinding()]
    param([string[]]$Arguments = @())

    $parsed = ParseForgumArguments -Arguments $Arguments

    if ($parsed.Help) {
        GetHelpMessage -Command 'preview'
        return
    }

    $cow = if ($parsed.Options.ContainsKey('cow')) { $parsed.Options['cow'] }
           elseif ($parsed.Text.Count -gt 0) { $parsed.Text[0] }
           else { 'default' }
    $text = if ($parsed.Options.ContainsKey('text')) { $parsed.Options['text'] }
            elseif ($parsed.Text.Count -gt 1) { $parsed.Text[1] }
            else { 'Hello World' }

    ShowCowPreview -CowFile $cow -Text $text
}
