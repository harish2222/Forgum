function ThemeCommand {
    [CmdletBinding()]
    param([string[]]$Arguments = @())

    $parsed = ParseForgumArguments -Arguments $Arguments

    if ($parsed.Help) {
        GetHelpMessage -Command 'theme'
        return
    }

    $action = if ($parsed.Text.Count -gt 0) { $parsed.Text[0] } else { 'list' }
    $config = GetConfig

    $themes = @{
        'rainbow'   = @{ lolcat = $true;  frequency = 0.1; spread = 3.0; truecolor = $true }
        'fire'      = @{ lolcat = $true;  frequency = 0.05; spread = 2.0; truecolor = $true }
        'ocean'     = @{ lolcat = $true;  frequency = 0.15; spread = 4.0; truecolor = $true }
        'matrix'    = @{ lolcat = $true;  frequency = 0.08; spread = 1.5; truecolor = $true }
        'pastel'    = @{ lolcat = $true;  frequency = 0.12; spread = 5.0; truecolor = $true }
        'mono'      = @{ lolcat = $false; frequency = 0.1; spread = 3.0; truecolor = $true }
        'off'       = @{ lolcat = $false; frequency = 0.1; spread = 3.0; truecolor = $true }
    }

    switch ($action.ToLower()) {
        'list' {
            Write-Output "Available themes:"
            Write-Output ""
            foreach ($name in ($themes.Keys | Sort-Object)) {
                $enabled = $themes[$name].lolcat
                $status = if ($enabled) { 'on ' } else { 'off' }
                Write-Output "  [$status] $name"
            }
            Write-Output ""
            Write-Output "Current: $(if ($config.lolcat.enabled) { 'rainbow' } else { 'mono' })"
            Write-Output ""
            Write-Output "Use: forgum theme <name> to set a theme"
        }

        { $_ -in 'set', 'apply' } {
            $themeName = if ($parsed.Text.Count -gt 1) { $parsed.Text[1] } else { $null }
            if (-not $themeName -or -not $themes.ContainsKey($themeName)) {
                Write-Warning "Unknown theme: $themeName. Available: $($themes.Keys -join ', ')"
                return
            }
            $theme = $themes[$themeName]
            $config.lolcat.enabled = $theme.lolcat
            $config.lolcat.frequency = $theme.frequency
            $config.lolcat.spread = $theme.spread
            $config.lolcat.truecolor = $theme.truecolor
            SetConfig -Config $config
            Write-Output "Theme set to: $themeName"
        }

        'reset' {
            $defaultPath = Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) 'Data/Templates/default-config.json'
            $default = Get-Content $defaultPath -Raw | ConvertFrom-Json
            $config.lolcat = $default.lolcat
            if ($default.PSObject.Properties['animation']) { $config.animation = $default.animation }
            if ($default.PSObject.Properties['cow']) { $config.cow = $default.cow }
            if ($default.PSObject.Properties['cowsay']) { $config.cowsay = $default.cowsay }
            if ($default.PSObject.Properties['theme']) { $config.theme = $default.theme }
            SetConfig -Config $config
            Write-Output "Theme reset to default (mono)"
        }

        default {
            Write-Warning "Unknown theme action: $action. Use: list, set <name>, or reset"
        }
    }
}
