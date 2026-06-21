function EyesCommand {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    param([string[]]$Arguments = @())

    $parsed = ParseForgumArguments -Arguments $Arguments

    if ($parsed.Help) {
        GetHelpMessage -Command 'eyes'
        return
    }

    $preset = if ($parsed.Options.ContainsKey('preset')) { $parsed.Options['preset'] } else { '' }
    $custom = if ($parsed.Options.ContainsKey('custom')) { $parsed.Options['custom'] } else { '' }

    if (-not $preset -and -not $custom -and $parsed.Text.Count -gt 0) {
        $val = $parsed.Text[0]
        if ($val.Length -eq 2) { $custom = $val } else { $preset = $val }
    }

    if ($preset) { SetCowEyes -Preset $preset }
    elseif ($custom) { SetCowEyes -Custom $custom }
    else { SetCowEyes }
}
