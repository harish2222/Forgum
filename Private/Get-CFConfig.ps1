function Get-CFConfig {
    <#
    .SYNOPSIS
        Returns the current Forgum configuration.
    .DESCRIPTION
        Loads config from disk (with caching) or returns defaults.
        Config is cached for 30 seconds to avoid repeated disk reads.
    .EXAMPLE
        Get-CFConfig
        Returns the full configuration object.
    .EXAMPLE
        (Get-CFConfig).lolcat.enabled
        Returns just the lolcat enabled setting.
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param()

    # Return cached config if still valid
    $now = [datetime]::UtcNow
    if ($null -ne $script:ConfigCache -and
        ($now - $script:ConfigCacheTime).TotalSeconds -lt $script:ConfigCacheTTL) {
        return $script:ConfigCache
    }

    $path = Get-ConfigPath

    if (Test-Path $path) {
        try {
            $config = Get-Content $path -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
        }
        catch {
            Write-Warning "Forgum: Corrupt config file, using defaults. Error: $($_.Exception.Message)"
            $config = $null
        }
    }

    if (-not $config) {
        $defaultPath = Join-Path (Split-Path $PSScriptRoot -Parent) 'Data/Templates/default-config.json'
        $config = Get-Content $defaultPath -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
    }

    # Cache the result
    $script:ConfigCache = $config
    $script:ConfigCacheTime = $now

    return $config
}
