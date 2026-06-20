function Invoke-ForgumExport {
    [CmdletBinding()]
    param([string[]]$Arguments = @())

    $parsed = Parse-ForgumArguments -Arguments $Arguments

    if ($parsed.Help) {
        Get-HelpMessage -Command 'export'
        return
    }

    $text = $parsed.TextString
    $config = Get-CFConfig

    $cowName = if ($parsed.Options.ContainsKey('cow')) { $parsed.Options['cow'] } else { $config.cow.file }
    $eyes = if ($parsed.Options.ContainsKey('eyes')) { $parsed.Options['eyes'] } else { $config.cow.eyes }
    $tongue = if ($parsed.Options.ContainsKey('tongue')) { $parsed.Options['tongue'] } else { $config.cow.tongue }
    $format = if ($parsed.Options.ContainsKey('format')) { $parsed.Options['format'] } else { 'txt' }
    $outputPath = if ($parsed.Options.ContainsKey('output')) { $parsed.Options['output'] } else { $null }
    $noColor = $parsed.Flags.ContainsKey('no-color')

    if ($outputPath) {
        $resolvedOutput = [System.IO.Path]::GetFullPath($outputPath)
        if ($resolvedOutput -match '[\\/]\.\.[\\/]') {
            Write-Warning "Invalid output path: path contains traversal sequences"
            return
        }
        $outputPath = $resolvedOutput
    }

    if ([string]::IsNullOrEmpty($text)) {
        Write-Warning "export requires text. Usage: forgum export <text> [--cow name] [--output file.txt]"
        return
    }

    $cowOutput = Invoke-Cowsay -Text $text -CowFile $cowName -Eyes $eyes -Tongue $tongue

    if (-not $noColor -and $config.lolcat.enabled) {
        $lp = Get-LolcatParams
        $cowOutput = Format-Lolcat -Text $cowOutput -Frequency $lp.Frequency -Spread $lp.Spread -Truecolor $lp.Truecolor
    }

    if (-not $outputPath) {
        $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
        $outputPath = "forgum-export-$timestamp.$format"
    }

    switch ($format.ToLower()) {
        'txt' {
            # Strip ANSI codes for plain text
            $plainText = $cowOutput -replace '\x1b\[[0-9;]*m', ''
            $plainText | Set-Content -Path $outputPath -Encoding UTF8 -Force
        }
        'ans' {
            # Keep ANSI escape codes
            $cowOutput | Set-Content -Path $outputPath -Encoding UTF8 -Force
        }
        default {
            Write-Warning "Unsupported format: $format. Use txt or ans"
            return
        }
    }

    Write-Output "Exported to: $outputPath"
}
