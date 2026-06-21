function ShowCowGallery {
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

    $cows = GetCowFiles
    if (-not $cows -or $cows.Count -eq 0) {
        Write-Warning "No cow files found."
        return
    }

    $selected = $cows | Get-Random -Count ([Math]::Min($Count, $cows.Count))
    foreach ($cow in $selected) {
        $fortune = GetFortune
        $output = InvokeCowsay -Text $fortune -CowFile $cow
        Write-Output ""
        Write-Output "=== $cow ==="
        Write-Output $output
    }
}
