function Show-CFCowGallery {
    <#
    .SYNOPSIS
        Displays a random gallery of cows.

    .DESCRIPTION
        Selects a specified number of random cows from the available collection
        and displays them with a random fortune.

    .PARAMETER Count
        The number of cows to display in the gallery. Default is 5.

    .EXAMPLE
        Show-CFCowGallery -Count 3
        Displays 3 random cows.

    .EXAMPLE
        cowgallery 10
        Displays 10 random cows using the alias.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [ValidateRange(1, 100)]
        [int]$Count = 5
    )

    $cows = Get-CFCow | Get-Random -Count $Count
    foreach ($cow in $cows) {
        $fortune = Get-Fortune -ErrorAction SilentlyContinue
        if ([string]::IsNullOrWhiteSpace($fortune)) { $fortune = "Moo!" }
        Write-Host "`n=== $($cow) ===" -ForegroundColor Cyan
        Invoke-Cowsay -Text $fortune -CowFile $cow
    }
}
