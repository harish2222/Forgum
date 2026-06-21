#Requires -Modules Pester

<#
    Ghost (Hostile QA) Tests
    Stress tests, boundary tests, and adversarial cases.
    Uses deep-copy config isolation.
#>

$env:FORGUM_NOAUTOSTART = '1'
$ModuleRoot = Split-Path $PSScriptRoot -Parent
$ModulePath = Join-Path $ModuleRoot 'Forgum.psd1'
Get-Module Forgum | Remove-Module Forgum -Force -ErrorAction SilentlyContinue
Import-Module $ModulePath -Force

BeforeAll {
}

AfterAll {
}

InModuleScope 'Forgum' {
Describe "Stress Tests" -Tag 'Stress' {
    BeforeAll {
        InModuleScope Forgum {
            $cfg = GetConfig | ConvertTo-JsonSafe | ConvertFrom-Json
            $cfg.animation.mode = 'static'
            $cfg.cow.random = $false
            $cfg.cow.file = 'default'
            SetConfig -Config $cfg
        }
    }

    It "handles 100 rapid config changes" {
        1..100 | ForEach-Object {
            $cfg = GetConfig
            $cfg.lolcat.enabled = (-not $cfg.lolcat.enabled)
            SetConfig -Config $cfg
        }
        $final = GetConfig
        $final | Should -Not -BeNullOrEmpty
        $final.PSObject.Properties.Name | Should -Contain 'animation'
    }

    It "handles 50 rapid fortune requests" {
        $fortunes = 1..50 | ForEach-Object { GetFortune }
        $unique = $fortunes | Select-Object -Unique
        $unique.Count | Should -BeGreaterThan 1
    }

    It "handles 10 rapid cow renders" {
        $results = 1..10 | ForEach-Object {
            forgum run --mode static "RapidTest $_" 6>&1 | Out-String
        }
        foreach ($r in $results) {
            $clean = $r -replace 'e\[[0-9;]*[a-zA-Z]', '' -replace '\x1b\[[0-9;]*[a-zA-Z]', ''
            $clean | Should -Match 'RapidTest' -Because "each rapid render should produce cow text"
        }
    }
}

Describe "Boundary Tests" -Tag 'Boundary' {
    BeforeAll {
        InModuleScope Forgum {
            $cfg = GetConfig | ConvertTo-JsonSafe | ConvertFrom-Json
            $cfg.animation.mode = 'static'
            $cfg.cow.random = $false
            $cfg.cow.file = 'default'
            SetConfig -Config $cfg
        }
    }

    It "handles zero-length text" {
        $output = forgum run --mode static "" 6>&1 | Out-String
        $clean = $output -replace 'e\[[0-9;]*[a-zA-Z]', '' -replace '\x1b\[[0-9;]*[a-zA-Z]', ''
        $clean | Should -Match '\^__\^' -Because "empty text should still render cow art"
    }

    It "handles single character text" {
        $output = forgum run --mode static "X" 6>&1 | Out-String
        $clean = $output -replace 'e\[[0-9;]*[a-zA-Z]', '' -replace '\x1b\[[0-9;]*[a-zA-Z]', ''
        $clean | Should -Match 'X' -Because "single char text should appear in cow"
        $clean | Should -Match '\^__\^'
    }

    It "handles extremely long text (5000 chars)" {
        $longText = "LongTextTest " + ("A" * 5000)
        $output = forgum run --mode static $longText 6>&1 | Out-String
        $clean = $output -replace 'e\[[0-9;]*[a-zA-Z]', '' -replace '\x1b\[[0-9;]*[a-zA-Z]', ''
        $clean | Should -Match 'LongTextTest' -Because "long text should appear in cow"
        $output.Length | Should -BeGreaterThan 100
    }
}

Describe "Content Injection Tests" -Tag 'Security' {
    It "handles ANSI escape sequences in text safely" {
        $injected = "AnsiTest`e[31mRed`e[0m"
        $output = forgum run --mode static $injected 6>&1 | Out-String
        $clean = $output -replace 'e\[[0-9;]*[a-zA-Z]', '' -replace '\x1b\[[0-9;]*[a-zA-Z]', ''
        $clean | Should -Match 'AnsiTest' -Because "text with ANSI should still render"
    }

    It "handles path traversal in cow file names safely" {
        try {
            $output = forgum "Test" -CowFile '../../../etc/passwd' 6>&1 | Out-String
            $output | Should -Not -Match 'root:'
            $output | Should -Not -Match '/bin/bash'
        }
        catch {
            $_.Exception.Message | Should -Match 'Cow file not found|not loaded|Invalid cow name|resolves outside'
        }
    }

    It "handles control characters in text" {
        $ctrl = "ControlTest`n`r`t"
        $output = forgum run --mode static $ctrl 6>&1 | Out-String
        $clean = $output -replace 'e\[[0-9;]*[a-zA-Z]', '' -replace '\x1b\[[0-9;]*[a-zA-Z]', ''
        $clean | Should -Match 'ControlTest' -Because "text with control chars should still render"
    }
}

Describe "Config Corruption Resilience" -Tag 'Resilience' {
    It "handles missing config file by creating default" {
        $configPath = InModuleScope Forgum { GetConfigPath }
        if (Test-Path $configPath) {
            $backup = Get-Content $configPath -Raw
            Remove-Item $configPath -Force
            try {
                InModuleScope Forgum { $script:ConfigCache = $null }
                InModuleScope Forgum {
                    $config = GetConfig
                    $config | Should -Not -BeNullOrEmpty
                    $config.animation.mode | Should -Not -BeNullOrEmpty
                }
            } finally {
                $backup | Set-Content $configPath
                InModuleScope Forgum { $script:ConfigCache = $null }
            }
        }
    }
}

Describe "Memory and Resource Tests" -Tag 'Resource' {
    BeforeAll {
        InModuleScope Forgum {
            $cfg = GetConfig | ConvertTo-JsonSafe | ConvertFrom-Json
            $cfg.animation.mode = 'static'
            $cfg.cow.random = $false
            $cfg.cow.file = 'default'
            SetConfig -Config $cfg
        }
    }

    AfterAll {
        InModuleScope Forgum {
            $orig = GetConfig | ConvertTo-JsonSafe | ConvertFrom-Json
            SetConfig -Config $orig -ErrorAction SilentlyContinue
        }
    }

    It "does not leak memory on repeated calls" {
        $memStart = [System.GC]::GetTotalMemory($true)
        1..20 | ForEach-Object { forgum run --mode static 6>&1 | Out-Null }
        $memEnd = [System.GC]::GetTotalMemory($true)
        $growth = $memEnd - $memStart
        $growth | Should -BeLessThan (50MB)
    }
}
}
