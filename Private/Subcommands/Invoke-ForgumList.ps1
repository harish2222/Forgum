function Invoke-ForgumList {
    [CmdletBinding()]
    param([string[]]$Arguments = @())

    $parsed = Parse-ForgumArguments -Arguments $Arguments

    if ($parsed.Help) {
        Get-HelpMessage -Command 'list'
        return
    }

    $search = if ($parsed.Options.ContainsKey('search')) { $parsed.Options['search'] } else { $null }
    $count = 0
    if ($parsed.Options.ContainsKey('count')) {
        $parsedInt = 0
        if ([int]::TryParse($parsed.Options['count'], [ref]$parsedInt) -and $parsedInt -gt 0) {
            $count = $parsedInt
        }
    }

    $cowsPath = Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) 'Data/Cows'
    $cows = Get-ChildItem -Path $cowsPath -Filter '*.cow' -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty BaseName |
        Sort-Object

    if ($search) {
        $cows = $cows | Where-Object { $_ -like "*$search*" }
    }

    $cowsArray = @($cows)
    $total = $cowsArray.Count

    if ($total -eq 0) {
        Write-Output "No cow templates found"
        return
    }

    if ($count -gt 0 -and $count -lt $total) {
        $cowsArray = $cowsArray | Get-Random -Count $count
        $total = $cowsArray.Count
    }

    Write-Output "Available cow templates ($total):"
    Write-Output ""

    foreach ($cow in $cowsArray) {
        Write-Output "  $cow"
    }

    Write-Output ""
    Write-Output "Use: forgum preview <cow> to see a cow"
    Write-Output "Use: forgum cowsay --cow <cow> <text> to use a cow"
}
