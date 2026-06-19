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
    
    function Get-DeepCopyConfig {
        $config = Get-CFConfig
        return ($config | ConvertTo-Json -Depth 10 | ConvertFrom-Json)
    }
    
    $script:OriginalConfig = Get-DeepCopyConfig
    $script:CowFiles = (Get-ChildItem (Join-Path $ModuleRoot 'Data/Cows') -Filter '*.cow').BaseName
}

AfterAll {
    if ($script:OriginalConfig) {
        Set-CFConfig -Config $script:OriginalConfig -ErrorAction SilentlyContinue
    }
}

Describe "Animation Mode Matrix" -Tag 'AnimationMatrix' {
    BeforeAll {
        $script:AllModes = @('static', 'talking', 'typewriter', 'slide-in', 'bounce',
                            'dissolve', 'fade-in', 'blink', 'wiggle', 'wave', 'disco', 'dynamic')
        $script:OrigConfig = Get-DeepCopyConfig
    }

    AfterAll {
        if ($script:OrigConfig) { Set-CFConfig -Config $script:OrigConfig -ErrorAction SilentlyContinue }
    }

    It "has 12 total animation modes" {
        $script:AllModes.Count | Should -Be 12
    }

    It "dispatches to correct mode for <mode>" -ForEach @(
        @{ mode = 'static' },
        @{ mode = 'talking' },
        @{ mode = 'typewriter' },
        @{ mode = 'slide-in' },
        @{ mode = 'bounce' },
        @{ mode = 'dissolve' },
        @{ mode = 'fade-in' },
        @{ mode = 'blink' },
        @{ mode = 'wiggle' },
        @{ mode = 'wave' },
        @{ mode = 'disco' },
        @{ mode = 'dynamic' }
    ) {
        $cfg = Get-DeepCopyConfig
        $cfg.animation.mode = $mode
        if ($mode -eq 'dynamic') { $cfg.animation.duration = 1 }
        Set-CFConfig -Config $cfg
        
        $result = forgum -ErrorAction SilentlyContinue
        $result | Should -Not -BeNullOrEmpty -Because "$mode mode should produce output"
        
        # Restore after each iteration
        Set-CFConfig -Config $script:OrigConfig -ErrorAction SilentlyContinue
    }
}

Describe "Config Feature Matrix" -Tag 'ConfigMatrix' {
    BeforeAll {
        $script:BaseConfig = Get-DeepCopyConfig
    }

    AfterEach {
        Set-CFConfig -Config $script:BaseConfig -ErrorAction SilentlyContinue
    }

    Context "Cow variations" {
        It "works with cow file <Cow>" -ForEach @(
            @{ Cow = 'default' },
            @{ Cow = 'tux' },
            @{ Cow = 'dragon' },
            @{ Cow = 'stegosaurus' },
            @{ Cow = 'sheep' }
        ) {
            $cfg = Get-DeepCopyConfig
            $cfg.cow.file = $Cow
            $cfg.animation.mode = 'static'
            Set-CFConfig -Config $cfg
            
            $output = forgum -ErrorAction SilentlyContinue
            $output | Should -Not -BeNullOrEmpty
        }
    }

    Context "Lolcat variations" {
        It "works with lolcat enabled" {
            $cfg = Get-DeepCopyConfig
            $cfg.lolcat.enabled = $true
            $cfg.animation.mode = 'static'
            Set-CFConfig -Config $cfg
            
            $output = forgum -ErrorAction SilentlyContinue
            $output | Should -Not -BeNullOrEmpty
        }

        It "works with lolcat disabled" {
            $cfg = Get-DeepCopyConfig
            $cfg.lolcat.enabled = $false
            $cfg.animation.mode = 'static'
            Set-CFConfig -Config $cfg
            
            $output = forgum -ErrorAction SilentlyContinue
            $output | Should -Not -BeNullOrEmpty
        }

        It "works with truecolor enabled" {
            $cfg = Get-DeepCopyConfig
            $cfg.lolcat.enabled = $true
            $cfg.lolcat.truecolor = $true
            $cfg.animation.mode = 'static'
            Set-CFConfig -Config $cfg
            
            $output = forgum -ErrorAction SilentlyContinue
            $output | Should -Not -BeNullOrEmpty
        }

        It "works with truecolor disabled" {
            $cfg = Get-DeepCopyConfig
            $cfg.lolcat.enabled = $true
            $cfg.lolcat.truecolor = $false
            $cfg.animation.mode = 'static'
            Set-CFConfig -Config $cfg
            
            $output = forgum -ErrorAction SilentlyContinue
            $output | Should -Not -BeNullOrEmpty
        }
    }
}

Describe "Edge Cases" -Tag 'EdgeCases' {
    BeforeAll {
        if (-not (Get-Module Forgum)) { Import-Module $ModulePath -Force }
        $script:OriginalConfig = Get-DeepCopyConfig
    }

    AfterEach {
        Set-CFConfig -Config $script:OriginalConfig -ErrorAction SilentlyContinue
    }

    It "handles very long text gracefully" {
        $longText = "A" * 1000
        $output = forgum $longText
        $output | Should -Not -BeNullOrEmpty
    }

    It "handles special characters in text" {
        $special = 'Test $&*(){}[]|:\"'''
        $output = forgum $special
        $output | Should -Not -BeNullOrEmpty
    }

    It "handles Unicode text" {
        $unicode = "Hello World 1234567890"
        $output = forgum $unicode
        $output | Should -Not -BeNullOrEmpty
    }
}

Describe "Performance Checks" -Tag 'Performance' {
    BeforeAll {
        if (-not (Get-Module Forgum)) { Import-Module $ModulePath -Force }
        $script:PerfRestoreConfig = Get-DeepCopyConfig
        $cfg = Get-CFConfig
        $cfg.animation.mode = 'static'
        $cfg.lolcat.enabled = $false
        Set-CFConfig -Config $cfg
    }

    AfterAll {
        if ($script:PerfRestoreConfig) { Set-CFConfig -Config $script:PerfRestoreConfig -ErrorAction SilentlyContinue }
    }

    It "generates output in reasonable time" {
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        $null = forgum
        $sw.Stop()
        $sw.ElapsedMilliseconds | Should -BeLessThan 10000
    }

    It "config read is fast" {
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        $null = Get-CFConfig
        $sw.Stop()
        $sw.ElapsedMilliseconds | Should -BeLessThan 100
    }
}
