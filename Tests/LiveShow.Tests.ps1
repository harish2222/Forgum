# Requires -Modules Pester

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

Describe 'Invoke-LiveShow' {
    It 'when Animation is enabled, calls Invoke-Engine with correct params' {
        InModuleScope Forgum {
            $mockConfig = [pscustomobject]@{ fortune = [pscustomobject]@{ database = 'dummy-db' } }
            Mock Get-CFConfig { return $mockConfig }
            Mock Get-CFCow { return @('cow1', 'cow2') }
            Mock Get-Fortune { return 'fortune1' }
            Mock Invoke-Cowsay { return 'cow-text' }
            Mock Get-Random { return 5000 } -ParameterFilter { $Maximum -eq 100000 }

            $script:lastInvoke = $null
            Mock Invoke-Engine {
                param([string]$Message, [string[]]$CowTemplate, [string]$Effect, [int]$Fps, [int]$Duration)
                $script:lastInvoke = [pscustomobject]@{
                    Message = $Message; CowText = $CowTemplate[0]
                    Effect = $Effect; Fps = $Fps; Duration = $Duration
                }
                return $true
            }

            $result = Invoke-LiveShow -RunOnce -Config $mockConfig -Toggles @{ Lolcat = $false; Animation = $true }
            $result.Status | Should -Be 'Complete'
            $script:lastInvoke | Should -Not -BeNullOrEmpty
            $script:lastInvoke.Fps | Should -Be 30
        }
    }

    It 'when Animation is disabled, calls Invoke-Engine with correct params' {
        InModuleScope Forgum {
            $mockConfig = [pscustomobject]@{ fortune = [pscustomobject]@{ database = 'dummy-db' } }
            Mock Get-CFConfig { return $mockConfig }
            Mock Get-CFCow { return @('cow1', 'cow2') }
            Mock Get-Fortune { return 'fortune1' }
            Mock Invoke-Cowsay { return 'cow-text' }
            Mock Get-Random { return 5000 } -ParameterFilter { $Maximum -eq 100000 }

            $script:lastInvoke = $null
            Mock Invoke-Engine {
                param([string]$Message, [string[]]$CowTemplate, [string]$Effect, [int]$Fps, [int]$Duration)
                $script:lastInvoke = [pscustomobject]@{
                    Message = $Message; CowText = $CowTemplate[0]
                    Effect = $Effect; Fps = $Fps; Duration = $Duration
                }
                return $true
            }

            $result = Invoke-LiveShow -RunOnce -Config $mockConfig -Toggles @{ Lolcat = $false; Animation = $false }
            $result.Status | Should -Be 'Complete'
            $script:lastInvoke | Should -Not -BeNullOrEmpty
            $script:lastInvoke.Fps | Should -Be 1
        }
    }

    It 'applies Lolcat to cow text when Lolcat toggle is enabled' {
        InModuleScope Forgum {
            $mockConfig = [pscustomobject]@{ fortune = [pscustomobject]@{ database = 'dummy-db' } }
            Mock Get-CFConfig { return $mockConfig }
            Mock Get-CFCow { return @('cow1', 'cow2') }
            Mock Get-Fortune { return 'fortune1' }
            Mock Invoke-Cowsay { return 'cow-text' }
            Mock Get-Random { return 5000 } -ParameterFilter { $Maximum -eq 100000 }
            Mock Format-Lolcat {
                param([string]$Text, [int]$Seed)
                return "lolcat-$Seed-$Text"
            }

            $script:lastInvoke = $null
            Mock Invoke-Engine {
                param([string]$Message, [string[]]$CowTemplate, [string]$Effect, [int]$Fps, [int]$Duration)
                $script:lastInvoke = [pscustomobject]@{
                    Message = $Message; CowText = $CowTemplate[0]
                    Effect = $Effect; Fps = $Fps; Duration = $Duration
                }
                return $true
            }

            $null = Invoke-LiveShow -RunOnce -Config $mockConfig -Toggles @{ Lolcat = $true; Animation = $false }
            $script:lastInvoke.CowText | Should -Be 'lolcat-5000-cow-text'
        }
    }
}
