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

    # 1. Resolve binary path using cross-platform helper
    $enginePath = Get-EngineBinary

    if (-not $enginePath) {
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
        effect     = $Effect
        cow_text   = $fullText
        fps        = $Fps
        duration   = $Duration
        background = $Background.IsPresent
    }

    $json = $scene | ConvertTo-Json -Depth 5 -Compress

    # 4. Pipe to engine
    try {
        if ($Background) {
            $proc = [System.Diagnostics.Process]::new()
            try {
                $proc.StartInfo.FileName = $enginePath
                $proc.StartInfo.Arguments = '--daemon'
                $proc.StartInfo.RedirectStandardInput = $true
                $proc.StartInfo.UseShellExecute = $false
                $proc.StartInfo.CreateNoWindow = $true
                $proc.Start()
                $proc.StandardInput.Write($json)
                $proc.StandardInput.Close()
                if (-not $proc.WaitForExit(5000)) {
                    $proc.Kill()
                    Write-Warning "forgum-engine timed out after 5s and was killed."
                }
                return $true
            } finally {
                if ($null -ne $proc) { $proc.Dispose() }
            }
        } else {
            $proc = [System.Diagnostics.Process]::new()
            try {
                $proc.StartInfo.FileName = $enginePath
                $proc.StartInfo.RedirectStandardInput = $true
                $proc.StartInfo.RedirectStandardOutput = $true
                $proc.StartInfo.UseShellExecute = $false
                $proc.StartInfo.CreateNoWindow = $true
                $proc.Start()
                $proc.StandardInput.Write($json)
                $proc.StandardInput.Close()
                if (-not $proc.WaitForExit(10000)) {
                    $proc.Kill()
                    Write-Warning "forgum-engine timed out after 10s and was killed."
                }
                return $true
            } finally {
                if ($null -ne $proc) { $proc.Dispose() }
            }
        }
    } catch {
        Write-Warning "Failed to execute Rust engine: $_"
        return $false
    }
}
