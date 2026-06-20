function Invoke-Cowsay {
    <#
    .SYNOPSIS
        Displays a cow saying a message.
    .DESCRIPTION
        Renders an ASCII cow with a speech balloon containing the message.
        Supports custom cow files, eyes, tongue, and thinking mode.
    .PARAMETER Text
        The message for the cow to say.
    .PARAMETER CowFile
        Name of the cow file to use (default: 'default').
    .PARAMETER Eyes
        Two-character eye string (default: 'oo').
    .PARAMETER Tongue
        Two-character tongue string (default: '  ').
    .PARAMETER Thoughts
        Character for the thought bubble connector (default: '\').
    .EXAMPLE
        Invoke-Cowsay -Text "Hello World"
    .EXAMPLE
        Invoke-Cowsay -Text "Thinking..." -Thoughts 'o'
    .EXAMPLE
        Invoke-Cowsay -Text "Tux says hi" -CowFile 'tux'
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(ValueFromPipeline)]
        [AllowEmptyString()]
        [string]$Text = '',

        [ValidateNotNullOrEmpty()]
        [string]$CowFile = 'default',

        [string]$Eyes = 'oo',

        [string]$Tongue = '  ',

        [string]$Thoughts = '\'
    )

    process {
        $config = Get-CFConfig

        # Validate eyes/tongue: enforce 2-char requirement manually
        if ($Eyes.Length -ne 2) { $Eyes = 'oo' }
        if ($Tongue.Length -ne 2) { $Tongue = '  ' }

        # Resolve random cow if configured
        if ($config.cow.random) {
            $cowsPath = Join-Path (Split-Path $PSScriptRoot -Parent) 'Data/Cows'
            $cowFiles = Get-ChildItem -Path $cowsPath -Filter '*.cow' -ErrorAction SilentlyContinue
            if (-not $cowFiles) { throw "No cow files found in $cowsPath" }
            $CowFile = ($cowFiles | Get-Random).BaseName
        }

        # Resolve cow mode presets (eyes/tongue overrides)
        if ($config.cow.mode) {
            $modes = @{
                'b' = @{ eyes = '=='; tongue = '  ' }
                'd' = @{ eyes = 'xx'; tongue = 'U ' }
                'g' = @{ eyes = '$$'; tongue = '  ' }
                'p' = @{ eyes = '@@'; tongue = '  ' }
                's' = @{ eyes = '**'; tongue = 'U ' }
                't' = @{ eyes = '--'; tongue = '  ' }
                'w' = @{ eyes = 'OO'; tongue = '  ' }
                'y' = @{ eyes = '..'; tongue = '  ' }
            }
            if ($modes.ContainsKey($config.cow.mode)) {
                if (-not $PSBoundParameters.ContainsKey('Eyes'))   { $Eyes   = $modes[$config.cow.mode].eyes }
                if (-not $PSBoundParameters.ContainsKey('Tongue')) { $Tongue = $modes[$config.cow.mode].tongue }
            }
        }
        else {
        # Only use config eyes/tongue if not explicitly provided via parameter
        if (-not $PSBoundParameters.ContainsKey('Eyes')) {
            $Eyes = if ($config.cow.eyes -and $config.cow.eyes.Length -eq 2) { $config.cow.eyes } else { 'oo' }
        }
        if (-not $PSBoundParameters.ContainsKey('Tongue')) {
            $Tongue = if ($config.cow.tongue -and $config.cow.tongue.Length -eq 2) { $config.cow.tongue } else { '  ' }
        }
        }

        # Build the cow template with variable substitutions
        $cowTemplate = Read-CowFile -CowName $CowFile
        $message = Format-CowMessage -Text $Text -MaxWidth $config.output.maxWidth

        # Apply substitutions using StringBuilder for performance
        $sb = [System.Text.StringBuilder]::new($cowTemplate)
        [void]$sb.Replace('$thoughts', $Thoughts)
        [void]$sb.Replace('$eyes', $Eyes)
        [void]$sb.Replace('${eyes}', $Eyes)
        [void]$sb.Replace('$tongue', $Tongue)
        [void]$sb.Replace('${tongue}', $Tongue)

        # Replace single-char eye placeholders ($eye) on the first matching line only
        $result = $sb.ToString()
        if ($Eyes.Length -ge 2) {
            $lines = $result -split "`n"
            $eyeReplaced = $false
            $newLines = [System.Collections.Generic.List[string]]::new($lines.Count)

            foreach ($line in $lines) {
                if (-not $eyeReplaced -and $line -match '\$eye') {
                    $replaced = $line -replace '\$eye', $Eyes[0]
                    $replaced = $replaced -replace '\$eye', $Eyes[1]
                    $newLines.Add($replaced)
                    $eyeReplaced = $true
                }
                else {
                    $newLines.Add($line)
                }
            }
            $result = $newLines -join "`n"
        }

        return "$message`n$result"
    }
}
