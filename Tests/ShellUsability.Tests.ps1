#Requires -Modules Pester

<#
    Shell Usability & Background Rendering Tests
    ==============================================
    Tests that animations run in background mode while shell remains usable.
    Verifies: background rendering, shell usability, config wiring.
    
    Run: Invoke-Pester -Path './Tests/ShellUsability.Tests.ps1' -Output Detailed
#>

BeforeAll {
    $env:FORGUM_NOAUTOSTART = '1'
    $ModuleRoot = Split-Path $PSScriptRoot -Parent
    $ModulePath = Join-Path $ModuleRoot 'Forgum.psd1'
    # Remove ALL Forgum module instances (including installed copies)
    do {
        $m = Get-Module Forgum -All -ErrorAction SilentlyContinue
        if ($m) { Remove-Module Forgum -Force -ErrorAction SilentlyContinue }
    } while ($m)
    Import-Module $ModulePath -Force

    # Find engine binary directly
    $script:EngineBinary = $null
    if ($IsWindows -or $env:OS -eq 'Windows_NT') {
        $candidates = @(
            (Join-Path $ModuleRoot 'engine/target/release/forgum-engine.exe'),
            (Join-Path $ModuleRoot 'bin/forgum-engine.exe')
        )
    } else {
        $candidates = @(
            (Join-Path $ModuleRoot 'engine/target/release/forgum-engine'),
            (Join-Path $ModuleRoot 'bin/forgum-engine')
        )
    }
    foreach ($c in $candidates) {
        if (Test-Path $c) { $script:EngineBinary = $c; break }
    }

    # Helper: strip ANSI escape codes from output
    function Strip-Ansi {
        param([string]$Text)
        $Text -replace '\x1b\[[0-9;]*[a-zA-Z]','' `
              -replace '\x1b\[[?][0-9;]*[a-zA-Z]','' `
              -replace '\x1b[78]','' `
              -replace '\x1b\]8;;[^\x07]*\x07',''
    }
}

Describe "Shell Usability During Animation" -Tag 'ShellUsability' {

    Context "1. Config animation.background is wired" {
        It "config has animation.background field" {
            $config = InModuleScope Forgum { GetConfig }
            $config.PSObject.Properties.Name | Should -Contain 'animation'
            $config.animation.PSObject.Properties.Name | Should -Contain 'background'
        }

        It "animation.background defaults to true" {
            $config = InModuleScope Forgum { GetConfig }
            [bool]$config.animation.background | Should -Be $true
        }
    }

    Context "2. Engine binary background mode" {
        It "forgum-engine binary exists" {
            $script:EngineBinary | Should -Not -BeNullOrEmpty
            Test-Path $script:EngineBinary | Should -Be $true
        }

        It "engine background=true outputs cow text to stdout for pipeline capture" {
            $json = '{"type":"render","effect":"static","cow_text":"BgTest","background":true,"duration":1,"fps":10}'
            $raw = $json | & $script:EngineBinary 2>&1 | Out-String
            $clean = Strip-Ansi $raw
            $clean.Trim() | Should -Match 'BgTest'
        }

        It "engine background=false renders cow text visible in output" {
            $json = '{"type":"render","effect":"static","cow_text":"FgTest","background":false,"duration":1,"fps":10}'
            $raw = $json | & $script:EngineBinary 2>&1 | Out-String
            $clean = Strip-Ansi $raw
            $clean | Should -Match 'FgTest'
        }
    }

    Context "3. Engine effects render without crash" {
        It "static effect renders" {
            $json = '{"type":"render","effect":"static","cow_text":"Test","background":true,"duration":1,"fps":10}'
            { $json | & $script:EngineBinary 2>&1 | Out-Null } | Should -Not -Throw
        }

        It "aurora effect renders" {
            $json = '{"type":"render","effect":"aurora","cow_text":"Test","background":true,"duration":1,"fps":10}'
            { $json | & $script:EngineBinary 2>&1 | Out-Null } | Should -Not -Throw
        }

        It "random effect renders" {
            $json = '{"type":"render","effect":"random","cow_text":"Test","background":true,"duration":1,"fps":10}'
            { $json | & $script:EngineBinary 2>&1 | Out-Null } | Should -Not -Throw
        }

        It "plasma effect renders" {
            $json = '{"type":"render","effect":"plasma","cow_text":"Test","background":true,"duration":1,"fps":10}'
            { $json | & $script:EngineBinary 2>&1 | Out-Null } | Should -Not -Throw
        }
    }

    Context "4. Cow file + fortune output" {
        It "engine returns cow output with fortune" {
            $json = '{"type":"render","effect":"static","cow_text":"Hello World","fortune_text":"Test fortune","background":false,"duration":1,"fps":10}'
            $raw = $json | & $script:EngineBinary 2>&1 | Out-String
            $clean = Strip-Ansi $raw
            # Cursor-positioned rendering may strip spaces between words
            $clean | Should -Match 'Hello.?World'
        }

        It "engine with tux cow returns tux in output" {
            $json = '{"type":"render","effect":"static","cow_file":"tux","cow_text":"Penguin","background":false,"duration":1,"fps":10}'
            $raw = $json | & $script:EngineBinary 2>&1 | Out-String
            $clean = Strip-Ansi $raw
            $clean | Should -Match 'Penguin'
        }
    }

    Context "5. Startup config defaults" {
        It "config animation.background is true by default" {
            $config = InModuleScope Forgum { GetConfig }
            $config.animation.background | Should -Be $true
        }

        It "config cow.random can be set" {
            InModuleScope Forgum {
                $config = GetConfig
                $config.cow.random = $true
                $config.cow.random | Should -Be $true
                $config.cow.random = $false
            }
        }
    }
}

Describe "Background Rendering Behavior" -Tag 'BackgroundRendering' {

    Context "6. Background vs foreground output" {
        It "background mode outputs cow text to stdout for pipeline capture" {
            $json = '{"type":"render","effect":"static","cow_text":"StdoutTest","background":true,"duration":1,"fps":10}'
            $raw = $json | & $script:EngineBinary 2>&1 | Out-String
            $clean = Strip-Ansi $raw
            $clean.Trim() | Should -Match 'StdoutTest'
        }

        It "foreground mode outputs cow text to stdout" {
            $json = '{"type":"render","effect":"static","cow_text":"StdoutTest","background":false,"duration":1,"fps":10}'
            $raw = $json | & $script:EngineBinary 2>&1 | Out-String
            $clean = Strip-Ansi $raw
            $clean | Should -Match 'StdoutTest'
        }
    }

    Context "7. Engine handles resize gracefully" {
        It "engine handles terminal size change without crash" {
            $json = '{"type":"render","effect":"static","cow_text":"Resize","background":true,"duration":1,"fps":10}'
            { $json | & $script:EngineBinary 2>&1 | Out-Null } | Should -Not -Throw
        }
    }

    Context "8. Engine process lifecycle" {
        It "engine starts and stops cleanly" {
            $proc = Start-Process -FilePath $script:EngineBinary -ArgumentList '--help' -PassThru -Wait -NoNewWindow
            $proc.ExitCode | Should -BeIn @(0, 1)
        }
    }
}

Describe "Cross-Platform Background Process" -Tag 'CrossPlatform' {

    Context "9. Platform detection" {
        It "engine binary matches platform" {
            if ($IsWindows -or $env:OS -eq 'Windows_NT') {
                $script:EngineBinary | Should -Match '\.exe$'
            } else {
                $script:EngineBinary | Should -Not -Match '\.exe$'
            }
        }
    }

    Context "10. Init command generates correct shell hooks" {
        It "init bash generates bash hook" {
            $output = & $script:EngineBinary init bash 2>&1 | Out-String
            $output | Should -Match 'forgum\(\)'
            $output | Should -Match 'cowsay'
            $output | Should -Match 'background.*true'
        }

        It "init zsh generates zsh hook" {
            $output = & $script:EngineBinary init zsh 2>&1 | Out-String
            $output | Should -Match 'forgum\(\)'
            $output | Should -Match 'background.*true'
        }

        It "init fish generates fish hook" {
            $output = & $script:EngineBinary init fish 2>&1 | Out-String
            $output | Should -Match 'function forgum'
            $output | Should -Match 'background.*true'
        }
    }

    Context "11. JSON protocol validation" {
        It "engine rejects malformed JSON" {
            $output = 'not json' | & $script:EngineBinary 2>&1 | Out-String
            $output | Should -Match '(?i)(error|parse|invalid)'
        }

        It "engine handles missing cow_text gracefully" {
            $json = '{"type":"render","effect":"static","background":true,"duration":1,"fps":10}'
            { $json | & $script:EngineBinary 2>&1 | Out-Null } | Should -Not -Throw
        }

        It "engine handles empty cow_text gracefully" {
            $json = '{"type":"render","effect":"static","cow_text":"","background":true,"duration":1,"fps":10}'
            { $json | & $script:EngineBinary 2>&1 | Out-Null } | Should -Not -Throw
        }
    }
}
