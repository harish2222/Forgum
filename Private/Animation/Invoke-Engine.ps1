function Invoke-Engine {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$true)]
        [string[]]$CowTemplate,
        
        [string]$Effect = 'plasma',
        
        [int]$Fps = 30
    )

    # 1. Resolve binary path
    $enginePath = Join-Path $PSScriptRoot "..\..\bin\forgum-engine.exe"
    if ($IsLinux -or $IsMacOS) {
        $enginePath = Join-Path $PSScriptRoot "../../bin/forgum-engine"
    }

    if (-not (Test-Path $enginePath)) {
        Write-Verbose "forgum-engine not found. Falling back to PowerShell native physics."
        return $false
    }

    # 2. Extract Speech Bubble vs Sprite
    $lines = $Message -split "`r?`n"
    $bubble = @()
    $sprite = @()
    
    $inBubble = $true
    foreach ($line in $lines) {
        if ($inBubble) {
            $bubble += $line
            # End of bubble logic... usually bottom of the bubble string
            if ($line -match "---" -or $line -match "===") {
                $inBubble = $false
            }
        } else {
            if ($line.Trim() -ne '') {
                $sprite += $line
            }
        }
    }
    
    if ($sprite.Count -eq 0) {
        $sprite = $CowTemplate
    }

    # 3. Construct JSON Scene
    $scene = @{
        static_header = $bubble
        sprite = $sprite
        effect = $Effect
        params = @{
            speed = 1.0
            amplitude = 2
            fps = $Fps
        }
        viewport = @{
            cols = [Console]::WindowWidth
            rows = [Console]::WindowHeight
        }
        color = @{
            mode = "lolcat"
            frequency = 0.1
            spread = 3.0
        }
    }

    $json = $scene | ConvertTo-Json -Depth 5 -Compress

    # 4. Pipe to engine
    try {
        $json | & $enginePath
        return $true
    } catch {
        Write-Warning "Failed to execute Rust engine: $_"
        return $false
    }
}
