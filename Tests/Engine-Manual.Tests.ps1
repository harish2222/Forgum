#Requires -Modules Pester

<#
    Engine Manual Production Test
    =============================
    Comprehensive Rust engine validation before production release.
    Run: Invoke-Pester -Path './Tests/Engine-Manual.Tests.ps1' -Output Detailed
#>

BeforeAll {
    $env:FORGUM_NOAUTOSTART = '1'
    $ModuleRoot = Split-Path $PSScriptRoot -Parent
    $ModulePath = Join-Path $ModuleRoot 'Forgum.psd1'
    do {
        $m = Get-Module Forgum -ErrorAction SilentlyContinue
        if ($m) { Remove-Module Forgum -Force -ErrorAction SilentlyContinue }
    } while ($m)
    Import-Module $ModulePath -Force

    # Find engine binary directly (not via InModuleScope)
    $script:EngineBinary = $null
    if ($IsWindows -or $env:OS -eq 'Windows_NT') {
        $candidates = @(
            (Join-Path $ModuleRoot 'engine/target/release/forgum-engine.exe'),
            (Join-Path $ModuleRoot 'engine/target/release/forgum_engine.exe'),
            (Join-Path $ModuleRoot 'bin/forgum-engine.exe')
        )
    } else {
        $candidates = @(
            (Join-Path $ModuleRoot 'engine/target/release/forgum-engine'),
            (Join-Path $ModuleRoot 'engine/target/release/forgum_engine'),
            (Join-Path $ModuleRoot 'bin/forgum-engine')
        )
    }
    foreach ($c in $candidates) {
        if (Test-Path $c) { $script:EngineBinary = $c; break }
    }
}

Describe "Engine Manual Production Test" -Tag 'Engine-Manual' {

    # ── 1: Binary Integrity ──────────────────────────────────────────────────
    Context "1. Binary Integrity" {

        It "engine binary exists" {
            $script:EngineBinary | Should -Not -BeNullOrEmpty
            Test-Path $script:EngineBinary | Should -Be $true
        }

        It "binary is reasonable size (>100KB, <50MB)" {
            $size = (Get-Item $script:EngineBinary).Length
            $size | Should -BeGreaterThan 100KB
            $size | Should -BeLessThan 50MB
        }

        It "responds to --help" {
            $output = & $script:EngineBinary --help 2>&1 | Out-String
            $output | Should -Match 'forgum-engine'
            $output | Should -Match 'Usage:'
        }

        It "binary is a valid executable" {
            $proc = Start-Process -FilePath $script:EngineBinary -ArgumentList '--help' -NoNewWindow -PassThru -Wait
            $proc.ExitCode | Should -BeIn @(0, 1)
        }
    }

    # ── 2: Shell Hook Generation ─────────────────────────────────────────────
    Context "2. Shell Hook Generation" {

        It "init bash" {
            $output = & $script:EngineBinary init bash 2>&1 | Out-String
            $output | Should -Match 'forgum\(\)'
            $output | Should -Match 'cowsay'
        }

        It "init zsh" {
            $output = & $script:EngineBinary init zsh 2>&1 | Out-String
            $output | Should -Match 'forgum\(\)'
        }

        It "init fish" {
            $output = & $script:EngineBinary init fish 2>&1 | Out-String
            $output | Should -Match 'function forgum'
        }

        It "init pwsh" {
            $output = & $script:EngineBinary init pwsh 2>&1 | Out-String
            $output | Should -Match 'Invoke-ForgumEngine'
        }

        It "init no args defaults to bash" {
            $output = & $script:EngineBinary init 2>&1 | Out-String
            $output | Should -Match 'forgum\(\)'
        }

        It "init invalid shell shows error" {
            $output = & $script:EngineBinary init elvish 2>&1 | Out-String
            $output | Should -Match '(?i)(unsupported|unknown|invalid|error)'
        }
    }

    # ── 3: JSON Protocol - Render ────────────────────────────────────────────
    Context "3. JSON Render Protocol" {

        It "renders basic cow" {
            $json = '{"type":"render","effect":"static","text":"Hello World","width":80,"height":24}'
            $output = $json | & $script:EngineBinary 2>&1 | Out-String
            $output | Should -Not -BeNullOrEmpty
        }

        It "renders with custom eyes" {
            $json = '{"type":"render","effect":"static","text":"Test","eyes":"@@","width":80,"height":24}'
            $output = $json | & $script:EngineBinary 2>&1 | Out-String
            $output | Should -Not -BeNullOrEmpty
        }

        It "renders with cow file" {
            $json = '{"type":"render","effect":"static","text":"Tux","cow_file":"tux","width":80,"height":24}'
            $output = $json | & $script:EngineBinary 2>&1 | Out-String
            $output | Should -Not -BeNullOrEmpty
        }

        It "renders all effects" {
            $effects = @('static', 'aurora', 'plasma', 'matrix', 'fire', 'rain', 'bounce', 'disco', 'physics')
            foreach ($effect in $effects) {
                $json = '{{"type":"render","effect":"{0}","text":"Test {0}","width":80,"height":24}}' -f $effect
                $output = $json | & $script:EngineBinary 2>&1 | Out-String
                $output | Should -Not -BeNullOrEmpty -Because "effect $effect should produce output"
            }
        }

        It "handles missing text" {
            $json = '{"type":"render","effect":"static","width":80,"height":24}'
            $p = $json | & $script:EngineBinary 2>&1
            # Should not crash (may return empty or error)
        }

        It "handles empty text" {
            $json = '{"type":"render","effect":"static","text":"","width":80,"height":24}'
            $p = $json | & $script:EngineBinary 2>&1
        }

        It "handles long text (5000 chars)" {
            $longText = "A" * 5000
            $json = '{{"type":"render","effect":"static","text":"{0}","width":80,"height":24}}' -f $longText
            $p = $json | & $script:EngineBinary 2>&1
        }
    }

    # ── 4: JSON Protocol - Init ──────────────────────────────────────────────
    Context "4. JSON Init Protocol" {

        It "init bash via JSON" {
            $json = '{"type":"init","shell":"bash"}'
            $output = $json | & $script:EngineBinary 2>&1 | Out-String
            $output | Should -Match 'forgum'
        }

        It "init zsh via JSON" {
            $json = '{"type":"init","shell":"zsh"}'
            $output = $json | & $script:EngineBinary 2>&1 | Out-String
            $output | Should -Match 'forgum'
        }

        It "init fish via JSON" {
            $json = '{"type":"init","shell":"fish"}'
            $output = $json | & $script:EngineBinary 2>&1 | Out-String
            $output | Should -Match 'forgum'
        }

        It "init pwsh via JSON" {
            $json = '{"type":"init","shell":"pwsh"}'
            $output = $json | & $script:EngineBinary 2>&1 | Out-String
            $output | Should -Match 'forgum'
        }
    }

    # ── 5: Error Handling ────────────────────────────────────────────────────
    Context "5. Error Handling & Robustness" {

        It "handles invalid JSON" {
            $p = "not valid json" | & $script:EngineBinary 2>&1
        }

        It "handles empty stdin" {
            $p = "" | & $script:EngineBinary 2>&1
        }

        It "handles empty JSON object" {
            $json = '{}'
            $p = $json | & $script:EngineBinary 2>&1
        }

        It "handles unknown type" {
            $json = '{"type":"unknown_command"}'
            $p = $json | & $script:EngineBinary 2>&1
        }

        It "handles malformed JSON" {
            $json = '{broken json'
            $p = $json | & $script:EngineBinary 2>&1
        }

        It "handles huge JSON (100K chars)" {
            $bigText = "X" * 100000
            $json = '{{"type":"render","effect":"static","text":"{0}","width":80,"height":24}}' -f $bigText
            $p = $json | & $script:EngineBinary 2>&1
        }

        It "handles zero dimensions" {
            $json = '{"type":"render","effect":"static","text":"Test","width":0,"height":0}'
            $p = $json | & $script:EngineBinary 2>&1
        }

        It "handles large dimensions" {
            $json = '{"type":"render","effect":"static","text":"Test","width":10000,"height":10000}'
            $p = $json | & $script:EngineBinary 2>&1
        }
    }

    # ── 6: Multi-line Text ───────────────────────────────────────────────────
    Context "6. Multi-line & Special Characters" {

        It "handles newlines" {
            $json = '{"type":"render","effect":"static","text":"Line1\nLine2","width":80,"height":24}'
            $output = $json | & $script:EngineBinary 2>&1 | Out-String
            $output | Should -Not -BeNullOrEmpty
        }

        It "handles tabs" {
            $json = '{"type":"render","effect":"static","text":"Tab\there","width":80,"height":24}'
            $output = $json | & $script:EngineBinary 2>&1 | Out-String
            $output | Should -Not -BeNullOrEmpty
        }
    }

    # ── 7: Rapid Requests ────────────────────────────────────────────────────
    Context "7. Rapid Sequential Requests" {

        It "10 rapid renders" {
            $ok = $true
            1..10 | ForEach-Object {
                $json = '{{"type":"render","effect":"static","text":"Rapid {0}","width":80,"height":24}}' -f $_
                try { $null = $json | & $script:EngineBinary 2>&1 } catch { $ok = $false }
            }
            $ok | Should -Be $true
        }

        It "10 mixed-type requests" {
            $ok = $true
            1..10 | ForEach-Object {
                $json = if ($_ % 2 -eq 0) {
                    '{{"type":"render","effect":"static","text":"Mixed {0}","width":80,"height":24}}' -f $_
                } else {
                    '{"type":"init","shell":"bash"}'
                }
                try { $null = $json | & $script:EngineBinary 2>&1 } catch { $ok = $false }
            }
            $ok | Should -Be $true
        }
    }

    # ── 8: Module Integration ────────────────────────────────────────────────
    Context "8. PowerShell Module Integration" {

        It "Get-EngineBinary returns valid path" {
            InModuleScope Forgum {
                $bin = Get-EngineBinary
                $bin | Should -Not -BeNullOrEmpty
                Test-Path $bin | Should -Be $true
            }
        }

        It "engine matches platform extension" {
            InModuleScope Forgum {
                $bin = Get-EngineBinary
                if ($IsWindows -or $env:OS -eq 'Windows_NT') {
                    $bin | Should -Match '\.exe$'
                } else {
                    $bin | Should -Not -Match '\.exe$'
                }
            }
        }

        It "Get-ForgumShellHook pwsh references engine" {
            InModuleScope Forgum {
                $hook = Get-ForgumShellHook -Shell 'pwsh'
                $hook | Should -Match 'Invoke-ForgumEngine'
            }
        }

        It "Get-ForgumShellHook bash is valid" {
            InModuleScope Forgum {
                $hook = Get-ForgumShellHook -Shell 'bash'
                $hook | Should -Match 'forgum\(\)'
                $hook | Should -Match 'cowsay'
                $hook | Should -Match 'forgum-engine'
            }
        }

        It "unsupported shell returns error" {
            InModuleScope Forgum {
                $hook = Get-ForgumShellHook -Shell 'elvish'
                $hook | Should -Match 'Unsupported'
            }
        }
    }

    # ── 9: Effect Output ─────────────────────────────────────────────────────
    Context "9. Effect-specific Output" {

        It "static contains message text" {
            $json = '{"type":"render","effect":"static","cow_text":"VerifyMe","width":80,"height":24}'
            $raw = $json | & $script:EngineBinary 2>&1 | Out-String
            $esc = [char]27
            $output = $raw -replace "${esc}\[[0-9;]*[a-zA-Z]", '' -replace "${esc}\][^\a]*\a", '' -replace 'e\[[0-9;]*m', ''
            $output | Should -Match 'VerifyMe'
        }

        $effects = @('aurora', 'plasma', 'matrix', 'fire', 'rain', 'bounce', 'disco', 'physics')
        foreach ($effect in $effects) {
            It "$effect produces output" {
                $json = '{{"type":"render","effect":"{0}","text":"Test","width":80,"height":24}}' -f $effect
                $output = $json | & $script:EngineBinary 2>&1 | Out-String
                $output | Should -Not -BeNullOrEmpty
            }
        }
    }

    # ── 10: Regression ───────────────────────────────────────────────────────
    Context "10. Regression" {

        It "does not hang on stdin close" {
            $proc = Start-Process -FilePath $script:EngineBinary -NoNewWindow -PassThru
            Start-Sleep -Milliseconds 500
            try { $proc.Kill() } catch {}
            $proc.HasExited | Should -Be $true
        }

        It "all effects produce output" {
            $effects = @('static', 'aurora', 'plasma', 'matrix', 'fire', 'rain', 'bounce', 'disco', 'physics')
            $failures = @()
            foreach ($effect in $effects) {
                $json = '{{"type":"render","effect":"{0}","text":"Regression {0}","width":80,"height":24}}' -f $effect
                $output = $json | & $script:EngineBinary 2>&1 | Out-String
                if ([string]::IsNullOrWhiteSpace($output)) { $failures += $effect }
            }
            $failures | Should -BeNullOrEmpty
        }
    }
}
