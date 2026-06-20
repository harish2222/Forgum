function Invoke-ForgumHistory {
    [CmdletBinding()]
    param([string[]]$Arguments = @())

    $parsed = Parse-ForgumArguments -Arguments $Arguments

    if ($parsed.Help) {
        Get-HelpMessage -Command 'history'
        return
    }

    $count = 10
    if ($parsed.Options.ContainsKey('count')) {
        $parsedInt = 0
        if ([int]::TryParse($parsed.Options['count'], [ref]$parsedInt) -and $parsedInt -gt 0) {
            $count = $parsedInt
        }
    }
    $clear = $parsed.Flags.ContainsKey('clear')

    $historyPath = Join-Path (Split-Path (Get-ConfigPath) -Parent) 'history.json'

    if ($clear) {
        if (Test-Path $historyPath) {
            Remove-Item $historyPath -Force
        }
        Write-Output "History cleared"
        return
    }

    if (-not (Test-Path $historyPath)) {
        Write-Output "No history yet. Run some cows first!"
        return
    }

    try {
        $history = Get-Content $historyPath -Raw | ConvertFrom-Json
    }
    catch {
        Write-Warning "Corrupt history file"
        return
    }

    $entries = @($history)
    if ($entries.Count -eq 0) {
        Write-Output "No history yet. Run some cows first!"
        return
    }

    # Show most recent first
    $shown = [Math]::Min($count, $entries.Count)
    Write-Output "Last $shown cows:"
    Write-Output ""

    $recent = $entries | Select-Object -Last $shown | Sort-Object { $_.timestamp } -Descending
    foreach ($entry in $recent) {
        $ts = if ($entry.timestamp) { $entry.timestamp } else { 'unknown' }
        $msg = if ($entry.message) { $entry.message } else { '(no text)' }
        $cow = if ($entry.cow) { $entry.cow } else { 'default' }
        Write-Output "  [$ts] $cow - $msg"
    }

    Write-Output ""
    Write-Output "Total: $($entries.Count) entries"
    Write-Output "Use: forgum history --clear to clear"
}
