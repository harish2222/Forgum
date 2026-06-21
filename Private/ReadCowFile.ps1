function ReadCowFile {
    <#
    .SYNOPSIS
        Reads and parses a .cow file template.
    .DESCRIPTION
        Extracts the cow template from a .cow file, unescaping Perl sequences.
    .PARAMETER CowName
        Name of the cow file (without .cow extension).
    .PARAMETER CustomPath
        Optional custom path to a .cow file.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [string]$CowName,

        [string]$CustomPath = ''
    )

    if ($script:CowFileCache -and $script:CowFileCache.ContainsKey($CowName)) {
        return $script:CowFileCache[$CowName]
    }

    $cowsPath = Join-Path (Split-Path $PSScriptRoot -Parent) 'Data/Cows'

    if ($CustomPath) {
        if ($CustomPath -match '\.\.') {
            throw "Path traversal detected in custom path: $CustomPath"
        }
        $filePath = $CustomPath
    } else {
        $filePath = Join-Path $cowsPath "$CowName.cow"
    }

    if (-not (Test-Path $filePath)) {
        throw "Cow file not found: $filePath"
    }

    $content = Get-Content -Path $filePath -Raw -ErrorAction Stop
    $content = $content -replace "`r`n", "`n"

    $pattern = "(?s)\`$the_cow\s*=\s*<<[""']?EOC[""']?;?\n(.*?)\n\s*EOC"
    if ($content -match $pattern) {
        $template = $Matches[1]
    } else {
        throw "Failed to parse cow file: $filePath"
    }

    $template = $template -replace '\\\\', '\'
    $template = $template -replace '\\@', '@'
    $template = $template -replace '\\$', '$'

    if (-not $script:CowFileCache) {
        $script:CowFileCache = @{}
    }
    $script:CowFileCache[$CowName] = $template

    return $template
}
