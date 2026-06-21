#Requires -Modules Pester

BeforeAll {
    $env:FORGUM_NOAUTOSTART = '1'
    $ModuleRoot = Split-Path $PSScriptRoot -Parent
    $ModulePath = Join-Path $ModuleRoot 'Forgum.psd1'
    do {
        $m = Get-Module Forgum -ErrorAction SilentlyContinue
        if ($m) { Remove-Module Forgum -Force -ErrorAction SilentlyContinue }
    } while ($m)
    Import-Module $ModulePath -Force

    function Remove-Ansi {
        param([string]$Text)
        $esc = [char]27
        $Text -replace "${esc}\[[0-9;]*[a-zA-Z]", '' `
              -replace "${esc}\][^\x07]*\x07", '' `
              -replace 'e\[[0-9;]*m', '' `
              -replace 'e\][^\a]*\a', ''
    }
}

Describe "Subcommand: run" -Tag 'Subcommand' {

    It "run --help returns help text" {
        $output = forgum run --help 2>&1 | Out-String
        $output | Should -Match 'forgum run'
        $output | Should -Match 'Usage:'
        $output | Should -Match '--cow'
        $output | Should -Match '--mode'
        $output | Should -Match '--lolcat'
        $output | Should -Match '--no-lolcat'
        $output | Should -Match '--fortune'
    }

    It "run -h returns help text" {
        $output = forgum run -h 2>&1 | Out-String
        $output | Should -Match 'forgum run'
        $output | Should -Match 'Usage:'
    }

    It "run --help shows examples" {
        $output = forgum run --help 2>&1 | Out-String
        $output | Should -Match 'Examples:'
        $output | Should -Match 'forgum run'
    }

    It "run with no args produces cow output" {
        $output = forgum run --mode static 6>&1 2>&1 | Out-String
        $output | Should -Not -BeNullOrEmpty
    }

    It "run with text produces that text" {
        $raw = forgum run --mode static "Hello Test" 6>&1 2>&1 | Out-String
        $output = Remove-Ansi $raw
        $output | Should -BeLike '*Hello Test*'
    }

    It "run --cow tux produces output" {
        $output = forgum run --mode static --cow tux "Test" 6>&1 2>&1 | Out-String
        $output | Should -Not -BeNullOrEmpty
    }

    It "run --cow tux --mode static produces output" {
        $output = forgum run --cow tux --mode static "Test" 6>&1 2>&1 | Out-String
        $output | Should -Not -BeNullOrEmpty
    }

    It "help run returns run help" {
        $output = forgum help run 2>&1 | Out-String
        $output | Should -Match 'forgum run'
        $output | Should -Match 'Usage:'
    }
}

Describe "Subcommand: gallery" -Tag 'Subcommand' {

    It "gallery --help returns help text" {
        $output = forgum gallery --help 2>&1 | Out-String
        $output | Should -Match 'forgum gallery'
        $output | Should -Match 'Usage:'
        $output | Should -Match '--count'
    }

    It "gallery -h returns help text" {
        $output = forgum gallery -h 2>&1 | Out-String
        $output | Should -Match 'forgum gallery'
    }

    It "gallery --help shows default count" {
        $output = forgum gallery --help 2>&1 | Out-String
        $output | Should -Match 'default: 5'
    }

    It "gallery with no args runs" {
        $output = forgum gallery 6>&1 2>&1 | Out-String
        $output | Should -Not -BeNullOrEmpty
    }

    It "gallery --count 2 runs" {
        $output = forgum gallery --count 2 6>&1 2>&1 | Out-String
        $output | Should -Not -BeNullOrEmpty
    }

    It "help gallery returns gallery help" {
        $output = forgum help gallery 2>&1 | Out-String
        $output | Should -Match 'forgum gallery'
    }
}

Describe "Subcommand: preview" -Tag 'Subcommand' {

    It "preview --help returns help text" {
        $output = forgum preview --help 2>&1 | Out-String
        $output | Should -Match 'forgum preview'
        $output | Should -Match 'Usage:'
        $output | Should -Match 'cow'
    }

    It "preview -h returns help text" {
        $output = forgum preview -h 2>&1 | Out-String
        $output | Should -Match 'forgum preview'
    }

    It "preview --help shows examples" {
        $output = forgum preview --help 2>&1 | Out-String
        $output | Should -Match 'Examples:'
    }

    It "preview with no args runs" {
        $output = forgum preview 6>&1 2>&1 | Out-String
        $output | Should -Not -BeNullOrEmpty
    }

    It "preview tux runs" {
        $output = forgum preview tux 6>&1 2>&1 | Out-String
        $output | Should -Not -BeNullOrEmpty
    }

    It "preview tux 'Custom text' runs" {
        $output = forgum preview tux "Custom text" 6>&1 2>&1 | Out-String
        $output | Should -Match 'Custom text'
    }

    It "help preview returns preview help" {
        $output = forgum help preview 2>&1 | Out-String
        $output | Should -Match 'forgum preview'
    }
}

Describe "Subcommand: update" -Tag 'Subcommand' {

    It "update --help returns help text" {
        $output = forgum update --help 2>&1 | Out-String
        $output | Should -Match 'forgum update'
        $output | Should -Match 'Usage:'
        $output | Should -Match '--force'
        $output | Should -Match '--check'
    }

    It "update -h returns help text" {
        $output = forgum update -h 2>&1 | Out-String
        $output | Should -Match 'forgum update'
    }

    It "update --help shows examples" {
        $output = forgum update --help 2>&1 | Out-String
        $output | Should -Match 'Examples:'
    }

    It "help update returns update help" {
        $output = forgum help update 2>&1 | Out-String
        $output | Should -Match 'forgum update'
    }
}

Describe "Subcommand: toggle" -Tag 'Subcommand' {

    It "toggle --help returns help text" {
        $output = forgum toggle --help 2>&1 | Out-String
        $output | Should -Match 'forgum toggle'
        $output | Should -Match 'Usage:'
        $output | Should -Match 'lolcat'
    }

    It "toggle -h returns help text" {
        $output = forgum toggle -h 2>&1 | Out-String
        $output | Should -Match 'forgum toggle'
    }

    It "toggle --help mentions rainbow" {
        $output = forgum toggle --help 2>&1 | Out-String
        $output | Should -Match 'rainbow'
    }

    It "toggle runs" {
        $output = forgum toggle 6>&1 2>&1 | Out-String
        $output | Should -Match 'Lolcat:'
    }

    It "help toggle returns toggle help" {
        $output = forgum help toggle 2>&1 | Out-String
        $output | Should -Match 'forgum toggle'
    }
}

Describe "Subcommand: animate" -Tag 'Subcommand' {

    It "animate --help returns help text" {
        $output = forgum animate --help 2>&1 | Out-String
        $output | Should -Match 'forgum animate'
        $output | Should -Match 'Usage:'
        $output | Should -Match 'aurora'
        $output | Should -Match 'plasma'
        $output | Should -Match 'static'
    }

    It "animate -h returns help text" {
        $output = forgum animate -h 2>&1 | Out-String
        $output | Should -Match 'forgum animate'
    }

    It "animate --help lists all flagship modes" {
        $output = forgum animate --help 2>&1 | Out-String
        $output | Should -Match 'aurora'
        $output | Should -Match 'plasma'
        $output | Should -Match 'ember'
        $output | Should -Match 'liquid-chrome'
        $output | Should -Match 'shatter'
        $output | Should -Match 'portal'
        $output | Should -Match 'glitch'
        $output | Should -Match 'neon-pulse'
    }

    It "animate --help lists all legacy modes" {
        $output = forgum animate --help 2>&1 | Out-String
        $output | Should -Match 'static'
        $output | Should -Match 'talking'
        $output | Should -Match 'typewriter'
        $output | Should -Match 'bounce'
        $output | Should -Match 'wave'
    }

    It "animate --help lists random" {
        $output = forgum animate --help 2>&1 | Out-String
        $output | Should -Match 'random'
    }

    It "animate static sets mode" {
        $output = forgum animate static 6>&1 2>&1 | Out-String
        $output | Should -Match 'Animation'
    }

    It "help animate returns animate help" {
        $output = forgum help animate 2>&1 | Out-String
        $output | Should -Match 'forgum animate'
    }
}

Describe "Subcommand: eyes" -Tag 'Subcommand' {

    It "eyes --help returns help text" {
        $output = forgum eyes --help 2>&1 | Out-String
        $output | Should -Match 'forgum eyes'
        $output | Should -Match 'Usage:'
        $output | Should -Match 'preset'
        $output | Should -Match 'borg'
    }

    It "eyes -h returns help text" {
        $output = forgum eyes -h 2>&1 | Out-String
        $output | Should -Match 'forgum eyes'
    }

    It "eyes --help lists all presets" {
        $output = forgum eyes --help 2>&1 | Out-String
        $output | Should -Match 'borg'
        $output | Should -Match 'dead'
        $output | Should -Match 'greedy'
        $output | Should -Match 'paranoia'
        $output | Should -Match 'stoned'
        $output | Should -Match 'tired'
        $output | Should -Match 'wasted'
        $output | Should -Match 'youthful'
    }

    It "eyes borg sets preset" {
        $output = forgum eyes borg 6>&1 2>&1 | Out-String
        $output | Should -Match 'Cow eyes:'
    }

    It "eyes @@ sets custom eyes" {
        $output = forgum eyes '@@' 6>&1 2>&1 | Out-String
        $output | Should -Match 'Cow eyes:'
    }

    It "eyes with no args shows current" {
        $output = forgum eyes 6>&1 2>&1 | Out-String
        $output | Should -Match 'Current cow eyes:'
    }

    It "help eyes returns eyes help" {
        $output = forgum help eyes 2>&1 | Out-String
        $output | Should -Match 'forgum eyes'
    }
}

Describe "Subcommand: init" -Tag 'Subcommand' {

    It "init --help returns help text" {
        $output = forgum init --help 2>&1 | Out-String
        $output | Should -Match 'forgum init'
        $output | Should -Match 'Usage:'
        $output | Should -Match 'bash'
        $output | Should -Match 'zsh'
        $output | Should -Match 'fish'
        $output | Should -Match 'pwsh'
    }

    It "init -h returns help text" {
        $output = forgum init -h 2>&1 | Out-String
        $output | Should -Match 'forgum init'
    }

    It "init --help lists supported shells" {
        $output = forgum init --help 2>&1 | Out-String
        $output | Should -Match 'bash'
        $output | Should -Match 'zsh'
        $output | Should -Match 'fish'
        $output | Should -Match 'pwsh'
    }

    It "init --help shows examples" {
        $output = forgum init --help 2>&1 | Out-String
        $output | Should -Match 'Examples:'
    }

    It "init bash generates hooks" {
        $output = forgum init bash 6>&1 2>&1 | Out-String
        $output | Should -Not -BeNullOrEmpty
    }

    It "init zsh generates hooks" {
        $output = forgum init zsh 6>&1 2>&1 | Out-String
        $output | Should -Not -BeNullOrEmpty
    }

    It "init fish generates hooks" {
        $output = forgum init fish 6>&1 2>&1 | Out-String
        $output | Should -Not -BeNullOrEmpty
    }

    It "help init returns init help" {
        $output = forgum help init 2>&1 | Out-String
        $output | Should -Match 'forgum init'
    }
}

Describe "Subcommand: live" -Tag 'Subcommand' {

    It "live --help returns help text" {
        $output = forgum live --help 2>&1 | Out-String
        $output | Should -Match 'forgum live'
        $output | Should -Match 'Usage:'
        $output | Should -Match '--duration'
    }

    It "live -h returns help text" {
        $output = forgum live -h 2>&1 | Out-String
        $output | Should -Match 'forgum live'
    }

    It "live --help mentions quit keys" {
        $output = forgum live --help 2>&1 | Out-String
        $output | Should -Match 'Press'
    }

    It "help live returns live help" {
        $output = forgum help live 2>&1 | Out-String
        $output | Should -Match 'forgum live'
    }
}

Describe "Subcommand: daemon" -Tag 'Subcommand' {

    It "daemon --help returns help text" {
        $output = forgum daemon --help 2>&1 | Out-String
        $output | Should -Match 'forgum daemon'
        $output | Should -Match 'Usage:'
        $output | Should -Match 'start'
        $output | Should -Match 'stop'
    }

    It "daemon -h returns help text" {
        $output = forgum daemon -h 2>&1 | Out-String
        $output | Should -Match 'forgum daemon'
    }

    It "daemon --help mentions background" {
        $output = forgum daemon --help 2>&1 | Out-String
        $output | Should -Match 'background'
    }

    It "help daemon returns daemon help" {
        $output = forgum help daemon 2>&1 | Out-String
        $output | Should -Match 'forgum daemon'
    }
}

Describe "Subcommand: help" -Tag 'Subcommand' {

    It "help with no args returns root help" {
        $output = forgum help 2>&1 | Out-String
        $output | Should -Match 'Usage:'
        $output | Should -Match 'forgum'
        $output | Should -Match 'Subcommands:'
    }

    It "help run returns run help" {
        $output = forgum help run 2>&1 | Out-String
        $output | Should -Match 'forgum run'
    }

    It "help gallery returns gallery help" {
        $output = forgum help gallery 2>&1 | Out-String
        $output | Should -Match 'forgum gallery'
    }

    It "help preview returns preview help" {
        $output = forgum help preview 2>&1 | Out-String
        $output | Should -Match 'forgum preview'
    }

    It "help update returns update help" {
        $output = forgum help update 2>&1 | Out-String
        $output | Should -Match 'forgum update'
    }

    It "help toggle returns toggle help" {
        $output = forgum help toggle 2>&1 | Out-String
        $output | Should -Match 'forgum toggle'
    }

    It "help animate returns animate help" {
        $output = forgum help animate 2>&1 | Out-String
        $output | Should -Match 'forgum animate'
    }

    It "help eyes returns eyes help" {
        $output = forgum help eyes 2>&1 | Out-String
        $output | Should -Match 'forgum eyes'
    }

    It "help init returns init help" {
        $output = forgum help init 2>&1 | Out-String
        $output | Should -Match 'forgum init'
    }

    It "help live returns live help" {
        $output = forgum help live 2>&1 | Out-String
        $output | Should -Match 'forgum live'
    }

    It "help daemon returns daemon help" {
        $output = forgum help daemon 2>&1 | Out-String
        $output | Should -Match 'forgum daemon'
    }

    It "help help returns help text" {
        $output = forgum help help 2>&1 | Out-String
        $output | Should -Match 'Usage:'
    }

    It "help unknown returns unknown message" {
        $output = forgum help nonexistent 2>&1 | Out-String
        $output | Should -Match 'Unknown command'
    }
}

Describe "Root-level help and version" -Tag 'Subcommand' {

    It "forgum --help returns root help" {
        $output = forgum --help 2>&1 | Out-String
        $output | Should -Match 'Usage:'
        $output | Should -Match 'Subcommands:'
    }

    It "forgum -h returns root help" {
        $output = forgum -h 2>&1 | Out-String
        $output | Should -Match 'Usage:'
    }

    It "forgum --version returns version" {
        $output = forgum --version 2>&1 | Out-String
        $output | Should -Match 'forgum v'
    }

    It "forgum help returns root help" {
        $output = forgum help 2>&1 | Out-String
        $output | Should -Match 'Usage:'
    }

    It "forgum with no args runs default" {
        $output = forgum 6>&1 2>&1 | Out-String
        $output | Should -Not -BeNullOrEmpty
    }

    It "forgum with text runs default" {
        $raw = forgum "Root test" 6>&1 3>&1 2>&1 | Out-String
        $output = Remove-Ansi $raw
        $output | Should -BeLike '*Root test*'
    }

    It "unknown subcommand with text treats as run" {
        $raw = forgum foobar "Test" 6>&1 3>&1 2>&1 | Out-String
        $output = Remove-Ansi $raw
        $output | Should -BeLike '*Test*'
    }

    It "unknown flag shows warning" {
        $output = forgum --invalid-flag 3>&1 2>&1 | Out-String
        $output | Should -Match 'Unknown option'
    }
}

Describe "ParseForgumArguments edge cases" -Tag 'Subcommand' {

    It "parses empty arguments" {
        InModuleScope Forgum {
            $parsed = ParseForgumArguments -Arguments @()
            $parsed.Help | Should -Be $false
            $parsed.Text.Count | Should -Be 0
            $parsed.TextString | Should -Be ''
        }
    }

    It "parses --help" {
        InModuleScope Forgum {
            $parsed = ParseForgumArguments -Arguments @('--help')
            $parsed.Help | Should -Be $true
        }
    }

    It "parses -h" {
        InModuleScope Forgum {
            $parsed = ParseForgumArguments -Arguments @('-h')
            $parsed.Help | Should -Be $true
        }
    }

    It "parses -?" {
        InModuleScope Forgum {
            $parsed = ParseForgumArguments -Arguments @('-?')
            $parsed.Help | Should -Be $true
        }
    }

    It "parses --cow tux" {
        InModuleScope Forgum {
            $parsed = ParseForgumArguments -Arguments @('--cow', 'tux')
            $parsed.Options['cow'] | Should -Be 'tux'
        }
    }

    It "parses --mode aurora" {
        InModuleScope Forgum {
            $parsed = ParseForgumArguments -Arguments @('--mode', 'aurora')
            $parsed.Options['mode'] | Should -Be 'aurora'
        }
    }

    It "parses --count 10" {
        InModuleScope Forgum {
            $parsed = ParseForgumArguments -Arguments @('--count', '10')
            $parsed.Options['count'] | Should -Be '10'
        }
    }

    It "parses --shell bash" {
        InModuleScope Forgum {
            $parsed = ParseForgumArguments -Arguments @('--shell', 'bash')
            $parsed.Options['shell'] | Should -Be 'bash'
        }
    }

    It "parses --duration 5" {
        InModuleScope Forgum {
            $parsed = ParseForgumArguments -Arguments @('--duration', '5')
            $parsed.Options['duration'] | Should -Be '5'
        }
    }

    It "parses --lolcat flag" {
        InModuleScope Forgum {
            $parsed = ParseForgumArguments -Arguments @('--lolcat')
            $parsed.Flags['lolcat'] | Should -Be $true
        }
    }

    It "parses --no-lolcat flag" {
        InModuleScope Forgum {
            $parsed = ParseForgumArguments -Arguments @('--no-lolcat')
            $parsed.Flags['no-lolcat'] | Should -Be $true
        }
    }

    It "parses --fortune flag" {
        InModuleScope Forgum {
            $parsed = ParseForgumArguments -Arguments @('--fortune')
            $parsed.Flags['fortune'] | Should -Be $true
        }
    }

    It "parses --force flag" {
        InModuleScope Forgum {
            $parsed = ParseForgumArguments -Arguments @('--force')
            $parsed.Flags['force'] | Should -Be $true
        }
    }

    It "parses --check flag" {
        InModuleScope Forgum {
            $parsed = ParseForgumArguments -Arguments @('--check')
            $parsed.Flags['check'] | Should -Be $true
        }
    }

    It "parses positional text" {
        InModuleScope Forgum {
            $parsed = ParseForgumArguments -Arguments @('Hello', 'World')
            $parsed.TextString | Should -Be 'Hello World'
        }
    }

    It "parses mixed options and text" {
        InModuleScope Forgum {
            $parsed = ParseForgumArguments -Arguments @('--cow', 'tux', 'Hello', 'World')
            $parsed.Options['cow'] | Should -Be 'tux'
            $parsed.TextString | Should -Be 'Hello World'
        }
    }

    It "parses multiple flags" {
        InModuleScope Forgum {
            $parsed = ParseForgumArguments -Arguments @('--lolcat', '--fortune')
            $parsed.Flags['lolcat'] | Should -Be $true
            $parsed.Flags['fortune'] | Should -Be $true
        }
    }

    It "parses help with other args" {
        InModuleScope Forgum {
            $parsed = ParseForgumArguments -Arguments @('--help', '--cow', 'tux')
            $parsed.Help | Should -Be $true
        }
    }

    It "unknown --option falls through to text" {
        InModuleScope Forgum {
            $parsed = ParseForgumArguments -Arguments @('--unknown', 'value')
            $parsed.Text | Should -Contain '--unknown'
            $parsed.Text | Should -Contain 'value'
        }
    }
}

Describe "Help content completeness" -Tag 'HelpContent' {

    It "root help lists all 12 subcommands" {
        $output = forgum help 2>&1 | Out-String
        $subcommands = @('run', 'config', 'gallery', 'preview', 'update', 'toggle', 'animate', 'eyes', 'init', 'live', 'daemon', 'help')
        foreach ($cmd in $subcommands) {
            $output | Should -Match $cmd
        }
    }

    It "root help lists global options" {
        $output = forgum help 2>&1 | Out-String
        $output | Should -Match '--help'
        $output | Should -Match '--version'
    }

    It "root help lists animation mode categories" {
        $output = forgum help 2>&1 | Out-String
        $output | Should -Match 'Flagship'
        $output | Should -Match 'Legacy'
    }

    It "root help lists flagship animation modes" {
        $output = forgum help 2>&1 | Out-String
        $modes = @('aurora', 'plasma', 'ember', 'liquid-chrome', 'shatter', 'portal', 'glitch', 'neon-pulse')
        foreach ($mode in $modes) {
            $output | Should -Match $mode
        }
    }

    It "run help lists all run options" {
        $output = forgum run --help 2>&1 | Out-String
        $output | Should -Match '--cow'
        $output | Should -Match '--mode'
        $output | Should -Match '--lolcat'
        $output | Should -Match '--no-lolcat'
        $output | Should -Match '--fortune'
        $output | Should -Match '--help'
    }

    It "gallery help lists --count" {
        $output = forgum gallery --help 2>&1 | Out-String
        $output | Should -Match '--count'
    }

    It "preview help lists cow and text args" {
        $output = forgum preview --help 2>&1 | Out-String
        $output | Should -Match 'cow'
        $output | Should -Match 'text'
    }

    It "update help lists --force and --check" {
        $output = forgum update --help 2>&1 | Out-String
        $output | Should -Match '--force'
        $output | Should -Match '--check'
    }

    It "animate help lists all modes with descriptions" {
        $output = forgum animate --help 2>&1 | Out-String
        $output | Should -Match 'aurora.*Northern lights'
        $output | Should -Match 'plasma.*plasma'
        $output | Should -Match 'ember.*fire'
        $output | Should -Match 'static.*No animation'
    }

    It "eyes help lists presets with eye characters" {
        $output = forgum eyes --help 2>&1 | Out-String
        $output | Should -Match 'borg.*=='
        $output | Should -Match 'dead.*xx'
        $output | Should -BeLike '*greedy*'
    }

    It "init help lists all shells" {
        $output = forgum init --help 2>&1 | Out-String
        $output | Should -Match 'bash'
        $output | Should -Match 'zsh'
        $output | Should -Match 'fish'
        $output | Should -Match 'pwsh'
    }

    It "daemon help lists start and stop" {
        $output = forgum daemon --help 2>&1 | Out-String
        $output | Should -Match 'start'
        $output | Should -Match 'stop'
    }

    It "live help lists --duration" {
        $output = forgum live --help 2>&1 | Out-String
        $output | Should -Match '--duration'
    }

    It "toggle help mentions lolcat" {
        $output = forgum toggle --help 2>&1 | Out-String
        $output | Should -Match 'lolcat'
    }
}

Describe "Help alias routing" -Tag 'HelpAlias' {

    It "help upgrade routes to update help" {
        $output = forgum help upgrade 2>&1 | Out-String
        $output | Should -Match 'forgum update'
    }

    It "help tui routes to interactive help" {
        $output = forgum help tui 2>&1 | Out-String
        $output | Should -Match 'forgum interactive'
    }

    It "help show routes to gallery help" {
        $output = forgum help show 2>&1 | Out-String
        $output | Should -Match 'forgum gallery'
    }

    It "help preview-cow routes to preview help" {
        $output = forgum help preview-cow 2>&1 | Out-String
        $output | Should -Match 'forgum preview'
    }

    It "help toggle-rainbow routes to toggle help" {
        $output = forgum help toggle-rainbow 2>&1 | Out-String
        $output | Should -Match 'forgum toggle'
    }

    It "help set-animation routes to animate help" {
        $output = forgum help set-animation 2>&1 | Out-String
        $output | Should -Match 'forgum animate'
    }

    It "help set-eyes routes to eyes help" {
        $output = forgum help set-eyes 2>&1 | Out-String
        $output | Should -Match 'forgum eyes'
    }
}

Describe "Module exports and structure" -Tag 'Structure' {

    It "module exports only forgum" {
        InModuleScope Forgum {
            $manifest = Test-ModuleManifest -Path (Join-Path (Split-Path $PSScriptRoot -Parent) 'Forgum.psd1') -ErrorAction Stop
            $manifest.ExportedFunctions.Keys | Should -Contain 'forgum'
            $manifest.ExportedFunctions.Keys.Count | Should -Be 1
        }
    }

    It "module version is 1.1.2.1" {
        InModuleScope Forgum {
            $manifest = Test-ModuleManifest -Path (Join-Path (Split-Path $PSScriptRoot -Parent) 'Forgum.psd1') -ErrorAction Stop
            $manifest.Version.ToString() | Should -Be '1.1.2.1'
        }
    }

    It "all private subcommand handlers exist" {
        InModuleScope Forgum {
            $handlers = @(
                'RunCommand', 'ConfigCommand', 'GalleryCommand',
                'PreviewCommand', 'UpdateCommand', 'ToggleCommand',
                'AnimateCommand', 'EyesCommand', 'InitCommand',
                'LiveCommand', 'DaemonCommand', 'CowsayCommand',
                'ListCommand', 'ThemeCommand', 'ExportCommand',
                'HistoryCommand', 'InteractiveCommand'
            )
            foreach ($h in $handlers) {
                Get-Command $h -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
            }
        }
    }

    It "all private helper functions exist" {
        InModuleScope Forgum {
            $helpers = @(
                'GetHelpMessage', 'ParseForgumArguments', 'GetEngineBinary',
                'GetForgumShellHook', 'GetShell', 'ShowCowGallery',
                'ShowCowPreview', 'ToggleLolcat', 'SetCowAnimate',
                'SetCowEyes', 'StartDaemon', 'StopDaemon',
                'InvokeForgumLive', 'InvokeForgumTUI', 'UpdateForgum',
                'GetLolcatParams', 'WriteHistory', 'GetPlatform',
                'ReadCowFile', 'FormatCowMessage', 'GetConfig', 'SetConfig',
                'GetCowFiles', 'GetFortune', 'ReadFortuneFile', 'InvokeCowsay',
                'WriteTerminalFrame', 'Set-Forgum'
            )
            foreach ($h in $helpers) {
                Get-Command $h -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty -Because "$h should exist"
            }
        }
    }

    It "all animation functions exist" {
        InModuleScope Forgum {
            $anims = @(
                'ShowAnimation', 'InvokeEngine'
            )
            foreach ($a in $anims) {
                Get-Command $a -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty -Because "$a should exist"
            }
        }
    }
}
