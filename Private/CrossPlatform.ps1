function Get-ForgumPlatform {
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

function Get-ForgumShell {
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
    } catch {}

    $shellEnv = $env:SHELL
    if ($shellEnv -match 'zsh')  { return 'zsh' }
    if ($shellEnv -match 'fish') { return 'fish' }
    if ($shellEnv -match 'bash') { return 'bash' }

    return 'bash'
}

function Get-ForgumProfilePath {
    <#
    .SYNOPSIS
        Returns the shell profile path for the current platform.
    #>
    $platform = Get-ForgumPlatform
    $shell = Get-ForgumShell

    switch ($platform) {
        'windows' {
            $docPath = [Environment]::GetFolderPath('MyDocuments')
            if ($PSVersionTable.PSVersion.Major -ge 7) {
                return Join-Path $docPath 'PowerShell/Microsoft.PowerShell_profile.ps1'
            }
            return Join-Path $docPath 'WindowsPowerShell/Microsoft.PowerShell_profile.ps1'
        }
        default {
            switch ($shell) {
                'fish' { return Join-Path $HOME '.config/fish/config.fish' }
                'zsh'  { return Join-Path $HOME '.zshrc' }
                default { return Join-Path $HOME '.bashrc' }
            }
        }
    }
}

function Get-ForgumConfigPath {
    <#
    .SYNOPSIS
        Returns the config file path for the current platform.
    #>
    $platform = Get-ForgumPlatform
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

function Get-ForgumModulePath {
    <#
    .SYNOPSIS
        Returns the module installation path.
    #>
    $platform = Get-ForgumPlatform
    switch ($platform) {
        'windows' {
            $docPath = [Environment]::GetFolderPath('MyDocuments')
            return Join-Path $docPath 'PowerShell/Modules/Forgum'
        }
        default {
            return Join-Path $HOME '.local/share/powershell/Modules/Forgum'
        }
    }
}
