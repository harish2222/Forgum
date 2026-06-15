# TestHelpers.psm1
# Shared test utilities for Forgum test suite

# Module path discovery
$script:ModuleRoot = Split-Path $PSScriptRoot -Parent
$script:ModulePath = Join-Path $script:ModuleRoot 'Forgum.psd1'
$script:ConfigTemplate = Join-Path $script:ModuleRoot 'Data/Templates/default-config.json'

<#
.SYNOPSIS
    Imports the Forgum module for testing with auto-start disabled.
.DESCRIPTION
    Disables auto-start, imports the module, and returns module info.
    Safe to call multiple times (idempotent).
#>
function Import-TestModule {
    [CmdletBinding()]
    param([switch]$Force)
    
    $env:FORGUM_NOAUTOSTART = '1'
    
    if (Get-Module Forgum) {
        if ($Force) {
            Remove-Module Forgum -Force
        } else {
            return (Get-Module Forgum)
        }
    }
    
    Import-Module $script:ModulePath -Force -ErrorVariable importErrors
    if ($importErrors) {
        throw "Failed to import Forgum module: $($importErrors -join '; ')"
    }
    
    return (Get-Module Forgum)
}

<#
.SYNOPSIS
    Creates a test configuration object with known values.
.DESCRIPTION
    Returns a deep copy of the default config that tests can modify safely.
#>
function New-TestConfig {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    if ($PSCmdlet.ShouldProcess("Test Environment", "Create new test configuration object")) {
        $configJson = Get-Content $script:ConfigTemplate -Raw
        $config = $configJson | ConvertFrom-Json -AsHashtable
        if (-not $config) {
            # Fallback for PS 5.1
            $config = $configJson | ConvertFrom-Json | ConvertTo-Json -Depth 10 | ConvertFrom-Json
        }
        return $config
    }
}

<#
.SYNOPSIS
    Saves the current config and returns it for later restoration.
.DESCRIPTION
    Use with Restore-TestConfig for proper test isolation.
#>
function Save-TestConfig {
    return Get-CFConfig
}

<#
.SYNOPSIS
    Restores a previously saved configuration.
.DESCRIPTION
    Reverts config changes made during tests.
#>
function Restore-TestConfig {
    param([Parameter(Mandatory)][object]$Config)
    Set-CFConfig -Config $Config -ErrorAction SilentlyContinue
}

<#
.SYNOPSIS
    Checks if a string contains ANSI escape codes.
.PARAMETER Text
    The string to check.
.PARAMETER Mode
    'Any', 'Truecolor' (38;2), or '256' (38;5).
#>
function Test-HasAnsi {
    param(
        [string]$Text,
        [ValidateSet('Any','Truecolor','256')]
        [string]$Mode = 'Any'
    )
    $esc = [char]27
    switch ($Mode) {
        'Any'        { return $Text -match "${esc}\[" }
        'Truecolor'  { return $Text -match "${esc}\[38;2;" }
        '256'        { return $Text -match "${esc}\[38;5;" }
    }
}

<#
.SYNOPSIS
    Returns a list of available cow files from the module.
#>
function Get-TestCowFile {
    $cowsPath = Join-Path $script:ModuleRoot 'Data/Cows'
    return (Get-ChildItem -Path $cowsPath -Filter '*.cow').BaseName
}

<#
.SYNOPSIS
    Tests that a function has proper CmdletBinding.
.PARAMETER Name
    Name of the function to check.
#>
function Test-HasCmdletBinding {
    param([string]$Name)
    $cmd = Get-Command $Name -ErrorAction SilentlyContinue
    if (-not $cmd) { return $false }
    return $cmd.Parameters.ContainsKey('Verbose')
}

<#
.SYNOPSIS
    Returns the module root path.
#>
function Get-ModuleRoot {
    return $script:ModuleRoot
}

<#
.SYNOPSIS
    Returns the module manifest path.
#>
function Get-ModuleManifestPath {
    return $script:ModulePath
}

<#
.SYNOPSIS
    Returns the config template path.
#>
function Get-ConfigTemplatePath {
    return $script:ConfigTemplate
}

# Export all functions
Export-ModuleMember -Function @(
    'Import-TestModule',
    'New-TestConfig',
    'Save-TestConfig',
    'Restore-TestConfig',
    'Test-HasAnsi',
    'Get-TestCowFile',
    'Test-HasCmdletBinding',
    'Get-ModuleRoot',
    'Get-ModuleManifestPath',
    'Get-ConfigTemplatePath'
)
