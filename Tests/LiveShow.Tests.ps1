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
            Mock Get-Random { return 5000 } -ParameterFilter { $Maximum -eq 10001 }

            $script:lastInvoke = $null
            Mock Invoke-Engine {
                param([string]$JsonPayload)
                $obj = $JsonPayload | ConvertFrom-Json
                $script:lastInvoke = [pscustomobject]@{
                    CowText = $obj.cow_text
                    Effect  = $obj.effect
                    Fps     = $obj.fps
                    Duration = $obj.duration
                }
                return 'mock-output'
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
            Mock Get-Random { return 5000 } -ParameterFilter { $Maximum -eq 10001 }

            $script:lastInvoke = $null
            Mock Invoke-Engine {
                param([string]$JsonPayload)
                $obj = $JsonPayload | ConvertFrom-Json
                $script:lastInvoke = [pscustomobject]@{
                    CowText = $obj.cow_text
                    Effect  = $obj.effect
                    Fps     = $obj.fps
                    Duration = $obj.duration
                }
                return 'mock-output'
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
            Mock Get-Random { return 5000 } -ParameterFilter { $Maximum -eq 10001 }
            Mock Format-Lolcat {
                param([string]$Text, [int]$Seed)
                return "lolcat-$Seed-$Text"
            }

            $script:lastInvoke = $null
            Mock Invoke-Engine {
                param([string]$JsonPayload)
                $obj = $JsonPayload | ConvertFrom-Json
                $script:lastInvoke = [pscustomobject]@{
                    CowText = $obj.cow_text
                    Effect  = $obj.effect
                    Fps     = $obj.fps
                    Duration = $obj.duration
                }
                return 'mock-output'
            }

            $null = Invoke-LiveShow -RunOnce -Config $mockConfig -Toggles @{ Lolcat = $true; Animation = $false }
            $script:lastInvoke.CowText | Should -BeLike '*lolcat-5000-cow-text*'
        }
    }
}
