function Set-CFCowEyes {
    <#
    .SYNOPSIS
        Sets cow eye preset or custom characters.
    .PARAMETER Preset
        Named eye preset (borg, dead, greedy, etc.).
    .PARAMETER Custom
        Two custom eye characters.
    #>
    [CmdletBinding()]
    param(
        [string]$Preset = '',
        [string]$Custom = ''
    )

    $presets = @{
        'borg'     = '=='
        'dead'     = 'xx'
        'greedy'   = '$$'
        'paranoia' = '@@'
        'stoned'   = '**'
        'tired'    = '--'
        'wasted'   = 'OO'
        'youthful' = '..'
    }

    $eyes = ''
    if ($Preset -and $presets.ContainsKey($Preset.ToLower())) {
        $eyes = $presets[$Preset.ToLower()]
    } elseif ($Custom -and $Custom.Length -eq 2) {
        $eyes = $Custom
    }

    if ($eyes) {
        $config = Get-CFConfig
        $config.cow.eyes = $eyes
        Set-CFConfig -Config $config
        Write-Host "Cow eyes: $eyes"
    } else {
        $config = Get-CFConfig
        Write-Host "Current cow eyes: $($config.cow.eyes)"
    }
}
