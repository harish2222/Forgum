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

Describe "Rust Engine" -Tag 'Engine' {

    Context "Binary detection" {
        It "GetEngineBinary finds engine binary" {
            InModuleScope Forgum {
                $bin = GetEngineBinary
                $bin | Should -Not -BeNullOrEmpty
                Test-Path $bin | Should -Be $true
            }
        }

        It "binary name matches platform" {
            InModuleScope Forgum {
                $bin = GetEngineBinary
                if ($IsWindows -or $env:OS -eq 'Windows_NT') {
                    $bin | Should -Match '\.exe$'
                } else {
                    $bin | Should -Not -Match '\.exe$'
                }
            }
        }
    }

    Context "Binary execution" {
        BeforeAll {
            InModuleScope Forgum {
                $script:BinaryPath = GetEngineBinary
            }
        }

        It "responds to --help" {
            if ($script:BinaryPath) {
                $output = & $script:BinaryPath --help 2>&1 | Out-String
                $output | Should -Match 'forgum-engine'
                $output | Should -Match 'Usage:'
            } else {
                Set-ItResult -Inconclusive -Because "engine binary not built"
            }
        }

        It "generates bash hooks via init" {
            if ($script:BinaryPath) {
                $output = & $script:BinaryPath init bash 2>&1 | Out-String
                $output | Should -Match 'forgum\(\)'
                $output | Should -Match 'cowsay'
            } else {
                Set-ItResult -Inconclusive -Because "engine binary not built"
            }
        }

        It "generates zsh hooks via init" {
            if ($script:BinaryPath) {
                $output = & $script:BinaryPath init zsh 2>&1 | Out-String
                $output | Should -Match 'forgum\(\)'
            } else {
                Set-ItResult -Inconclusive -Because "engine binary not built"
            }
        }

        It "generates fish hooks via init" {
            if ($script:BinaryPath) {
                $output = & $script:BinaryPath init fish 2>&1 | Out-String
                $output | Should -Match 'function forgum'
            } else {
                Set-ItResult -Inconclusive -Because "engine binary not built"
            }
        }

        It "generates pwsh hooks via init" {
            if ($script:BinaryPath) {
                $output = & $script:BinaryPath init pwsh 2>&1 | Out-String
                $output | Should -Match 'Invoke-ForgumEngine'
            } else {
                Set-ItResult -Inconclusive -Because "engine binary not built"
            }
        }

        It "handles invalid JSON gracefully" {
            if ($script:BinaryPath) {
                $output = "not json" | & $script:BinaryPath 2>&1 | Out-String
                $output | Should -Match '(?i)(error|parse|invalid|failed)'
            } else {
                Set-ItResult -Inconclusive -Because "engine binary not built"
            }
        }

        It "handles empty stdin gracefully" {
            if ($script:BinaryPath) {
                $output = "" | & $script:BinaryPath 2>&1 | Out-String
                $output | Should -Match '(?i)(no input|empty|error|pipe)'
            } else {
                Set-ItResult -Inconclusive -Because "engine binary not built"
            }
        }
    }

    Context "GetForgumShellHook" {
        It "bash hook contains function definition" {
            InModuleScope Forgum {
                $hook = GetForgumShellHook -Shell 'bash'
                $hook | Should -Match 'forgum\(\)'
                $hook | Should -Match 'cowsay'
                $hook | Should -Match 'forgum-engine'
            }
        }

        It "zsh hook contains function definition" {
            InModuleScope Forgum {
                $hook = GetForgumShellHook -Shell 'zsh'
                $hook | Should -Match 'forgum\(\)'
                $hook | Should -Match 'cowsay'
            }
        }

        It "fish hook contains function definition" {
            InModuleScope Forgum {
                $hook = GetForgumShellHook -Shell 'fish'
                $hook | Should -Match 'function forgum'
                $hook | Should -Match 'cowsay'
            }
        }

        It "pwsh hook contains function definition" {
            InModuleScope Forgum {
                $hook = GetForgumShellHook -Shell 'pwsh'
                $hook | Should -Match 'Invoke-ForgumEngine'
                $hook | Should -Match 'forgum-engine'
            }
        }

        It "unsupported shell returns error message" {
            InModuleScope Forgum {
                $hook = GetForgumShellHook -Shell 'elvish'
                $hook | Should -Match 'Unsupported'
            }
        }
    }
}
