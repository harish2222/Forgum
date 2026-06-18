function Show-CFCowPreview {
    <#
    .SYNOPSIS
        Previews a specific cow with custom text.

    .DESCRIPTION
        Quickly preview what a specific cow looks like with a custom message.

    .PARAMETER CowFile
        The name of the cow to preview. Default is 'default'.

    .PARAMETER Text
        The custom text message to display. Default is 'Hello!'.

    .EXAMPLE
        Show-CFCowPreview -CowFile "dragon" -Text "Rawr!"

    .EXAMPLE
        cowpreview tux "Hello from Linux!"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]$CowFile = 'default',

        [Parameter(Position = 1)]
        [string]$Text = 'Hello!'
    )

    Invoke-Cowsay -Text $Text -CowFile $CowFile
}
