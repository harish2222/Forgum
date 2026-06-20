function Get-Fortune {
    <#
    .SYNOPSIS
        Returns a random fortune from the fortune database.
    .DESCRIPTION
        Reads the fortune database file, parses entries, and returns one at random.
        Results are cached for performance.
    .PARAMETER Database
        Name of the fortune database file (without .txt extension).
    .EXAMPLE
        Get-Fortune
        Returns a random fortune from the default database.
    .EXAMPLE
        Get-Fortune -Database 'fortunes'
        Returns a random fortune from the specified database.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [ValidateNotNullOrEmpty()]
        [string]$Database = 'fortunes'
    )

    $fortunePath = Join-Path (Split-Path $PSScriptRoot -Parent) "Data/Fortunes/$Database.txt"
    $resolvedPath = [System.IO.Path]::GetFullPath($fortunePath)
    $baseDir = [System.IO.Path]::GetFullPath((Join-Path (Split-Path $PSScriptRoot -Parent) 'Data/Fortunes'))
    if (-not $resolvedPath.StartsWith($baseDir)) {
        throw "Invalid database name: $Database"
    }

    if (-not (Test-Path $fortunePath)) {
        throw "Fortune database not found: $Database (looked at $fortunePath)"
    }

    $entries = Read-FortuneFile -Path $fortunePath

    if ($entries.Count -eq 0) {
        throw "Fortune database is empty: $Database"
    }

    return ($entries | Get-Random)
}
