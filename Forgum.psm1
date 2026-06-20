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
# Guard against duplicate module import bookkeeping (prevents accumulating OnRemove handlers)
if (-not $script:__ForgumOnRemoveRegistered) {
    $script:__ForgumOnRemoveRegistered = $true
    $ExecutionContext.SessionState.Module.OnRemove += $_ForgumOnRemove
}

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

# Module version
$script:ModuleVersion = '1.1.2'

# Define command aliases (legacy compat — aliased to forgum subcommands)
Set-Alias -Name forgum-show   -Value forgum -Scope Script -ErrorAction SilentlyContinue
Set-Alias -Name forgum-setup  -Value forgum -Scope Script -ErrorAction SilentlyContinue

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
    if (Get-Command forgum -ErrorAction Ignore) {
        try {
            # Update check
            $realConfig = Get-CFConfig
            $configDir = Split-Path (Get-ConfigPath) -Parent
            $flagPath = Join-Path $configDir ".update_available"

            if (Test-Path $flagPath) {
                Write-Host "`n🚀 A new version of Forgum is available! Run 'forgum update' to upgrade.`n" -ForegroundColor Yellow
            }

            # Signal to Show-CFAnimation that this is auto-start: use --once
            # so the binary exits after one frame and never blocks startup.
            $script:IsAutoStart = $true
            $config = $realConfig | Select-Object *
            $config.cow.random = $true
            $config.lolcat.enabled = $true

            $savedCache = $script:ConfigCache
            $savedCacheTime = $script:ConfigCacheTime
            $script:ConfigCache = $config
            $script:ConfigCacheTime = [datetime]::UtcNow
            try {
                $cowText = forgum run "startup" 2>&1 | Out-String
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

# Register tab completion (PowerShell 5.1+)
# Note: Register-ArgumentCompleter is available in PS 5.0+ but arg completion behavior
# differs between PSReadLine versions. This guard keeps module import safe in PS where
# the cmdlet is missing.
if (-not $script:__ForgumCompletionRegistered -and (Get-Command Register-ArgumentCompleter -ErrorAction SilentlyContinue)) {
    $script:__ForgumCompletionRegistered = $true

    $subCommands = @(
        'run','config','gallery','preview','update','toggle','animate',
        'eyes','init','live','daemon','cowsay','list','theme','export',
        'history','interactive','help'
    )

    # --- Invoke-Cowsay completion (existing) ---
    Register-ArgumentCompleter -CommandName Invoke-Cowsay -ParameterName CowFile -ScriptBlock {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
        Get-CFCow | Where-Object { $_ -like "*$wordToComplete*" } | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }

    # --- forgum SubCommand completion ---
    $subCommands = @('run','config','gallery','preview','update','toggle','animate','eyes','init','live','daemon','cowsay','list','theme','export','history','interactive','help')
    Register-ArgumentCompleter -CommandName forgum -ParameterName SubCommand -ScriptBlock {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

        # If a subcommand is already typed, complete flags for that subcommand
        $existing = $commandAst.CommandElements | Where-Object { $_.Value -in $subCommands } | Select-Object -First 1
        if ($existing) {
            $flags = switch ($existing.Value) {
                'run'       { @('--cow','--mode','--eyes','--tongue','--thoughts','--lolcat','--no-lolcat','--fortune','--no-color') }
                'cowsay'    { @('--cow','--eyes','--tongue','--thoughts','--lolcat','--no-lolcat','--no-color') }
                'export'    { @('--cow','--eyes','--tongue','--output','--format','--no-color') }
                'config'    { @('--path','--dir','--show','--open') }
                'list'      { @('--count','--search') }
                'gallery'   { @('--count') }
                'history'   { @('--count','--clear') }
                'init'      { @('--shell') }
                'animate'   { @('--mode','--duration') }
                'eyes'      { @('--preset','--custom') }
                'toggle'    { @('--lolcat') }
                'theme'     { @('--name') }
                default     { @() }
            }
            $flags | Where-Object { $_ -like "*$wordToComplete*" } | ForEach-Object {
                [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
            }
        } else {
            $subCommands | Where-Object { $_ -like "*$wordToComplete*" } | ForEach-Object {
                [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
            }
        }
    }
}

Export-ModuleMember -Function forgum -Alias forgum-show, forgum-setup
