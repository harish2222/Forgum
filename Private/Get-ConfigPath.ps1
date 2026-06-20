function Get-ConfigPath {
    <#
    .SYNOPSIS
        Returns the cross-platform config file path.
    .DESCRIPTION
        Checks Forgum_CONFIG env var first, then uses platform-appropriate defaults.
        Uses PS7 automatic variables ($IsWindows/$IsLinux/$IsMacOS) when available and
        falls back to $env:OS for Windows PowerShell 5.1 compatibility.
    .NOTES
        Module-path note for cross-platform installs:
          - Windows PowerShell 5.1:  $env:USERPROFILE\Documents\WindowsPowerShell\Modules\Forgum
          - PowerShell 7 (Win):      $env:USERPROFILE\Documents\PowerShell\Modules\Forgum
          - PowerShell 7 (Linux/macOS): ~/.local/share/powershell/Modules/Forgum
        Use $PSVersionTable.PSVersion and $IsWindows to pick the correct module path.
    #>
    [CmdletBinding()]
    param()

    if ($env:Forgum_CONFIG) {
        return $env:Forgum_CONFIG
    }

    # Prefer PS7 automatic variables; fall back to $env:OS for PS5.1.
    $isPS7 = $PSVersionTable.PSVersion.Major -ge 7
    $onWindows = if ($isPS7) { [bool]$IsWindows } else { $env:OS -eq 'Windows_NT' }
    $onLinux   = if ($isPS7) { [bool]$IsLinux }   else { $env:OS -eq 'Linux' }
    $onMacOS   = if ($isPS7) { [bool]$IsMacOS }   else { $env:OS -eq 'Darwin' }

    if ($onLinux -or $onMacOS) {
        return Join-Path (Join-Path $HOME '.config') 'Forgum/config.json'
    }

    if ($onWindows) {
        return Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'PowerShell/Forgum/config.json'
    }

    # Unknown / unsupported platform - use XDG-style fallback.
    return Join-Path (Join-Path $HOME '.config') 'Forgum/config.json'
}
