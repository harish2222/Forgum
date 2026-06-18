function Set-CFCowEyes {
    <#
    .SYNOPSIS
        Sets the cow eyes in your Forgum configuration.

    .DESCRIPTION
        Change the eyes characters of your default cow. You can pick from predefined
        presets or provide a custom string.

    .PARAMETER Preset
        A predefined eye style (e.g., borg, dead, greedy).

    .PARAMETER Custom
        A custom 2-character string to use for eyes.

    .EXAMPLE
        Set-CFCowEyes -Preset borg
        Sets the eyes to '=='.

    .EXAMPLE
        cow-eyes @@
        Sets custom eyes.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    param(
        [Parameter(Position = 0, ParameterSetName = 'Preset')]
        [ValidateSet('borg', 'dead', 'greedy', 'paranoia', 'stoned', 'tired', 'wasted', 'youthful')]
        [string]$Preset,

        [Parameter(Position = 0, ParameterSetName = 'Custom')]
        [string]$Custom
    )

    $eyes = switch ($PSCmdlet.ParameterSetName) {
        'Preset' {
            switch ($Preset) {
                'borg'      { '==' }
                'dead'      { 'xx' }
                'greedy'    { '$$' }
                'paranoia'  { '@@' }
                'stoned'    { '**' }
                'tired'     { '--' }
                'wasted'    { 'OO' }
                'youthful'  { '..' }
            }
        }
        'Custom' { $Custom }
    }

    $config = Get-CFConfig
    if (-not $config) {
        Write-Error "Could not retrieve Forgum configuration."
        return
    }

    if ($eyes.Length -gt 2) {
        Write-Warning "Cow eyes are usually 2 characters."
    }

    $config.cow.eyes = $eyes
    Set-CFConfig -Config $config
    Write-Host "Cow eyes set to: $eyes" -ForegroundColor Green
}
