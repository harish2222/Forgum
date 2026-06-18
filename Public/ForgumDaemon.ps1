function Start-ForgumDaemon {
    <#
    .SYNOPSIS
        Starts a background daemon that periodically displays animated cows.
    .DESCRIPTION
        Runs a background runspace that occasionally wakes up, picks a random cow
        and fortune, and renders it directly to the console in the background
        without interrupting your prompt.
    .PARAMETER Interval
        Seconds between animations. Default is 600 (10 minutes).
    .PARAMETER Duration
        Duration of each animation in frames. Default is 150 (5 seconds at 30fps).
    #>
    [CmdletBinding()]
    param(
        [int]$Interval = 600,
        [int]$Duration = 150
    )

    if ($global:ForgumDaemonRunspace -and $global:ForgumDaemonRunspace.RunspaceStateInfo.State -eq 'Opened') {
        Write-Warning "Forgum Daemon is already running."
        return
    }

    $rs = [runspacefactory]::CreateRunspace()
    $rs.ApartmentState = 'STA'
    $rs.ThreadOptions = 'ReuseThread'
    $rs.Open()
    $global:ForgumDaemonRunspace = $rs

    $ps = [powershell]::Create()
    $ps.Runspace = $rs

    $scriptBlock = {
        param($Interval, $Duration, $ModuleRoot)
        
        Import-Module (Join-Path $ModuleRoot "Forgum.psd1") -Force
        
        while ($true) {
            Start-Sleep -Seconds $Interval
            try {
                $availableEffects = @('aurora', 'ember', 'shatter', 'plasma', 'liquid-chrome', 'portal', 'glitch', 'neon-pulse')
                $effect = $availableEffects | Get-Random
                
                $cowsPath = Join-Path $ModuleRoot 'Data/Cows'
                $cowFile = (Get-ChildItem -Path $cowsPath -Filter '*.cow' | Get-Random).BaseName
                
                $fortune = Get-Fortune
                $cowOutput = Invoke-Cowsay -Text $fortune -CowFile $cowFile
                
                # We invoke the Rust engine with -Background so it runs without blocking
                Invoke-Engine -Message $fortune -CowTemplate ($cowOutput -split "`r?`n") -Effect $effect -Fps 30 -Duration $Duration -Background
                
            } catch {
                # Silently ignore errors in the daemon so it doesn't pollute the user's screen
            }
        }
    }

    $null = $ps.AddScript($scriptBlock).AddArgument($Interval).AddArgument($Duration).AddArgument($PSScriptRoot)
    $global:ForgumDaemonAsyncResult = $ps.BeginInvoke()
    Write-Host "Forgum Daemon started. It will draw a cow every $Interval seconds." -ForegroundColor Green
}

function Stop-ForgumDaemon {
    <#
    .SYNOPSIS
        Stops the Forgum background daemon.
    #>
    [CmdletBinding()]
    param()

    if ($global:ForgumDaemonRunspace) {
        $global:ForgumDaemonRunspace.Close()
        $global:ForgumDaemonRunspace.Dispose()
        $global:ForgumDaemonRunspace = $null
        Write-Host "Forgum Daemon stopped." -ForegroundColor Green
    } else {
        Write-Host "Forgum Daemon is not running." -ForegroundColor Yellow
    }
}
