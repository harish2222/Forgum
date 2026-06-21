function GetEngineBinary {
    <#
    .SYNOPSIS
        Locates the forgum-engine binary cross-platform.
    .DESCRIPTION
        Searches bin/, engine/target/release/, engine/target/debug/.
        Auto-rebuilds if no binary found and Rust toolchain is available.
        Returns full path or $null if not found.
    #>
    $onWindows = $IsWindows -or $env:OS -eq 'Windows_NT'
    $binaryName = if ($onWindows) { 'forgum-engine.exe' } else { 'forgum-engine' }

    $moduleRoot = Split-Path $PSScriptRoot -Parent

    $candidates = @(
        (Join-Path $moduleRoot "bin/$binaryName"),
        (Join-Path $moduleRoot "engine/target/release/$binaryName"),
        (Join-Path $moduleRoot "engine/target/debug/$binaryName")
    )

    foreach ($path in $candidates) {
        if (Test-Path $path) { return $path }
    }

    # Auto-rebuild if Rust toolchain is available
    $cargo = Get-Command cargo -ErrorAction SilentlyContinue
    if ($cargo) {
        $buildScript = Join-Path $moduleRoot "Scripts/build-engine.ps1"
        if (Test-Path $buildScript) {
            try {
                & $buildScript -Quiet 2>$null
                # Re-check after build
                foreach ($path in $candidates) {
                    if (Test-Path $path) { return $path }
                }
            } catch { }
        }
    }

    return $null
}
