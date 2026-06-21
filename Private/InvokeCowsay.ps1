function InvokeCowsay {
    <#
    .SYNOPSIS
        Renders a cow with a speech bubble.
    .DESCRIPTION
        Combines cow template with message to produce ASCII art.
    .PARAMETER Text
        The message to display in the speech bubble.
    .PARAMETER CowFile
        Name of the cow file to use (default: 'default').
    .PARAMETER Eyes
        Two-character eye string (default: from config).
    .PARAMETER Tongue
        Two-character tongue string (default: from config).
    .PARAMETER Thoughts
        Thought character (default: '\').
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [string]$Text = '',
        [string]$CowFile = 'default',
        [string]$Eyes = '',
        [string]$Tongue = '',
        [string]$Thoughts = '\'
    )

    $config = GetConfig

    if ([string]::IsNullOrEmpty($Eyes)) {
        $Eyes = if ($config.cow.eyes) { $config.cow.eyes } else { 'oo' }
    }
    if ([string]::IsNullOrEmpty($Tongue)) {
        $Tongue = if ($config.cow.tongue) { $config.cow.tongue } else { '  ' }
    }

    if ($config.cow.random) {
        $cowsPath = Join-Path (Split-Path $PSScriptRoot -Parent) 'Data/Cows'
        $cowFiles = Get-ChildItem -Path $cowsPath -Filter '*.cow' -ErrorAction SilentlyContinue
        if ($cowFiles) {
            $randomCow = $cowFiles | Get-Random
            $CowFile = $randomCow.BaseName
        }
    }

    $eyeMap = @{
        'b' = '=='; 'd' = 'xx'; 'g' = '@@'; 'p' = '@@';
        's' = '**'; 't' = ';;'; 'w' = '@@'; 'y' = '..'
    }

    if ($Eyes.Length -eq 1 -and $eyeMap.ContainsKey($Eyes)) {
        $Eyes = $eyeMap[$Eyes]
    }

    $template = ReadCowFile -CowName $CowFile

    if ([string]::IsNullOrEmpty($Text)) {
        $Text = 'Moo!'
    }

    $message = FormatCowMessage -Text $Text -MaxWidth $config.output.maxWidth

    $result = $template
    $result = $result -replace '\$thoughts', $Thoughts
    $result = $result -replace '\$\{?eyes\}?', $Eyes
    $result = $result -replace '\$\{?tongue\}?', $Tongue

    $firstEyeLine = $true
    $resultLines = $result -split "`n"
    $outputLines = @()

    foreach ($line in $resultLines) {
        $modifiedLine = $line
        if ($firstEyeLine -and $modifiedLine -match '\$\{?eye\}?') {
            $singleEye = $Eyes.Substring(0, 1)
            $modifiedLine = $modifiedLine -replace '\$\{?eye\}?', $singleEye
            $firstEyeLine = $false
        }
        $outputLines += $modifiedLine
    }

    $result = $outputLines -join "`n"

    return "$message`n$result"
}
