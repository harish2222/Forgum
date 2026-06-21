function GetForgumShellHook {
    <#
    .SYNOPSIS
        Generates shell hooks for the specified shell.
    .DESCRIPTION
        Returns native shell hook code for bash, zsh, fish, or pwsh.
    .PARAMETER Shell
        Shell to generate hooks for (bash, zsh, fish, pwsh).
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Shell
    )

    $configPath = GetForgumConfigPath

    $effect = 'random'
    if (Test-Path $configPath) {
        try {
            $conf = Get-Content $configPath -Raw | ConvertFrom-Json -ErrorAction SilentlyContinue
            if ($conf.effect) { $effect = $conf.effect }
        } catch {
            Write-Verbose "Non-critical error ignored"
        }
    }

    switch ($Shell) {
        'bash' {
            $template = @'
# Forgum bash hook
forgum() {
    local effect="EFFECT_PLACEHOLDER"
    local cow="$(cowsay "$@")"
    local json_cow="${cow//$'\n'/\\n}"
    json_cow="${json_cow//\"/\\\"}"
    echo "{\"effect\":\"$effect\",\"cow_text\":\"$json_cow\",\"background\":true,\"duration\":150}" | forgum-engine
}
'@
            return $template.Replace('EFFECT_PLACEHOLDER', $effect)
        }
        'zsh' {
            $template = @'
# Forgum zsh hook
forgum() {
    local effect="EFFECT_PLACEHOLDER"
    local cow="$(cowsay "$@")"
    local json_cow="${cow//$'\n'/\\n}"
    json_cow="${json_cow//\"/\\\"}"
    echo "{\"effect\":\"$effect\",\"cow_text\":\"$json_cow\",\"background\":true,\"duration\":150}" | forgum-engine
}
'@
            return $template.Replace('EFFECT_PLACEHOLDER', $effect)
        }
        'fish' {
            $template = @'
# Forgum fish hook
function forgum
    set effect "EFFECT_PLACEHOLDER"
    set cow (cowsay $argv | string collect)
    set json_cow (string replace -a '\n' '\\n' "$cow")
    set json_cow (string replace -a '"' '\"' "$json_cow")
    echo "{\"effect\":\"$effect\",\"cow_text\":\"$json_cow\",\"background\":true,\"duration\":150}" | forgum-engine
end
'@
            return $template.Replace('EFFECT_PLACEHOLDER', $effect)
        }
        'pwsh' {
            return @"
# Forgum PowerShell hook
function Invoke-ForgumEngine {
    param(
        [Parameter(ValueFromPipeline=`$true)]
        [string]`$CowText
    )
    process {
        `$effect = "$effect"
        `$payload = @{ effect = `$effect; cow_text = `$CowText; background = `$true; duration = 150 } | ConvertTo-Json -Compress
        `$payload | & forgum-engine
    }
}
"@
        }
        default {
            return "# Unsupported shell: $Shell`n# Supported shells: bash, zsh, fish, pwsh"
        }
    }
}
