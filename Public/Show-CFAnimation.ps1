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
    $binName = if ($IsWindows -or ($PSVersionTable.PSVersion.Major -lt 6)) { "forgum-core.exe" } else { "forgum-core" }
    $binPath = Join-Path (Split-Path $PSScriptRoot -Parent) "bin\$binName"

    if (Test-Path $binPath) {
        # Call the new Rust engine
        $CowOutput | & $binPath --message $Message --mode $mode
    } else {
        # Fallback to legacy
        Write-Warning "forgum-core not found, falling back to static"
        return $CowOutput
    }
}
