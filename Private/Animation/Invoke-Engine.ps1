function Invoke-Engine {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$JsonPayload
    )
    process {
        $enginePath = Get-EngineBinary

        if (-not $enginePath) {
            Write-Verbose "forgum-engine not found."
            return $null
        }

        try {
            $proc = [System.Diagnostics.Process]::new()
            try {
                $proc.StartInfo.FileName = $enginePath
                $proc.StartInfo.RedirectStandardInput = $true
                $proc.StartInfo.RedirectStandardOutput = $true
                $proc.StartInfo.UseShellExecute = $false
                $proc.StartInfo.CreateNoWindow = $true
                $proc.Start()
                $proc.StandardInput.Write($JsonPayload)
                $proc.StandardInput.Close()
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
