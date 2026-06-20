function Invoke-ForgumConfig {
    [CmdletBinding()]
    param([string[]]$Arguments = @())

    $parsed = Parse-ForgumArguments -Arguments $Arguments

    if ($parsed.Help) {
        Get-HelpMessage -Command 'config'
        return
    }

    $path = Get-ConfigPath
    $configDir = Split-Path $path -Parent

    if (-not (Test-Path $configDir)) {
        New-Item -ItemType Directory -Path $configDir -Force | Out-Null
    }

    if (-not (Test-Path $path)) {
        $defaultPath = Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) 'Data/Templates/default-config.json'
        if (Test-Path $defaultPath) {
            Copy-Item -Path $defaultPath -Destination $path -Force
        }
    }

    $action = if ($parsed.Text.Count -gt 0) { $parsed.Text[0] } else { 'open' }

    switch ($action.ToLower()) {
        'path' {
            Write-Output $path
        }
        'dir' {
            Write-Output $configDir
        }
        'show' {
            if (Test-Path $path) {
                Get-Content $path -Raw
            } else {
                Write-Warning "Config file not found: $path"
            }
        }
        default {
            Write-Output "Config file: $path"
            Write-Output ""

            if (Test-Path $path) {
                try {
                    Start-Process -FilePath $path -Verb Open -ErrorAction Stop
                    Write-Output "Opened config in default editor"
                }
                catch {
                    Write-Output "Could not open automatically. Config path:"
                    Write-Output "  $path"
                    Write-Output ""
                    Write-Output "Edit it manually or use: forgum config show"
                }
            } else {
                Write-Warning "Config file not found at: $path"
            }
        }
    }
}
