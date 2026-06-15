function Invoke-ForgumLive {
    <#
    .SYNOPSIS
        Starts the Forgum Live Showcase.
    .DESCRIPTION
        Enters an interactive mode that cycles through random cows and fortunes
        with various animations. Supports real-time toggles and manual cycling.
        Alias: forgum-show
    .PARAMETER Duration
        How long to run the showcase in seconds. If 0 (default), runs until 'Q' is pressed.
    .EXAMPLE
        Invoke-ForgumLive
    #>
    [CmdletBinding()]
    [Alias('forgum-show')]
    param(
        [Parameter()]
        [double]$Duration = 0
    )

    $config = Get-CFConfig
    $toggles = @{
        Lolcat = $config.lolcat.enabled
        Animation = $config.animation.mode -ne 'static'
    }

    $startTime = [DateTime]::UtcNow
    
    # Hide cursor if possible
    $cursorVisible = $true
    try {
        $cursorVisible = [Console]::CursorVisible
        [Console]::CursorVisible = $false
    } catch {}

    Write-Host "Starting Forgum Live Showcase..."
    Write-Host "Controls: [L] Toggle Lolcat | [A] Toggle Animation | [Space] Next Cow | [Q] Quit"
    Start-Sleep -Seconds 1

    try {
        while ($true) {
            if ($Duration -gt 0 -and ([DateTime]::UtcNow - $startTime).TotalSeconds -ge $Duration) {
                break
            }

            # Call the shared brain
            $result = Invoke-LiveShow -Config $config -Toggles $toggles -RunOnce:$false -Duration $Duration

            # If we returned, it's either an interrupt or completion
            if ([Console]::KeyAvailable) {
                $key = [Console]::ReadKey($true)
                switch ($key.Key) {
                    'L' { 
                        $toggles.Lolcat = -not $toggles.Lolcat
                    }
                    'A' {
                        $toggles.Animation = -not $toggles.Animation
                    }
                    'Spacebar' {
                        # Simply continue to the next loop iteration to get a new cow
                    }
                    'Q' {
                        return
                    }
                }
            }
            else {
                # If no key was available but we returned, it might be due to Duration
                if ($Duration -gt 0 -and ([DateTime]::UtcNow - $startTime).TotalSeconds -ge $Duration) {
                    break
                }
            }
        }
    }
    finally {
        # Restore cursor
        try { [Console]::CursorVisible = $cursorVisible } catch {}
        Write-Host "`nShowcase ended."
    }
}
