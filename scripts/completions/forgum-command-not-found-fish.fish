# Optional fish "command not found" suggestion for Forgum.
# Usage: source this file from your config.fish.
#
# Fish doesn't have a direct command_not_found_handle equivalent like Bash,
# but we can hook into command-not-found events via a function.

function __forgum_cmd_not_found --on-event fish_command_not_found
    set -l cmd $argv[1]
    if test -n "$cmd"
        switch -s -q "$cmd"
            case forgum* Forgum* FORGUM*
                echo "Forgum: command '$cmd' not found. Did you mean 'forgum' or 'forgum help'?" >&2
        end
    end
end
