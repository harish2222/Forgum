function Write-ForgumHistory {
    <#
    .SYNOPSIS
        Logs a cow render to history.
    .PARAMETER Message
        The text that was rendered.
    .PARAMETER Cow
        The cow template used.
    #>
    [CmdletBinding()]
    param(
        [string]$Message,
        [string]$Cow = 'default'
    )

    $configDir = Split-Path (Get-ConfigPath) -Parent
    $historyPath = Join-Path $configDir 'history.json'

    $entry = [PSCustomObject]@{
        timestamp = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
        message   = $Message
        cow       = $Cow
    }

    $history = @()
    if (Test-Path $historyPath) {
        try {
            $history = @(Get-Content $historyPath -Raw | ConvertFrom-Json)
        }
        catch {
            $history = @()
        }
    }

    $history = @($history) + @($entry)

    # Keep last 100 entries
    if ($history.Count -gt 100) {
        $history = $history | Select-Object -Last 100
    }

    if (-not (Test-Path $configDir)) {
        New-Item -ItemType Directory -Path $configDir -Force | Out-Null
    }

    $history | ConvertTo-Json -Depth 5 | Set-Content -Path $historyPath -Encoding UTF8 -Force
}
