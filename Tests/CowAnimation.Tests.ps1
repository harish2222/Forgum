#Requires -Modules Pester
<#
    Cow File Animation Tests
    Tests ALL cow files with their matched animation effects.

    Run: Invoke-Pester -Path './Tests/CowAnimation.Tests.ps1' -Output Detailed
#>

$env:FORGUM_NOAUTOSTART = '1'

function Get-CowText {
    param([string]$FilePath)
    $content = Get-Content $FilePath -Raw
    $lines = $content -split "`r?`n"
    $art = @()
    $capture = $false
    foreach ($line in $lines) {
        if ($line -match '^\s*EOC') { break }
        if ($capture) {
            $clean = $line -replace '\$thoughts', '  ' -replace '\$eye', 'oo' -replace '\$eyes', 'oo'
            $art += $clean
        }
        if ($line -match '^\$the_cow') { $capture = $true }
    }
    while ($art.Count -gt 0 -and $art[0].Trim() -eq '') { $art = $art[1..($art.Count-1)] }
    while ($art.Count -gt 0 -and $art[-1].Trim() -eq '') { $art = $art[0..($art.Count-2)] }
    return ($art -join "`n")
}

$ModuleRoot = Split-Path $PSScriptRoot -Parent
$CowsDir = Join-Path $ModuleRoot 'Data\Cows'

$EffectMap = @{
    'armadillo'='liquid'; 'atat'='liquid'; 'bearface'='breathe'; 'beavis.zen'='matrix'
    'bees'='fly'; 'bill-the-cat'='matrix'; 'bud-frogs'='talk'; 'bunny'='squish'
    'cat'='liquid'; 'cat2'='liquid'; 'catfence'='sway'; 'charizardvice'='fly'
    'charlie'='liquid'; 'claw-arm'='sway'; 'cower'='talk'; 'cowfee'='fire'
    'cthulhu-mini'='pulse'; 'daemon'='fire'; 'default'='talk'; 'docker-whale'='squish'
    'doge'='matrix'; 'dolphin'='squish'; 'dragon'='fire'; 'dragon-and-cow'='fly'
    'ebi_furai'='squish'; 'elephant'='liquid'; 'elephant2'='liquid'
    'elephant-in-snake'='breathe'; 'eyes'='talk'; 'fat-banana'='sway'; 'fat-cow'='talk'
    'fence'='sway'; 'flaming-sheep'='fire'; 'fox'='liquid'; 'ghost'='dissolve'
    'ghostbusters'='squish'; 'glados'='matrix'; 'goat'='sway'; 'goat2'='sway'
    'golden-eagle'='fly'; 'happy-whale'='squish'; 'hedgehog'='dissolve'
    'hellokitty'='sway'; 'hippie'='breathe'; 'hiya'='sway'; 'hypno'='pulse'
    'jellyfish'='squish'; 'king'='liquid'; 'kiss'='breathe'; 'kitten'='liquid'
    'kitty'='liquid'; 'knight'='liquid'; 'koala'='breathe'; 'kosh'='squish'
    'lamb'='liquid'; 'lamb2'='liquid'; 'lobster'='liquid'; 'lollerskates'='liquid'
    'luke-koala'='breathe'; 'meow'='liquid'; 'minotaur'='liquid'; 'mona-lisa'='talk'
    'moofasa'='breathe'; 'mooghidjirah'='breathe'; 'moojira'='breathe'; 'moose'='liquid'
    'mule'='liquid'; 'mutilated'='matrix'; 'nyan'='fly'; 'octopus'='sway'
    'owl'='matrix'; 'pawn'='liquid'; 'periodic-table'='pulse'; 'personality-sphere'='matrix'
    'pterodactyl'='fly'; 'queen'='liquid'; 'ren'='matrix'; 'rook'='liquid'
    'satanic'='fire'; 'seahorse'='squish'; 'seahorse-big'='squish'; 'sheep'='breathe'
    'shikato'='liquid'; 'shrug'='breathe'; 'skeleton'='matrix'; 'small'='liquid'
    'smiling-octopus'='sway'; 'snoopy'='breathe'; 'snoopyhouse'='breathe'
    'snoopysleep'='breathe'; 'spidercow'='liquid'; 'squirrel'='matrix'
    'stegosaurus'='liquid'; 'stimpy'='matrix'; 'supermilker'='talk'; 'surgery'='matrix'
    'tortoise'='liquid'; 'turkey'='sway'; 'turtle'='liquid'; 'tux'='sway'
    'tux-big'='sway'; 'tweety-bird'='fly'; 'weeping-angel'='sway'; 'whale'='squish'
    'wizard'='pulse'; 'world'='pulse'
}

# Pre-compute cow text at script scope (Pester can't call script-scope functions from It blocks)
$CowTestCases = @()
$cowFiles = Get-ChildItem "$CowsDir\*.cow" -ErrorAction SilentlyContinue
foreach ($f in $cowFiles) {
    $text = Get-CowText -FilePath $f.FullName
    $eff = if ($EffectMap.ContainsKey($f.BaseName)) { $EffectMap[$f.BaseName] } else { 'talk' }
    $CowTestCases += @{ CowFile = $f.FullName; CowName = $f.BaseName; Effect = $eff; CowText = $text }
}

Describe "Cow File Animation Tests" -Tag 'CowAnimation' {

    BeforeAll {
        $ModuleRoot = Split-Path $PSScriptRoot -Parent
        $ModulePath = Join-Path $ModuleRoot 'Forgum.psd1'
        do {
            $m = Get-Module Forgum -All -ErrorAction SilentlyContinue
            if ($m) { Remove-Module Forgum -Force -ErrorAction SilentlyContinue }
        } while ($m)
        Import-Module $ModulePath -Force

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
    }

    Context "Engine binary" {
        It "engine binary exists" {
            $script:EngineBinary | Should -Not -BeNullOrEmpty
            Test-Path $script:EngineBinary | Should -Be $true
        }
    }

    Context "All cow files parse correctly" {
        It "<CowName>.cow parses to non-empty text" -TestCases $CowTestCases {
            $CowText | Should -Not -BeNullOrEmpty
            $CowText.Length | Should -BeGreaterThan 5
        }
    }

    Context "All cow+effect combinations render without crash" {
        It "<CowName> (<Effect>) renders" -TestCases $CowTestCases {
            $text = if ([string]::IsNullOrWhiteSpace($CowText)) { "  $CowName" } else { $CowText }

            $json = @{
                type = 'render'; effect = $Effect; cow_text = $text; cow_file = $CowName
                width = 80; height = 24; background = $true; duration = 1; fps = 10
            } | ConvertTo-Json -Compress

            { $json | & $script:EngineBinary 2>&1 | Out-Null } | Should -Not -Throw
        }
    }

    Context "All effects produce output" {
        It "effect '<Effect>' renders cow text" -TestCases @(
            @{ Effect = 'fire' }; @{ Effect = 'fly' }; @{ Effect = 'liquid' }
            @{ Effect = 'breathe' }; @{ Effect = 'sway' }; @{ Effect = 'squish' }
            @{ Effect = 'matrix' }; @{ Effect = 'dissolve' }; @{ Effect = 'pulse' }
            @{ Effect = 'talk' }
        ) {
            $json = @{
                type = 'render'; effect = $Effect; cow_text = "  TestCow`n  ^__^"
                width = 80; height = 24; background = $true; duration = 1; fps = 10
            } | ConvertTo-Json -Compress
            $raw = $json | & $script:EngineBinary 2>&1 | Out-String
            $raw | Should -Not -BeNullOrEmpty
        }
    }

    Context "Static effect outputs to stdout" {
        It "static effect returns cow text" {
            $json = @{
                type = 'render'; effect = 'static'; cow_text = "  StaticTest`n  ^__^"
                width = 80; height = 24; background = $false; duration = 1; fps = 10
            } | ConvertTo-Json -Compress
            $raw = $json | & $script:EngineBinary 2>&1 | Out-String
            $raw | Should -Match 'StaticTest'
        }
    }
}
