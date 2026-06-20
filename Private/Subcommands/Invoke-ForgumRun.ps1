function Invoke-ForgumRun {
    [CmdletBinding()]
    param([string[]]$Arguments = @())

    $parsed = Parse-ForgumArguments -Arguments $Arguments

    if ($parsed.Help) {
        Get-HelpMessage -Command 'run'
        return
    }

    $text = $parsed.TextString
    $config = Get-CFConfig

    $animationMode = if ($parsed.Options.ContainsKey('mode')) { $parsed.Options['mode'] } else { $config.animation.mode }
    $useLolcat = if ($parsed.Flags.ContainsKey('lolcat')) { $true } elseif ($parsed.Flags.ContainsKey('no-lolcat')) { $false } else { $config.lolcat.enabled }
    $cowName = if ($parsed.Options.ContainsKey('cow')) { $parsed.Options['cow'] } elseif ($config.cow.file) { $config.cow.file } else { 'default' }

    if ([string]::IsNullOrEmpty($text)) {
        $text = Get-Fortune
    }

    $cowOutput = Invoke-Cowsay -Text $text -CowFile $cowName -Eyes $config.cow.eyes -Tongue $config.cow.tongue

    if ($useLolcat) {
        $freq = if ($config.lolcat.frequency -and $config.lolcat.frequency -ge 0.01) { $config.lolcat.frequency } else { 0.1 }
        $spread = if ($config.lolcat.spread -and $config.lolcat.spread -ge 0.1) { $config.lolcat.spread } else { 3.0 }
        $cowOutput = Format-Lolcat -Text $cowOutput -Frequency $freq -Spread $spread -Truecolor $config.lolcat.truecolor
    }

    if ($animationMode -ne 'static' -and $animationMode -ne '') {
        Show-CFAnimation -CowOutput $cowOutput -Message $text -Mode $animationMode -Config $config
    } else {
        $cowOutput
    }
}
