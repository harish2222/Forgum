function Invoke-Engine {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$JsonPayload,

        [switch]$NonBlocking
    )
    process {
        $enginePath = Get-EngineBinary

        if (-not $enginePath) {
            Write-Verbose "forgum-engine not found."
            return $null
        }

        # Parse JSON to check if background mode is requested
        $isBackground = $false
        try {
            $payloadObj = $JsonPayload | ConvertFrom-Json
            if ($payloadObj.background -eq $true) {
                $isBackground = $true
            }
        } catch {
            # If we can't parse, assume foreground
        }

        try {
            $proc = [System.Diagnostics.Process]::new()
            try {
                $proc.StartInfo.FileName = $enginePath
                $proc.StartInfo.RedirectStandardInput = $true
                $proc.StartInfo.RedirectStandardOutput = $true
                $proc.StartInfo.UseShellExecute = $false
                $proc.StartInfo.CreateNoWindow = $true
                $null = $proc.Start()
                $proc.StandardInput.Write($JsonPayload)
                $proc.StandardInput.Close()

                # Non-blocking mode: for background animations, don't wait
                # Engine renders directly to terminal via cursor save/restore
                if ($isBackground -and $NonBlocking.IsPresent) {
                    # Start async read but don't block
                    $null = $proc.StandardOutput.ReadToEndAsync()
                    # Return immediately - shell stays interactive
                    return $null
                }

                # Blocking mode: wait for engine to finish
                $output = $proc.StandardOutput.ReadToEnd()
                if (-not $proc.WaitForExit(30000)) {
                    $proc.Kill()
                    Write-Warning "forgum-engine timed out after 30s."
                    return $null
                }
                return $output
            } finally {
                if ($null -ne $proc) { $proc.Dispose() }
            }
        } catch {
            Write-Warning "forgum-engine error: $_"
            return $null
        }
    }
}
