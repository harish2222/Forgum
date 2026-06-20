# Optional: Zsh "command not found" suggestion for Forgum.
# Usage:
#   Copy/source from your ~/.zshrc (optional).
#
# This is conservative and only triggers when the typed command starts with "forgum".

_forgum_cmd_not_found_handler() {
  local cmd="$1"
  case "$cmd" in
    forgum*|Forgum*|FORGUM*)
      echo "Forgum: command '$cmd' not found. Did you mean: forgum ? or 'forgum help'?" >&2
      ;;
  esac
}

# Only install hook if zsh is present and add-zsh-hook is available.
if command -v add-zsh-hook >/dev/null 2>&1; then
  add-zsh-hook 'command_not_found_handler' _forgum_cmd_not_found_handler 2>/dev/null || true
fi
