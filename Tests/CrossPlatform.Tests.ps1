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

Describe "Cross-Platform Support" -Tag 'CrossPlatform' {

    Context "Platform detection" {
        It "GetPlatform returns valid platform" {
            InModuleScope Forgum {
                $platform = GetPlatform
                $platform | Should -BeIn @('windows', 'macos', 'linux', 'unknown')
            }
        }

        It "platform matches actual OS" {
            InModuleScope Forgum {
                $platform = GetPlatform
                if ($IsWindows -or $env:OS -eq 'Windows_NT') {
                    $platform | Should -Be 'windows'
                } elseif ($IsMacOS) {
                    $platform | Should -Be 'macos'
                } elseif ($IsLinux) {
                    $platform | Should -Be 'linux'
                }
            }
        }
    }

    Context "Shell detection" {
        It "GetShell returns valid shell" {
            InModuleScope Forgum {
                $shell = GetShell
                $shell | Should -BeIn @('bash', 'zsh', 'fish', 'pwsh', 'powershell', 'unknown')
            }
        }

        It "Windows returns pwsh or powershell" {
            if ($IsWindows -or $env:OS -eq 'Windows_NT') {
                InModuleScope Forgum {
                    $shell = GetShell
                    $shell | Should -BeIn @('pwsh', 'powershell')
                }
            }
        }
    }

    Context "Config path" {
        It "GetForgumConfigPath returns non-empty path" {
            InModuleScope Forgum {
                $path = GetForgumConfigPath
                $path | Should -Not -BeNullOrEmpty
            }
        }

        It "Windows path uses backslash" {
            if ($IsWindows -or $env:OS -eq 'Windows_NT') {
                InModuleScope Forgum {
                    $path = GetForgumConfigPath
                    $path | Should -Match '\\'
                }
            }
        }

        It "path ends with config.json" {
            InModuleScope Forgum {
                $path = GetForgumConfigPath
                $path | Should -Match 'config\.json$'
            }
        }
    }

    Context "Module manifest" {
        It "manifest loads correctly" {
            $manifest = Test-ModuleManifest -Path (Join-Path $ModuleRoot 'Forgum.psd1') -ErrorAction Stop
            $manifest.Version | Should -Not -BeNullOrEmpty
        }

        It "exports only forgum" {
            $manifest = Test-ModuleManifest -Path (Join-Path $ModuleRoot 'Forgum.psd1') -ErrorAction Stop
            $manifest.ExportedFunctions.Keys.Count | Should -Be 1
        }

        It "version is 1.1.2" {
            $manifest = Test-ModuleManifest -Path (Join-Path $ModuleRoot 'Forgum.psd1') -ErrorAction Stop
            $manifest.Version.ToString() | Should -Be '1.1.2'
        }
    }
}
