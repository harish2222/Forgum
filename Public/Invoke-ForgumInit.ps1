function Invoke-ForgumInit {
    <#
    .SYNOPSIS
        Generates the shell hook script to initialize Forgum on shell startup.
    .DESCRIPTION
        Outputs the shell script code needed to initialize Forgum dynamically.
        For PowerShell, you can run: Invoke-ForgumInit pwsh | Invoke-Expression
        For Bash/Zsh, you can run: eval "$(forgum-engine init bash)"
    .PARAMETER Shell
        The shell to generate the hook for (pwsh, bash, zsh, fish).
    .EXAMPLE
        Invoke-ForgumInit pwsh | Out-String | Invoke-Expression
    #>
    [CmdletBinding()]
    param(
        [ValidateSet('pwsh', 'bash', 'zsh', 'fish')]
        [string]$Shell = 'pwsh'
    )

    $enginePath = Join-Path $PSScriptRoot "..\bin\forgum-engine.exe"
    if ($IsLinux -or $IsMacOS) {
        $enginePath = Join-Path $PSScriptRoot "../bin/forgum-engine"
    }

    if (Test-Path $enginePath) {
        # Let the Rust binary emit the robust native shell script
        & $enginePath init $Shell
    } else {
        if ($Shell -eq 'pwsh') {
            # Fallback PowerShell initialization
            return "Import-Module Forgum; Invoke-Forgum -Lolcat"
        } else {
            Write-Warning "forgum-engine not found. Only PowerShell initialization is supported natively without the engine binary."
        }
    }
}
