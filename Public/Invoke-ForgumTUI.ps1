function Invoke-ForgumTUI {
    <#
    .SYNOPSIS
        Opens an interactive Terminal User Interface (TUI) to configure Forgum.
    .DESCRIPTION
        Displays a navigable TUI using cursor keys to toggle Forgum options
        and regenerate your shell profile integration.
    .EXAMPLE
        Invoke-ForgumTUI
    #>
    [CmdletBinding()]
    param()

    $config = Get-CFConfig
    
    # Defaults for profile settings
    $fortuneOnStartup = $true
    $addAliases = $true
    $addCompletion = $true

    $cows = Get-CFCow
    $animModes = @('static', 'dynamic', 'talking', 'typewriter', 'rainbow', 'fade', 'bounce', 'pulse', 'slide', 'blink', 'scroll')

    $menuItems = @(
        @{ Name="Fortune on Startup"; Type="bool"; Value=$fortuneOnStartup },
        @{ Name="Lolcat Rainbow"; Type="bool"; Value=[bool]$config.lolcat.enabled },
        @{ Name="Default Cow"; Type="list"; Options=$cows; Value=$config.cow.file },
        @{ Name="Animation Mode"; Type="list"; Options=$animModes; Value=$config.animation.mode },
        @{ Name="Daily Auto-Update"; Type="bool"; Value=[bool]$config.update.autoCheck },
        @{ Name="Shell Aliases"; Type="bool"; Value=$addAliases },
        @{ Name="Tab Completion"; Type="bool"; Value=$addCompletion },
        @{ Name="Save & Apply"; Type="action" },
        @{ Name="Cancel"; Type="action" }
    )

    $selectedIndex = 0
    $running = $true
    $oldCursorVisible = [Console]::CursorVisible
    [Console]::CursorVisible = $false

    try {
        while ($running) {
            Clear-Host
            Write-Host "======================================" -ForegroundColor Cyan
            Write-Host " Forgum Configuration TUI" -ForegroundColor Magenta
            Write-Host "======================================" -ForegroundColor Cyan
            Write-Host "Use Up/Down to navigate." -ForegroundColor Gray
            Write-Host "Use Left/Right or Space/Enter to change." -ForegroundColor Gray
            Write-Host ""

            for ($i = 0; $i -lt $menuItems.Count; $i++) {
                $item = $menuItems[$i]
                $prefix = if ($i -eq $selectedIndex) { "> " } else { "  " }
                $fg = if ($i -eq $selectedIndex) { "Yellow" } else { "White" }

                if ($item.Type -eq "bool") {
                    $valStr = if ($item.Value) { "[ON]" } else { "[OFF]" }
                    Write-Host "$prefix $($item.Name.PadRight(20)) : $valStr" -ForegroundColor $fg
                } elseif ($item.Type -eq "list") {
                    Write-Host "$prefix $($item.Name.PadRight(20)) : < $($item.Value) >" -ForegroundColor $fg
                } elseif ($item.Type -eq "action") {
                    Write-Host "$prefix [$($item.Name)]" -ForegroundColor $fg
                }
            }

            $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            
            switch ($key.VirtualKeyCode) {
                38 { # Up
                    $selectedIndex--
                    if ($selectedIndex -lt 0) { $selectedIndex = $menuItems.Count - 1 }
                }
                40 { # Down
                    $selectedIndex++
                    if ($selectedIndex -ge $menuItems.Count) { $selectedIndex = 0 }
                }
                37 { # Left
                    $item = $menuItems[$selectedIndex]
                    if ($item.Type -eq "bool") {
                        $item.Value = -not $item.Value
                    } elseif ($item.Type -eq "list") {
                        $idx = [Array]::IndexOf($item.Options, $item.Value)
                        $idx--
                        if ($idx -lt 0) { $idx = $item.Options.Count - 1 }
                        $item.Value = $item.Options[$idx]
                    }
                }
                39 { # Right
                    $item = $menuItems[$selectedIndex]
                    if ($item.Type -eq "bool") {
                        $item.Value = -not $item.Value
                    } elseif ($item.Type -eq "list") {
                        $idx = [Array]::IndexOf($item.Options, $item.Value)
                        $idx++
                        if ($idx -ge $item.Options.Count) { $idx = 0 }
                        $item.Value = $item.Options[$idx]
                    }
                }
                13 { # Enter
                    $item = $menuItems[$selectedIndex]
                    if ($item.Type -eq "bool") {
                        $item.Value = -not $item.Value
                    } elseif ($item.Type -eq "list") {
                        $idx = [Array]::IndexOf($item.Options, $item.Value)
                        $idx++
                        if ($idx -ge $item.Options.Count) { $idx = 0 }
                        $item.Value = $item.Options[$idx]
                    } elseif ($item.Type -eq "action") {
                        if ($item.Name -eq "Cancel") {
                            $running = $false
                        } elseif ($item.Name -eq "Save & Apply") {
                            $running = $false
                            $config.lolcat.enabled = $menuItems[1].Value
                            $config.cow.file = $menuItems[2].Value
                            $config.animation.mode = $menuItems[3].Value
                            $config.update.autoCheck = $menuItems[4].Value
                            Set-CFConfig -Config $config

                            Set-ForgumProfile -FortuneOnStartup $menuItems[0].Value `
                                              -AddAliases $menuItems[5].Value `
                                              -AddCompletion $menuItems[6].Value
                        }
                    }
                }
                32 { # Space
                    $item = $menuItems[$selectedIndex]
                    if ($item.Type -eq "bool") {
                        $item.Value = -not $item.Value
                    } elseif ($item.Type -eq "list") {
                        $idx = [Array]::IndexOf($item.Options, $item.Value)
                        $idx++
                        if ($idx -ge $item.Options.Count) { $idx = 0 }
                        $item.Value = $item.Options[$idx]
                    } elseif ($item.Type -eq "action") {
                        if ($item.Name -eq "Cancel") {
                            $running = $false
                        } elseif ($item.Name -eq "Save & Apply") {
                            $running = $false
                            $config.lolcat.enabled = $menuItems[1].Value
                            $config.cow.file = $menuItems[2].Value
                            $config.animation.mode = $menuItems[3].Value
                            $config.update.autoCheck = $menuItems[4].Value
                            Set-CFConfig -Config $config

                            Set-ForgumProfile -FortuneOnStartup $menuItems[0].Value `
                                              -AddAliases $menuItems[5].Value `
                                              -AddCompletion $menuItems[6].Value
                        }
                    }
                }
                27 { # Escape
                    $running = $false
                }
            }
        }
    } finally {
        [Console]::CursorVisible = $oldCursorVisible
        Clear-Host
    }
}
