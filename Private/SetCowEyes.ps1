function SetCowEyes {
    <#
    .SYNOPSIS
        Sets cow eye preset or custom characters.
    .PARAMETER Preset
        Named eye preset (borg, dead, greedy, etc.).
    .PARAMETER Custom
        Two custom eye characters.
    #>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
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
        $config = GetConfig
        $config.cow.eyes = $eyes
        SetConfig -Config $config -Confirm:$false
        "Cow eyes: $eyes"
    } else {
        $config = GetConfig
        "Current cow eyes: $($config.cow.eyes)"
    }
}
