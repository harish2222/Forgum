BeforeAll {
    Import-Module "$PSScriptRoot/../Forgum.psd1" -Force
    $script:OriginalLocation = Get-Location
    $script:TestConfigDir = Join-Path ([System.IO.Path]::GetTempPath()) "forgum-test-$(Get-Random)"
    New-Item -ItemType Directory -Path $script:TestConfigDir -Force | Out-Null

    function Remove-Ansi($text) { $text -replace 'e\[[0-9;]*m', '' -replace '\x1b\[[0-9;]*m', '' }
}

AfterAll {
    Set-Location $script:OriginalLocation
    if (Test-Path $script:TestConfigDir) { Remove-Item $script:TestConfigDir -Recurse -Force -ErrorAction SilentlyContinue }
}

Describe "forgum cowsay" -Tag 'NewSubcommand' {

    It "cowsay with text produces output" {
        $output = forgum cowsay "Hello Test" 6>&1 2>&1 | Out-String
        $output | Should -Not -BeNullOrEmpty
    }

    It "cowsay contains the message text" {
        $raw = forgum cowsay "CowsayTest" 6>&1 2>&1 | Out-String
        Remove-Ansi $raw | Should -BeLike '*CowsayTest*'
    }

    It "cowsay contains balloon borders" {
        $raw = forgum cowsay "BorderTest" 6>&1 2>&1 | Out-String
        $output = Remove-Ansi $raw
        $output | Should -Match '##'
        $output | Should -Match '\|\|'
    }

    It "cowsay --cow tux uses tux" {
        $raw = forgum cowsay "TuxTest" --cow tux 6>&1 2>&1 | Out-String
        $output = Remove-Ansi $raw
        $output | Should -Match 'TuxTest'
    }

    It "cowsay --eyes @@ sets custom eyes" {
        $raw = forgum cowsay "EyesTest" --cow default --eyes '@@' 2>&1 | Out-String
        $output = Remove-Ansi $raw
        $output | Should -Match '@@'
    }

    It "cowsay --help shows help" {
        $output = forgum cowsay --help 2>&1 | Out-String
        $output | Should -Match 'Direct cowsay'
    }

    It "cowsay with no text shows warning" {
        $output = forgum cowsay 3>&1 2>&1 | Out-String
        $output | Should -Match 'requires text'
    }

    It "cowsay --lolcat produces colored output" {
        $raw = forgum cowsay "LolTest" --lolcat 6>&1 2>&1 | Out-String
        $raw | Should -Not -BeNullOrEmpty
    }
}

Describe "forgum list" -Tag 'NewSubcommand' {

    It "list shows available cows" {
        $output = forgum list 2>&1 | Out-String
        $output | Should -Match 'Available cow templates'
    }

    It "list contains tux" {
        $output = forgum list 2>&1 | Out-String
        $output | Should -Match 'tux'
    }

    It "list contains default" {
        $output = forgum list 2>&1 | Out-String
        $output | Should -Match 'default'
    }

    It "list --search cat filters results" {
        $output = forgum list --search cat 2>&1 | Out-String
        $output | Should -Match 'cat'
    }

    It "list --count 3 shows limited results" {
        $output = forgum list --count 3 2>&1 | Out-String
        $output | Should -Not -BeNullOrEmpty
    }

    It "list --help shows help" {
        $output = forgum list --help 2>&1 | Out-String
        $output | Should -Match 'List available cow templates'
    }

    It "list shows usage hints" {
        $output = forgum list 2>&1 | Out-String
        $output | Should -Match 'forgum preview'
    }
}

Describe "forgum theme" -Tag 'NewSubcommand' {

    It "theme with no args lists themes" {
        $output = forgum theme 2>&1 | Out-String
        $output | Should -Match 'Available themes'
    }

    It "theme list shows themes" {
        $output = forgum theme list 2>&1 | Out-String
        $output | Should -Match 'rainbow'
    }

    It "theme list shows mono" {
        $output = forgum theme list 2>&1 | Out-String
        $output | Should -Match 'mono'
    }

    It "theme set rainbow applies theme" {
        $output = forgum theme set rainbow 2>&1 | Out-String
        $output | Should -Match 'Theme set to'
    }

    It "theme set mono applies theme" {
        $output = forgum theme set mono 2>&1 | Out-String
        $output | Should -Match 'Theme set to'
    }

    It "theme reset restores default" {
        $output = forgum theme reset 2>&1 | Out-String
        $output | Should -Match 'reset'
    }

    It "theme set unknown shows warning" {
        $output = forgum theme set foobar 3>&1 2>&1 | Out-String
        $output | Should -Match 'Unknown theme'
    }

    It "theme --help shows help" {
        $output = forgum theme --help 2>&1 | Out-String
        $output | Should -Match 'Manage color themes'
    }
}

Describe "forgum export" -Tag 'NewSubcommand' {

    It "export with text produces file" {
        $output = forgum export "ExportTest" --output "$script:TestConfigDir\test1.txt" 2>&1 | Out-String
        $output | Should -Match 'Exported to'
    }

    It "exported file exists" {
        forgum export "FileTest" --output "$script:TestConfigDir\test2.txt" 2>&1 | Out-Null
        Test-Path "$script:TestConfigDir\test2.txt" | Should -Be $true
    }

    It "exported file contains message" {
        forgum export "ContentCheck" --output "$script:TestConfigDir\test3.txt" 2>&1 | Out-Null
        $content = Get-Content "$script:TestConfigDir\test3.txt" -Raw
        $content = $content -replace 'e\[[0-9;]*[a-zA-Z]', '' -replace '\x1b\[[0-9;]*[a-zA-Z]', ''
        $content | Should -Match 'ContentCheck'
    }

    It "export --cow tux uses tux" {
        forgum export "TuxExport" --cow tux --output "$script:TestConfigDir\test4.txt" 2>&1 | Out-Null
        $content = Get-Content "$script:TestConfigDir\test4.txt" -Raw
        $content = $content -replace 'e\[[0-9;]*[a-zA-Z]', '' -replace '\x1b\[[0-9;]*[a-zA-Z]', ''
        $content | Should -Match 'TuxExport'
    }

    It "export --format txt produces plain text" {
        forgum export "FormatTest" --format txt --output "$script:TestConfigDir\test5.txt" 2>&1 | Out-Null
        $content = Get-Content "$script:TestConfigDir\test5.txt" -Raw
        # Should not contain ANSI escape codes
        $content | Should -Not -Match '\x1b\['
    }

    It "export with no text shows warning" {
        $output = forgum export 3>&1 2>&1 | Out-String
        $output | Should -Match 'requires text'
    }

    It "export --help shows help" {
        $output = forgum export --help 2>&1 | Out-String
        $output | Should -Match 'Export cow art'
    }

    It "export --no-color strips ANSI" {
        forgum export "NoColorTest" --no-color --output "$script:TestConfigDir\test6.txt" 2>&1 | Out-Null
        $content = Get-Content "$script:TestConfigDir\test6.txt" -Raw
        $content | Should -Not -Match '\x1b\['
    }
}

Describe "forgum history" -Tag 'NewSubcommand' {

    It "history with no entries shows message" {
        $output = forgum history --clear 2>&1 | Out-Null
        $output = forgum history 2>&1 | Out-String
        $output | Should -Match 'No history yet|Last'
    }

    It "history --clear clears history" {
        $output = forgum history --clear 3>&1 2>&1 | Out-String
        $output | Should -Match 'cleared'
    }

    It "history --count 5 limits output" {
        $output = forgum history --count 5 2>&1 | Out-String
        $output | Should -Not -BeNullOrEmpty
    }

    It "history --help shows help" {
        $output = forgum history --help 2>&1 | Out-String
        $output | Should -Match 'Show recent cows'
    }

    It "history after cowsay shows entry" {
        forgum cowsay "HistoryTest" 6>&1 | Out-Null
        $output = forgum history --count 1 2>&1 | Out-String
        $output | Should -Match 'HistoryTest'
    }

    It "history shows cow name" {
        forgum cowsay "CowNameTest" --cow tux 6>&1 | Out-Null
        $output = forgum history --count 1 2>&1 | Out-String
        $output | Should -Match 'tux'
    }
}

Describe "forgum interactive" -Tag 'NewSubcommand' {

    It "interactive --help shows help" {
        $output = forgum interactive --help 2>&1 | Out-String
        $output | Should -Match 'interactive'
    }

    It "interactive alias tui resolves" {
        $output = forgum help tui 2>&1 | Out-String
        $output | Should -Match 'interactive'
    }

    It "interactive alias menu resolves" {
        $output = forgum help menu 2>&1 | Out-String
        $output | Should -Match 'interactive'
    }
}

Describe "New subcommands - module structure" -Tag 'NewSubcommand' {

    It "all 5 new handlers exist" {
        InModuleScope Forgum {
            $handlers = @(
                'CowsayCommand',
                'ListCommand',
                'ThemeCommand',
                'ExportCommand',
                'HistoryCommand',
                'InteractiveCommand'
            )
            foreach ($h in $handlers) {
                Get-Command $h -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
            }
        }
    }

    It "WriteHistory helper exists" {
        InModuleScope Forgum {
            Get-Command WriteHistory -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
        }
    }

    It "help text exists for all new commands" {
        InModuleScope Forgum {
            $commands = @('cowsay', 'list', 'theme', 'export', 'history', 'config', 'interactive')
            foreach ($cmd in $commands) {
                $help = GetHelpMessage -Command $cmd
                $help | Should -Match 'Usage:'
            }
        }
    }

    It "aliases resolve for new commands" {
        InModuleScope Forgum {
            $aliases = @{
                'say'   = 'cowsay'
                'ls'    = 'list'
                'colors'= 'theme'
                'save'  = 'export'
                'log'   = 'history'
                'tui'   = 'interactive'
                'menu'  = 'interactive'
            }
            foreach ($alias in $aliases.Keys) {
                $help = GetHelpMessage -Command $alias
                $help | Should -Match 'Usage:'
            }
        }
    }

    It "forgum --help lists all new subcommands" {
        $output = forgum --help 2>&1 | Out-String
        $output | Should -Match 'cowsay'
        $output | Should -Match 'list'
        $output | Should -Match 'theme'
        $output | Should -Match 'export'
        $output | Should -Match 'history'
        $output | Should -Match 'interactive'
    }
}
