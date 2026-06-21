function InvokeForgumTUI {
    <#
    .SYNOPSIS
        Launches the interactive configuration TUI.
    .DESCRIPTION
        Opens an interactive terminal menu for editing Forgum configuration.
        Navigate with arrow keys or number input, press Enter to select.
    #>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
    param()

    $config = GetConfig

    while ($true) {
        Clear-Host
        Write-Host "=== Forgum Configuration TUI ===" -ForegroundColor Cyan
        Write-Host ""

        Write-Host "  Current Settings:" -ForegroundColor Yellow
        Write-Host "    Animation:  $($config.animation.mode)" -ForegroundColor White
        Write-Host "    Cow file:   $($config.cow.file)" -ForegroundColor White
        Write-Host "    Eyes:       $($config.cow.eyes)" -ForegroundColor White
        Write-Host "    Tongue:     $($config.cow.tongue)" -ForegroundColor White
        Write-Host "    Lolcat:     $(if ($config.lolcat.enabled) { 'ON' } else { 'OFF' })" -ForegroundColor $(if ($config.lolcat.enabled) { 'Green' } else { 'Gray' })
        Write-Host "    Random cow: $(if ($config.cow.random) { 'ON' } else { 'OFF' })" -ForegroundColor $(if ($config.cow.random) { 'Green' } else { 'Gray' })
        Write-Host ""

        Write-Host "  Options:" -ForegroundColor Yellow
        Write-Host "    [1] Change animation mode" -ForegroundColor White
        Write-Host "    [2] Change cow file" -ForegroundColor White
        Write-Host "    [3] Change cow eyes" -ForegroundColor White
        Write-Host "    [4] Change cow tongue" -ForegroundColor White
        Write-Host "    [5] Toggle lolcat (rainbow)" -ForegroundColor White
        Write-Host "    [6] Toggle random cow" -ForegroundColor White
        Write-Host "    [7] Reset to defaults" -ForegroundColor White
        Write-Host "    [8] Open config file" -ForegroundColor White
        Write-Host "    [0] Exit" -ForegroundColor Gray
        Write-Host ""

        $choice = Read-Host "  Select option"

        switch ($choice) {
            '1' {
                Clear-Host
                Write-Host "=== Animation Modes ===" -ForegroundColor Cyan
                Write-Host ""
                Write-Host "  Flagship (Rust-powered):" -ForegroundColor Yellow
                $flagship = @('aurora', 'plasma', 'ember', 'liquid-chrome', 'shatter', 'portal', 'glitch', 'neon-pulse')
                for ($i = 0; $i -lt $flagship.Count; $i++) {
                    $mark = if ($config.animation.mode -eq $flagship[$i]) { '*' } else { ' ' }
                    Write-Host "    [$mark] $($flagship[$i])" -ForegroundColor White
                }
                Write-Host ""
                Write-Host "  Legacy (PowerShell):" -ForegroundColor Yellow
                $legacy = @('static', 'talking', 'typewriter', 'bounce', 'wave', 'wiggle', 'dissolve', 'fade-in', 'slide-in', 'disco', 'blink', 'dynamic', 'procedural', 'physics')
                for ($i = 0; $i -lt $legacy.Count; $i++) {
                    $mark = if ($config.animation.mode -eq $legacy[$i]) { '*' } else { ' ' }
                    Write-Host "    [$mark] $($legacy[$i])" -ForegroundColor White
                }
                Write-Host ""
                Write-Host "  Special:" -ForegroundColor Yellow
                Write-Host "    [ ] random" -ForegroundColor White
                Write-Host ""
                $newMode = Read-Host "  Enter mode name"
                if ($newMode) {
                    $config.animation.mode = $newMode
                    SetConfig -Config $config -Confirm:$false
                    Write-Host "  Set to: $newMode" -ForegroundColor Green
                    Start-Sleep -Milliseconds 500
                }
            }
            '2' {
                Clear-Host
                Write-Host "=== Cow Files ===" -ForegroundColor Cyan
                $cowsPath = Join-Path (Split-Path $PSScriptRoot -Parent) 'Data/Cows'
                $cows = Get-ChildItem -Path $cowsPath -Filter '*.cow' -ErrorAction SilentlyContinue |
                    Select-Object -ExpandProperty BaseName |
                    Sort-Object
                $cowArray = @($cows)
                for ($i = 0; $i -lt $cowArray.Count; $i++) {
                    $mark = if ($config.cow.file -eq $cowArray[$i]) { '*' } else { ' ' }
                    Write-Host "    [$mark] $($cowArray[$i])" -ForegroundColor White
                }
                Write-Host ""
                $newCow = Read-Host "  Enter cow name"
                if ($newCow) {
                    $config.cow.file = $newCow
                    SetConfig -Config $config -Confirm:$false
                    Write-Host "  Set to: $newCow" -ForegroundColor Green
                    Start-Sleep -Milliseconds 500
                }
            }
            '3' {
                Clear-Host
                Write-Host "=== Cow Eyes ===" -ForegroundColor Cyan
                Write-Host ""
                Write-Host "  Presets:" -ForegroundColor Yellow
                Write-Host "    borg       ==" -ForegroundColor White
                Write-Host "    dead       xx" -ForegroundColor White
                Write-Host "    greedy     $$" -ForegroundColor White
                Write-Host "    paranoia   @@" -ForegroundColor White
                Write-Host "    stoned     **" -ForegroundColor White
                Write-Host "    tired      --" -ForegroundColor White
                Write-Host "    wasted     OO" -ForegroundColor White
                Write-Host "    youthful   .." -ForegroundColor White
                Write-Host ""
                Write-Host "  Or type 2 custom characters (e.g. @@)" -ForegroundColor Gray
                Write-Host ""
                $newEyes = Read-Host "  Enter eyes"
                if ($newEyes) {
                    $presets = @{
                        'borg' = '=='; 'dead' = 'xx'; 'greedy' = '$$';
                        'paranoia' = '@@'; 'stoned' = '**'; 'tired' = '--';
                        'wasted' = 'OO'; 'youthful' = '..'
                    }
                    $resolved = if ($presets.ContainsKey($newEyes)) { $presets[$newEyes] } else { $newEyes }
                    if ($resolved.Length -eq 2) {
                        $config.cow.eyes = $resolved
                        SetConfig -Config $config -Confirm:$false
                        Write-Host "  Set to: $resolved" -ForegroundColor Green
                    } else {
                        Write-Warning "Eyes must be exactly 2 characters"
                    }
                    Start-Sleep -Milliseconds 500
                }
            }
            '4' {
                Clear-Host
                Write-Host "=== Cow Tongue ===" -ForegroundColor Cyan
                Write-Host ""
                $newTongue = Read-Host "  Enter 2 characters for tongue (or spaces for none)"
                if ($newTongue -and $newTongue.Length -eq 2) {
                    $config.cow.tongue = $newTongue
                    SetConfig -Config $config -Confirm:$false
                    Write-Host "  Set to: $newTongue" -ForegroundColor Green
                } elseif ($newTongue) {
                    Write-Warning "Tongue must be exactly 2 characters"
                }
                Start-Sleep -Milliseconds 500
            }
            '5' {
                $config.lolcat.enabled = -not $config.lolcat.enabled
                SetConfig -Config $config -Confirm:$false
                $state = if ($config.lolcat.enabled) { 'ON' } else { 'OFF' }
                Write-Host "  Lolcat: $state" -ForegroundColor $(if ($config.lolcat.enabled) { 'Green' } else { 'Gray' })
                Start-Sleep -Milliseconds 500
            }
            '6' {
                $config.cow.random = -not $config.cow.random
                SetConfig -Config $config -Confirm:$false
                $state = if ($config.cow.random) { 'ON' } else { 'OFF' }
                Write-Host "  Random cow: $state" -ForegroundColor $(if ($config.cow.random) { 'Green' } else { 'Gray' })
                Start-Sleep -Milliseconds 500
            }
            '7' {
                $confirm = Read-Host "  Reset all settings to defaults? (y/n)"
                if ($confirm -eq 'y') {
                    $defaultPath = Join-Path (Split-Path $PSScriptRoot -Parent) 'Data/Templates/default-config.json'
                    $config = Get-Content $defaultPath -Raw | ConvertFrom-Json
                    SetConfig -Config $config -Confirm:$false
                    Write-Host "  Reset to defaults" -ForegroundColor Green
                    Start-Sleep -Milliseconds 500
                }
            }
            '8' {
                $path = GetConfigPath
                if (Test-Path $path) {
                    Start-Process -FilePath $path -Verb Open -ErrorAction SilentlyContinue
                    Write-Host "  Opened config file" -ForegroundColor Green
                } else {
                    Write-Warning "Config file not found"
                }
                Start-Sleep -Milliseconds 500
            }
            '0' {
                break
            }
            default {
                Write-Host "  Invalid option" -ForegroundColor Red
                Start-Sleep -Milliseconds 500
            }
        }
    }

    Clear-Host
    Write-Host "Config saved. Run 'forgum' to see your changes!" -ForegroundColor Green
}
