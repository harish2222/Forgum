function Set-CFConfig {
    <#
    .SYNOPSIS
        Saves the Forgum configuration to disk.
    .DESCRIPTION
        Accepts a hashtable or PSCustomObject and saves it as JSON.
        Creates the config directory if it doesn't exist.
        Invalidates the config cache so subsequent reads use the new values.
    .PARAMETER Config
        Configuration object to save. Must be a hashtable or PSCustomObject.
    .EXAMPLE
        $config = Get-CFConfig
        $config.lolcat.enabled = $true
        Set-CFConfig -Config $config
    .EXAMPLE
        Set-CFConfig -Config @{ lolcat = @{ enabled = $true }; cow = @{ file = 'tux' } }
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([void])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ $_ -is [hashtable] -or $_ -is [PSCustomObject] })]
        $Config
    )

    $path = Get-ConfigPath
    $dir = Split-Path $path -Parent

    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force -ErrorAction Stop | Out-Null
    }

    if ($PSCmdlet.ShouldProcess($path, 'Save configuration')) {
        # Convert to JSON with sufficient depth
        $json = $Config | ConvertTo-Json -Depth 10

        # Atomic write: write to temp file then move (prevents corruption on crash)
        $tempPath = "$path.tmp"
        try {
            $json | Set-Content -Path $tempPath -Encoding UTF8 -Force -ErrorAction Stop
            Move-Item -Path $tempPath -Destination $path -Force -ErrorAction Stop
        }
        catch {
            if (Test-Path $tempPath) { Remove-Item $tempPath -Force -ErrorAction SilentlyContinue }
            throw
        }
    }

    # Invalidate cache
    $script:ConfigCache = $null
    $script:ConfigCacheTime = [datetime]::MinValue
}
