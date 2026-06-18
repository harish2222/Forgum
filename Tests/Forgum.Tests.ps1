#Requires -Modules Pester

BeforeAll {
    $env:FORGUM_NOAUTOSTART = '1'
    $ModuleRoot = Split-Path $PSScriptRoot -Parent
    $ModulePath = Join-Path $ModuleRoot 'Forgum.psd1'
    
    # Force complete removal of any existing module instances
    do {
        $m = Get-Module Forgum -ErrorAction SilentlyContinue
        if ($m) { Remove-Module Forgum -Force -ErrorAction SilentlyContinue }
    } while ($m)

    Import-Module $ModulePath -Force
    $script:TestCows = (Get-ChildItem (Join-Path $ModuleRoot 'Data/Cows') -Filter '*.cow').BaseName
    $script:TestFortunes = Get-Content (Join-Path $ModuleRoot 'Data/Fortunes/fortunes.txt') -Raw
    $script:OriginalConfig = Get-CFConfig | ConvertTo-Json -Depth 10 | ConvertFrom-Json
    
    function Get-DeepCopyConfig {
        $config = Get-CFConfig
        return ($config | ConvertTo-Json -Depth 10 | ConvertFrom-Json)
    }
}

Describe "Module Loading" -Tag 'Module' {
    It "loads without errors" {
        { Get-Module Forgum } | Should -Not -Throw
    }

    it "exports exactly 19 functions" {
        (Get-Command -Module Forgum -CommandType Function).Count | Should -Be 19
    }

    It "exports setup alias" {
        (Get-Command -Module Forgum -CommandType Alias).Name | Should -Contain 'forgum-setup'
    }

    It "exports all 9 expected functions" {
        $expected = @('Invoke-Cowsay', 'Invoke-Forgum', 'Get-Fortune', 'Get-CFCow', 'Get-CFConfig', 'Set-CFConfig', 'Show-CFAnimation', 'Invoke-ForgumSetup', 'Update-Forgum')
        $actual = (Get-Command -Module Forgum -CommandType Function).Name
        
        foreach ($cmd in $expected) {
            $actual | Should -Contain $cmd
        }
    }

    It "module code correctly exports functions" {
        $funcs = @('Invoke-Cowsay', 'Get-Fortune', 'Get-CFCow', 'Get-CFConfig', 'Set-CFConfig', 'Show-CFAnimation', 'Invoke-Forgum', 'Invoke-ForgumSetup', 'Update-Forgum')
        foreach ($func in $funcs) {
            $cmd = Get-Command $func -Module Forgum
            $cmd.Parameters.ContainsKey('Verbose') | Should -Be $true -Because "$func should support -Verbose"
        }
    }
}

Describe "Config System" -Tag 'Config' {
    BeforeAll {
        $script:OriginalConfig = Get-DeepCopyConfig
        $template = Get-Content (Join-Path $ModuleRoot 'Data/Templates/default-config.json') -Raw | ConvertFrom-Json
        Set-CFConfig -Config $template
    }

    AfterAll {
        if ($script:OriginalConfig) {
            Set-CFConfig -Config $script:OriginalConfig -ErrorAction SilentlyContinue
        }
    }

    Context "Default values from template" {
        It "has correct default animation settings" {
            $config = Get-CFConfig
            $config.animation.mode | Should -Be 'random'
            $config.animation.speed | Should -Be 20
            $config.animation.duration | Should -Be 12
            $config.animation.blinkRate | Should -Be 0.2
            $config.animation.amplitude | Should -Be 2
            $config.animation.cycleInterval | Should -Be 3
        }

        It "has correct default cow settings" {
            $config = Get-CFConfig
            $config.cow.file | Should -Be 'default'
            $config.cow.random | Should -Be $false
            $config.cow.eyes | Should -Be 'oo'
            $config.cow.tongue | Should -Be '  '
        }

        It "has correct default lolcat settings" {
            $config = Get-CFConfig
            $config.lolcat.enabled | Should -Be $false
            $config.lolcat.truecolor | Should -Be $true
            $config.lolcat.frequency | Should -Be 0.1
        }

        It "has correct default output settings" {
            $config = Get-CFConfig
            $config.output.wordWrap | Should -Be $true
            $config.output.maxWidth | Should -Be 60
        }
    }

    Context "Config round-trip persistence" {
        It "persists config changes" {
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

Describe "Set-Forgum" -Tag 'Config' {
    BeforeAll {
        if (-not (Get-Module Forgum)) { Import-Module $ModulePath -Force }
        $script:SetForgumRestore = Get-DeepCopyConfig
    }

    AfterAll {
        if ($script:SetForgumRestore) { Set-CFConfig -Config $script:SetForgumRestore -ErrorAction SilentlyContinue }
    }

    It "updates animation mode" {
        Set-Forgum -Animation 'typewriter'
        (Get-CFConfig).animation.mode | Should -Be 'typewriter'
    }

    It "updates cow file" {
        Set-Forgum -Cow 'tux'
        (Get-CFConfig).cow.file | Should -Be 'tux'
    }

    It "updates cow eyes" {
        Set-Forgum -Eyes 'XX'
        (Get-CFConfig).cow.eyes | Should -Be 'XX'
    }

    It "updates lolcat status" {
        Set-Forgum -Lolcat $true
        (Get-CFConfig).lolcat.enabled | Should -Be $true
        Set-Forgum -Lolcat $false
        (Get-CFConfig).lolcat.enabled | Should -Be $false
    }

    It "updates random cow status" {
        Set-Forgum -RandomCow $true
        (Get-CFConfig).cow.random | Should -Be $true
        Set-Forgum -RandomCow $false
        (Get-CFConfig).cow.random | Should -Be $false
    }

    It "updates rainbow frequency" {
        Set-Forgum -RainbowFrequency 0.5
        (Get-CFConfig).lolcat.frequency | Should -Be 0.5
    }
}

Describe "Cow File System" -Tag 'Cows' {
    BeforeAll {
        if (-not (Get-Module Forgum)) { Import-Module $ModulePath -Force }
    }

    It "lists available cow files" {
        $cows = Get-CFCow
        $cows | Should -Not -BeNullOrEmpty
        $cows.Count | Should -BeGreaterThan 50
    }

    It "can read specific cow files" -ForEach @(
        @{ Cow = 'default' },
        @{ Cow = 'tux' },
        @{ Cow = 'dragon' },
        @{ Cow = 'sheep' }
    ) {
        $cowText = Get-CFCow -Name $Cow
        $cowText | Should -Not -BeNullOrEmpty
        $cowText | Should -Match '\$eyes|\$thoughts'
    }

    It "throws for nonexistent cow names" {
        { Get-CFCow -Name 'nonexistent-cow-12345' } | Should -Throw
    }
}

Describe "Fortune System" -Tag 'Fortune' {
    BeforeAll {
        if (-not (Get-Module Forgum)) { Import-Module $ModulePath -Force }
    }

    It "returns a fortune string" {
        $fortune = Get-Fortune
        $fortune | Should -Not -BeNullOrEmpty
        $fortune.Length | Should -BeGreaterThan 0
    }

    It "returns different fortunes on multiple calls" {
        $f1 = Get-Fortune
        $f2 = Get-Fortune
        $f3 = Get-Fortune
        ($f1 -ne $f2 -or $f2 -ne $f3) | Should -Be $true
    }
}

Describe "Invoke-Cowsay" -Tag 'Cowsay' {
    BeforeAll {
        if (-not (Get-Module Forgum)) { Import-Module $ModulePath -Force }
        # Reset config to default for clean state
        $template = Get-Content (Join-Path $ModuleRoot 'Data/Templates/default-config.json') -Raw | ConvertFrom-Json
        Set-CFConfig -Config $template
    }

    It "renders a cow with text bubble" {
        $output = Invoke-Cowsay -Text "Test message"
        $output | Should -Not -BeNullOrEmpty
        $output | Should -Match 'Test message'
        $output | Should -Match '\^__\^|o\.o|oo|\*\*|XX|@@|\$\$|==|--|\.\.'
    }

    It "supports custom cow files" {
        $output = Invoke-Cowsay -Text "Custom cow" -CowFile 'tux'
        $output | Should -Not -BeNullOrEmpty
        $output | Should -Match 'Custom cow'
    }

    It "supports thinking mode with string parameter" {
        $output = Invoke-Cowsay -Text "Thinking..." -Thoughts 'o'
        $output | Should -Not -BeNullOrEmpty
        $output | Should -Match 'Thinking'
    }

    It "supports custom eyes" {
        $output = Invoke-Cowsay -Text "Custom eyes" -Eyes 'XX'
        $output | Should -Not -BeNullOrEmpty
        $output | Should -Match 'Custom eyes'
        $output | Should -Match 'XX'
    }

    It "handles empty text gracefully" {
        $output = Invoke-Cowsay -Text ""
        $output | Should -Not -BeNullOrEmpty
    }

    It "handles multi-line text" {
        $output = Invoke-Cowsay -Text "Line 1`nLine 2"
        $output | Should -Not -BeNullOrEmpty
        $output | Should -Match 'Line 1'
        $output | Should -Match 'Line 2'
    }
}

Describe "Lolcat Colorization" -Tag 'Lolcat' {
    BeforeAll {
        if (-not (Get-Module Forgum)) { Import-Module $ModulePath -Force }
    }

    Context "With truecolor enabled" {
        BeforeAll {
            $script:RestoreConfig = Get-DeepCopyConfig
            $cfg = Get-CFConfig
            $cfg.lolcat.enabled = $true
            $cfg.lolcat.truecolor = $true
            $cfg.animation.mode = 'static'
            Set-CFConfig -Config $cfg
        }

        AfterAll {
            if ($script:RestoreConfig) { Set-CFConfig -Config $script:RestoreConfig -ErrorAction SilentlyContinue }
        }

        It "produces truecolor ANSI output (38;2)" {
            $output = Invoke-Forgum
            $output | Should -Not -BeNullOrEmpty
            $esc = [char]27
            $output | Should -Match "$esc\[38;2;"
        }
    }

    Context "With truecolor disabled" {
        BeforeAll {
            $script:RestoreConfig = Get-DeepCopyConfig
            $script:OrigColorterm = $env:COLORTERM
            $script:OrigWTSession = $env:WT_SESSION
            $env:COLORTERM = $null
            $env:WT_SESSION = $null
            $cfg = Get-CFConfig
            $cfg.lolcat.enabled = $true
            $cfg.lolcat.truecolor = $false
            $cfg.animation.mode = 'static'
            Set-CFConfig -Config $cfg
        }

        AfterAll {
            $env:COLORTERM = $script:OrigColorterm
            $env:WT_SESSION = $script:OrigWTSession
            if ($script:RestoreConfig) { Set-CFConfig -Config $script:RestoreConfig -ErrorAction SilentlyContinue }
        }

        It "produces 256-color ANSI output (38;5)" {
            $output = Invoke-Forgum
            $output | Should -Not -BeNullOrEmpty
            $esc = [char]27
            $output | Should -Match "$esc\[38;5;"
        }
    }

    Context "When disabled" {
        BeforeAll {
            $script:RestoreConfig = Get-DeepCopyConfig
            $cfg = Get-CFConfig
            $cfg.lolcat.enabled = $false
            $cfg.animation.mode = 'static'
            Set-CFConfig -Config $cfg
        }

        AfterAll {
            if ($script:RestoreConfig) { Set-CFConfig -Config $script:RestoreConfig -ErrorAction SilentlyContinue }
        }

        It "does not colorize output" {
            $output = Invoke-Forgum
            $esc = [char]27
            $output | Should -Not -Match "$esc\[38;"
            $output | Should -Not -Match "$esc\[48;"
        }
    }
}

Describe "Animation Modes" -Tag 'Animation' {
    BeforeAll {
        if (-not (Get-Module Forgum)) { Import-Module $ModulePath -Force }
        $script:OrigConfig = Get-DeepCopyConfig
    }

    AfterAll {
        if ($script:OrigConfig) { Set-CFConfig -Config $script:OrigConfig -ErrorAction SilentlyContinue }
    }

    Context "Static animation" {
        BeforeAll {
            $script:RestoreConfig = Get-DeepCopyConfig
            $cfg = Get-CFConfig
            $cfg.animation.mode = 'static'
            Set-CFConfig -Config $cfg
        }

        AfterAll {
            if ($script:RestoreConfig) { Set-CFConfig -Config $script:RestoreConfig -ErrorAction SilentlyContinue }
        }

        It "returns cow text immediately" {
            $output = Show-CFAnimation -CowOutput "Test cow" -Message "Hello"
            $output | Should -Not -BeNullOrEmpty
        }
    }
    
    Context "Dynamic animation" {
        BeforeAll {
            $script:RestoreConfig = Get-DeepCopyConfig
            $cfg = Get-CFConfig
            $cfg.animation.mode = 'dynamic'
            $cfg.animation.duration = 1
            Set-CFConfig -Config $cfg
        }

        AfterAll {
            if ($script:RestoreConfig) { Set-CFConfig -Config $script:RestoreConfig -ErrorAction SilentlyContinue }
        }

        It "cycles through random cows and fortunes" {
            { Show-CFAnimation -CowOutput "Test cow" -Message "Hello" } | Should -Not -Throw
        }
    }

    Context "Physics animation" {
        BeforeAll {
            $script:RestoreConfig = Get-DeepCopyConfig
            $cfg = Get-CFConfig
            $cfg.animation.mode = 'physics'
            $cfg.animation.duration = 1
            Set-CFConfig -Config $cfg
        }

        AfterAll {
            if ($script:RestoreConfig) { Set-CFConfig -Config $script:RestoreConfig -ErrorAction SilentlyContinue }
        }

        It "runs without throwing" {
            { Show-CFAnimation -CowOutput "Test cow" -Message "Hello" } | Should -Not -Throw
        }
    }
}

Describe "Cross-Platform Behavior" -Tag 'Platform' {
    BeforeAll {
        if (-not (Get-Module Forgum)) { Import-Module $ModulePath -Force }
    }

    It "has platform-agnostic path handling" {
        $path = & (Get-Module Forgum | Where-Object ModuleType -eq Script | Select-Object -First 1) { Get-ConfigPath }
        $path | Should -Not -BeNullOrEmpty
        if ($IsLinux) { $path | Should -Match '/' }
        elseif ($IsMacOS) { $path | Should -Match '/' }
        else { $path | Should -Not -Match '/' }
    }

    It "module manifest loads correctly with correct encoding" {
        $manifest = Test-ModuleManifest -Path (Join-Path $ModuleRoot 'Forgum.psd1') -ErrorAction Stop
        $manifest.Version | Should -Not -BeNullOrEmpty
        $manifest.ExportedFunctions.Keys.Count | Should -BeGreaterOrEqual 7
    }
}

Describe "Format-CowMessage Alignment" -Tag 'Formatting' {
    BeforeAll {
        if (-not (Get-Module Forgum)) { Import-Module $ModulePath -Force }
    }
    It "correctly calculates width with tabs and invisible chars" {
        & (Get-Module Forgum | Where-Object ModuleType -eq Script | Select-Object -First 1) {
            # A fortune string with a tab and a zero-width space (\u200B)
            $trickyFortune = "A wise cow says:`tmoo." + [char]0x200B
            $output = Format-CowMessage -Text $trickyFortune -MaxWidth 40
            $lines = $output -split "`n"
            
            # Verify top and bottom borders have identical length
            $lines[0].Length | Should -Be $lines[-1].Length
            
            # Verify right side border '||' is perfectly aligned
            foreach ($line in $lines[1..($lines.Count-2)]) {
                $line.EndsWith('||') | Should -Be $true -Because "Line should end with ||: '$line'"
                $line.Length | Should -Be $lines[0].Length -Because "Line length $($line.Length) should match top border length $($lines[0].Length). Line: '$line', Top: '$($lines[0])'"
            }
        }
    }
}

Describe "Invoke-ForgumSetup" -Tag 'Setup' {
    BeforeAll {
        if (-not (Get-Module Forgum)) { Import-Module $ModulePath -Force }
    }
    It "exports Invoke-ForgumSetup" {
        Get-Command Invoke-ForgumSetup -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
    }
}

Describe "Update-Forgum" -Tag 'Update' {
    BeforeAll {
        if (-not (Get-Module Forgum)) { Import-Module $ModulePath -Force }
    }
    It "exports Update-Forgum" {
        Get-Command Update-Forgum -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
    }

    It "has a -Force parameter" {
        $params = (Get-Command Update-Forgum).Parameters
        $params.ContainsKey('Force') | Should -Be $true
        $params['Force'].ParameterType.Name | Should -Be 'SwitchParameter'
    }
}

Describe "Show-CFAnimation Cross-Platform Wrapper" -Tag 'Wrapper' {
    It "invokes forgum-engine binary for flagship modes when present" {
        $binPath = Join-Path $ModuleRoot "bin/forgum-engine.exe"
        if ($IsLinux -or $IsMacOS) { $binPath = Join-Path $ModuleRoot "bin/forgum-engine" }

        if (Test-Path $binPath) {
            # Let it run for real (will exit after 30 frames in CI or fast on local due to Show-CFAnimation defaults)
            $script:RestoreConfig = Get-DeepCopyConfig
            $cfg = Get-CFConfig
            $cfg.animation.mode = 'aurora'
            Set-CFConfig -Config $cfg
            { Show-CFAnimation -CowOutput "moo" -Message "real rendering test" } | Should -Not -Throw
            Set-CFConfig -Config $script:RestoreConfig
        } else {
            Set-ItResult -Inconclusive -Because "Rust engine binary not built/found at $binPath"
        }
    }

    It "falls back to physics mode if forgum-engine is missing for flagship modes" {
        Mock Test-Path { return $false } -ParameterFilter { $Path -like "*forgum-engine*" }
        $script:RestoreConfig = Get-DeepCopyConfig
        $cfg = Get-CFConfig
        $cfg.animation.mode = 'aurora'
        Set-CFConfig -Config $cfg

        $result = Show-CFAnimation -CowOutput "moo" -Message "test"
        # Since it runs via physics fallback or directly prints, it should not throw and typically returns an empty string
        $result | Should -Be ""
        Set-CFConfig -Config $script:RestoreConfig
    }
}

