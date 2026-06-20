function Read-CowFile {
    <#
    .SYNOPSIS
        Reads and parses a .cow template file with caching.
    .DESCRIPTION
        Extracts the $the_cow block from a Perl-format .cow file.
        Handles escape sequences (\@, \$, \\) and caches results for performance.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$CowName,

        [string]$CustomPath
    )

    # Check cache first
    $cacheKey = if ($CustomPath) { $CustomPath } else { $CowName }
    if ($script:CowFileCache.ContainsKey($cacheKey)) {
        return $script:CowFileCache[$cacheKey]
    }

    # Resolve path
    if ($CustomPath) {
        $path = [System.IO.Path]::GetFullPath($CustomPath)
        if ($path -match '[\\/]\.\.[\\/]') {
            throw "Invalid custom path: '$CustomPath' contains path traversal"
        }
    }
    else {
        $cowsPath = Join-Path (Split-Path $PSScriptRoot -Parent) 'Data/Cows'
        $path = Join-Path $cowsPath "$CowName.cow"
        # Security: ensure resolved path stays within Cows directory
        $resolvedPath = [System.IO.Path]::GetFullPath($path)
        $resolvedBase = [System.IO.Path]::GetFullPath($cowsPath)
        if (-not $resolvedPath.StartsWith($resolvedBase, [StringComparison]::OrdinalIgnoreCase)) {
            throw "Invalid cow name: '$CowName' resolves outside the Cows directory"
        }
        $path = $resolvedPath
    }

    if (-not (Test-Path $path)) {
        throw "Cow file not found: $path"
    }

    $content = Get-Content $path -Raw -ErrorAction Stop
    $content = $content -replace "`r`n", "`n"

    # Extract $the_cow heredoc block
    # Use \n instead of \s* to preserve leading whitespace in cow template lines
    if ($content -match '(?s)\$the_cow\s*=\s*<<["'']?EOC["'']?;?\n(.*?)\n\s*EOC') {
        $content = $Matches[1]
    }

    # Unescape Perl escape sequences (order matters: \\ before \@ and \$)
    $content = $content -replace '\\\\', '\'
    $content = $content -replace '\\@',  '@'
    $content = $content -replace '\\\$', '$'

    # Cache for subsequent calls
    $script:CowFileCache[$cacheKey] = $content

    return $content
}
