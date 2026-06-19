function forgum {
    <#
    .SYNOPSIS
        The ultimate Forgum CLI wrapper. All features in one keyword!

    .DESCRIPTION
        Acts as the central router for all Forgum functionality. You can use it as a 
        standard command to render cows, or use subcommands (like 'update', 'config', 'gallery')
        to trigger specific workflows. All parameters are seamlessly exposed via Get-Help!

    .PARAMETER Action
        The main subcommand (e.g. 'update', 'config', 'gallery', 'toggle') OR the text you want the cow to say.

    .PARAMETER Lolcat
        [Default Set] Forces the rainbow color mode on.

    .PARAMETER Cow
        [Default Set] Overrides the cow file for the default rendering.

    .PARAMETER Animation
        [Default Set] Overrides the animation mode for the default rendering.

    .PARAMETER Count
        [Gallery Set] How many cows to show in the gallery. (Default: 5)

    .PARAMETER PreviewCow
        [Preview Set] The name of the cow to preview.

    .PARAMETER PreviewText
        [Preview Set] The text to show in the preview.

    .PARAMETER Mode
        [Animate Set] The animation mode to set globally.

    .PARAMETER Preset
        [Eyes Set] The named eye preset to use (e.g. 'borg', 'dead').

    .PARAMETER CustomEyes
        [Eyes Set] Exactly two characters for custom eyes (e.g. '@@').

    .PARAMETER Force
        [Update Set] Forces the standalone updater to bypass package manager warnings.

    .PARAMETER CheckOnly
        [Update Set] Only checks if an update is available without installing.

    .EXAMPLE
        forgum
        Shows the default Forgum greeting.

    .EXAMPLE
        forgum "My custom message" -Lolcat -Cow tux
        Standard Invoke-Forgum behavior passing text and switches.

    .EXAMPLE
        forgum config
        Opens the interactive Forgum Configuration TUI.

    .EXAMPLE
        forgum update -Force
        Checks for and forces installation of the latest version of Forgum.

    .EXAMPLE
        forgum gallery -Count 3
        Shows 3 random cows.

    .EXAMPLE
        forgum preview tux "Linux rules!"
        Previews the 'tux' cow.

    .EXAMPLE
        forgum animate aurora
        Changes your global animation mode to 'aurora'.
    #>
    [CmdletBinding(DefaultParameterSetName='Default')]
    param(
        [Parameter(ParameterSetName='Default', Position=0)]
        [Parameter(ParameterSetName='Update', Position=0)]
        [Parameter(ParameterSetName='Config', Position=0)]
        [Parameter(ParameterSetName='Gallery', Position=0)]
        [Parameter(ParameterSetName='Preview', Position=0)]
        [Parameter(ParameterSetName='Toggle', Position=0)]
        [Parameter(ParameterSetName='Animate', Position=0)]
        [Parameter(ParameterSetName='Eyes', Position=0)]
        [Parameter(ParameterSetName='Help', Position=0)]
        [ArgumentCompleter({
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
            $commands = 'update','upgrade','config','tui','setup','gallery','preview','toggle','animate','eyes','help'
            $commands | Where-Object { $_ -like "$wordToComplete*" }
        })]
        [string]$Action = '',

        # --- Default Parameter Set (Invoke-Forgum) ---
        [Parameter(ParameterSetName='Default')]
        [switch]$Lolcat,
        [Parameter(ParameterSetName='Default')]
        [string]$Animation,
        [Parameter(ParameterSetName='Default')]
        [string]$Cow,

        # --- Update Parameter Set ---
        [Parameter(ParameterSetName='Update')]
        [switch]$Force,
        [Parameter(ParameterSetName='Update')]
        [switch]$CheckOnly,

        # --- Gallery Parameter Set ---
        [Parameter(ParameterSetName='Gallery')]
        [int]$Count = 5,

        # --- Preview Parameter Set ---
        [Parameter(ParameterSetName='Preview')]
        [string]$PreviewCow,
        [Parameter(ParameterSetName='Preview')]
        [string]$PreviewText,

        # --- Animate Parameter Set ---
        [Parameter(ParameterSetName='Animate')]
        [string]$Mode,

        # --- Eyes Parameter Set ---
        [Parameter(ParameterSetName='Eyes')]
        [string]$Preset,
        [Parameter(ParameterSetName='Eyes')]
        [string]$CustomEyes,

        # Catch remaining positional arguments so standard CLI syntax like "forgum preview tux" works naturally
        [Parameter(ValueFromRemainingArguments=$true)]
        [string[]]$ArgumentList
    )

    switch -Regex ($Action) {
        '^(update|upgrade)$' {
            if ($PSBoundParameters.ContainsKey('CheckOnly')) { Update-Forgum -CheckOnly }
            elseif ($PSBoundParameters.ContainsKey('Force')) { Update-Forgum -Force }
            else { Update-Forgum }
            break
        }
        '^(config|tui|setup)$' {
            Invoke-ForgumTUI
            break
        }
        '^gallery$' {
            Show-CFCowGallery -Count $Count
            break
        }
        '^preview$' {
            $pCow = if ($PreviewCow) { $PreviewCow } elseif ($ArgumentList.Count -gt 0) { $ArgumentList[0] } else { 'default' }
            $pText = if ($PreviewText) { $PreviewText } elseif ($ArgumentList.Count -gt 1) { $ArgumentList[1] } else { 'Hello World' }
            Show-CFCowPreview -CowFile $pCow -Text $pText
            break
        }
        '^toggle$' {
            Toggle-CFLolcat
            break
        }
        '^animate$' {
            $m = if ($Mode) { $Mode } elseif ($ArgumentList.Count -gt 0) { $ArgumentList[0] } else { '' }
            if ($m) { Set-CFCowAnimate -Mode $m } else { Set-CFCowAnimate }
            break
        }
        '^eyes$' {
            if ($Preset) { Set-CFCowEyes -Preset $Preset }
            elseif ($CustomEyes) { Set-CFCowEyes -Custom $CustomEyes }
            elseif ($ArgumentList.Count -gt 0) { 
                if ($ArgumentList[0].Length -eq 2) { Set-CFCowEyes -Custom $ArgumentList[0] }
                else { Set-CFCowEyes -Preset $ArgumentList[0] }
            } else { Set-CFCowEyes }
            break
        }
        '^(help|--help|-h|-\?)$' {
            Get-Help forgum -Detailed
            break
        }
        default {
            $invokeParams = @{}
            if ($Action) { $invokeParams.Text = $Action }
            if ($Lolcat) { $invokeParams.Lolcat = $true }
            if ($Animation) { $invokeParams.Animation = $Animation }
            if ($Cow) { $invokeParams.Cow = $Cow }
            Invoke-Forgum @invokeParams
            break
        }
    }
}
