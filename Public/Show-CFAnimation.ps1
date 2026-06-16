function Show-CFAnimation {
    <#
    .SYNOPSIS
        Displays cow output with the configured animation mode.
        .DESCRIPTION
        Dispatches to the appropriate animation function based on config.
        Modes: static, talking, typewriter, slide-in, bounce, dissolve,
        fade-in, blink, wiggle, wave, disco, dynamic.
    .PARAMETER CowOutput
        The rendered cow string to animate.
    .PARAMETER Message
        The original message text (used by some animations).
    .EXAMPLE
        Show-CFAnimation -CowOutput $cow -Message "Hello"
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [string]$CowOutput,

        [string]$Message = ''
    )

    $config = Get-CFConfig
    $mode = $config.animation.mode

    $isWin = $IsWindows -or ($PSVersionTable.PSVersion.Major -lt 6) -or ($env:OS -eq 'Windows_NT')
    $isMac = $IsMacOS

    if ($isWin) {
        $arch = $env:PROCESSOR_ARCHITECTURE
        $binName = if ($arch -eq 'ARM64' -or $arch -eq 'Arm64') { "forgum-core-arm64.exe" } else { "forgum-core.exe" }
    } elseif ($isMac) {
        $binName = "forgum-core-mac"
    } else {
        $arch = [System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture.ToString()
        $binName = if ($arch -eq 'Arm64' -or $arch -eq 'ARM64') { "forgum-core-arm64" } else { "forgum-core" }
    }

    $binPath = Join-Path (Split-Path $PSScriptRoot -Parent) "bin\$binName"
    if (-not (Test-Path $binPath)) {
        $fallbackName = if ($isWin) { "forgum-core.exe" } else { "forgum-core" }
        $fallbackPath = Join-Path (Split-Path $PSScriptRoot -Parent) "bin\$fallbackName"
        if (Test-Path $fallbackPath) {
            $binPath = $fallbackPath
        }
    }

    if (Test-Path $binPath) {
        # Call the new Rust engine
        $CowOutput | & $binPath --message $Message --mode $mode
    } else {
        # Fallback to legacy
        Write-Warning "forgum-core not found, falling back to static"
        return $CowOutput
    }
}
