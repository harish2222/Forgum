function Get-MaxDepth {
    <#
    .SYNOPSIS
        Calculates the maximum nesting depth of an object.
    .DESCRIPTION
        Recursively walks hashtables and PSCustomObjects to find the deepest level.
        Returns 1 for flat objects, 2 for one level of nesting, etc.
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(ValueFromPipeline)]
        $Object
    )

    if ($null -eq $Object) { return 1 }

    if ($Object -is [hashtable] -or $Object -is [System.Collections.Specialized.OrderedDictionary]) {
        $maxChild = 1
        foreach ($key in $Object.Keys) {
            $childDepth = 1 + (Get-MaxDepth $Object[$key])
            if ($childDepth -gt $maxChild) { $maxChild = $childDepth }
        }
        return $maxChild
    }

    if ($Object -is [PSCustomObject]) {
        $maxChild = 1
        foreach ($prop in $Object.PSObject.Properties) {
            $childDepth = 1 + (Get-MaxDepth $prop.Value)
            if ($childDepth -gt $maxChild) { $maxChild = $childDepth }
        }
        return $maxChild
    }

    if ($Object -is [System.Collections.IEnumerable] -and $Object -isnot [string]) {
        $maxChild = 1
        foreach ($item in $Object) {
            $childDepth = 1 + (Get-MaxDepth $item)
            if ($childDepth -gt $maxChild) { $maxChild = $childDepth }
        }
        return $maxChild
    }

    return 1
}

function ConvertTo-JsonSafe {
    <#
    .SYNOPSIS
        Converts an object to JSON with dynamic depth. No truncation warning.
    .DESCRIPTION
        Calculates the actual nesting depth of the object and serializes with
        sufficient depth to avoid the "Resulting JSON is truncated" warning.
        Adds a small buffer (depth + 2) for safety.
        Handles arrays correctly by collecting all pipeline input before serializing.
    .PARAMETER InputObject
        The object to serialize.
    .PARAMETER Compress
        If set, produces a single-line JSON string.
    .PARAMETER DepthOverride
        Optional explicit depth. If not provided, depth is calculated dynamically.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(ValueFromPipeline, Mandatory)]
        $InputObject,

        [switch]$Compress,

        [int]$DepthOverride = 0
    )

    begin {
        $collected = [System.Collections.Generic.List[object]]::new()
    }

    process {
        $collected.Add($InputObject)
    }

    end {
        $target = if ($collected.Count -eq 1) { $collected[0] } else { ,$collected.ToArray() }

        $depth = if ($DepthOverride -gt 0) {
            $DepthOverride
        } else {
            $calculated = Get-MaxDepth $target
            $calculated + 2
        }

        if ($Compress) {
            $target | ConvertTo-Json -Depth $depth -Compress
        } else {
            $target | ConvertTo-Json -Depth $depth
        }
    }
}
