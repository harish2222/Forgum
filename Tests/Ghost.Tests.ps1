#Requires -Modules Pester

<#
    Ghost (Hostile QA) Tests
    Stress tests, boundary tests, and adversarial cases.
    Uses deep-copy config isolation.
#>

BeforeAll {
    $env:FORGUM_NOAUTOSTART = '1'
    $ModuleRoot = Split-Path $PSScriptRoot -Parent
    $ModulePath = Join-Path $ModuleRoot 'Forgum.psd1'
    Get-Module Forgum | Remove-Module Forgum -Force -ErrorAction SilentlyContinue
    Import-Module $ModulePath -Force
    $script:OriginalConfig = Get-CFConfig | ConvertTo-Json -Depth 10 | ConvertFrom-Json
    
    function Get-DeepCopyConfig {
        $config = Get-CFConfig
        return ($config | ConvertTo-Json -Depth 10 | ConvertFrom-Json)
    }
}

AfterAll {
    if ($script:OriginalConfig) {
        Set-CFConfig -Config $script:OriginalConfig -ErrorAction SilentlyContinue
    }
}

InModuleScope 'Forgum' {
Describe "Stress Tests" -Tag 'Stress' {
    It "handles 100 rapid config changes" {
        1..100 | ForEach-Object {
            $cfg = Get-CFConfig
            $cfg.lolcat.enabled = (-not $cfg.lolcat.enabled)
            Set-CFConfig -Config $cfg
        }
        $final = Get-CFConfig
        $final | Should -Not -BeNullOrEmpty
    }

    It "handles 50 rapid fortune requests" {
        $fortunes = 1..50 | ForEach-Object { Get-Fortune }
        $unique = $fortunes | Select-Object -Unique
        $unique.Count | Should -BeGreaterThan 1
    }

    It "handles 10 rapid cow renders" {
        $results = 1..10 | ForEach-Object {
            forgum "Test $_"
        }
        $results | Where-Object { -not $_ } | Should -BeNullOrEmpty
    }
}

Describe "Boundary Tests" -Tag 'Boundary' {
    It "handles zero-length text" {
        $output = forgum ""
        $output | Should -Not -BeNullOrEmpty
    }

    It "handles single character text" {
        $output = forgum "A"
        $output | Should -Not -BeNullOrEmpty
    }

    It "handles extremely long text (5000 chars)" {
        $longText = "A" * 5000
        $output = forgum $longText
        $output | Should -Not -BeNullOrEmpty
        $output.Length | Should -BeGreaterThan 100
    }
}

Describe "Content Injection Tests" -Tag 'Security' {
    It "handles ANSI escape sequences in text safely" {
        $injected = "Test`e[31mRed`e[0m"
        $output = forgum $injected
        $output | Should -Not -BeNullOrEmpty
    }

    It "handles path traversal in cow file names safely" {
        try {
            $output = forgum "Test" -CowFile '../../../etc/passwd'
            $output | Should -Not -Match 'root:'
            $output | Should -Not -Match '/bin/bash'
        }
        catch {
            $_.Exception.Message | Should -Match 'Cow file not found|not loaded|Invalid cow name|resolves outside'
        }
    }

    It "handles control characters in text" {
        $ctrl = "Test`n`r`t"
        $output = forgum $ctrl
        $output | Should -Not -BeNullOrEmpty
    }
}

Describe "Config Corruption Resilience" -Tag 'Resilience' {
    It "handles missing config file by creating default" {
        $configPath = InModuleScope Forgum { Get-ConfigPath }
        if (Test-Path $configPath) {
            $backup = Get-Content $configPath -Raw
            Remove-Item $configPath -Force
            try {
                InModuleScope Forgum { $script:ConfigCache = $null }
                $config = Get-CFConfig
                $config | Should -Not -BeNullOrEmpty
                $config.animation.mode | Should -Not -BeNullOrEmpty
            } finally {
                $backup | Set-Content $configPath
                InModuleScope Forgum { $script:ConfigCache = $null }
            }
        }
    }
}

Describe "Memory and Resource Tests" -Tag 'Resource' {
    BeforeAll {
        # Reset to static mode to avoid console issues
        $cfg = Get-DeepCopyConfig
        $cfg.animation.mode = 'static'
        Set-CFConfig -Config $cfg
    }

    AfterAll {
        if ($script:OriginalConfig) { Set-CFConfig -Config $script:OriginalConfig -ErrorAction SilentlyContinue }
    }

    It "does not leak memory on repeated calls" {
        $memStart = [System.GC]::GetTotalMemory($true)
        1..20 | ForEach-Object { forgum | Out-Null }
        $memEnd = [System.GC]::GetTotalMemory($true)
        $growth = $memEnd - $memStart
        $growth | Should -BeLessThan (50MB)
    }
}
}
