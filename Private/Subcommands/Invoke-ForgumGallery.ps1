function Invoke-ForgumGallery {
    [CmdletBinding()]
    param([string[]]$Arguments = @())

    $parsed = Parse-ForgumArguments -Arguments $Arguments

    if ($parsed.Help) {
        Get-HelpMessage -Command 'gallery'
        return
    }

    $count = 5
    if ($parsed.Options.ContainsKey('count')) {
        $parsedInt = 0
        if ([int]::TryParse($parsed.Options['count'], [ref]$parsedInt) -and $parsedInt -gt 0) {
            $count = $parsedInt
        }
    }

    Show-CFCowGallery -Count $count
}
