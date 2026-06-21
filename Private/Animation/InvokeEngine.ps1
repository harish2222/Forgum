function InvokeEngine {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$JsonPayload,

        [switch]$NonBlocking
    )
    process {
        $enginePath = GetEngineBinary

        if (-not $enginePath) {
            Write-Verbose "forgum-engine not found."
            return $null
        }

        # Parse JSON to determine rendering mode
        $isBackground = $false
        $effect = 'static'
        try {
            $payloadObj = $JsonPayload | ConvertFrom-Json
            if ($payloadObj.background -eq $true) { $isBackground = $true }
            if ($payloadObj.effect) { $effect = $payloadObj.effect }
        } catch {}

        $needsAnimation = ($effect -ne 'static')

        try {
            if ($needsAnimation) {
                # Animated effects: write JSON to temp file and launch via cmd /c
                # This bypasses PowerShell's pipe wrapping so the engine gets
                # direct console access for crossterm rendering.
                $tmpFile = Join-Path ([System.IO.Path]::GetTempPath()) "forgum_engine_$([System.IO.Path]::GetRandomFileName()).json"
                [System.IO.File]::WriteAllText($tmpFile, $JsonPayload)

                $escapedPath = $enginePath -replace '\\', '\\\\'
                $escapedFile = $tmpFile -replace '\\', '\\\\'

                if ($isBackground -and $NonBlocking.IsPresent) {
                    # Background: launch detached, don't wait
                    # CreateNoWindow=$true ensures engine shares the parent console
                    # instead of creating a hidden new window (which would make the
                    # animation invisible). The engine opens CONOUT$ directly.
                    $psi = New-Object System.Diagnostics.ProcessStartInfo
                    $psi.FileName = $enginePath
                    $psi.Arguments = "--file `"$tmpFile`""
                    $psi.UseShellExecute = $false
                    $psi.CreateNoWindow = $true
                    $null = [System.Diagnostics.Process]::Start($psi)
                    return $null
                }

                # Foreground blocking: run via cmd /c and wait
                & cmd /c "`"$enginePath`" --file `"$tmpFile`""
                Remove-Item $tmpFile -Force -ErrorAction SilentlyContinue
                return $null
            }

            # Static mode: pipe JSON to engine, capture output
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
