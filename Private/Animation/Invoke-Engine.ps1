function Invoke-Engine {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [AllowEmptyString()]
        [string]$Message,
        
        [Parameter(Mandatory=$false)]
        $CowTemplate = @(),
        
        [string]$Effect = 'plasma',
        
        [int]$Fps = 30,

        [int]$Duration = 0,

        [switch]$Background
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
    $fullText = $Message
    if ($fullText.Trim() -ne '' -and $CowTemplate.Count -gt 0) {
        $fullText += "`n"
    }
    $fullText += ($CowTemplate -join "`n")

    $scene = @{
        effect = $Effect
        cow_text = $fullText
        fps = $Fps
        duration = $Duration
        background = $Background.IsPresent
    }

    $json = $scene | ConvertTo-Json -Depth 5 -Compress

    # 4. Pipe to engine
    try {
        if ($Background) {
            $tmp = New-TemporaryFile
            $json | Out-File -FilePath $tmp.FullName -Encoding utf8
            Start-Process -FilePath $enginePath -RedirectStandardInput $tmp.FullName -NoNewWindow
            return $true
        } else {
            $json | & $enginePath
            return $true
        }
    } catch {
        Write-Warning "Failed to execute Rust engine: $_"
        return $false
    }
}
