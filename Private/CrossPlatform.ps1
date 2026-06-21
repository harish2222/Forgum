function GetPlatform {
    <#
    .SYNOPSIS
        Detects the current operating system platform.
    .DESCRIPTION
        Returns 'windows', 'macos', 'linux', or 'unknown'.
    #>
    if ($IsWindows -or $env:OS -eq 'Windows_NT') { return 'windows' }
    if ($IsMacOS) { return 'macos' }
    if ($IsLinux) { return 'linux' }
    return 'unknown'
}

function GetShell {
    <#
    .SYNOPSIS
        Detects the current shell.
    .DESCRIPTION
        Returns 'bash', 'zsh', 'fish', 'pwsh', 'powershell', or 'unknown'.
    #>
    if ($IsWindows -or $env:OS -eq 'Windows_NT') {
        if ($PSVersionTable.PSVersion.Major -ge 7) { return 'pwsh' }
        return 'powershell'
    }

    try {
        $proc = (Get-Process -Id $PPID -ErrorAction SilentlyContinue).Path
        if ($proc -match 'zsh')  { return 'zsh' }
        if ($proc -match 'fish') { return 'fish' }
        if ($proc -match 'bash') { return 'bash' }
    } catch {
        Write-Verbose "Non-critical error ignored"
    }

    $shellEnv = $env:SHELL
    if ($shellEnv -match 'zsh')  { return 'zsh' }
    if ($shellEnv -match 'fish') { return 'fish' }
    if ($shellEnv -match 'bash') { return 'bash' }

    return 'bash'
}

function GetForgumConfigPath {
    <#
    .SYNOPSIS
        Returns the config file path for the current platform.
    #>
    $platform = GetPlatform
    switch ($platform) {
        'windows' {
            $docPath = [Environment]::GetFolderPath('MyDocuments')
            return Join-Path $docPath 'PowerShell/Forgum/config.json'
        }
        default {
            return Join-Path $HOME '.config/Forgum/config.json'
        }
    }
}
