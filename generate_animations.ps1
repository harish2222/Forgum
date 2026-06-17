$cows = Get-ChildItem "D:\Projects\Forgum\Data\Cows" -Filter "*.cow" | Select-Object -ExpandProperty Name
$mapping = @{}

foreach ($cow in $cows) {
    $base = "Breathe"
    $particles = $null
    $speed = 1.0

    if ($cow -match "(default|cower|fat-cow)") {
        $base = "Talk"
    } elseif ($cow -match "supermilker") {
        $base = "Talk"; $speed = 2.0
    } elseif ($cow -match "(moose|mule|lamb|lamb2)") {
        $base = "Walk"
    } elseif ($cow -match "(sheep|flaming-sheep|pig)") {
        $base = "Breathe"
        if ($cow -match "flaming") { $particles = "Fire" }
    } elseif ($cow -match "goat") {
        $base = "Sway"
    } elseif ($cow -match "(dolphin|whale|happy-whale|docker-whale)") {
        $base = "Float"; $particles = "Bubbles"
    } elseif ($cow -match "octopus") {
        $base = "Sway"
    } elseif ($cow -match "jellyfish") {
        $base = "Float"
    } elseif ($cow -match "seahorse") {
        $base = "Float"; $speed = 1.5; $particles = "Bubbles"
    } elseif ($cow -match "lobster") {
        $base = "Walk"
    } elseif ($cow -match "(duck|turkey|tux)") {
        $base = "Sway"
    } elseif ($cow -match "owl") {
        $base = "Glitch"
    } elseif ($cow -match "golden-eagle") {
        $base = "Fly"
    } elseif ($cow -match "tweety-bird") {
        $base = "Fly"; $speed = 2.0
    } elseif ($cow -match "pterodactyl") {
        $base = "Fly"
    } elseif ($cow -match "(cat|kitty|kitten|meow)") {
        $base = "Walk"
    } elseif ($cow -match "doge") {
        $base = "Glitch"
    } elseif ($cow -match "fox") {
        $base = "Walk"; $speed = 0.5
    } elseif ($cow -match "bunny") {
        $base = "Float"; $speed = 2.0
    } elseif ($cow -match "squirrel") {
        $base = "Glitch"
    } elseif ($cow -match "hedgehog") {
        $base = "Dissolve"
    } elseif ($cow -match "koala") {
        $base = "Breathe"; $particles = "Zzz"
    } elseif ($cow -match "(dragon|charizard)") {
        $base = "Fly"; $particles = "Fire"
    } elseif ($cow -match "(ghost)") {
        $base = "Float"; $particles = "Glitch"
    } elseif ($cow -match "weeping-angel") {
        $base = "Glitch"
    } elseif ($cow -match "(alien|cthulhu)") {
        $base = "Pulse"
    } elseif ($cow -match "(daemon|satanic)") {
        $base = "Float"; $particles = "Fire"
    } elseif ($cow -match "minotaur") {
        $base = "Walk"; $speed = 1.5
    } elseif ($cow -match "(glados|personality-sphere|surgery|mutilated)") {
        $base = "Glitch"
    } elseif ($cow -match "kosh") {
        $base = "Float"
    } elseif ($cow -match "batman") {
        $base = "Fly"
    } elseif ($cow -match "snoopy") {
        $base = "Breathe"
        if ($cow -match "sleep") { $particles = "Zzz" }
    } elseif ($cow -match "(ren|stimpy|beavis)") {
        $base = "Glitch"
    } elseif ($cow -match "nyan") {
        $base = "Fly"; $particles = "Stars"
    } elseif ($cow -match "hellokitty") {
        $base = "Sway"
    } elseif ($cow -match "bees") {
        $base = "Fly"; $speed = 2.0
    } elseif ($cow -match "spidercow") {
        $base = "Walk"
    } elseif ($cow -match "(stegosaurus|tortoise|turtle)") {
        $base = "Walk"; $speed = 0.3
    } elseif ($cow -match "mona-lisa") {
        $base = "Talk"
    } elseif ($cow -match "(periodic-table|world)") {
        $base = "Pulse"
    } elseif ($cow -match "(king|queen|knight|rook|pawn)") {
        $base = "Walk"
    } else {
        $base = "Breathe"
    }

    $mapping[$cow] = @{
        base = $base
        particles = $particles
        speed = $speed
    }
}

$mapping | ConvertTo-Json -Depth 3 | Out-File "D:\Projects\Forgum\Data\Cows\animations.json" -Encoding utf8
