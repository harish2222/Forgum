# Forgum Test Runner
# Usage: pwsh -File run_tests_final.ps1

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
param()

$ErrorActionPreference = 'Stop'
$env:FORGUM_NOAUTOSTART = '1'

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Forgum Test Suite Runner" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check Pester version
$pester = Get-Module -ListAvailable -Name Pester | Where-Object { $_.Version.Major -ge 5 } | Select-Object -First 1
if (-not $pester) {
    Write-Host "Pester 5.7+ required. Installing..." -ForegroundColor Yellow
    Install-Module -Name Pester -Force -SkipPublisherCheck -Scope CurrentUser -MinimumVersion 5.7.0 -MaximumVersion 5.99.99
    $pester = Get-Module -ListAvailable -Name Pester | Where-Object { $_.Version.Major -ge 5 } | Select-Object -First 1
}

Write-Host "Pester version: $($pester.Version)" -ForegroundColor Green

# Import module
$ModuleRoot = $PSScriptRoot
$ModulePath = Join-Path $ModuleRoot 'Forgum.psd1'

if (-not (Test-Path $ModulePath)) {
    Write-Host "Module manifest not found: $ModulePath" -ForegroundColor Red
    exit 1
}

Import-Module $ModulePath -Force
Write-Host "Module imported: Forgum v$((Get-Module Forgum).Version)" -ForegroundColor Green
Write-Host ""

# Run tests
$config = New-PesterConfiguration
$config.Run.Path = './Tests'
$config.Run.PassThru = $true
$config.Output.Verbosity = 'Detailed'

$results = Invoke-Pester -Configuration $config

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Results Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Total:   $($results.TotalCount)" -ForegroundColor White
Write-Host "Passed:  $($results.PassedCount)" -ForegroundColor Green
Write-Host "Failed:  $($results.FailedCount)" -ForegroundColor $(if ($results.FailedCount -gt 0) { 'Red' } else { 'Green' })
Write-Host "Skipped: $($results.SkippedCount)" -ForegroundColor Yellow
Write-Host "Duration: $($results.Duration)" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Cyan

if ($results.FailedCount -gt 0) {
    Write-Host ""
    Write-Host "Failed Tests:" -ForegroundColor Red
    $results.TestResult | Where-Object Result -eq 'Failed' | ForEach-Object {
        Write-Host "  - $($_.Name)" -ForegroundColor Red
        Write-Host "    $($_.ErrorRecord.DisplayErrorMessage)" -ForegroundColor DarkRed
    }
    exit 1
}

Write-Host ""
Write-Host "All tests passed!" -ForegroundColor Green
exit 0
