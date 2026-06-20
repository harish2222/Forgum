# Optional fish "command not found" suggestion for Forgum.
# Usage: source this file from your config.fish.

function __forgum_cmd_not_found --on-event fish_command_not_found
    set -l cmd $argv[1]
    if test -n "$cmd"
        switch "$cmd"
            case 'forgum*' 'Forgum*' 'FORGUM*'
                echo "Forgum: command '$cmd' not found. Did you mean 'forgum' or 'forgum help'?" >&2
        end
    end
end
