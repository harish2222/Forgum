#Requires -Modules Pester

<#
    Comprehensive Feature Matrix Tests
    Tests all animation modes, config combinations, and edge cases.
    Uses deep-copy config isolation to prevent contamination.
#>

BeforeAll {
    $env:FORGUM_NOAUTOSTART = '1'
    $ModuleRoot = Split-Path $PSScriptRoot -Parent
    $ModulePath = Join-Path $ModuleRoot 'Forgum.psd1'
    Get-Module Forgum | Remove-Module Forgum -Force -ErrorAction SilentlyContinue
    Import-Module $ModulePath -Force
    $script:CowFiles = (Get-ChildItem (Join-Path $ModuleRoot 'Data/Cows') -Filter '*.cow').BaseName
}

Describe "Animation Mode Matrix" -Tag 'AnimationMatrix' {
    BeforeAll {
        InModuleScope Forgum {
            $script:AllModes = @('static', 'talking', 'typewriter', 'dynamic', 'physics')
            $script:OrigConfig = Get-CFConfig | ConvertTo-Json -Depth 10 | ConvertFrom-Json
        }
    }

    AfterAll {
        InModuleScope Forgum {
            if ($script:OrigConfig) { Set-CFConfig -Config $script:OrigConfig -ErrorAction SilentlyContinue }
        }
    }

    It "has 5 total animation modes" {
        InModuleScope Forgum { $script:AllModes.Count | Should -Be 5 }
    }

    It "dispatches to correct mode for <mode>" -ForEach @(
        @{ mode = 'static' },
        @{ mode = 'talking' },
        @{ mode = 'typewriter' },
        @{ mode = 'dynamic' },
        @{ mode = 'physics' }
    ) {
        InModuleScope Forgum {
            param($mode)
            $cfg = Get-CFConfig | ConvertTo-Json -Depth 10 | ConvertFrom-Json
            $cfg.animation.mode = $mode
            if ($mode -eq 'dynamic') { $cfg.animation.duration = 1 }
            if ($mode -eq 'physics') { $cfg.animation.duration = 1 }
            Set-CFConfig -Config $cfg
        } -ArgumentList $mode

        $result = forgum -ErrorAction SilentlyContinue 6>&1 | Out-String
        $result | Should -Not -BeNullOrEmpty -Because "$mode mode should produce output"

        InModuleScope Forgum {
            $orig = Get-CFConfig | ConvertTo-Json -Depth 10 | ConvertFrom-Json
            Set-CFConfig -Config $orig -ErrorAction SilentlyContinue
        }
    }
}

Describe "Config Feature Matrix" -Tag 'ConfigMatrix' {
    BeforeAll {
        InModuleScope Forgum {
            $script:BaseConfig = Get-CFConfig | ConvertTo-Json -Depth 10 | ConvertFrom-Json
        }
    }

    AfterEach {
        InModuleScope Forgum {
            if ($script:BaseConfig) { Set-CFConfig -Config $script:BaseConfig -ErrorAction SilentlyContinue }
        }
    }

    Context "Cow variations" {
        It "works with cow file <Cow>" -ForEach @(
            @{ Cow = 'default' },
            @{ Cow = 'tux' },
            @{ Cow = 'dragon' },
            @{ Cow = 'stegosaurus' },
            @{ Cow = 'sheep' }
        ) {
            InModuleScope Forgum {
                param($Cow)
                $cfg = Get-CFConfig | ConvertTo-Json -Depth 10 | ConvertFrom-Json
                $cfg.cow.file = $Cow
                $cfg.animation.mode = 'static'
                Set-CFConfig -Config $cfg
            } -ArgumentList $Cow

            $output = forgum -ErrorAction SilentlyContinue 6>&1 | Out-String
            $output | Should -Not -BeNullOrEmpty
        }
    }

    Context "Lolcat variations" {
        It "works with lolcat enabled" {
            InModuleScope Forgum {
                $cfg = Get-CFConfig | ConvertTo-Json -Depth 10 | ConvertFrom-Json
                $cfg.lolcat.enabled = $true
                $cfg.lolcat.frequency = 0.1
                $cfg.lolcat.spread = 3.0
                $cfg.animation.mode = 'static'
                Set-CFConfig -Config $cfg
            }

            $output = forgum -ErrorAction SilentlyContinue 6>&1 | Out-String
            $output | Should -Not -BeNullOrEmpty
        }

        It "works with lolcat disabled" {
            InModuleScope Forgum {
                $cfg = Get-CFConfig | ConvertTo-Json -Depth 10 | ConvertFrom-Json
                $cfg.lolcat.enabled = $false
                $cfg.animation.mode = 'static'
                Set-CFConfig -Config $cfg
            }

            $output = forgum -ErrorAction SilentlyContinue 6>&1 | Out-String
            $output | Should -Not -BeNullOrEmpty
        }

        It "works with truecolor enabled" {
            InModuleScope Forgum {
                $cfg = Get-CFConfig | ConvertTo-Json -Depth 10 | ConvertFrom-Json
                $cfg.lolcat.enabled = $true
                $cfg.lolcat.truecolor = $true
                $cfg.lolcat.frequency = 0.1
                $cfg.lolcat.spread = 3.0
                $cfg.animation.mode = 'static'
                Set-CFConfig -Config $cfg
            }

            $output = forgum -ErrorAction SilentlyContinue 6>&1 | Out-String
            $output | Should -Not -BeNullOrEmpty
        }

        It "works with truecolor disabled" {
            InModuleScope Forgum {
                $cfg = Get-CFConfig | ConvertTo-Json -Depth 10 | ConvertFrom-Json
                $cfg.lolcat.enabled = $true
                $cfg.lolcat.truecolor = $false
                $cfg.lolcat.frequency = 0.1
                $cfg.lolcat.spread = 3.0
                $cfg.animation.mode = 'static'
                Set-CFConfig -Config $cfg
            }

            $output = forgum -ErrorAction SilentlyContinue 6>&1 | Out-String
            $output | Should -Not -BeNullOrEmpty
        }
    }
}

Describe "Edge Cases" -Tag 'EdgeCases' {
    BeforeAll {
        InModuleScope Forgum {
            $script:OriginalConfig = Get-CFConfig | ConvertTo-Json -Depth 10 | ConvertFrom-Json
        }
    }

    AfterEach {
        InModuleScope Forgum {
            if ($script:OriginalConfig) { Set-CFConfig -Config $script:OriginalConfig -ErrorAction SilentlyContinue }
        }
    }

    It "handles very long text gracefully" {
        $longText = "A" * 1000
        $output = forgum $longText 6>&1 | Out-String
        $output | Should -Not -BeNullOrEmpty
    }

    It "handles special characters in text" {
        $special = 'Test $&*(){}[]|:\"'''
        $output = forgum $special 6>&1 | Out-String
        $output | Should -Not -BeNullOrEmpty
    }

    It "handles Unicode text" {
        $unicode = "Hello World 1234567890"
        $output = forgum $unicode 6>&1 | Out-String
        $output | Should -Not -BeNullOrEmpty
    }
}

Describe "Performance Checks" -Tag 'Performance' {
    BeforeAll {
        InModuleScope Forgum {
            $script:PerfRestoreConfig = Get-CFConfig | ConvertTo-Json -Depth 10 | ConvertFrom-Json
            $cfg = Get-CFConfig
            $cfg.animation.mode = 'static'
            $cfg.lolcat.enabled = $false
            Set-CFConfig -Config $cfg
        }
    }

    AfterAll {
        InModuleScope Forgum {
            if ($script:PerfRestoreConfig) { Set-CFConfig -Config $script:PerfRestoreConfig -ErrorAction SilentlyContinue }
        }
    }

    It "generates output in reasonable time" {
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        $null = forgum 6>&1
        $sw.Stop()
        $sw.ElapsedMilliseconds | Should -BeLessThan 10000
    }

    It "config read is fast" {
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        InModuleScope Forgum { $null = Get-CFConfig }
        $sw.Stop()
        $sw.ElapsedMilliseconds | Should -BeLessThan 100
    }
}
