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

        [Parameter(ValueFromRemainingArguments)]
        [string[]]$Arguments
    )

    # Handle --help / -h / --version that PowerShell binds to $Arguments
    # via ValueFromRemainingArguments when there's no named subcommand.
    # Only intercept when SubCommand is null (no subcommand was given).
    if ([string]::IsNullOrEmpty($SubCommand) -and $Arguments -and $Arguments.Count -gt 0) {
        $first = $Arguments[0]
        if ($first -in '--help', '-h') {
            Get-HelpMessage -Command 'root'
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
            Get-HelpMessage -Command 'root'
            return
        }
    }

    if ([string]::IsNullOrEmpty($SubCommand)) {
        Invoke-ForgumRun -Arguments $Arguments
        return
    }

    $SubCommand = $SubCommand.ToLower()

    switch ($SubCommand) {
        'run'       { Invoke-ForgumRun -Arguments $Arguments }
        'config'    { Invoke-ForgumConfig -Arguments $Arguments }
        'gallery'   { Invoke-ForgumGallery -Arguments $Arguments }
        'preview'   { Invoke-ForgumPreview -Arguments $Arguments }
        'update'    { Invoke-ForgumUpdate -Arguments $Arguments }
        'toggle'    { Invoke-ForgumToggle -Arguments $Arguments }
        'animate'   { Invoke-ForgumAnimate -Arguments $Arguments }
        'eyes'      { Invoke-ForgumEyes -Arguments $Arguments }
        'init'      { Invoke-ForgumInit -Arguments $Arguments }
        'live'      { Invoke-ForgumLiveHandler -Arguments $Arguments }
        'daemon'    { Invoke-ForgumDaemon -Arguments $Arguments }
        'help'      {
            if ($Arguments.Count -gt 0) {
                Get-HelpMessage -Command $Arguments[0]
            } else {
                Get-HelpMessage -Command 'root'
            }
        }
        { $_ -in '--help', '-h', 'help', 'h' }  { Get-HelpMessage -Command 'root' }
        { $_ -in '--version', '-v', 'version', 'v' } { "forgum v$($script:ModuleVersion)" }
        default {
            if ($SubCommand -match '^-') {
                Write-Warning "Unknown option: $SubCommand. Run 'forgum help' for usage."
                return
            }
            $fullText = "$SubCommand $($Arguments -join ' ')"
            Invoke-ForgumRun -Arguments @($fullText)
        }
    }
}
