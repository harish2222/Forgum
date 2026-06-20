# Fish completion for Forgum (forgum CLI wrapper)
# To enable:
#   - Copy this file to: ~/.config/fish/completions/forgum.fish
#     (or /usr/share/fish/vendor_completions.d/forgum.fish)
#
# Completion targets:
#   - Root subcommands
#   - Common flags/args

function __forgum_subcommands
    echo run cowsay list theme export history config interactive toggle animate eyes init daemon live gallery preview update help
end

complete -c forgum -n '__fish_use_subcommand' -a '(__forgum_subcommands)' -d 'forgum subcommand'

# Flags
complete -c forgum -s h -l help -d 'Show help'
complete -c forgum -l version -d 'Show version'
complete -c forgum -l cow -d 'Cow template name'
complete -c forgum -l eyes -d 'Custom eyes (2 chars)'
complete -c forgum -l tongue -d 'Custom tongue (2 chars)'
complete -c forgum -l mode -d 'Animation mode'
complete -c forgum -l count -d 'Number of times to run'
complete -c forgum -l lolcat -d 'Enable rainbow colors'
complete -c forgum -l no-lolcat -d 'Disable rainbow colors'
complete -c forgum -l fortune -d 'Force new random fortune'
complete -c forgum -l no-color -d 'Disable colors'
complete -c forgum -l format -d 'Output format (txt, ansi)'
complete -c forgum -l output -d 'Output file path'
complete -c forgum -l search -d 'Search cow templates'
complete -c forgum -l clear -d 'Clear history'
complete -c forgum -l duration -d 'Animation duration'
complete -c forgum -l force -d 'Force update'
complete -c forgum -l check -d 'Only check for update'
complete -c forgum -l thoughts -d 'Thought bubble character'
complete -c forgum -l preset -d 'Eye preset name'
complete -c forgum -l custom -d 'Custom eye characters'
