function forgum {
    <#
    .SYNOPSIS
        Forgum - fortune + cow + rainbow in your terminal.

    .DESCRIPTION
        Single entry point for all Forgum functionality.
        Use 'forgum help' to see all available commands.
        Use 'forgum <command> --help' for command-specific help.

    .PARAMETER SubCommand
        The subcommand to run. Run 'forgum help' for all options.

    .PARAMETER Arguments
        Arguments passed to the subcommand.

    .EXAMPLE
        forgum
        forgum "Hello World"
        forgum run --cow tux --mode aurora
        forgum config
        forgum gallery --count 5
        forgum help
        forgum run --help
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]$SubCommand,

        [string]$Text,

        [Parameter(ValueFromRemainingArguments)]
        [string[]]$Arguments
    )

    # Handle --help / -h / --version that PowerShell binds to $Arguments
    # via ValueFromRemainingArguments when there's no named subcommand.
    # Only intercept when SubCommand is null (no subcommand was given).
    if ([string]::IsNullOrEmpty($SubCommand) -and $Arguments -and $Arguments.Count -gt 0) {
        $first = $Arguments[0]
        if ($first -in '--help', '-h') {
            GetHelpMessage -Command 'root'
            return
        }
        if ($first -in '--version') {
            "forgum v$($script:ModuleVersion)"
            return
        }
    }

    # PowerShell with [CmdletBinding()] silently drops unknown single-dash
    # params like -v. Use $args as a last-resort fallback for these.
    if ([string]::IsNullOrEmpty($SubCommand) -and $args.Count -gt 0) {
        if ($args[0] -in '-v') {
            "forgum v$($script:ModuleVersion)"
            return
        }
        if ($args[0] -in '-h') {
            GetHelpMessage -Command 'root'
            return
        }
    }

    if ([string]::IsNullOrEmpty($SubCommand)) {
        if (-not [string]::IsNullOrEmpty($Text)) {
            RunCommand -Arguments @($Text)
        } else {
            RunCommand -Arguments $Arguments
        }
        return
    }

    $originalSubCommand = $SubCommand
    $SubCommand = $SubCommand.ToLower()

    switch ($SubCommand) {
        'run'       { RunCommand -Arguments $Arguments }
        'config'    { ConfigCommand -Arguments $Arguments }
        'gallery'   { GalleryCommand -Arguments $Arguments }
        'preview'   { PreviewCommand -Arguments $Arguments }
        'update'    { UpdateCommand -Arguments $Arguments }
        'toggle'    { ToggleCommand -Arguments $Arguments }
        'animate'   { AnimateCommand -Arguments $Arguments }
        'eyes'      { EyesCommand -Arguments $Arguments }
        'init'      { InitCommand -Arguments $Arguments }
        'live'      { LiveCommand -Arguments $Arguments }
        'daemon'    { DaemonCommand -Arguments $Arguments }
        'cowsay'    { CowsayCommand -Arguments $Arguments }
        'list'      { ListCommand -Arguments $Arguments }
        'theme'     { ThemeCommand -Arguments $Arguments }
        'export'    { ExportCommand -Arguments $Arguments }
        'history'   { HistoryCommand -Arguments $Arguments }
        'interactive'{ InteractiveCommand -Arguments $Arguments }
        'help'      {
            if ($Arguments.Count -gt 0) {
                GetHelpMessage -Command $Arguments[0]
            } else {
                GetHelpMessage -Command 'root'
            }
        }
        { $_ -in '--help', '-h', 'h' }  { GetHelpMessage -Command 'root' }
        { $_ -in '--version', '-v', 'version', 'v' } { "forgum v$($script:ModuleVersion)" }
        default {
            if ($SubCommand -match '^-') {
                Write-Warning "Unknown option: $SubCommand. Run 'forgum help' for usage."
                return
            }
            $fullText = "$originalSubCommand $($Arguments -join ' ')"
            RunCommand -Arguments @($fullText)
        }
    }
}
