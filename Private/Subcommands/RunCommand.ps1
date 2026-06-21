function RunCommand {
    [CmdletBinding()]
    param([string[]]$Arguments = @())

    $parsed = ParseForgumArguments -Arguments $Arguments

    if ($parsed.Help) {
        GetHelpMessage -Command 'run'
        return
    }

    $text = $parsed.TextString
    $config = GetConfig

    $animationMode = if ($parsed.Options.ContainsKey('mode')) { $parsed.Options['mode'] } else { $config.animation.mode }
    $useLolcat = if ($parsed.Flags.ContainsKey('lolcat')) { $true } elseif ($parsed.Flags.ContainsKey('no-lolcat')) { $false } else { $config.lolcat.enabled }
    $cowName = if ($parsed.Options.ContainsKey('cow')) { $parsed.Options['cow'] } elseif ($config.cow.file) { $config.cow.file } else { 'default' }

    if ([string]::IsNullOrEmpty($text)) {
        $text = GetFortune
    }

    $cowOutput = InvokeCowsay -Text $text -CowFile $cowName -Eyes $config.cow.eyes -Tongue $config.cow.tongue

    if ($useLolcat) {
        $lp = GetLolcatParams
        $cowOutput = FormatLolcat -Text $cowOutput -Frequency $lp.Frequency -Spread $lp.Spread -Truecolor $lp.Truecolor
    }

    if ($animationMode -ne 'static' -and $animationMode -ne '') {
        # Check if background mode is enabled (from config or explicit flag)
        $isBackground = if ($null -ne $config.animation.background) { [bool]$config.animation.background } else { $true }
        if ($isBackground) {
            # Background mode: engine renders directly to terminal.
            # Suppress ShowAnimation return to prevent cow text leaking to pipeline.
            $null = ShowAnimation -CowOutput $cowOutput -Mode $animationMode -Config $config
            WriteHistory -Message $text -Cow $cowName
            return
        } else {
            $null = ShowAnimation -CowOutput $cowOutput -Mode $animationMode -Config $config
        }
    }

    WriteHistory -Message $text -Cow $cowName

    return $cowOutput
}
