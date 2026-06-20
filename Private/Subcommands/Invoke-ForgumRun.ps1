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
        $lp = Get-LolcatParams
        $cowOutput = Format-Lolcat -Text $cowOutput -Frequency $lp.Frequency -Spread $lp.Spread -Truecolor $lp.Truecolor
    }

    if ($animationMode -ne 'static' -and $animationMode -ne '') {
        Show-CFAnimation -CowOutput $cowOutput -Message $text -Mode $animationMode -Config $config
    }

    Write-ForgumHistory -Message $text -Cow $cowName

    return $cowOutput
}
