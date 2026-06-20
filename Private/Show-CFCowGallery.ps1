function Show-CFCowGallery {
    <#
    .SYNOPSIS
        Displays a gallery of random cow files.
    .DESCRIPTION
        Selects N random cows and renders them with a fortune.
    .PARAMETER Count
        Number of cows to show (default: 5).
    #>
    [CmdletBinding()]
    param(
        [int]$Count = 5
    )

    $cows = Get-CFCow
    if (-not $cows -or $cows.Count -eq 0) {
        Write-Warning "No cow files found."
        return
    }

    $selected = $cows | Get-Random -Count ([Math]::Min($Count, $cows.Count))
    foreach ($cow in $selected) {
        $fortune = Get-Fortune
        $output = Invoke-Cowsay -Text $fortune -CowFile $cow
        Write-Host ""
        Write-Host "=== $cow ===" -ForegroundColor Cyan
        Write-Host $output
    }
}
