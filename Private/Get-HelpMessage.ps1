function Get-HelpMessage {
    <#
    .SYNOPSIS
        Centralized help message registry for all forgum commands.
    .DESCRIPTION
        Returns formatted help text for any command, subcommand, or argument.
        Supports --help on every level: forgum --help, forgum run --help, etc.
    .PARAMETER Command
        The command or subcommand to get help for.
    #>
    param(
        [string]$Command = ''
    )

    $messages = @{

        'root' = @"

  Forgum - fortune + cow + rainbow in your terminal

  Usage:
    forgum                               Run with random fortune (default)
    forgum <text>                        Run with custom text
    forgum <subcommand> [options]        Run a subcommand

  Subcommands:
    run        [text] [options]          Run with options
    config                               Open interactive config TUI
    gallery    [--count N]               Show random cows
    preview    <cow> [text]              Preview a specific cow
    update     [--force] [--check]       Update to latest version
    toggle                               Toggle rainbow mode
    animate    <mode>                    Set animation mode
    eyes       <preset|custom>           Set cow eyes
    init       [shell]                   Generate shell hooks
    live                                 Live showcase mode
    daemon     start|stop                Background daemon
    help       [command]                 Show help

  Global Options:
    --help, -h                           Show help for a command
    --version, -v                        Show version

  Animation Modes:
    Flagship (Rust-powered):
      aurora, plasma, ember, liquid-chrome, shatter, portal, glitch, neon-pulse

    Legacy (PowerShell-powered):
      static, talking, typewriter, bounce, wave, wiggle, dissolve,
      fade-in, slide-in, disco, blink, dynamic, procedural, physics

    Special:
      random                             Randomly pick a flagship mode

  Examples:
    forgum                               # Random fortune
    forgum "Hello World!"                # Custom text
    forgum run --cow dragon --mode aurora
    forgum config                        # Open config TUI
    forgum gallery --count 5             # Show 5 random cows
    forgum animate plasma                # Set animation to plasma
    forgum eyes stoned                   # Set cow eyes
    forgum daemon start                  # Start background daemon

"@

        'run' = @"

  forgum run - Run with random or custom text

  Usage:
    forgum run [text] [options]

  Arguments:
    text                                  Text for the cow to say
                                          (default: random fortune)

  Options:
    --cow <name>                          Use specific cow file
    --mode <mode>                         Animation mode
    --lolcat                              Enable rainbow colors
    --no-lolcat                           Disable rainbow colors
    --fortune                             Force new random fortune
    --help, -h                            Show this help

  Examples:
    forgum run                            # Random fortune
    forgum run "Hello!"                   # Custom text
    forgum run --cow tux --mode aurora    # Tux cow + aurora
    forgum run --lolcat "Moo!"            # Rainbow colors

"@

        'config' = @"

  forgum config - Open interactive configuration TUI

  Usage:
    forgum config [options]

  Options:
    --help, -h                            Show this help

  The TUI lets you change:
    - Animation mode (static, aurora, plasma, etc.)
    - Default cow file
    - Cow eyes and tongue
    - Lolcat (rainbow) settings
    - Output formatting (word wrap, max width)
    - Fortune settings

  Config file locations:
    Windows:   ~/Documents/PowerShell/Forgum/config.json
    Linux:     ~/.config/Forgum/config.json
    macOS:     ~/.config/Forgum/config.json

  Examples:
    forgum config                         # Open TUI
    forgum config --help                  # Show this help

"@

        'gallery' = @"

  forgum gallery - Show a gallery of available cow files

  Usage:
    forgum gallery [options]

  Options:
    --count <N>                           Number of cows to show
                                          (default: 5)
    --help, -h                            Show this help

  Examples:
    forgum gallery                        # Show 5 random cows
    forgum gallery --count 10             # Show 10 random cows

"@

        'preview' = @"

  forgum preview - Preview a specific cow file

  Usage:
    forgum preview <cow> [text] [options]

  Arguments:
    cow                                   Cow file name (e.g. tux, dragon)
                                          (default: default)
    text                                  Text to display
                                          (default: Hello World)

  Options:
    --help, -h                            Show this help

  Examples:
    forgum preview tux                    # Preview tux with default text
    forgum preview dragon "Roar!"         # Preview dragon with custom text

"@

        'update' = @"

  forgum update - Update Forgum to the latest version

  Usage:
    forgum update [options]

  Options:
    --force                               Force update even if up-to-date
    --check                               Only check if update is available
    --help, -h                            Show this help

  Examples:
    forgum update                         # Update to latest
    forgum update --check                 # Check only
    forgum update --force                 # Force reinstall

"@

        'toggle' = @"

  forgum toggle - Toggle rainbow (lolcat) mode on/off

  Usage:
    forgum toggle [options]

  Options:
    --help, -h                            Show this help

  Toggles the lolcat.enabled setting in config.
  When enabled, cow output is colorized with rainbow colors.

  Examples:
    forgum toggle                         # Toggle rainbow on/off

"@

        'animate' = @"

  forgum animate - Set the default animation mode

  Usage:
    forgum animate <mode> [options]

  Arguments:
    mode                                  Animation mode to set

  Options:
    --help, -h                            Show this help

  Animation Modes:
    Flagship (Rust-powered):
      aurora            Northern lights effect
      plasma            Pulsing plasma waves
      ember             Rising fire embers
      liquid-chrome     Metallic liquid effect
      shatter           Exploding text particles
      portal            Swirling portal vortex
      glitch            Digital glitch distortion
      neon-pulse        Neon light pulse

    Legacy (PowerShell):
      static            No animation (default)
      talking           Bouncing text
      typewriter        Character-by-character reveal
      bounce            Bouncing cow
      wave              Wave motion
      wiggle            Wiggle animation
      dissolve          Dissolve effect
      fade-in           Fade in from black
      slide-in          Slide in from side
      disco             Disco colors
      blink             Blinking text
      dynamic           Dynamic random effects
      procedural        Procedural animation
      physics           Physics simulation

    Special:
      random            Randomly pick a flagship mode

  Examples:
    forgum animate aurora                 # Set to aurora
    forgum animate plasma                 # Set to plasma
    forgum animate static                 # Disable animation
    forgum animate random                 # Random each time

"@

        'eyes' = @"

  forgum eyes - Set cow eye preset or custom characters

  Usage:
    forgum eyes <preset|custom> [options]

  Arguments:
    preset                                Named eye preset
    custom                                Two custom eye characters

  Options:
    --help, -h                            Show this help

  Eye Presets:
    borg          [==]          dead          [xx]
    greedy        [$$]          paranoia      [@@]
    stoned        [**]          tired         [ --]
    wasted        [OO]          youthful      [..]

  Examples:
    forgum eyes borg                      # Set borg preset
    forgum eyes @@                        # Custom @@ eyes
    forgum eyes                           # Show current eyes

"@

        'init' = @"

  forgum init - Generate shell hooks for your shell

  Usage:
    forgum init [shell] [options]

  Arguments:
    shell                                 Shell to generate hooks for
                                          (bash, zsh, fish, pwsh)
                                          (default: auto-detect)

  Options:
    --help, -h                            Show this help

  Supported Shells:
    bash        Bash shell (Linux, macOS)
    zsh         Z shell (macOS default)
    fish        Fish shell (Linux, macOS)
    pwsh        PowerShell Core (all platforms)

  The generated hooks:
    - Auto-run forgum on shell startup
    - Read config from cross-platform config path
    - Pipe to forgum-engine for animation
    - Stay in background while you use the shell

  Examples:
    forgum init bash                      # Generate bash hooks
    forgum init zsh                       # Generate zsh hooks
    forgum init fish                      # Generate fish hooks
    forgum init pwsh                      # Generate PowerShell hooks
    forgum init                           # Auto-detect current shell

"@

        'live' = @"

  forgum live - Live showcase mode (cycles through effects)

  Usage:
    forgum live [options]

  Options:
    --duration <seconds>                  Duration per effect
                                          (default: 5)
    --help, -h                            Show this help

  Cycles through all available animation effects
  with sample text, showing each for the specified duration.

  Press q, Esc, or Enter to stop.

  Examples:
    forgum live                           # Live showcase, 5s each
    forgum live --duration 10             # 10 seconds per effect

"@

        'daemon' = @"

  forgum daemon - Start/stop the background animation daemon

  Usage:
    forgum daemon <action> [options]

  Arguments:
    action                                start or stop

  Options:
    --help, -h                            Show this help

  The daemon runs the Rust engine in the background,
  rendering animations in an overlay region while you
  continue using your shell and prompt normally.

  Examples:
    forgum daemon start                   # Start background daemon
    forgum daemon stop                    # Stop background daemon

"@

        'help' = @"

  forgum help - Show help for commands

  Usage:
    forgum help [command] [options]

  Arguments:
    command                               Command to get help for

  Options:
    --help, -h                            Show this help

  Examples:
    forgum help                           # Show all commands
    forgum help run                       # Show run command help
    forgum help config                    # Show config command help

"@

    }

    if ([string]::IsNullOrEmpty($Command) -or $Command -eq 'help') {
        return $messages['root']
    }

    $Command = $Command.ToLower().TrimStart('-')

    if ($messages.ContainsKey($Command)) {
        return $messages[$Command]
    }

    $aliases = @{
        'upgrade'       = 'update'
        'tui'           = 'config'
        'setup'         = 'config'
        'show'          = 'gallery'
        'preview-cow'   = 'preview'
        'toggle-rainbow'= 'toggle'
        'set-animation' = 'animate'
        'set-eyes'      = 'eyes'
        'start-daemon'  = 'daemon'
        'stop-daemon'   = 'daemon'
    }

    if ($aliases.ContainsKey($Command)) {
        return $messages[$aliases[$Command]]
    }

    return @"
  Unknown command: $Command

  Run 'forgum help' to see all available commands.
"@
}
