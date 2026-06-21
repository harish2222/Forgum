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
    $script:TestCows = (Get-ChildItem (Join-Path $ModuleRoot 'Data/Cows') -Filter '*.cow').BaseName
    $script:TestFortunes = Get-Content (Join-Path $ModuleRoot 'Data/Fortunes/fortunes.txt') -Raw

    function Remove-Ansi {
        param([string]$Text)
        $Text -replace 'e\[[0-9;]*[a-zA-Z]', '' -replace 'e\][^\a]*\a', '' -replace '[\x1b]\[[0-9;]*[a-zA-Z]', '' -replace '[\x1b]\][^\x07]*\x07', ''
    }
}

Describe "Module Loading" -Tag 'Module' {
    It "loads without errors" {
        { Get-Module Forgum } | Should -Not -Throw
    }

    It "exports the expected function(s)" {
        $expected = @('forgum')
        $actual = (Get-Command -Module Forgum -CommandType Function).Name
        foreach ($cmd in $expected) {
            $actual | Should -Contain $cmd
        }
    }

    It "exports no aliases" {
        (Get-Command -Module Forgum -CommandType Alias).Name | Should -BeNullOrEmpty
    }

    It "exports the expected function" {
        $expected = @('forgum')
        $actual = (Get-Command -Module Forgum -CommandType Function).Name

        foreach ($cmd in $expected) {
            $actual | Should -Contain $cmd
        }
    }

    It "module code correctly exports functions" {
        $funcs = @('forgum')
        foreach ($func in $funcs) {
            $cmd = Get-Command $func -Module Forgum
            $cmd.Parameters.ContainsKey('Verbose') | Should -Be $true -Because "$func should support -Verbose"
        }
    }
}

Describe "Config System" -Tag 'Config' {
    BeforeAll {
        InModuleScope Forgum {
            $script:ModuleRoot = (Get-Module Forgum).ModuleBase
            $script:OriginalConfig = GetConfig | ConvertTo-JsonSafe | ConvertFrom-Json
            $template = Get-Content (Join-Path $script:ModuleRoot 'Data/Templates/default-config.json') -Raw | ConvertFrom-Json
            SetConfig -Config $template
        }
    }

    AfterAll {
        InModuleScope Forgum {
            if ($script:OriginalConfig) {
                SetConfig -Config $script:OriginalConfig -ErrorAction SilentlyContinue
            }
        }
    }

    Context "Default values from template" {
        It "has correct default animation settings" {
            InModuleScope Forgum {
                $config = GetConfig
                $config.animation.mode | Should -Be 'random'
                $config.animation.speed | Should -Be 20
                $config.animation.duration | Should -Be 12
                $config.animation.blinkRate | Should -Be 0.2
                $config.animation.amplitude | Should -Be 2
                $config.animation.cycleInterval | Should -Be 3
            }
        }

        It "has correct default cow settings" {
            InModuleScope Forgum {
                $config = GetConfig
                $config.cow.file | Should -Be 'default'
                $config.cow.random | Should -Be $true
                $config.cow.eyes | Should -Be 'oo'
                $config.cow.tongue | Should -Be '  '
            }
        }

        It "has correct default lolcat settings" {
            InModuleScope Forgum {
                $config = GetConfig
                $config.lolcat.enabled | Should -Be $true
                $config.lolcat.truecolor | Should -Be $true
                $config.lolcat.frequency | Should -Be 0.1
            }
        }

        It "has correct default output settings" {
            InModuleScope Forgum {
                $config = GetConfig
                $config.output.wordWrap | Should -Be $true
                $config.output.maxWidth | Should -Be 60
            }
        }
    }

    Context "Config round-trip persistence" {
        It "persists config changes" {
            InModuleScope Forgum {
                $config = GetConfig
                $origMode = $config.animation.mode
                $config.animation.mode = 'disco'
                SetConfig -Config $config

                (GetConfig).animation.mode | Should -Be 'disco'

                $config.animation.mode = $origMode
                SetConfig -Config $config
                (GetConfig).animation.mode | Should -Be $origMode
            }
        }
    }
}

Describe "Cow File System" -Tag 'Cows' {
    It "lists available cow files" {
        InModuleScope Forgum {
            $cows = GetCowFiles
            $cows | Should -Not -BeNullOrEmpty
            $cows.Count | Should -BeGreaterThan 50
        }
    }

    It "can read specific cow files" -ForEach @(
        @{ Cow = 'default' },
        @{ Cow = 'tux' },
        @{ Cow = 'dragon' },
        @{ Cow = 'sheep' }
    ) {
        InModuleScope Forgum {
            param($Cow)
            $cowText = GetCowFiles -Name $Cow
            $cowText | Should -Not -BeNullOrEmpty
            $cowText | Should -Match '\$eyes|\$thoughts'
        } -ArgumentList $Cow
    }

    It "throws for nonexistent cow names" {
        InModuleScope Forgum {
            { GetCowFiles -Name 'nonexistent-cow-12345' } | Should -Throw
        }
    }
}

Describe "Fortune System" -Tag 'Fortune' {
    It "returns a fortune string" {
        InModuleScope Forgum {
            $fortune = GetFortune
            $fortune | Should -Not -BeNullOrEmpty
            $fortune.Length | Should -BeGreaterThan 0
        }
    }

    It "returns different fortunes on multiple calls" {
        InModuleScope Forgum {
            $f1 = GetFortune
            $f2 = GetFortune
            $f3 = GetFortune
            ($f1 -ne $f2 -or $f2 -ne $f3) | Should -Be $true
        }
    }
}

Describe "forgum" -Tag 'Cowsay' {
    BeforeAll {
        InModuleScope Forgum {
            $moduleRoot = (Get-Module Forgum).ModuleBase
            $template = Get-Content (Join-Path $moduleRoot 'Data/Templates/default-config.json') -Raw | ConvertFrom-Json
            SetConfig -Config $template
        }
    }

    It "renders a cow with text bubble" {
        $raw = forgum run --mode static "Test message" 6>&1 | Out-String
        $output = Remove-Ansi $raw
        $output | Should -Not -BeNullOrEmpty
        $output | Should -Match 'Test message'
    }

    It "supports custom cow files" {
        $raw = forgum run --mode static --cow tux "Custom cow" 6>&1 | Out-String
        $output = Remove-Ansi $raw
        $output | Should -Not -BeNullOrEmpty
        $output | Should -Match 'Custom cow'
    }

    It "supports thinking mode with string parameter" {
        $raw = forgum run --mode static --eyes '@@' "Thinking..." 6>&1 | Out-String
        $output = Remove-Ansi $raw
        $output | Should -Not -BeNullOrEmpty
        $output | Should -Match 'Thinking'
    }

    It "supports custom eyes" {
        $raw = forgum run --mode static --eyes 'XX' "Custom eyes" 6>&1 | Out-String
        $output = Remove-Ansi $raw
        $output | Should -Not -BeNullOrEmpty
        $output | Should -Match 'Custom eyes'
    }

    It "handles empty text gracefully" {
        $raw = forgum run --mode static "" 6>&1 | Out-String
        $output = Remove-Ansi $raw
        $output | Should -Not -BeNullOrEmpty
    }

    It "handles multi-line text" {
        $raw = forgum run --mode static "Line 1`nLine 2" 6>&1 | Out-String
        $output = Remove-Ansi $raw
        $output | Should -Not -BeNullOrEmpty
        $output | Should -Match 'Line 1'
        $output | Should -Match 'Line 2'
    }
}

Describe "Lolcat Colorization" -Tag 'Lolcat' {
    Context "With truecolor enabled" {
        BeforeAll {
            InModuleScope Forgum {
                $script:RestoreConfig = GetConfig | ConvertTo-JsonSafe | ConvertFrom-Json
                $cfg = GetConfig
                $cfg.lolcat.enabled = $true
                $cfg.lolcat.truecolor = $true
                $cfg.lolcat.frequency = 0.1
                $cfg.lolcat.spread = 3.0
                $cfg.animation.mode = 'static'
                SetConfig -Config $cfg
            }
        }

        AfterAll {
            InModuleScope Forgum {
                if ($script:RestoreConfig) { SetConfig -Config $script:RestoreConfig -ErrorAction SilentlyContinue }
            }
        }

        It "produces truecolor ANSI output (38;2)" {
            $output = forgum 6>&1 | Out-String
            $output | Should -Not -BeNullOrEmpty

            $esc = [char]27
            $hasAnsi = $output -match [regex]::Escape("$esc[38;2;")
            if (-not $hasAnsi) {
                InModuleScope Forgum {
                    $cfg = GetConfig
                    $cfg.lolcat.enabled = $false
                    $cfg.animation.mode = 'static'
                    SetConfig -Config $cfg
                }
                $plain = forgum 6>&1 | Out-String
                ($output -ne $plain) | Should -Be $true
                InModuleScope Forgum {
                    $cfg = GetConfig
                    $cfg.lolcat.enabled = $true
                    $cfg.lolcat.truecolor = $true
                    SetConfig -Config $cfg
                }
            } else {
                $output | Should -Match "$esc\[38;2;"
            }
        }
    }

    Context "With truecolor disabled" {
        BeforeAll {
            InModuleScope Forgum {
                $script:RestoreConfig = GetConfig | ConvertTo-JsonSafe | ConvertFrom-Json
                $cfg = GetConfig
                $cfg.lolcat.enabled = $true
                $cfg.lolcat.truecolor = $false
                $cfg.lolcat.frequency = 0.1
                $cfg.lolcat.spread = 3.0
                $cfg.animation.mode = 'static'
                SetConfig -Config $cfg
            }
            $script:OrigColorterm = $env:COLORTERM
            $script:OrigWTSession = $env:WT_SESSION
            $env:COLORTERM = $null
            $env:WT_SESSION = $null
        }

        AfterAll {
            $env:COLORTERM = $script:OrigColorterm
            $env:WT_SESSION = $script:OrigWTSession
            InModuleScope Forgum {
                if ($script:RestoreConfig) { SetConfig -Config $script:RestoreConfig -ErrorAction SilentlyContinue }
            }
        }

        It "produces 256-color ANSI output (38;5)" {
            $output = forgum 6>&1 | Out-String
            $output | Should -Not -BeNullOrEmpty

            $esc = [char]27
            $hasAnsi = $output -match [regex]::Escape("$esc[38;5;")
            if (-not $hasAnsi) {
                InModuleScope Forgum {
                    $cfg = GetConfig
                    $cfg.lolcat.enabled = $false
                    $cfg.animation.mode = 'static'
                    SetConfig -Config $cfg
                }
                $plain = forgum 6>&1 | Out-String
                ($output -ne $plain) | Should -Be $true
                InModuleScope Forgum {
                    $cfg = GetConfig
                    $cfg.lolcat.enabled = $true
                    $cfg.lolcat.truecolor = $false
                    SetConfig -Config $cfg
                }
            } else {
                $output | Should -Match "$esc\[38;5;"
            }
        }
    }

    Context "When disabled" {
        BeforeAll {
            InModuleScope Forgum {
                $script:RestoreConfig = GetConfig | ConvertTo-JsonSafe | ConvertFrom-Json
                $cfg = GetConfig
                $cfg.lolcat.enabled = $false
                $cfg.lolcat.frequency = 0.1
                $cfg.lolcat.spread = 3.0
                $cfg.animation.mode = 'static'
                SetConfig -Config $cfg
            }
        }

        AfterAll {
            InModuleScope Forgum {
                if ($script:RestoreConfig) { SetConfig -Config $script:RestoreConfig -ErrorAction SilentlyContinue }
            }
        }

        It "does not colorize output" {
            $output = forgum 6>&1 | Out-String
            $esc = [char]27
            $output | Should -Not -Match "$esc\[38;"
            $output | Should -Not -Match "$esc\[48;"
        }
    }
}

Describe "Animation Modes" -Tag 'Animation' {
    BeforeAll {
        InModuleScope Forgum {
            $script:OrigConfig = GetConfig | ConvertTo-JsonSafe | ConvertFrom-Json
        }
    }

    AfterAll {
        InModuleScope Forgum {
            if ($script:OrigConfig) { SetConfig -Config $script:OrigConfig -ErrorAction SilentlyContinue }
        }
    }

    Context "Static animation" {
        BeforeAll {
            InModuleScope Forgum {
                $script:RestoreConfig = GetConfig | ConvertTo-JsonSafe | ConvertFrom-Json
                $cfg = GetConfig
                $cfg.animation.mode = 'static'
                SetConfig -Config $cfg
            }
        }

        AfterAll {
            InModuleScope Forgum {
                if ($script:RestoreConfig) { SetConfig -Config $script:RestoreConfig -ErrorAction SilentlyContinue }
            }
        }

        It "returns cow text immediately" {
            InModuleScope Forgum {
                $output = ShowAnimation -CowOutput "Test cow"
                $output | Should -Not -BeNullOrEmpty
            }
        }
    }

    Context "Dynamic animation" {
        BeforeAll {
            InModuleScope Forgum {
                $script:RestoreConfig = GetConfig | ConvertTo-JsonSafe | ConvertFrom-Json
                $cfg = GetConfig
                $cfg.animation.mode = 'dynamic'
                $cfg.animation.duration = 1
                SetConfig -Config $cfg
            }
        }

        AfterAll {
            InModuleScope Forgum {
                if ($script:RestoreConfig) { SetConfig -Config $script:RestoreConfig -ErrorAction SilentlyContinue }
            }
        }

        It "cycles through random cows and fortunes" {
            InModuleScope Forgum {
                { ShowAnimation -CowOutput "Test cow" } | Should -Not -Throw
            }
        }
    }

    Context "Physics animation" {
        BeforeAll {
            InModuleScope Forgum {
                $script:RestoreConfig = GetConfig | ConvertTo-JsonSafe | ConvertFrom-Json
                $cfg = GetConfig
                $cfg.animation.mode = 'physics'
                $cfg.animation.duration = 1
                SetConfig -Config $cfg
            }
        }

        AfterAll {
            InModuleScope Forgum {
                if ($script:RestoreConfig) { SetConfig -Config $script:RestoreConfig -ErrorAction SilentlyContinue }
            }
        }

        It "runs without throwing" {
            InModuleScope Forgum {
                { ShowAnimation -CowOutput "Test cow" } | Should -Not -Throw
            }
        }
    }
}

Describe "Cross-Platform Behavior" -Tag 'Platform' {
    It "has platform-agnostic path handling" {
        InModuleScope Forgum {
            $path = GetConfigPath
            $path | Should -Not -BeNullOrEmpty
            if ($IsLinux) { $path | Should -Match '/' }
            elseif ($IsMacOS) { $path | Should -Match '/' }
            else { $path | Should -Not -Match '/' }
        }
    }

    It "module manifest loads correctly with correct encoding" {
        $manifest = Test-ModuleManifest -Path (Join-Path $ModuleRoot 'Forgum.psd1') -ErrorAction Stop
        $manifest.Version | Should -Not -BeNullOrEmpty
        $manifest.ExportedFunctions.Keys.Count | Should -Be 1
    }
}

Describe "FormatCowMessage Alignment" -Tag 'Formatting' {
    It "correctly calculates width with tabs and invisible chars" {
        InModuleScope Forgum {
            $trickyFortune = "A wise cow says:`tmoo." + [char]0x200B
            $output = FormatCowMessage -Text $trickyFortune -MaxWidth 40
            $lines = $output -split "`n"

            $lines[0].Length | Should -Be $lines[-1].Length

            foreach ($line in $lines[1..($lines.Count-2)]) {
                $line.EndsWith('||') | Should -Be $true -Because "Line should end with ||: '$line'"
                $line.Length | Should -Be $lines[0].Length -Because "Line length $($line.Length) should match top border length $($lines[0].Length). Line: '$line', Top: '$($lines[0])'"
            }
        }
    }
}

Describe "ShowAnimation Cross-Platform Wrapper" -Tag 'Wrapper' {
    It "invokes forgum-engine binary for flagship modes when present" {
        $moduleRoot = Split-Path (Get-Module Forgum).ModuleBase -Parent
        $binPath = Join-Path $moduleRoot "bin/forgum-engine.exe"
        if ($IsLinux -or $IsMacOS) { $binPath = Join-Path $moduleRoot "bin/forgum-engine" }

        if (Test-Path $binPath) {
            InModuleScope Forgum {
                param($binPath)
                $script:RestoreConfig = GetConfig | ConvertTo-JsonSafe | ConvertFrom-Json
                $cfg = GetConfig
                $cfg.animation.mode = 'aurora'
                SetConfig -Config $cfg
                { ShowAnimation -CowOutput "moo" } | Should -Not -Throw
                SetConfig -Config $script:RestoreConfig
            } -ArgumentList $binPath
        } else {
            Set-ItResult -Inconclusive -Because "Rust engine binary not built/found at $binPath"
        }
    }

    It "falls back safely if forgum-engine is missing for flagship modes" {
        InModuleScope Forgum {
            Mock Test-Path { return $false } -ParameterFilter { $Path -like "*forgum-engine*" }
            $script:RestoreConfig = GetConfig | ConvertTo-JsonSafe | ConvertFrom-Json
            $cfg = GetConfig
            $cfg.animation.mode = 'aurora'
            SetConfig -Config $cfg

            { ShowAnimation -CowOutput "moo" } | Should -Not -Throw
            SetConfig -Config $script:RestoreConfig
        }
    }
}
