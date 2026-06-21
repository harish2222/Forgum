function SetConfig {
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
        $config = GetConfig
        $config.lolcat.enabled = $true
        SetConfig -Config $config
    .EXAMPLE
        SetConfig -Config @{ lolcat = @{ enabled = $true }; cow = @{ file = 'tux' } }
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([void])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ $_ -is [hashtable] -or $_ -is [PSCustomObject] })]
        $Config
    )

    $path = GetConfigPath
    $dir = Split-Path $path -Parent

    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force -ErrorAction Stop | Out-Null
    }

    if ($PSCmdlet.ShouldProcess($path, 'Save configuration')) {
        # Convert to JSON with sufficient depth
        $json = $Config | ConvertTo-JsonSafe

        # Atomic write: use WriteAllText which is atomic on Windows
        # Avoids Move-Item race conditions that cause corruption
        try {
            $utf8NoBom = New-Object System.Text.UTF8Encoding $false
            [System.IO.File]::WriteAllText($path, $json, $utf8NoBom)
        }
        catch {
            throw
        }
    }

    # Invalidate cache
    $script:ConfigCache = $null
    $script:ConfigCacheTime = [datetime]::MinValue
}
