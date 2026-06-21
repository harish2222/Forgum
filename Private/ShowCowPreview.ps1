function ShowCowPreview {
    <#
    .SYNOPSIS
        Previews a specific cow file with custom text.
    .PARAMETER CowFile
        Name of the cow file to preview.
    .PARAMETER Text
        Text to display in the cow bubble.
    #>
    [CmdletBinding()]
    param(
        [string]$CowFile = 'default',
        [string]$Text = 'Hello World'
    )

    InvokeCowsay -Text $Text -CowFile $CowFile
}
