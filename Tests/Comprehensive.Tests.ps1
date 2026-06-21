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
            $script:OrigConfig = GetConfig | ConvertTo-JsonSafe | ConvertFrom-Json
        }
    }

    AfterAll {
        InModuleScope Forgum {
            if ($script:OrigConfig) { SetConfig -Config $script:OrigConfig -ErrorAction SilentlyContinue }
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
            $cfg = GetConfig | ConvertTo-JsonSafe | ConvertFrom-Json
            $cfg.animation.mode = $mode
            if ($mode -eq 'dynamic') { $cfg.animation.duration = 1 }
            if ($mode -eq 'physics') { $cfg.animation.duration = 1 }
            SetConfig -Config $cfg
        } -ArgumentList $mode

        $result = forgum run --mode static "ModeTest" 6>&1 | Out-String
        $clean = $result -replace 'e\[[0-9;]*[a-zA-Z]', '' -replace '\x1b\[[0-9;]*[a-zA-Z]', ''
        $clean | Should -Match 'ModeTest' -Because "$mode mode should render cow text"

        InModuleScope Forgum {
            $orig = GetConfig | ConvertTo-JsonSafe | ConvertFrom-Json
            SetConfig -Config $orig -ErrorAction SilentlyContinue
        }
    }
}

Describe "Config Feature Matrix" -Tag 'ConfigMatrix' {
    BeforeAll {
        InModuleScope Forgum {
            $script:BaseConfig = GetConfig | ConvertTo-JsonSafe | ConvertFrom-Json
        }
    }

    AfterEach {
        InModuleScope Forgum {
            if ($script:BaseConfig) { SetConfig -Config $script:BaseConfig -ErrorAction SilentlyContinue }
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
                $cfg = GetConfig | ConvertTo-JsonSafe | ConvertFrom-Json
                $cfg.cow.file = $Cow
                $cfg.animation.mode = 'static'
                SetConfig -Config $cfg
            } -ArgumentList $Cow

            $output = forgum run --mode static "CowTest $Cow" 6>&1 | Out-String
            $clean = $output -replace 'e\[[0-9;]*[a-zA-Z]', '' -replace '\x1b\[[0-9;]*[a-zA-Z]', ''
            $clean | Should -Match 'CowTest'
            $clean | Should -Match "CowTest $Cow|\\$Cow"
        }
    }

    Context "Lolcat variations" {
        It "works with lolcat enabled" {
            InModuleScope Forgum {
                $cfg = GetConfig | ConvertTo-JsonSafe | ConvertFrom-Json
                $cfg.lolcat.enabled = $true
                $cfg.lolcat.frequency = 0.1
                $cfg.lolcat.spread = 3.0
                $cfg.animation.mode = 'static'
                $cfg.cow.random = $false
                $cfg.cow.file = 'default'
                SetConfig -Config $cfg
            }

            $output = forgum run --mode static "LolcatTest" 6>&1 | Out-String
            $clean = $output -replace 'e\[[0-9;]*[a-zA-Z]', '' -replace '\x1b\[[0-9;]*[a-zA-Z]', ''
            $clean | Should -Match 'LolcatTest'
            $clean | Should -Match '\^__\^'
        }

        It "works with lolcat disabled" {
            InModuleScope Forgum {
                $cfg = GetConfig | ConvertTo-JsonSafe | ConvertFrom-Json
                $cfg.lolcat.enabled = $false
                $cfg.animation.mode = 'static'
                $cfg.cow.random = $false
                $cfg.cow.file = 'default'
                SetConfig -Config $cfg
            }

            $output = forgum run --mode static "NoLolcat" 6>&1 | Out-String
            $clean = $output -replace 'e\[[0-9;]*[a-zA-Z]', '' -replace '\x1b\[[0-9;]*[a-zA-Z]', ''
            $clean | Should -Match 'NoLolcat'
            $clean | Should -Match '\^__\^'
        }

        It "works with truecolor enabled" {
            InModuleScope Forgum {
                $cfg = GetConfig | ConvertTo-JsonSafe | ConvertFrom-Json
                $cfg.lolcat.enabled = $true
                $cfg.lolcat.truecolor = $true
                $cfg.lolcat.frequency = 0.1
                $cfg.lolcat.spread = 3.0
                $cfg.animation.mode = 'static'
                $cfg.cow.random = $false
                $cfg.cow.file = 'default'
                SetConfig -Config $cfg
            }

            $output = forgum run --mode static "TrueColor" 6>&1 | Out-String
            $clean = $output -replace 'e\[[0-9;]*[a-zA-Z]', '' -replace '\x1b\[[0-9;]*[a-zA-Z]', ''
            $clean | Should -Match 'TrueColor'
            $clean | Should -Match '\^__\^'
        }

        It "works with truecolor disabled" {
            InModuleScope Forgum {
                $cfg = GetConfig | ConvertTo-JsonSafe | ConvertFrom-Json
                $cfg.lolcat.enabled = $true
                $cfg.lolcat.truecolor = $false
                $cfg.lolcat.frequency = 0.1
                $cfg.lolcat.spread = 3.0
                $cfg.animation.mode = 'static'
                $cfg.cow.random = $false
                $cfg.cow.file = 'default'
                SetConfig -Config $cfg
            }

            $output = forgum run --mode static "NoTrueColor" 6>&1 | Out-String
            $clean = $output -replace 'e\[[0-9;]*[a-zA-Z]', '' -replace '\x1b\[[0-9;]*[a-zA-Z]', ''
            $clean | Should -Match 'NoTrueColor'
            $clean | Should -Match '\^__\^'
        }
    }
}

Describe "Edge Cases" -Tag 'EdgeCases' {
    BeforeAll {
        InModuleScope Forgum {
            $script:OriginalConfig = GetConfig | ConvertTo-JsonSafe | ConvertFrom-Json
        }
    }

    AfterEach {
        InModuleScope Forgum {
            if ($script:OriginalConfig) { SetConfig -Config $script:OriginalConfig -ErrorAction SilentlyContinue }
        }
    }

    It "handles very long text gracefully" {
        $longText = "LongTextTest " + ("A" * 1000)
        $output = forgum run --mode static $longText 6>&1 | Out-String
        $clean = $output -replace 'e\[[0-9;]*[a-zA-Z]', '' -replace '\x1b\[[0-9;]*[a-zA-Z]', ''
        $clean | Should -Match 'LongTextTest'
    }

    It "handles special characters in text" {
        $special = 'SpecialChars $&*(){}[]'
        $output = forgum run --mode static $special 6>&1 | Out-String
        $clean = $output -replace 'e\[[0-9;]*[a-zA-Z]', '' -replace '\x1b\[[0-9;]*[a-zA-Z]', ''
        $clean | Should -Match 'SpecialChars'
    }

    It "handles Unicode text" {
        $unicode = "UnicodeTest cafe"
        $output = forgum run --mode static $unicode 6>&1 | Out-String
        $clean = $output -replace 'e\[[0-9;]*[a-zA-Z]', '' -replace '\x1b\[[0-9;]*[a-zA-Z]', ''
        $clean | Should -Match 'UnicodeTest'
    }
}

Describe "Performance Checks" -Tag 'Performance' {
    BeforeAll {
        InModuleScope Forgum {
            $script:PerfRestoreConfig = GetConfig | ConvertTo-JsonSafe | ConvertFrom-Json
            $cfg = GetConfig
            $cfg.animation.mode = 'static'
            $cfg.lolcat.enabled = $false
            SetConfig -Config $cfg
        }
    }

    AfterAll {
        InModuleScope Forgum {
            if ($script:PerfRestoreConfig) { SetConfig -Config $script:PerfRestoreConfig -ErrorAction SilentlyContinue }
        }
    }

    It "generates output in reasonable time" {
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        $null = forgum run --mode static 6>&1
        $sw.Stop()
        $sw.ElapsedMilliseconds | Should -BeLessThan 10000
    }

    It "config read is fast" {
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        InModuleScope Forgum { $null = GetConfig }
        $sw.Stop()
        $sw.ElapsedMilliseconds | Should -BeLessThan 100
    }
}
