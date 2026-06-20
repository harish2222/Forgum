function Invoke-ForgumGallery {
    [CmdletBinding()]
    param([string[]]$Arguments = @())

    $parsed = Parse-ForgumArguments -Arguments $Arguments

    if ($parsed.Help) {
        Get-HelpMessage -Command 'gallery'
        return
    }

    $count = if ($parsed.Options.ContainsKey('count')) { [int]$parsed.Options['count'] } else { 5 }

    Show-CFCowGallery -Count $count
}
