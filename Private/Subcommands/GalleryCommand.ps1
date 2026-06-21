function GalleryCommand {
    [CmdletBinding()]
    param([string[]]$Arguments = @())

    $parsed = ParseForgumArguments -Arguments $Arguments

    if ($parsed.Help) {
        GetHelpMessage -Command 'gallery'
        return
    }

    $count = 5
    if ($parsed.Options.ContainsKey('count')) {
        $parsedInt = 0
        if ([int]::TryParse($parsed.Options['count'], [ref]$parsedInt) -and $parsedInt -gt 0) {
            $count = $parsedInt
        }
    }

    ShowCowGallery -Count $count
}
