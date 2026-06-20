# Optional: Bash "command not found" suggestion for Forgum.
# Usage:
#   source this file from your ~/.bashrc (or ~/.bash_profile).
#
# This is intentionally conservative: it only suggests forgum-related
# commands when the user already typed something that starts with "forgum".
#
_forgum_cmd_not_found_handle() {
  local cmd="$1"
  # Only handle potential forgum misspellings/prefixes
  case "$cmd" in
    forgum*|Forgum*|FORGUM*)
      echo "Forgum: command '$cmd' not found. Did you mean: forgum ? or 'forgum help'?"
      ;;
  esac
  return 127
}

# Only install handler if user shell supports it.
if ! declare -F command_not_found_handle >/dev/null 2>&1; then
  command_not_found_handle() { _forgum_cmd_not_found_handle "$@"; }
fi
