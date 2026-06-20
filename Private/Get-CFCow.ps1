function Get-CFCow {
    <#
    .SYNOPSIS
        Lists available cow files or reads a specific cow.
    .DESCRIPTION
        With -Name, returns the parsed cow template content.
        Without parameters, returns a list of all available cow names.
    .PARAMETER Name
        Name of the cow file to read (without .cow extension).
    .EXAMPLE
        Get-CFCow
        Lists all available cow names.
    .EXAMPLE
        Get-CFCow -Name 'tux'
        Returns the parsed template for the tux cow.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [ValidateNotNullOrEmpty()]
        [string]$Name
    )

    $cowsPath = Join-Path (Split-Path $PSScriptRoot -Parent) 'Data/Cows'

    if ($Name) {
        return Read-CowFile -CowName $Name
    }

    $cows = Get-ChildItem -Path $cowsPath -Filter '*.cow' -ErrorAction Stop |
        Select-Object -ExpandProperty BaseName |
        Sort-Object

    return @($cows)
}
