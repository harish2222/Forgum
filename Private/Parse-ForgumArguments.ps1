function Parse-ForgumArguments {
    <#
    .SYNOPSIS
        Parses command-line arguments for forgum subcommands.
    .DESCRIPTION
        Handles --flag, --key value, positional text, and --help detection.
        Returns a hashtable with parsed values.
    .PARAMETER Arguments
        Raw argument array to parse.
    .PARAMETER KnownFlags
        Array of known boolean flags.
    .PARAMETER KnownOptions
        Array of known key-value options.
    #>
    param(
        [string[]]$Arguments = @(),
        [string[]]$KnownFlags = @('help','json','force','check','lolcat','no-lolcat','fortune','no-color','clear'),
        [string[]]$KnownOptions = @('cow','mode','count','text','preset','custom','shell','duration','eyes','tongue','thoughts','output','format','search')
    )

    $result = @{
        Text        = @()
        Flags       = @{}
        Options     = @{}
        Help        = $false
        RawArgs     = $Arguments
        TextString  = ''
    }

    $i = 0
    while ($i -lt $Arguments.Length) {
        $arg = $Arguments[$i]

        if ($arg -eq '--help' -or $arg -eq '-h' -or $arg -eq '-?') {
            $result.Help = $true
            $i++
            continue
        }

        if ($arg -like '--*') {
            $key = $arg.Substring(2).ToLower()

            if ($key -in $KnownFlags) {
                $result.Flags[$key] = $true
                $i++
                continue
            }

            if ($key -in $KnownOptions -and ($i + 1) -lt $Arguments.Length) {
                $result.Options[$key] = $Arguments[$i + 1]
                $i += 2
                continue
            }

            $result.Text += $Arguments[$i..($Arguments.Length - 1)]
            break
        }

        $result.Text += $arg
        $i++
    }

    if ($result.Text.Count -gt 0) {
        $result.TextString = $result.Text -join ' '
    }

    return $result
}
