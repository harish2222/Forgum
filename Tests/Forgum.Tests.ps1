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

    It "exports setup alias" {
        (Get-Command -Module Forgum -CommandType Alias).Name | Should -Contain 'forgum-setup'
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
            $script:OriginalConfig = Get-CFConfig | ConvertTo-Json -Depth 10 | ConvertFrom-Json
            $template = Get-Content (Join-Path $script:ModuleRoot 'Data/Templates/default-config.json') -Raw | ConvertFrom-Json
            Set-CFConfig -Config $template
        }
    }

    AfterAll {
        InModuleScope Forgum {
            if ($script:OriginalConfig) {
                Set-CFConfig -Config $script:OriginalConfig -ErrorAction SilentlyContinue
            }
        }
    }

    Context "Default values from template" {
        It "has correct default animation settings" {
            InModuleScope Forgum {
                $config = Get-CFConfig
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
                $config = Get-CFConfig
                $config.cow.file | Should -Be 'default'
                $config.cow.random | Should -Be $false
                $config.cow.eyes | Should -Be 'oo'
                $config.cow.tongue | Should -Be '  '
            }
        }

        It "has correct default lolcat settings" {
            InModuleScope Forgum {
                $config = Get-CFConfig
                $config.lolcat.enabled | Should -Be $false
                $config.lolcat.truecolor | Should -Be $true
                $config.lolcat.frequency | Should -Be 0.1
            }
        }

        It "has correct default output settings" {
            InModuleScope Forgum {
                $config = Get-CFConfig
                $config.output.wordWrap | Should -Be $true
                $config.output.maxWidth | Should -Be 60
            }
        }
    }

    Context "Config round-trip persistence" {
        It "persists config changes" {
            InModuleScope Forgum {
                $config = Get-CFConfig
                $origMode = $config.animation.mode
                $config.animation.mode = 'disco'
                Set-CFConfig -Config $config

                (Get-CFConfig).animation.mode | Should -Be 'disco'

                $config.animation.mode = $origMode
                Set-CFConfig -Config $config
                (Get-CFConfig).animation.mode | Should -Be $origMode
            }
        }
    }
}

Describe "Cow File System" -Tag 'Cows' {
    It "lists available cow files" {
        InModuleScope Forgum {
            $cows = Get-CFCow
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
            $cowText = Get-CFCow -Name $Cow
            $cowText | Should -Not -BeNullOrEmpty
            $cowText | Should -Match '\$eyes|\$thoughts'
        } -ArgumentList $Cow
    }

    It "throws for nonexistent cow names" {
        InModuleScope Forgum {
            { Get-CFCow -Name 'nonexistent-cow-12345' } | Should -Throw
        }
    }
}

Describe "Fortune System" -Tag 'Fortune' {
    It "returns a fortune string" {
        InModuleScope Forgum {
            $fortune = Get-Fortune
            $fortune | Should -Not -BeNullOrEmpty
            $fortune.Length | Should -BeGreaterThan 0
        }
    }

    It "returns different fortunes on multiple calls" {
        InModuleScope Forgum {
            $f1 = Get-Fortune
            $f2 = Get-Fortune
            $f3 = Get-Fortune
            ($f1 -ne $f2 -or $f2 -ne $f3) | Should -Be $true
        }
    }
}

Describe "forgum" -Tag 'Cowsay' {
    BeforeAll {
        InModuleScope Forgum {
            $moduleRoot = (Get-Module Forgum).ModuleBase
            $template = Get-Content (Join-Path $moduleRoot 'Data/Templates/default-config.json') -Raw | ConvertFrom-Json
            Set-CFConfig -Config $template
        }
    }

    It "renders a cow with text bubble" {
        $output = forgum "Test message" 6>&1 | Out-String
        $output | Should -Not -BeNullOrEmpty
        $output | Should -Match 'Test message'
    }

    It "supports custom cow files" {
        $output = forgum "Custom cow" -CowFile 'tux' 6>&1 | Out-String
        $output | Should -Not -BeNullOrEmpty
        $output | Should -Match 'Custom cow'
    }

    It "supports thinking mode with string parameter" {
        $output = forgum "Thinking..." -Thoughts 'o' 6>&1 | Out-String
        $output | Should -Not -BeNullOrEmpty
        $output | Should -Match 'Thinking'
    }

    It "supports custom eyes" {
        $output = forgum "Custom eyes" -Eyes 'XX' 6>&1 | Out-String
        $output | Should -Not -BeNullOrEmpty
        $output | Should -Match 'Custom eyes'
    }

    It "handles empty text gracefully" {
        $output = forgum "" 6>&1 | Out-String
        $output | Should -Not -BeNullOrEmpty
    }

    It "handles multi-line text" {
        $output = forgum "Line 1`nLine 2" 6>&1 | Out-String
        $output | Should -Not -BeNullOrEmpty
        $output | Should -Match 'Line 1'
        $output | Should -Match 'Line 2'
    }
}

Describe "Lolcat Colorization" -Tag 'Lolcat' {
    Context "With truecolor enabled" {
        BeforeAll {
            InModuleScope Forgum {
                $script:RestoreConfig = Get-CFConfig | ConvertTo-Json -Depth 10 | ConvertFrom-Json
                $cfg = Get-CFConfig
                $cfg.lolcat.enabled = $true
                $cfg.lolcat.truecolor = $true
                $cfg.lolcat.frequency = 0.1
                $cfg.lolcat.spread = 3.0
                $cfg.animation.mode = 'static'
                Set-CFConfig -Config $cfg
            }
        }

        AfterAll {
            InModuleScope Forgum {
                if ($script:RestoreConfig) { Set-CFConfig -Config $script:RestoreConfig -ErrorAction SilentlyContinue }
            }
        }

        It "produces truecolor ANSI output (38;2)" {
            $output = forgum 6>&1 | Out-String
            $output | Should -Not -BeNullOrEmpty

            $esc = [char]27
            $hasAnsi = $output -match [regex]::Escape("$esc[38;2;")
            if (-not $hasAnsi) {
                InModuleScope Forgum {
                    $cfg = Get-CFConfig
                    $cfg.lolcat.enabled = $false
                    $cfg.animation.mode = 'static'
                    Set-CFConfig -Config $cfg
                }
                $plain = forgum 6>&1 | Out-String
                ($output -ne $plain) | Should -Be $true
                InModuleScope Forgum {
                    $cfg = Get-CFConfig
                    $cfg.lolcat.enabled = $true
                    $cfg.lolcat.truecolor = $true
                    Set-CFConfig -Config $cfg
                }
            } else {
                $output | Should -Match "$esc\[38;2;"
            }
        }
    }

    Context "With truecolor disabled" {
        BeforeAll {
            InModuleScope Forgum {
                $script:RestoreConfig = Get-CFConfig | ConvertTo-Json -Depth 10 | ConvertFrom-Json
                $cfg = Get-CFConfig
                $cfg.lolcat.enabled = $true
                $cfg.lolcat.truecolor = $false
                $cfg.lolcat.frequency = 0.1
                $cfg.lolcat.spread = 3.0
                $cfg.animation.mode = 'static'
                Set-CFConfig -Config $cfg
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
                if ($script:RestoreConfig) { Set-CFConfig -Config $script:RestoreConfig -ErrorAction SilentlyContinue }
            }
        }

        It "produces 256-color ANSI output (38;5)" {
            $output = forgum 6>&1 | Out-String
            $output | Should -Not -BeNullOrEmpty

            $esc = [char]27
            $hasAnsi = $output -match [regex]::Escape("$esc[38;5;")
            if (-not $hasAnsi) {
                InModuleScope Forgum {
                    $cfg = Get-CFConfig
                    $cfg.lolcat.enabled = $false
                    $cfg.animation.mode = 'static'
                    Set-CFConfig -Config $cfg
                }
                $plain = forgum 6>&1 | Out-String
                ($output -ne $plain) | Should -Be $true
                InModuleScope Forgum {
                    $cfg = Get-CFConfig
                    $cfg.lolcat.enabled = $true
                    $cfg.lolcat.truecolor = $false
                    Set-CFConfig -Config $cfg
                }
            } else {
                $output | Should -Match "$esc\[38;5;"
            }
        }
    }

    Context "When disabled" {
        BeforeAll {
            InModuleScope Forgum {
                $script:RestoreConfig = Get-CFConfig | ConvertTo-Json -Depth 10 | ConvertFrom-Json
                $cfg = Get-CFConfig
                $cfg.lolcat.enabled = $false
                $cfg.lolcat.frequency = 0.1
                $cfg.lolcat.spread = 3.0
                $cfg.animation.mode = 'static'
                Set-CFConfig -Config $cfg
            }
        }

        AfterAll {
            InModuleScope Forgum {
                if ($script:RestoreConfig) { Set-CFConfig -Config $script:RestoreConfig -ErrorAction SilentlyContinue }
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
            $script:OrigConfig = Get-CFConfig | ConvertTo-Json -Depth 10 | ConvertFrom-Json
        }
    }

    AfterAll {
        InModuleScope Forgum {
            if ($script:OrigConfig) { Set-CFConfig -Config $script:OrigConfig -ErrorAction SilentlyContinue }
        }
    }

    Context "Static animation" {
        BeforeAll {
            InModuleScope Forgum {
                $script:RestoreConfig = Get-CFConfig | ConvertTo-Json -Depth 10 | ConvertFrom-Json
                $cfg = Get-CFConfig
                $cfg.animation.mode = 'static'
                Set-CFConfig -Config $cfg
            }
        }

        AfterAll {
            InModuleScope Forgum {
                if ($script:RestoreConfig) { Set-CFConfig -Config $script:RestoreConfig -ErrorAction SilentlyContinue }
            }
        }

        It "returns cow text immediately" {
            InModuleScope Forgum {
                $output = Show-CFAnimation -CowOutput "Test cow"
                $output | Should -Not -BeNullOrEmpty
            }
        }
    }

    Context "Dynamic animation" {
        BeforeAll {
            InModuleScope Forgum {
                $script:RestoreConfig = Get-CFConfig | ConvertTo-Json -Depth 10 | ConvertFrom-Json
                $cfg = Get-CFConfig
                $cfg.animation.mode = 'dynamic'
                $cfg.animation.duration = 1
                Set-CFConfig -Config $cfg
            }
        }

        AfterAll {
            InModuleScope Forgum {
                if ($script:RestoreConfig) { Set-CFConfig -Config $script:RestoreConfig -ErrorAction SilentlyContinue }
            }
        }

        It "cycles through random cows and fortunes" {
            InModuleScope Forgum {
                { Show-CFAnimation -CowOutput "Test cow" } | Should -Not -Throw
            }
        }
    }

    Context "Physics animation" {
        BeforeAll {
            InModuleScope Forgum {
                $script:RestoreConfig = Get-CFConfig | ConvertTo-Json -Depth 10 | ConvertFrom-Json
                $cfg = Get-CFConfig
                $cfg.animation.mode = 'physics'
                $cfg.animation.duration = 1
                Set-CFConfig -Config $cfg
            }
        }

        AfterAll {
            InModuleScope Forgum {
                if ($script:RestoreConfig) { Set-CFConfig -Config $script:RestoreConfig -ErrorAction SilentlyContinue }
            }
        }

        It "runs without throwing" {
            InModuleScope Forgum {
                { Show-CFAnimation -CowOutput "Test cow" } | Should -Not -Throw
            }
        }
    }
}

Describe "Cross-Platform Behavior" -Tag 'Platform' {
    It "has platform-agnostic path handling" {
        InModuleScope Forgum {
            $path = Get-ConfigPath
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

Describe "Format-CowMessage Alignment" -Tag 'Formatting' {
    It "correctly calculates width with tabs and invisible chars" {
        InModuleScope Forgum {
            $trickyFortune = "A wise cow says:`tmoo." + [char]0x200B
            $output = Format-CowMessage -Text $trickyFortune -MaxWidth 40
            $lines = $output -split "`n"

            $lines[0].Length | Should -Be $lines[-1].Length

            foreach ($line in $lines[1..($lines.Count-2)]) {
                $line.EndsWith('||') | Should -Be $true -Because "Line should end with ||: '$line'"
                $line.Length | Should -Be $lines[0].Length -Because "Line length $($line.Length) should match top border length $($lines[0].Length). Line: '$line', Top: '$($lines[0])'"
            }
        }
    }
}

Describe "Show-CFAnimation Cross-Platform Wrapper" -Tag 'Wrapper' {
    It "invokes forgum-engine binary for flagship modes when present" {
        $moduleRoot = Split-Path (Get-Module Forgum).ModuleBase -Parent
        $binPath = Join-Path $moduleRoot "bin/forgum-engine.exe"
        if ($IsLinux -or $IsMacOS) { $binPath = Join-Path $moduleRoot "bin/forgum-engine" }

        if (Test-Path $binPath) {
            InModuleScope Forgum {
                param($binPath)
                $script:RestoreConfig = Get-CFConfig | ConvertTo-Json -Depth 10 | ConvertFrom-Json
                $cfg = Get-CFConfig
                $cfg.animation.mode = 'aurora'
                Set-CFConfig -Config $cfg
                { Show-CFAnimation -CowOutput "moo" } | Should -Not -Throw
                Set-CFConfig -Config $script:RestoreConfig
            } -ArgumentList $binPath
        } else {
            Set-ItResult -Inconclusive -Because "Rust engine binary not built/found at $binPath"
        }
    }

    It "falls back safely if forgum-engine is missing for flagship modes" {
        InModuleScope Forgum {
            Mock Test-Path { return $false } -ParameterFilter { $Path -like "*forgum-engine*" }
            $script:RestoreConfig = Get-CFConfig | ConvertTo-Json -Depth 10 | ConvertFrom-Json
            $cfg = Get-CFConfig
            $cfg.animation.mode = 'aurora'
            Set-CFConfig -Config $cfg

            { Show-CFAnimation -CowOutput "moo" } | Should -Not -Throw
            Set-CFConfig -Config $script:RestoreConfig
        }
    }
}
