function CowsayCommand {
    [CmdletBinding()]
    param([string[]]$Arguments = @())

    $parsed = ParseForgumArguments -Arguments $Arguments

    if ($parsed.Help) {
        GetHelpMessage -Command 'cowsay'
        return
    }

    $text = $parsed.TextString
    $config = GetConfig

    $cowName = if ($parsed.Options.ContainsKey('cow')) { $parsed.Options['cow'] } elseif ($config.cow.file) { $config.cow.file } else { 'default' }
    $explicitCow = $parsed.Options.ContainsKey('cow')
    $eyes = if ($parsed.Options.ContainsKey('eyes')) { $parsed.Options['eyes'] } else { $config.cow.eyes }
    $tongue = if ($parsed.Options.ContainsKey('tongue')) { $parsed.Options['tongue'] } else { $config.cow.tongue }
    $thoughts = if ($parsed.Options.ContainsKey('thoughts')) { $parsed.Options['thoughts'] } else { '\' }
    $useLolcat = $parsed.Flags.ContainsKey('lolcat')

    if ([string]::IsNullOrEmpty($text)) {
        Write-Warning "cowsay requires text. Usage: forgum cowsay <text> [--cow name] [--eyes xx]"
        return
    }

    $cowParams = @{ Text = $text; CowFile = $cowName; Eyes = $eyes; Tongue = $tongue; Thoughts = $thoughts }
    if ($explicitCow) { $cowParams['NoRandom'] = $true }
    $cowOutput = InvokeCowsay @cowParams

    if ($useLolcat) {
        $lp = GetLolcatParams
        $cowOutput = FormatLolcat -Text $cowOutput -Frequency $lp.Frequency -Spread $lp.Spread -Truecolor $lp.Truecolor
    }

    WriteHistory -Message $text -Cow $cowName

    $cowOutput
}
