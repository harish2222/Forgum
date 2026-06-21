function GetHelpMessage {
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
    cowsay     <text> [options]          Direct cowsay
    list       [--search] [--count]     List cow templates
    theme      [list|set|reset]          Manage color themes
    export     <text> [options]          Export cow art to file
    history    [--count] [--clear]       Show recent cows
    interactive                           Interactive config TUI
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

  forgum config - Open config file location

  Usage:
    forgum config [action] [options]

  Arguments:
    action                                Action to perform
                                          (default: open in editor)

  Options:
    --help, -h                            Show this help

  Actions:
    (no action)                           Open config in default editor
    path                                  Print config file path
    dir                                   Print config directory path
    show                                  Print config contents

  Config file locations:
    Windows:   ~/Documents/PowerShell/Forgum/config.json
    Linux:     ~/.config/Forgum/config.json
    macOS:     ~/.config/Forgum/config.json

  Examples:
    forgum config                         # Open in editor
    forgum config path                    # Show file path
    forgum config dir                     # Show directory path
    forgum config show                    # Print config contents

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

        'cowsay' = @"

  forgum cowsay - Direct cowsay (bypass random fortune)

  Usage:
    forgum cowsay <text> [options]

  Arguments:
    text                                  Text for the cow to say (required)

  Options:
    --cow <name>                          Use specific cow file
    --eyes <xx>                           Two-character eye string
    --tongue <xx>                         Two-character tongue string
    --thoughts <char>                     Thought bubble character
    --lolcat                              Enable rainbow colors
    --help, -h                            Show this help

  Examples:
    forgum cowsay "Hello!"                # Simple cowsay
    forgum cowsay "Moo" --cow tux         # Tux cow
    forgum cowsay "Hi" --eyes @@          # Custom eyes
    forgum cowsay "Yo" --lolcat           # Rainbow colors

"@

        'list' = @"

  forgum list - List available cow templates

  Usage:
    forgum list [options]

  Options:
    --search <term>                       Filter cows by name
    --count <N>                           Show N random cows
    --help, -h                            Show this help

  Examples:
    forgum list                           # List all cows
    forgum list --search cat              # Find cats
    forgum list --count 5                 # Show 5 random cows

"@

        'theme' = @"

  forgum theme - Manage color themes

  Usage:
    forgum theme [action] [name] [options]

  Arguments:
    action                                list, set, or reset
    name                                  Theme name (for set)

  Options:
    --help, -h                            Show this help

  Available Themes:
    rainbow     Bright rainbow colors
    fire        Warm fire tones
    ocean       Cool ocean blues
    matrix      Green matrix style
    pastel      Soft pastel colors
    mono        No color (monochrome)
    off         Disable colors

  Examples:
    forgum theme                          # List all themes
    forgum theme set rainbow              # Set rainbow theme
    forgum theme reset                    # Reset to default

"@

        'export' = @"

  forgum export - Export cow art to a file

  Usage:
    forgum export <text> [options]

  Arguments:
    text                                  Text for the cow to say (required)

  Options:
    --cow <name>                          Use specific cow file
    --eyes <xx>                           Two-character eye string
    --tongue <xx>                         Two-character tongue string
    --format <fmt>                        Output format: txt, ans (default: txt)
    --output <path>                       Output file path
    --no-color                            Strip ANSI color codes
    --help, -h                            Show this help

  Formats:
    txt         Plain text (ANSI codes stripped)
    ans         Keep ANSI escape codes

  Examples:
    forgum export "Hello!"                # Export to forgum-export-*.txt
    forgum export "Moo" --cow tux         # Tux cow to file
    forgum export "Hi" --format ans       # Keep ANSI codes
    forgum export "Yo" --output art.txt   # Custom output path

"@

        'history' = @"

  forgum history - Show recent cows rendered

  Usage:
    forgum history [options]

  Options:
    --count <N>                           Number of entries to show
                                          (default: 10)
    --clear                               Clear all history
    --help, -h                            Show this help

  Examples:
    forgum history                        # Show last 10
    forgum history --count 20             # Show last 20
    forgum history --clear                # Clear history

"@

        'interactive' = @"

  forgum interactive - Open interactive config TUI menu

  Usage:
    forgum interactive [options]

  Options:
    --help, -h                            Show this help

  Opens a terminal-based interactive menu where you can:
    - Change animation mode
    - Change cow file
    - Change cow eyes and tongue
    - Toggle lolcat (rainbow) on/off
    - Toggle random cow on/off
    - Reset to defaults
    - Open config file in editor

  Navigate with number keys, press Enter to select.
  Press 0 to exit and save.

  Examples:
    forgum interactive                    # Open TUI
    forgum tui                            # Short alias

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
        'tui'           = 'interactive'
        'setup'         = 'config'
        'show'          = 'gallery'
        'preview-cow'   = 'preview'
        'toggle-rainbow'= 'toggle'
        'set-animation' = 'animate'
        'set-eyes'      = 'eyes'
        'start-daemon'  = 'daemon'
        'stop-daemon'   = 'daemon'
        'say'           = 'cowsay'
        'ls'            = 'list'
        'colors'        = 'theme'
        'save'          = 'export'
        'log'           = 'history'
        'menu'          = 'interactive'
        'h'             = 'root'
    }

    if ($aliases.ContainsKey($Command)) {
        return $messages[$aliases[$Command]]
    }

    return @"
  Unknown command: $Command

  Run 'forgum help' to see all available commands.
"@
}
