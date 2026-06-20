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
}

Describe "forgum CLI" -Tag 'CLI' {

    Context "Root --help" {
        It "shows help with --help" {
            $output = forgum --help 2>&1 | Out-String
            $output | Should -Match 'Usage:'
            $output | Should -Match 'forgum'
            $output | Should -Match 'Subcommands:'
        }

        It "shows help with -h" {
            $output = forgum -h 2>&1 | Out-String
            $output | Should -Match 'Usage:'
        }

        It "shows help with help subcommand" {
            $output = forgum help 2>&1 | Out-String
            $output | Should -Match 'Usage:'
            $output | Should -Match 'forgum'
        }

        It "lists all subcommands" {
            $output = forgum help 2>&1 | Out-String
            $output | Should -Match 'run'
            $output | Should -Match 'config'
            $output | Should -Match 'gallery'
            $output | Should -Match 'preview'
            $output | Should -Match 'update'
            $output | Should -Match 'toggle'
            $output | Should -Match 'animate'
            $output | Should -Match 'eyes'
            $output | Should -Match 'init'
            $output | Should -Match 'daemon'
            $output | Should -Match 'live'
        }

        It "lists animation modes" {
            $output = forgum --help 2>&1 | Out-String
            $output | Should -Match 'aurora'
            $output | Should -Match 'plasma'
            $output | Should -Match 'ember'
            $output | Should -Match 'static'
        }
    }

    Context "Version" {
        It "shows version with --version" {
            $output = forgum --version 2>&1 | Out-String
            $output | Should -Match 'forgum v'
        }

        It "shows version with --version (short -v is unreliable with CmdletBinding)" {
            $output = forgum --version 2>&1 | Out-String
            $output | Should -Match 'forgum v'
        }
    }

    Context "Subcommand --help" {
        It "run --help shows run help" {
            $output = forgum run --help 2>&1 | Out-String
            $output | Should -Match 'Usage:'
            $output | Should -Match 'forgum run'
            $output | Should -Match '--cow'
            $output | Should -Match '--mode'
            $output | Should -Match '--lolcat'
        }

        It "config --help shows config help" {
            $output = forgum config --help 2>&1 | Out-String
            $output | Should -Match 'Usage:'
            $output | Should -Match 'forgum config'
        }

        It "gallery --help shows gallery help" {
            $output = forgum gallery --help 2>&1 | Out-String
            $output | Should -Match 'Usage:'
            $output | Should -Match 'forgum gallery'
            $output | Should -Match '--count'
        }

        It "preview --help shows preview help" {
            $output = forgum preview --help 2>&1 | Out-String
            $output | Should -Match 'Usage:'
            $output | Should -Match 'forgum preview'
        }

        It "update --help shows update help" {
            $output = forgum update --help 2>&1 | Out-String
            $output | Should -Match 'Usage:'
            $output | Should -Match 'forgum update'
            $output | Should -Match '--force'
            $output | Should -Match '--check'
        }

        It "toggle --help shows toggle help" {
            $output = forgum toggle --help 2>&1 | Out-String
            $output | Should -Match 'Usage:'
            $output | Should -Match 'forgum toggle'
        }

        It "animate --help shows animate help" {
            $output = forgum animate --help 2>&1 | Out-String
            $output | Should -Match 'Usage:'
            $output | Should -Match 'forgum animate'
            $output | Should -Match 'aurora'
            $output | Should -Match 'plasma'
        }

        It "eyes --help shows eyes help" {
            $output = forgum eyes --help 2>&1 | Out-String
            $output | Should -Match 'Usage:'
            $output | Should -Match 'forgum eyes'
            $output | Should -Match 'preset'
            $output | Should -Match 'borg'
        }

        It "init --help shows init help" {
            $output = forgum init --help 2>&1 | Out-String
            $output | Should -Match 'Usage:'
            $output | Should -Match 'forgum init'
            $output | Should -Match 'bash'
            $output | Should -Match 'zsh'
            $output | Should -Match 'fish'
        }

        It "daemon --help shows daemon help" {
            $output = forgum daemon --help 2>&1 | Out-String
            $output | Should -Match 'Usage:'
            $output | Should -Match 'forgum daemon'
            $output | Should -Match 'start'
            $output | Should -Match 'stop'
        }

        It "live --help shows live help" {
            $output = forgum live --help 2>&1 | Out-String
            $output | Should -Match 'Usage:'
            $output | Should -Match 'forgum live'
            $output | Should -Match '--duration'
        }

        It "help run shows run help" {
            $output = forgum help run 2>&1 | Out-String
            $output | Should -Match 'Usage:'
            $output | Should -Match 'forgum run'
        }
    }

    Context "Default behavior" {
        It "runs with no arguments" {
            $output = forgum 6>&1 2>&1 | Out-String
            $output | Should -Not -BeNullOrEmpty
        }

        It "runs with text argument" {
            $output = forgum "Test message" 6>&1 2>&1 | Out-String
            $output | Should -Match 'Test message'
        }
    }

    Context "Module exports" {
        It "exports only forgum function" {
            $funcs = (Get-Command -Module Forgum -CommandType Function).Name
            $funcs | Should -Contain 'forgum'
            $funcs.Count | Should -Be 1
        }

        It "exports aliases" {
            $aliases = (Get-Command -Module Forgum -CommandType Alias).Name
            $aliases | Should -Contain 'forgum-setup'
        }
    }

    Context "Parse-ForgumArguments" {
        It "parses --help flag" {
            InModuleScope Forgum {
                $parsed = Parse-ForgumArguments -Arguments @('--help')
                $parsed.Help | Should -Be $true
            }
        }

        It "parses -h flag" {
            InModuleScope Forgum {
                $parsed = Parse-ForgumArguments -Arguments @('-h')
                $parsed.Help | Should -Be $true
            }
        }

        It "parses --cow option" {
            InModuleScope Forgum {
                $parsed = Parse-ForgumArguments -Arguments @('--cow', 'tux')
                $parsed.Options['cow'] | Should -Be 'tux'
            }
        }

        It "parses --mode option" {
            InModuleScope Forgum {
                $parsed = Parse-ForgumArguments -Arguments @('--mode', 'aurora')
                $parsed.Options['mode'] | Should -Be 'aurora'
            }
        }

        It "parses --count option" {
            InModuleScope Forgum {
                $parsed = Parse-ForgumArguments -Arguments @('--count', '10')
                $parsed.Options['count'] | Should -Be '10'
            }
        }

        It "parses --lolcat flag" {
            InModuleScope Forgum {
                $parsed = Parse-ForgumArguments -Arguments @('--lolcat')
                $parsed.Flags['lolcat'] | Should -Be $true
            }
        }

        It "parses positional text" {
            InModuleScope Forgum {
                $parsed = Parse-ForgumArguments -Arguments @('Hello', 'World')
                $parsed.TextString | Should -Be 'Hello World'
            }
        }

        It "parses mixed args and text" {
            InModuleScope Forgum {
                $parsed = Parse-ForgumArguments -Arguments @('--cow', 'tux', 'Hello')
                $parsed.Options['cow'] | Should -Be 'tux'
                $parsed.TextString | Should -Be 'Hello'
            }
        }
    }
}
