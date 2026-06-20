function Get-EngineBinary {
    <#
    .SYNOPSIS
        Locates the forgum-engine binary cross-platform.
    .DESCRIPTION
        Searches bin/, engine/target/release/, engine/target/debug/.
        Returns full path or $null if not found.
    #>
    $isWindows = $IsWindows -or $env:OS -eq 'Windows_NT'
    $binaryName = if ($isWindows) { 'forgum-engine.exe' } else { 'forgum-engine' }

    $moduleRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent

    $candidates = @(
        (Join-Path $moduleRoot "bin/$binaryName"),
        (Join-Path $moduleRoot "engine/target/release/$binaryName"),
        (Join-Path $moduleRoot "engine/target/debug/$binaryName")
    )

    foreach ($path in $candidates) {
        if (Test-Path $path) { return $path }
    }

    return $null
}
