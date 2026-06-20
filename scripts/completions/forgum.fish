# Fish completion for Forgum (forgum CLI wrapper)
# To enable:
#   - Copy this file to: ~/.config/fish/completions/forgum.fish
#     (or /usr/share/fish/vendor_completions.d/forgum.fish)
#
# Completion targets:
#   - Root subcommands / Action tokens
#   - Common flags/args

function __forgum_subcommands
    echo update upgrade config tui setup gallery preview toggle animate eyes help
end

# fish completion function
function forgum
    # no-op: this function name is used by fish completion system only
end

complete -c forgum -n '__fish_use_subcommand' -a '(__forgum_subcommands)' -d 'forgum subcommand'

# Generic flags completion (best-effort)
complete -c forgum -s h -l help -d 'Show help'
complete -c forgum -l Lolcat -d 'Force lolcat mode on'
complete -c forgum -l Cow -d 'Alias/cow file override for invocation'
complete -c forgum -l CowFile -d 'Cow file name'
complete -c forgum -l Animation -d 'Animation mode override'
complete -c forgum -l Count -d 'Gallery count'
complete -c forgum -l PreviewCow -d 'Preview cow name'
complete -c forgum -l PreviewText -d 'Preview text'
complete -c forgum -l Mode -d 'Animation mode to set globally'
complete -c forgum -l Preset -d 'Eyes preset'
complete -c forgum -l CustomEyes -d 'Custom eyes (2 chars)'
complete -c forgum -l Force -d 'Force update'
complete -c forgum -l CheckOnly -d 'Only check for update'
complete -c forgum -l Background -d 'Enable background for some animations'
