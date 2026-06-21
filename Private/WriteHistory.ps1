function WriteHistory {
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

    $configDir = Split-Path (GetConfigPath) -Parent
    $historyPath = Join-Path $configDir 'history.json'

    $entry = [PSCustomObject]@{
        timestamp = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
        message   = $Message
        cow       = $Cow
    }

    $history = @()
    if (Test-Path $historyPath) {
        try {
            $parsed = Get-Content $historyPath -Raw | ConvertFrom-Json
            # ConvertTo-Json unwraps single-item arrays; re-wrap for consistency
            if ($parsed -is [System.Array]) { $history = @($parsed) } else { $history = @($parsed) }
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

    # ConvertTo-JsonSafe collects pipeline input and serializes arrays correctly
    ,$history | ConvertTo-JsonSafe | Set-Content -Path $historyPath -Encoding UTF8 -Force
}
