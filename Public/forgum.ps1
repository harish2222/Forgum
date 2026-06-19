function forgum {
    <#
    .SYNOPSIS
        The main CLI entrypoint for Forgum.

    .DESCRIPTION
        Acts as a central router to all Forgum features. You can use it without arguments
        to render a random cow, or pass subcommands to configure or update Forgum.

    .PARAMETER Command
        The subcommand to run. Available: update, config, gallery, preview, toggle, animate, eyes, help.

    .PARAMETER Args
        Additional arguments passed to the subcommand.

    .EXAMPLE
        forgum
        Shows the default Forgum greeting.

    .EXAMPLE
        forgum update
        Checks for and installs the latest version of Forgum.

    .EXAMPLE
        forgum config
        Opens the interactive Forgum Configuration TUI.
        
    .EXAMPLE
        forgum toggle
        Toggles the lolcat rainbow mode.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [string]$Command = '',

        [ValueFromRemainingArguments()]
        [string[]]$ArgumentList
    )

    switch -Regex ($Command) {
        '^(update|upgrade)$' {
            Update-Forgum
            break
        }
        '^(config|tui|setup)$' {
            Invoke-ForgumTUI
            break
        }
        '^gallery$' {
            if ($ArgumentList) { Show-CFCowGallery @ArgumentList }
            else { Show-CFCowGallery }
            break
        }
        '^preview$' {
            if ($ArgumentList) { Show-CFCowPreview @ArgumentList }
            else { Show-CFCowPreview }
            break
        }
        '^toggle$' {
            Toggle-CFLolcat
            break
        }
        '^animate$' {
            if ($ArgumentList) { Set-CFCowAnimate @ArgumentList }
            else { Set-CFCowAnimate }
            break
        }
        '^eyes$' {
            if ($ArgumentList) { Set-CFCowEyes @ArgumentList }
            else { Set-CFCowEyes }
            break
        }
        '^(help|--help|-h)$' {
            Write-Host "Forgum CLI" -ForegroundColor Cyan
            Write-Host "Usage: forgum [command] [args...]"
            Write-Host "`nCommands:"
            Write-Host "  (none)      Show a random cow and fortune"
            Write-Host "  config      Open the configuration TUI"
            Write-Host "  update      Check for and apply updates"
            Write-Host "  gallery     Show a gallery of cows (e.g. forgum gallery -Count 3)"
            Write-Host "  preview     Preview a specific cow (e.g. forgum preview tux)"
            Write-Host "  toggle      Toggle Lolcat colors"
            Write-Host "  animate     Set animation mode (e.g. forgum animate physics)"
            Write-Host "  eyes        Set cow eyes (e.g. forgum eyes @@)"
            Write-Host "  help        Show this help message"
            break
        }
        '^$' {
            # No command provided, run the default
            Invoke-Forgum
            break
        }
        default {
            Write-Host "Unknown command: $Command" -ForegroundColor Red
            Write-Host "Run 'forgum help' for usage." -ForegroundColor Yellow
        }
    }
}
