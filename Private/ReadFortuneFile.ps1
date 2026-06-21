function ReadFortuneFile {
    <#
    .SYNOPSIS
        Reads and parses a fortune database file with caching.
    .DESCRIPTION
        Splits fortune file by % delimiters and returns an array of entries.
        Caches parsed results for performance.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    # Check cache first
    if ($script:FortuneCache.ContainsKey($Path)) {
        return $script:FortuneCache[$Path]
    }

    if (-not (Test-Path $Path)) {
        throw "Fortune file not found: $Path"
    }

    $content = Get-Content $Path -Raw -ErrorAction Stop
    $content = $content -replace '\r?\n', "`n"

    $entries = $content -split '\n%\n'
    $entries = @($entries | Where-Object { $_.Trim() -ne '' })

    # Cache for subsequent calls
    $script:FortuneCache[$Path] = $entries

    return $entries
}
