#Requires -Modules Forgum
<#
    Visual Cow Animation Test - 60 FPS, direct terminal render
    Run: pwsh -NoProfile -File Scripts\Test-AllCowAnimations.ps1
#>

$env:FORGUM_NOAUTOSTART = '1'
$ModuleRoot = Split-Path $PSScriptRoot -Parent
Import-Module "$ModuleRoot\Forgum.psd1" -Force

$EnginePath = Join-Path $ModuleRoot 'bin\forgum-engine.exe'
$CowsDir = Join-Path $ModuleRoot 'Data\Cows'
$Duration = 10
$FPS = 60

$Tests = @(
    @{ Cow = 'dragon';       Effect = 'fire' },
    @{ Cow = 'golden-eagle'; Effect = 'fly' },
    @{ Cow = 'cat';          Effect = 'liquid' },
    @{ Cow = 'sheep';        Effect = 'breathe' },
    @{ Cow = 'tux';          Effect = 'sway' },
    @{ Cow = 'dolphin';      Effect = 'squish' },
    @{ Cow = 'owl';          Effect = 'matrix' },
    @{ Cow = 'ghost';        Effect = 'dissolve' },
    @{ Cow = 'cthulhu-mini'; Effect = 'pulse' },
    @{ Cow = 'default';      Effect = 'static' }
)

function Get-CowText {
    param([string]$FilePath)
    $content = Get-Content $FilePath -Raw
    $lines = $content -split "`r?`n"
    $art = @()
    $capture = $false
    foreach ($line in $lines) {
        if ($line -match '^\s*EOC') { break }
        if ($capture) {
            # Strip Perl variable references ($thoughts, $eye, etc)
            $clean = $line -replace '\$thoughts', '  ' -replace '\$eye', 'oo' -replace '\$eyes', 'oo'
            $art += $clean
        }
        if ($line -match '^\$the_cow') { $capture = $true }
    }
    while ($art.Count -gt 0 -and $art[0].Trim() -eq '') { $art = $art[1..($art.Count-1)] }
    while ($art.Count -gt 0 -and $art[-1].Trim() -eq '') { $art = $art[0..($art.Count-2)] }
    return ($art -join "`n")
}

Write-Host "`n=== Forgum Visual Test: 10 Cows x ${Duration}s @ ${FPS}fps ===" -ForegroundColor Cyan

foreach ($t in $Tests) {
    $cow = $t.Cow
    $effect = $t.Effect
    $cowFile = Join-Path $CowsDir "$cow.cow"

    if (-not (Test-Path $cowFile)) {
        Write-Host "  SKIP $cow (not found)" -ForegroundColor Yellow
        continue
    }

    $cowText = Get-CowText -FilePath $cowFile
    if ([string]::IsNullOrWhiteSpace($cowText)) {
        Write-Host "  SKIP $cow (empty text)" -ForegroundColor Yellow
        continue
    }

    $json = @{
        type = 'render'; effect = $effect; cow_text = $cowText; cow_file = $cow
        width = 80; height = 24; background = $false
        duration = $Duration * $FPS; fps = $FPS
    } | ConvertTo-Json -Compress

    $tmpFile = Join-Path $env:TEMP "forgum_cowtest.json"
    [System.IO.File]::WriteAllText($tmpFile, $json)

    Write-Host "`n>>> $cow ($effect) - ${Duration}s @ ${FPS}fps <<<" -ForegroundColor Yellow

    $proc = [System.Diagnostics.Process]::new()
    $proc.StartInfo.FileName = $EnginePath
    $proc.StartInfo.Arguments = "--file `"$tmpFile`""
    $proc.StartInfo.UseShellExecute = $false
    $proc.StartInfo.CreateNoWindow = $false
    $proc.StartInfo.RedirectStandardOutput = $false
    $proc.StartInfo.RedirectStandardError = $false
    $null = $proc.Start()
    $proc.WaitForExit()

    Remove-Item $tmpFile -Force -ErrorAction SilentlyContinue
}

Write-Host "`n=== Done ===" -ForegroundColor Green
