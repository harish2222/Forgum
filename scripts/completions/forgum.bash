# Bash completion for Forgum (forgum CLI wrapper)
# Usage:
#   1) Copy this file into a bash-completion directory or source it directly.
#   2) Ensure bash-completion is installed:
#        sudo apt-get install bash-completion
#   3) Reload your shell.
#
# Completion covers:
#   forgum <subcommand> and Action text tokens
#   args: --lolcat, --cow, --eyes, --mode, --count, --format, --output, etc.

_forgum_subcommands="run cowsay list theme export history config interactive toggle animate eyes init daemon live gallery preview update help"

_forgum_complete() {
  local cur prev
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  # Complete subcommands
  local sub
  for sub in $_forgum_subcommands; do
    if [[ "$sub" == "$cur"* ]]; then
      COMPREPLY+=("$sub")
    fi
  done

  # Complete known flags/args
  if [[ "$cur" == -* ]]; then
    COMPREPLY+=(
      $(compgen -W "--help --version --cow --eyes --tongue --thoughts --mode --count --lolcat --no-lolcat --fortune --no-color --format --output --search --clear --duration --force --check --preset --custom" -- "$cur")
    )
    return 0
  fi

  # Subcommand-specific completions
  case "$prev" in
    --cow|--eyes|--tongue|--thoughts|--mode|--format|--output|--search|--preset|--custom)
      # Expecting user input (no further completion)
      ;;
  esac

  return 0
}

# Register completion for `forgum` command
complete -F _forgum_complete forgum
