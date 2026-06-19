#Requires -Version 5.1

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
param()

# Preserve caller's preferences — restore on module unload so this module never
# leaks global state. Required for safe composability with other modules / profiles.
$_ForgumPreviousErrorActionPreference = $ErrorActionPreference
$_ForgumPreviousProgressPreference   = $ProgressPreference
$_ForgumOnRemove = {
    $ErrorActionPreference = $script:_ForgumPreviousErrorActionPreference
    $ProgressPreference   = $script:_ForgumPreviousProgressPreference
}
$ExecutionContext.SessionState.Module.OnRemove += $_ForgumOnRemove

# Enable Virtual Terminal Processing for truecolor ANSI support on Windows.
# Lazy: only set VT mode when both stdout and stderr go to a real console. Skipping
# this on non-interactive sessions avoids Add-Type cost (5-15ms) on every import
# and avoids touching handles in CI / piped contexts.
if (($IsWindows -or $env:OS -eq 'Windows_NT') -and
    -not [Console]::IsOutputRedirected) {
    try {
        if (-not ('VTTerminal' -as [type])) {
            Add-Type @"
                using System;
                using System.Runtime.InteropServices;
                public class VTTerminal {
                    [DllImport("kernel32.dll", SetLastError=true)]
                    public static extern IntPtr GetStdHandle(int nStdHandle);
                    [DllImport("kernel32.dll", SetLastError=true)]
                    public static extern bool GetConsoleMode(IntPtr hConsoleHandle, out uint lpMode);
                    [DllImport("kernel32.dll", SetLastError=true)]
                    public static extern bool SetConsoleMode(IntPtr hConsoleHandle, uint dwMode);
                    public const int STD_OUTPUT_HANDLE = -11;
                    public const int STD_ERROR_HANDLE  = -12;
                    public const uint ENABLE_VIRTUAL_TERMINAL_PROCESSING = 0x0004;
                }
"@
        }

        $hOut = [VTTerminal]::GetStdHandle([VTTerminal]::STD_OUTPUT_HANDLE)
        $mode = 0
        if ([VTTerminal]::GetConsoleMode($hOut, [ref]$mode)) {
            $newMode = $mode -bor [VTTerminal]::ENABLE_VIRTUAL_TERMINAL_PROCESSING
            [void][VTTerminal]::SetConsoleMode($hOut, $newMode)
        }
    } catch {
        Write-Verbose "Forgum: Virtual Terminal Processing not available: $_"
    }
}

# Module-scoped error handling: errors abort the module load itself, but we do
# NOT mutate $ErrorActionPreference globally — callers keep their preference.
$ErrorActionPreference = 'Stop'

$privatePath = Join-Path $PSScriptRoot 'Private'
$publicPath  = Join-Path $PSScriptRoot 'Public'

# Dot-source private functions (order matters for dependencies)
Get-ChildItem -Path $privatePath -Filter '*.ps1' -Recurse -ErrorAction SilentlyContinue |
    ForEach-Object {
        try { . $_.FullName }
        catch { Write-Warning "Forgum: Failed to load $($_.FullName): $_" }
    }

# Dot-source public functions
Get-ChildItem -Path $publicPath -Filter '*.ps1' -Recurse -ErrorAction SilentlyContinue |
    ForEach-Object {
        try { . $_.FullName }
        catch { Write-Warning "Forgum: Failed to load $($_.FullName): $_" }
    }

# Define command aliases
Set-Alias -Name cowgallery    -Value Show-CFCowGallery   -Scope Script -ErrorAction SilentlyContinue
Set-Alias -Name cowpreview    -Value Show-CFCowPreview   -Scope Script -ErrorAction SilentlyContinue
Set-Alias -Name cowconfig     -Value Show-CFConfig       -Scope Script -ErrorAction SilentlyContinue
Set-Alias -Name lolcat-toggle -Value Toggle-CFLolcat     -Scope Script -ErrorAction SilentlyContinue
Set-Alias -Name cow-animate   -Value Set-CFCowAnimate    -Scope Script -ErrorAction SilentlyContinue
Set-Alias -Name cow-eyes      -Value Set-CFCowEyes       -Scope Script -ErrorAction SilentlyContinue

# Module-scoped cache for performance
$script:CowFileCache = @{}
$script:FortuneCache = @{}
$script:ConfigCache  = $null
$script:ConfigCacheTime = [datetime]::MinValue

# Auto-start flag: Show-CFAnimation checks this to decide whether to use --once
# (safe for startup) or --frames N (allows animation for manual invocations).
$script:IsAutoStart = $false

# Cache TTL in seconds (avoids stale reads during long sessions)
$script:ConfigCacheTTL = 30

# Default config sections (module-level constant — avoids recreation per Get-CFConfig call)
$script:DefaultConfigSections = @{
    animation = @{ mode = 'physics'; speed = 20; duration = 12; spread = 3.0; blinkRate = 0.2; amplitude = 2; cycleInterval = 3 }
    cow = @{ file = 'default'; random = $false; mode = $null; eyes = 'oo'; tongue = '  ' }
    fortune = @{ database = 'fortunes'; databases = @('fortunes'); offensive = $false; lengthFilter = $null }
    lolcat = @{ enabled = $false; truecolor = $true; frequency = 0.1; spread = 3.0; seed = 0; invert = $false; animate = $false; duration = 12; speed = 20.0 }
    output = @{ wordWrap = $true; maxWidth = 60; noWrap = $false }
    startup = @{ enabled = $true; command = 'Invoke-Forgum' }
    shell = @{ integration = 'auto'; tmux = @{ enabled = $false; pane = 'status-right' } }
}

# Auto-start: render a single static cow with lolcat on every import.
#
# Skipped when:
#   - $env:FORGUM_NOAUTOSTART = '1' (caller-controlled)
#   - output is redirected / non-interactive (CI, scripts, piped contexts)
#   - HostName is ServerRemoteHost (SSH session, etc.)
#
# Never animates on auto-start: animations require interactive consent because
# they block the terminal until completion (or keypress).
if ($env:FORGUM_NOAUTOSTART -ne '1' -and
    -not [Console]::IsOutputRedirected -and
    $Host.Name -ne 'ServerRemoteHost') {
    if (Get-Command Invoke-Forgum -ErrorAction Ignore) {
        try {
            # Signal to Show-CFAnimation that this is auto-start: use --once
            # so the binary exits after one frame and never blocks startup.
            $script:IsAutoStart = $true
            $config = Get-CFConfig
            $config.cow.random = $true
            $config.lolcat.enabled = $true

            $savedCache = $script:ConfigCache
            $savedCacheTime = $script:ConfigCacheTime
            $script:ConfigCache = $config
            $script:ConfigCacheTime = [datetime]::UtcNow
            try {
                $cowText = Invoke-Forgum -Lolcat
                if ($cowText) { Write-Host $cowText }
            } finally {
                $script:ConfigCache = $savedCache
                $script:ConfigCacheTime = $savedCacheTime
                $script:IsAutoStart = $false
            }
        } catch {
            Write-Verbose "Forgum auto-start skipped: $_"
            $script:IsAutoStart = $false
        }
    }
}

# Register tab completion for Invoke-Cowsay
if (Get-Command Register-ArgumentCompleter -ErrorAction SilentlyContinue) {
    Register-ArgumentCompleter -CommandName Invoke-Cowsay -ParameterName CowFile -ScriptBlock {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
        Get-CFCow | Where-Object { $_ -like "*$wordToComplete*" } | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }
}
