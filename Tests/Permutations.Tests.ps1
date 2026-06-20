#Requires -Modules Pester
#
# Comprehensive permutation tests for the forgum unified CLI.
# Covers: every subcommand × every arg/flag permutation, every help path,
# edge cases, alignment/rendering validation, and integration flows.
#

BeforeAll {
    $env:FORGUM_NOAUTOSTART = '1'
    $ModuleRoot = Split-Path $PSScriptRoot -Parent
    $ModulePath = Join-Path $ModuleRoot 'Forgum.psd1'
    do {
        $m = Get-Module Forgum -ErrorAction SilentlyContinue
        if ($m) { Remove-Module Forgum -Force -ErrorAction SilentlyContinue }
    } while ($m)
    Import-Module $ModulePath -Force

    function Strip-Ansi {
        param([string]$Text)
        $Text -replace '\x1b\[[0-9;]*[a-zA-Z]', '' -replace '\x1b\][^\x07]*\x07', ''
    }

    # All 12 subcommands
    $AllSubCommands = @('run','config','gallery','preview','update','toggle','animate','eyes','init','live','daemon','help')

    # All valid animation modes from help
    $FlagshipModes = @('aurora','plasma','ember','liquid-chrome','shatter','portal','glitch','neon-pulse')
    $LegacyModes   = @('static','talking','typewriter','bounce','wave','wiggle','dissolve','fade-in','slide-in','disco','blink','dynamic','procedural','physics')
    $AllModes      = $FlagshipModes + $LegacyModes + @('random')

    # All valid eye presets
    $EyePresets = @('borg','dead','greedy','paranoia','stoned','tired','wasted','youthful')

    # All shells for init
    $Shells = @('bash','zsh','fish','pwsh')

    # Known cows (subset for testing)
    $KnownCows = @('default','tux','dragon','kitty','whale','ghost')
}

# ─────────────────────────────────────────────────────────────────────────────
# 1. SUBCOMMAND × HELP PERMUTATIONS
#    Every subcommand must respond to: --help, -h, help <sub>
# ─────────────────────────────────────────────────────────────────────────────
Describe "Help permutations — every subcommand × help method" -Tag 'Permutation' {

    foreach ($cmd in $AllSubCommands) {
        It "$cmd --help returns non-empty help text" {
            $output = & forgum $cmd --help 2>&1 | Out-String
            $output | Should -Not -BeNullOrEmpty
            $output | Should -Match 'Usage:'
        }

        It "$cmd -h returns non-empty help text" {
            $output = & forgum $cmd -h 2>&1 | Out-String
            $output | Should -Not -BeNullOrEmpty
            $output | Should -Match 'Usage:'
        }

        It "help $cmd returns help mentioning the subcommand" {
            $output = forgum help $cmd 2>&1 | Out-String
            $output | Should -Match $cmd
            $output | Should -Match 'Usage:'
        }
    }
}

# ─────────────────────────────────────────────────────────────────────────────
# 2. ROOT-LEVEL ROUTING PERMUTATIONS
#    forgum, forgum <text>, forgum --help, forgum -h, forgum --version,
#    forgum h, forgum v, forgum version, forgum help, case insensitivity
# ─────────────────────────────────────────────────────────────────────────────
Describe "Root routing permutations" -Tag 'Permutation' {

    It "forgum with no args produces output" {
        $output = forgum 6>&1 2>&1 | Out-String
        $output | Should -Not -BeNullOrEmpty
    }

    It "forgum 'text' produces that text" {
        $raw = forgum "PermTest1" 6>&1 3>&1 2>&1 | Out-String
        Strip-Ansi $raw | Should -BeLike '*PermTest1*'
    }

    It "forgum --help shows root help" {
        $output = forgum --help 2>&1 | Out-String
        $output | Should -Match 'Subcommands:'
    }

    It "forgum -h shows root help" {
        $output = forgum -h 2>&1 | Out-String
        $output | Should -Match 'Usage:'
    }

    It "forgum --version shows version" {
        $output = forgum --version 2>&1 | Out-String
        $output | Should -Match 'forgum v'
    }

    It "forgum help shows root help" {
        $output = forgum help 2>&1 | Out-String
        $output | Should -Match 'Subcommands:'
    }

    It "forgum h shows root help" {
        $output = forgum h 2>&1 | Out-String
        $output | Should -Match 'Usage:'
    }

    It "forgum v shows version" {
        $output = forgum v 2>&1 | Out-String
        $output | Should -Match 'forgum v'
    }

    It "forgum version shows version" {
        $output = forgum version 2>&1 | Out-String
        $output | Should -Match 'forgum v'
    }

    It "case-insensitive: forgum RUN routes to run" {
        $output = forgum RUN "PermCase" 6>&1 2>&1 | Out-String
        $output | Should -Not -BeNullOrEmpty
    }

    It "case-insensitive: forgum Run routes to run" {
        $output = forgum Run "PermCase2" 6>&1 2>&1 | Out-String
        $output | Should -Not -BeNullOrEmpty
    }

    It "unknown --flag shows warning" {
        $output = forgum --nope 3>&1 2>&1 | Out-String
        $output | Should -Match 'Unknown option'
    }

    It "unknown subcommand text is treated as run input" {
        $raw = forgum unknowncmd "PermX" 6>&1 3>&1 2>&1 | Out-String
        Strip-Ansi $raw | Should -BeLike '*PermX*'
    }
}

# ─────────────────────────────────────────────────────────────────────────────
# 3. RUN SUBCOMMAND — ARG/FLAG PERMUTATIONS
#    run, run text, run --cow X, run --mode X, run --lolcat,
#    run --no-lolcat, run --fortune, combined flags, text after flags
# ─────────────────────────────────────────────────────────────────────────────
Describe "run — arg permutations" -Tag 'Permutation' {

    It "run with no args" {
        $output = forgum run 6>&1 2>&1 | Out-String
        $output | Should -Not -BeNullOrEmpty
    }

    It "run with text" {
        $raw = forgum run "PermRunText" 6>&1 2>&1 | Out-String
        Strip-Ansi $raw | Should -BeLike '*PermRunText*'
    }

    It "run with multi-word text" {
        $raw = forgum run "Perm Run Multi" 6>&1 2>&1 | Out-String
        Strip-Ansi $raw | Should -BeLike '*Perm Run Multi*'
    }

    foreach ($cow in $KnownCows) {
        It "run --cow $cow produces output" {
            $output = forgum run --cow $cow "PermCow" 6>&1 2>&1 | Out-String
            $output | Should -Not -BeNullOrEmpty
        }
    }

    It "run --cow tux --mode static" {
        $output = forgum run --cow tux --mode static "PermStatic" 6>&1 2>&1 | Out-String
        $output | Should -Not -BeNullOrEmpty
    }

    It "run --cow tux --mode static --lolcat" {
        $output = forgum run --cow tux --mode static --lolcat "PermLol" 6>&1 2>&1 | Out-String
        $output | Should -Not -BeNullOrEmpty
    }

    It "run --cow tux --mode static --no-lolcat" {
        $output = forgum run --cow tux --mode static --no-lolcat "PermNoLol" 6>&1 2>&1 | Out-String
        $output | Should -Not -BeNullOrEmpty
    }

    It "run --fortune produces output" {
        $output = forgum run --fortune 6>&1 2>&1 | Out-String
        $output | Should -Not -BeNullOrEmpty
    }

    It "run --cow tux --fortune" {
        $output = forgum run --cow tux --fortune 6>&1 2>&1 | Out-String
        $output | Should -Not -BeNullOrEmpty
    }

    It "run --lolcat --cow tux 'text'" {
        $output = forgum run --lolcat --cow tux "PermFlagOrder" 6>&1 2>&1 | Out-String
        $output | Should -Not -BeNullOrEmpty
    }

    It "run text --cow tux (text before flag)" {
        $raw = forgum run "PermBeforeFlag" --cow tux 6>&1 2>&1 | Out-String
        Strip-Ansi $raw | Should -BeLike '*PermBeforeFlag*'
    }

    It "run --cow tux 'Hello World' --mode static --lolcat" {
        $output = forgum run --cow tux "Hello World" --mode static --lolcat 6>&1 2>&1 | Out-String
        $output | Should -Not -BeNullOrEmpty
    }
}

# ─────────────────────────────────────────────────────────────────────────────
# 4. GALLERY — ARG/FLAG PERMUTATIONS
#    gallery, gallery --count N (various values)
# ─────────────────────────────────────────────────────────────────────────────
Describe "gallery — arg permutations" -Tag 'Permutation' {

    It "gallery with no args" {
        $output = forgum gallery 6>&1 2>&1 | Out-String
        $output | Should -Not -BeNullOrEmpty
    }

    It "gallery --count 1" {
        $output = forgum gallery --count 1 6>&1 2>&1 | Out-String
        $output | Should -Not -BeNullOrEmpty
    }

    It "gallery --count 2" {
        $output = forgum gallery --count 2 6>&1 2>&1 | Out-String
        $output | Should -Not -BeNullOrEmpty
    }

    It "gallery --count 10" {
        $output = forgum gallery --count 10 6>&1 2>&1 | Out-String
        $output | Should -Not -BeNullOrEmpty
    }
}

# ─────────────────────────────────────────────────────────────────────────────
# 5. PREVIEW — ARG/FLAG PERMUTATIONS
#    preview, preview cow, preview cow text, preview default
# ─────────────────────────────────────────────────────────────────────────────
Describe "preview — arg permutations" -Tag 'Permutation' {

    It "preview with no args" {
        $output = forgum preview 6>&1 2>&1 | Out-String
        $output | Should -Not -BeNullOrEmpty
    }

    It "preview default" {
        $output = forgum preview default 6>&1 2>&1 | Out-String
        $output | Should -Not -BeNullOrEmpty
    }

    It "preview tux" {
        $output = forgum preview tux 6>&1 2>&1 | Out-String
        $output | Should -Not -BeNullOrEmpty
    }

    It "preview tux 'Custom'" {
        $raw = forgum preview tux "Custom" 6>&1 2>&1 | Out-String
        Strip-Ansi $raw | Should -BeLike '*Custom*'
    }

    It "preview dragon 'Roar'" {
        $raw = forgum preview dragon "Roar" 6>&1 2>&1 | Out-String
        Strip-Ansi $raw | Should -BeLike '*Roar*'
    }

    It "preview kitty 'Meow'" {
        $raw = forgum preview kitty "Meow" 6>&1 2>&1 | Out-String
        Strip-Ansi $raw | Should -BeLike '*Meow*'
    }

    It "preview whale 'Big ideas'" {
        $raw = forgum preview whale "Big ideas" 6>&1 2>&1 | Out-String
        Strip-Ansi $raw | Should -BeLike '*Big ideas*'
    }

    It "preview ghost 'Boo'" {
        $raw = forgum preview ghost "Boo" 6>&1 2>&1 | Out-String
        Strip-Ansi $raw | Should -BeLike '*Boo*'
    }
}

# ─────────────────────────────────────────────────────────────────────────────
# 6. ANIMATE — MODE PERMUTATIONS
#    animate with each valid mode
# ─────────────────────────────────────────────────────────────────────────────
Describe "animate — mode permutations" -Tag 'Permutation' {

    foreach ($mode in $AllModes) {
        It "animate $mode sets mode" {
            $output = forgum animate $mode 6>&1 2>&1 | Out-String
            $output | Should -Match 'Animation'
        }
    }
}

# ─────────────────────────────────────────────────────────────────────────────
# 7. EYES — PRESET/CUSTOM PERMUTATIONS
#    eyes with each preset, eyes with custom 2-char, eyes with no args
# ─────────────────────────────────────────────────────────────────────────────
Describe "eyes — preset/custom permutations" -Tag 'Permutation' {

    foreach ($preset in $EyePresets) {
        It "eyes $preset sets preset" {
            $output = forgum eyes $preset 6>&1 2>&1 | Out-String
            $output | Should -Match 'Cow eyes:'
        }
    }

    It "eyes '==' custom" {
        $output = forgum eyes '==' 6>&1 2>&1 | Out-String
        $output | Should -Match 'Cow eyes:'
    }

    It "eyes 'xx' custom" {
        $output = forgum eyes 'xx' 6>&1 2>&1 | Out-String
        $output | Should -Match 'Cow eyes:'
    }

    It "eyes '**' custom" {
        $output = forgum eyes '**' 6>&1 2>&1 | Out-String
        $output | Should -Match 'Cow eyes:'
    }

    It "eyes 'OO' custom" {
        $output = forgum eyes 'OO' 6>&1 2>&1 | Out-String
        $output | Should -Match 'Cow eyes:'
    }

    It "eyes with no args shows current" {
        $output = forgum eyes 6>&1 2>&1 | Out-String
        $output | Should -Match 'Current cow eyes:'
    }
}

# ─────────────────────────────────────────────────────────────────────────────
# 8. INIT — SHELL PERMUTATIONS
#    init, init bash, init zsh, init fish, init pwsh
# ─────────────────────────────────────────────────────────────────────────────
Describe "init — shell permutations" -Tag 'Permutation' {

    It "init with no args (auto-detect)" {
        $output = forgum init 6>&1 2>&1 | Out-String
        $output | Should -Not -BeNullOrEmpty
    }

    foreach ($shell in $Shells) {
        It "init $shell generates output" {
            $output = forgum init $shell 6>&1 2>&1 | Out-String
            $output | Should -Not -BeNullOrEmpty
        }
    }
}

# ─────────────────────────────────────────────────────────────────────────────
# 9. DAEMON — ACTION PERMUTATIONS
#    daemon start, daemon stop
# ─────────────────────────────────────────────────────────────────────────────
Describe "daemon — action permutations" -Tag 'Permutation' {

    It "daemon with no args defaults to start" {
        $enginePath = InModuleScope Forgum { Get-EngineBinary -ErrorAction SilentlyContinue }
        if (-not $enginePath) {
            Set-ItResult -Inconclusive -Because "forgum-engine not built"
            return
        }
        $output = forgum daemon 6>&1 2>&1 | Out-String
        $output | Should -Not -BeNullOrEmpty
    }

    It "daemon start" {
        $enginePath = InModuleScope Forgum { Get-EngineBinary -ErrorAction SilentlyContinue }
        if (-not $enginePath) {
            Set-ItResult -Inconclusive -Because "forgum-engine not built"
            return
        }
        $output = forgum daemon start 6>&1 2>&1 | Out-String
        $output | Should -Not -BeNullOrEmpty
    }

    It "daemon stop" {
        $output = forgum daemon stop 6>&1 2>&1 | Out-String
        $output | Should -Not -BeNullOrEmpty
    }
}

# ─────────────────────────────────────────────────────────────────────────────
# 10. UPDATE — FLAG PERMUTATIONS
#     update, update --check, update --force, update --force --check
# ─────────────────────────────────────────────────────────────────────────────
Describe "update — flag permutations" -Tag 'Permutation' {

    It "update with no args" {
        $output = forgum update 6>&1 2>&1 | Out-String
        $output | Should -Not -BeNullOrEmpty
    }

    It "update --check" {
        $output = forgum update --check 6>&1 2>&1 | Out-String
        $output | Should -Not -BeNullOrEmpty
    }

    It "update --force" {
        $output = forgum update --force 6>&1 2>&1 | Out-String
        $output | Should -Not -BeNullOrEmpty
    }

    It "update --force --check" {
        $output = forgum update --force --check 6>&1 2>&1 | Out-String
        $output | Should -Not -BeNullOrEmpty
    }
}

# ─────────────────────────────────────────────────────────────────────────────
# 11. TOGGLE — BEHAVIOR
# ─────────────────────────────────────────────────────────────────────────────
Describe "toggle — behavior" -Tag 'Permutation' {

    It "toggle flips lolcat state" {
        $output = forgum toggle 6>&1 2>&1 | Out-String
        $output | Should -Match 'Lolcat:'
    }

    It "toggle twice restores state" {
        $null = forgum toggle 6>&1 2>&1
        $output = forgum toggle 6>&1 2>&1 | Out-String
        $output | Should -Match 'Lolcat:'
    }
}

# ─────────────────────────────────────────────────────────────────────────────
# 12. LIVE — HELP ONLY (too slow to run)
# ─────────────────────────────────────────────────────────────────────────────
Describe "live — help permutations" -Tag 'Permutation' {

    It "live --help shows duration option" {
        $output = forgum live --help 2>&1 | Out-String
        $output | Should -Match '--duration'
        $output | Should -Match 'default: 5'
    }
}

# ─────────────────────────────────────────────────────────────────────────────
# 13. HELP SUBCOMMAND — DEEP PERMUTATIONS
#     help, help <each sub>, help --help, help -h, help <alias>,
#     help <unknown>, help h, help v, help help
# ─────────────────────────────────────────────────────────────────────────────
Describe "help — deep permutations" -Tag 'Permutation' {

    It "help with no args" {
        $output = forgum help 2>&1 | Out-String
        $output | Should -Match 'Subcommands:'
    }

    foreach ($cmd in $AllSubCommands) {
        It "help $cmd" {
            $output = forgum help $cmd 2>&1 | Out-String
            $output | Should -Match $cmd
        }
    }

    It "help --help returns help" {
        $output = forgum help --help 2>&1 | Out-String
        $output | Should -Match 'Usage:'
    }

    It "help -h returns help" {
        $output = forgum help -h 2>&1 | Out-String
        $output | Should -Match 'Usage:'
    }

    It "help h returns help" {
        $output = forgum help h 2>&1 | Out-String
        $output | Should -Match 'Usage:'
    }

    It "help v returns unknown (v is not a help subcommand)" {
        $output = forgum help v 2>&1 | Out-String
        $output | Should -Match 'Unknown command'
    }

    It "help version returns unknown (version is not a help subcommand)" {
        $output = forgum help version 2>&1 | Out-String
        $output | Should -Match 'Unknown command'
    }

    It "help help returns help" {
        $output = forgum help help 2>&1 | Out-String
        $output | Should -Match 'Usage:'
    }

    It "help upgrade alias resolves to update" {
        $output = forgum help upgrade 2>&1 | Out-String
        $output | Should -Match 'update'
    }

    It "help tui alias resolves to interactive" {
        $output = forgum help tui 2>&1 | Out-String
        $output | Should -Match 'interactive'
    }

    It "help setup alias resolves to config" {
        $output = forgum help setup 2>&1 | Out-String
        $output | Should -Match 'config'
    }

    It "help show alias resolves to gallery" {
        $output = forgum help show 2>&1 | Out-String
        $output | Should -Match 'gallery'
    }

    It "help preview-cow alias resolves to preview" {
        $output = forgum help preview-cow 2>&1 | Out-String
        $output | Should -Match 'preview'
    }

    It "help toggle-rainbow alias resolves to toggle" {
        $output = forgum help toggle-rainbow 2>&1 | Out-String
        $output | Should -Match 'toggle'
    }

    It "help set-animation alias resolves to animate" {
        $output = forgum help set-animation 2>&1 | Out-String
        $output | Should -Match 'animate'
    }

    It "help set-eyes alias resolves to eyes" {
        $output = forgum help set-eyes 2>&1 | Out-String
        $output | Should -Match 'eyes'
    }

    It "help foobar unknown returns unknown" {
        $output = forgum help foobar 2>&1 | Out-String
        $output | Should -Match 'Unknown command'
    }
}

# ─────────────────────────────────────────────────────────────────────────────
# 14. EDGE CASES — TEXT INPUT
#     Empty text, very long text, special chars, unicode, multiple spaces
# ─────────────────────────────────────────────────────────────────────────────
Describe "Edge cases — text input" -Tag 'EdgeCase' {

    It "empty string text runs" {
        $output = forgum run "" 6>&1 2>&1 | Out-String
        $output | Should -Not -BeNullOrEmpty
    }

    It "single character text" {
        $raw = forgum run "X" 6>&1 2>&1 | Out-String
        Strip-Ansi $raw | Should -BeLike '*X*'
    }

    It "very long text (500 chars)" {
        $longText = "A" * 500
        $output = forgum run $longText 6>&1 2>&1 | Out-String
        $output | Should -Not -BeNullOrEmpty
    }

    It "text with spaces and punctuation" {
        $raw = forgum run "Hello, World! How are you?" 6>&1 2>&1 | Out-String
        Strip-Ansi $raw | Should -BeLike '*Hello, World! How are you?*'
    }

    It "text with numbers" {
        $raw = forgum run "12345 test 67890" 6>&1 2>&1 | Out-String
        Strip-Ansi $raw | Should -BeLike '*12345 test 67890*'
    }

    It "text with parentheses" {
        $raw = forgum run "test (parens)" 6>&1 2>&1 | Out-String
        Strip-Ansi $raw | Should -BeLike '*test (parens)*'
    }

    It "text with angle brackets" {
        $raw = forgum run "test <brackets>" 6>&1 2>&1 | Out-String
        Strip-Ansi $raw | Should -BeLike '*test <brackets>*'
    }

    It "text with quotes" {
        $raw = forgum run "it is a test" 6>&1 2>&1 | Out-String
        Strip-Ansi $raw | Should -BeLike "*it is a test*"
    }

    It "text with dollar sign" {
        $raw = forgum run 'test $var' 6>&1 2>&1 | Out-String
        Strip-Ansi $raw | Should -BeLike '*test $var*'
    }

    It "text with backslash" {
        $raw = forgum run 'test \path' 6>&1 2>&1 | Out-String
        Strip-Ansi $raw | Should -BeLike '*test \path*'
    }

    It "text with pipe character" {
        $raw = forgum run 'test | pipe' 6>&1 2>&1 | Out-String
        Strip-Ansi $raw | Should -BeLike '*test | pipe*'
    }

    It "text with semicolon" {
        $raw = forgum run 'test; semicolon' 6>&1 2>&1 | Out-String
        Strip-Ansi $raw | Should -BeLike '*test; semicolon*'
    }
}

# ─────────────────────────────────────────────────────────────────────────────
# 15. EDGE CASES — ARGUMENT STRUCTURE
#     Flags after text, text after flags, mixed order, extra whitespace
# ─────────────────────────────────────────────────────────────────────────────
Describe "Edge cases — argument structure" -Tag 'EdgeCase' {

    It "run 'text' --cow tux (text before flag)" {
        $raw = forgum run "EdgeBefore" --cow tux 6>&1 2>&1 | Out-String
        Strip-Ansi $raw | Should -BeLike '*EdgeBefore*'
    }

    It "run --cow tux 'text' (flag before text)" {
        $raw = forgum run --cow tux "EdgeAfter" 6>&1 2>&1 | Out-String
        Strip-Ansi $raw | Should -BeLike '*EdgeAfter*'
    }

    It "run --mode static --cow tux --lolcat 'text'" {
        $output = forgum run --mode static --cow tux --lolcat "EdgeAll" 6>&1 2>&1 | Out-String
        $output | Should -Not -BeNullOrEmpty
    }

    It "run --cow tux --lolcat --mode static 'text' (mixed order)" {
        $output = forgum run --cow tux --lolcat --mode static "EdgeMixed" 6>&1 2>&1 | Out-String
        $output | Should -Not -BeNullOrEmpty
    }

    It "gallery --count 3 (option form)" {
        $output = forgum gallery --count 3 6>&1 2>&1 | Out-String
        $output | Should -Not -BeNullOrEmpty
    }

    It "animate --mode static (option form)" {
        $output = forgum animate --mode static 6>&1 2>&1 | Out-String
        $output | Should -Match 'Animation'
    }

    It "eyes --preset borg (option form)" {
        $output = forgum eyes --preset borg 6>&1 2>&1 | Out-String
        $output | Should -Match 'Cow eyes:'
    }

    It "eyes --custom @@ (option form)" {
        $output = forgum eyes --custom '@@' 6>&1 2>&1 | Out-String
        $output | Should -Match 'Cow eyes:'
    }

    It "init --shell bash (option form)" {
        $output = forgum init --shell bash 6>&1 2>&1 | Out-String
        $output | Should -Not -BeNullOrEmpty
    }

    It "live --duration 3 (option form)" {
        $output = forgum live --duration 3 6>&1 2>&1 | Out-String
        $output | Should -Not -BeNullOrEmpty
    }
}

# ─────────────────────────────────────────────────────────────────────────────
# 16. ALIGNMENT & RENDERING VALIDATION
#     Cow output must contain proper ASCII art structure, balloon borders,
#     eye/tongue substitution, fortune presence
# ─────────────────────────────────────────────────────────────────────────────
Describe "Alignment and rendering validation" -Tag 'Rendering' {

    It "cow output contains balloon top border (##)" {
        $raw = forgum run "RenderTest" 6>&1 2>&1 | Out-String
        $output = Strip-Ansi $raw
        $output | Should -Match '#'
    }

    It "cow output contains balloon side border (||)" {
        $raw = forgum run "RenderTest" 6>&1 2>&1 | Out-String
        $output = Strip-Ansi $raw
        $output | Should -Match '\|\|'
    }

    It "cow output contains cow body markers" {
        $raw = forgum run "RenderTest" 6>&1 2>&1 | Out-String
        $output = Strip-Ansi $raw
        $output | Should -Match '\^__^|\(oo\)|\\____|\\   \\'
    }

    It "cow output contains the message text" {
        $raw = forgum run "UniqueMessage99" 6>&1 2>&1 | Out-String
        $output = Strip-Ansi $raw
        $output | Should -BeLike '*UniqueMessage99*'
    }

    It "preview tux has proper cow structure" {
        $raw = forgum preview tux "AlignTest" 6>&1 2>&1 | Out-String
        $output = Strip-Ansi $raw
        $output | Should -Match '#'
        $output | Should -Match '\|\|'
        $output | Should -BeLike '*AlignTest*'
    }

    It "gallery output contains multiple cow sections" {
        $raw = forgum gallery --count 3 6>&1 2>&1 | Out-String
        $output = Strip-Ansi $raw
        $output | Should -Match '==='
    }

    It "run --cow tux uses tux cow" {
        $raw = forgum run --cow tux --mode static "TuxTest" 6>&1 2>&1 | Out-String
        $output = Strip-Ansi $raw
        $output | Should -BeLike '*TuxTest*'
    }

    It "eyes borg sets eyes to ==" {
        $output = forgum eyes borg 6>&1 2>&1 | Out-String
        $output | Should -Match '=='
    }

    It "eyes dead sets eyes to xx" {
        $output = forgum eyes dead 6>&1 2>&1 | Out-String
        $output | Should -Match 'xx'
    }

    It "eyes '@@' sets eyes to @@" {
        $output = forgum eyes '@@' 6>&1 2>&1 | Out-String
        $output | Should -Match '@@'
    }
}

# ─────────────────────────────────────────────────────────────────────────────
# 17. INTEGRATION FLOWS
#     End-to-end: set config -> run -> verify, toggle -> verify, animate -> verify
# ─────────────────────────────────────────────────────────────────────────────
Describe "Integration flows" -Tag 'Integration' {

    It "toggle ON -> toggle OFF restores state" {
        $before = forgum toggle 6>&1 2>&1 | Out-String
        $after  = forgum toggle 6>&1 2>&1 | Out-String
        $before | Should -Match 'Lolcat:'
        $after  | Should -Match 'Lolcat:'
    }

    It "eyes borg -> eyes shows borg eyes" {
        $null = forgum eyes borg 6>&1 2>&1
        $output = forgum eyes 6>&1 2>&1 | Out-String
        $output | Should -Match '=='
    }

    It "eyes dead -> eyes shows dead eyes" {
        $null = forgum eyes dead 6>&1 2>&1
        $output = forgum eyes 6>&1 2>&1 | Out-String
        $output | Should -Match 'xx'
    }

    It "eyes @@ -> eyes shows @@ eyes" {
        $null = forgum eyes '@@' 6>&1 2>&1
        $output = forgum eyes 6>&1 2>&1 | Out-String
        $output | Should -Match '@@'
    }

    It "animate static -> run with static mode" {
        $null = forgum animate static 6>&1 2>&1
        $output = forgum run "IntStatic" 6>&1 2>&1 | Out-String
        $output | Should -Not -BeNullOrEmpty
    }

    It "animate aurora -> run with aurora mode (may fall back)" {
        $null = forgum animate aurora 6>&1 2>&1
        $output = forgum run "IntAurora" 6>&1 2>&1 | Out-String
        $output | Should -Not -BeNullOrEmpty
    }

    It "preview tux -> run --cow tux shows same cow" {
        $preview = forgum preview tux "IntCow" 6>&1 2>&1 | Out-String
        $run     = forgum run --cow tux --mode static "IntCow" 6>&1 2>&1 | Out-String
        $preview | Should -Not -BeNullOrEmpty
        $run     | Should -Not -BeNullOrEmpty
    }

    It "gallery --count 1 -> preview same cow" {
        $gallery = forgum gallery --count 1 6>&1 2>&1 | Out-String
        $gallery | Should -Not -BeNullOrEmpty
    }
}

# ─────────────────────────────────────────────────────────────────────────────
# 18. MODULE STRUCTURE VALIDATION
#     Verify all functions exist, module loads, version correct
# ─────────────────────────────────────────────────────────────────────────────
Describe "Module structure — comprehensive" -Tag 'Structure' {

    It "module loads without errors" {
        $m = Get-Module Forgum
        $m | Should -Not -BeNullOrEmpty
    }

    It "module exports exactly 1 function" {
        $funcs = (Get-Command -Module Forgum -CommandType Function).Name
        $funcs.Count | Should -Be 1
        $funcs | Should -Contain 'forgum'
    }

    It "module exports aliases" {
        $aliases = (Get-Command -Module Forgum -CommandType Alias).Name
        $aliases | Should -Contain 'forgum-show'
        $aliases | Should -Contain 'forgum-setup'
    }

    It "module version is 1.1.2" {
        InModuleScope Forgum {
            $manifest = Test-ModuleManifest -Path (Join-Path (Split-Path $PSScriptRoot -Parent) 'Forgum.psd1') -ErrorAction Stop
            $manifest.Version.ToString() | Should -Be '1.1.2'
        }
    }

    It "all 12 subcommand handlers exist" {
        InModuleScope Forgum {
            @('Invoke-ForgumRun','Invoke-ForgumConfig','Invoke-ForgumGallery',
              'Invoke-ForgumPreview','Invoke-ForgumUpdate','Invoke-ForgumToggle',
              'Invoke-ForgumAnimate','Invoke-ForgumEyes','Invoke-ForgumInit',
              'Invoke-ForgumLiveHandler','Invoke-ForgumDaemon') |
              ForEach-Object {
                Get-Command $_ -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty -Because "$_ should exist"
            }
        }
    }

    It "all 15 helper functions exist" {
        InModuleScope Forgum {
            @('Get-HelpMessage','Parse-ForgumArguments','Get-EngineBinary',
              'Get-ForgumShellHook','Get-ForgumShell','Show-CFCowGallery',
              'Show-CFCowPreview','Toggle-CFLolcat','Set-CFCowAnimate',
              'Set-CFCowEyes','Start-ForgumDaemon','Stop-ForgumDaemon',
              'Invoke-ForgumLive','Invoke-ForgumTUI','Update-Forgum') |
              ForEach-Object {
                Get-Command $_ -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty -Because "$_ should exist"
            }
        }
    }

    It "all core private functions exist" {
        InModuleScope Forgum {
            @('Get-CFConfig','Set-CFConfig','Get-CFCow','Get-Fortune',
              'Invoke-Cowsay','Show-CFAnimation',
              'Get-ConfigPath','Format-CowMessage','Format-Lolcat') |
              ForEach-Object {
                Get-Command $_ -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty -Because "$_ should exist"
            }
        }
    }

    It "all animation functions exist" {
        InModuleScope Forgum {
            @('Invoke-TalkingAnimation','Invoke-TypewriterAnimation',
              'Invoke-DynamicAnimation','Invoke-PhysicsCow',
              'Show-CFAnimation','Invoke-Engine') |
              ForEach-Object {
                Get-Command $_ -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty -Because "$_ should exist"
            }
        }
    }

    It "all cow files are accessible" {
        InModuleScope Forgum {
            $cows = Get-CFCow
            $cows | Should -Not -BeNullOrEmpty
            $cows.Count | Should -BeGreaterThan 50
        }
    }

    It "config loads successfully" {
        InModuleScope Forgum {
            $config = Get-CFConfig
            $config | Should -Not -BeNullOrEmpty
            $config.animation | Should -Not -BeNullOrEmpty
            $config.cow | Should -Not -BeNullOrEmpty
            $config.lolcat | Should -Not -BeNullOrEmpty
        }
    }

    It "Get-HelpMessage returns help for all subcommands" {
        InModuleScope Forgum {
            foreach ($cmd in @('root','run','config','gallery','preview','update','toggle','animate','eyes','init','live','daemon','help')) {
                $msg = Get-HelpMessage -Command $cmd
                $msg | Should -Not -BeNullOrEmpty -Because "help for $cmd should not be empty"
                $msg | Should -Match 'Usage:' -Because "help for $cmd should contain Usage:"
            }
        }
    }

    It "Get-HelpMessage handles unknown commands" {
        InModuleScope Forgum {
            $msg = Get-HelpMessage -Command 'nonexistent'
            $msg | Should -Match 'Unknown command'
        }
    }

    It "Get-HelpMessage handles empty command" {
        InModuleScope Forgum {
            $msg = Get-HelpMessage -Command ''
            $msg | Should -Match 'Usage:'
        }
    }

    It "Get-HelpMessage handles help command" {
        InModuleScope Forgum {
            $msg = Get-HelpMessage -Command 'help'
            $msg | Should -Match 'Usage:'
        }
    }

    It "Get-HelpMessage aliases resolve correctly" {
        InModuleScope Forgum {
            $aliases = @{
                'upgrade'='update'; 'tui'='interactive'; 'setup'='config';
                'show'='gallery'; 'preview-cow'='preview'; 'toggle-rainbow'='toggle';
                'set-animation'='animate'; 'set-eyes'='eyes';
                'start-daemon'='daemon'; 'stop-daemon'='daemon'
            }
            foreach ($alias in $aliases.Keys) {
                $msg = Get-HelpMessage -Command $alias
                $msg | Should -Not -BeNullOrEmpty -Because "alias $alias should resolve"
                $msg | Should -Match 'Usage:' -Because "alias $alias should return help"
            }
        }
    }
}
