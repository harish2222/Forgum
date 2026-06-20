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
        # Check if background mode is enabled (from config or explicit flag)
        $isBackground = if ($null -ne $config.animation.background) { [bool]$config.animation.background } else { $true }
        if ($isBackground) {
            # Background mode: engine renders directly to terminal
            # Don't return cow text - it's already rendered
            Show-CFAnimation -CowOutput $cowOutput -Mode $animationMode -Config $config
            Write-ForgumHistory -Message $text -Cow $cowName
            return
        } else {
            Show-CFAnimation -CowOutput $cowOutput -Mode $animationMode -Config $config
        }
    }

    Write-ForgumHistory -Message $text -Cow $cowName

    return $cowOutput
}
