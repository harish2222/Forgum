# Bash completion for Forgum (forgum CLI wrapper)
# Usage:
#   1) Copy this file into a bash-completion directory or source it directly.
#   2) Ensure bash-completion is installed:
#        sudo apt-get install bash-completion
#   3) Reload your shell.
#
# Completion covers:
#   forgum <subcommand> and Action text tokens
#   args: -Lolcat, -Cow, -CowFile, -Count, -PreviewCow, -PreviewText, -Mode, -Preset, -CustomEyes
#
# Note: This completion assumes the root CLI command is named `forgum`.

_forgum_subcommands="update upgrade config tui setup gallery preview toggle animate eyes help"

_forgum_complete() {
  local cur prev word
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  # If completing subcommands / action token
  local sub
  for sub in $_forgum_subcommands; do
    if [[ "$sub" == "$cur"* ]]; then
      COMPREPLY+=("$sub")
    fi
  done

  # If completing known flags/args
  if [[ "$cur" == -* ]]; then
    COMPREPLY+=(
      $(compgen -W "-Lolcat -Cow -Animation -CowFile -Count -PreviewCow -PreviewText -Mode -Preset -CustomEyes -Force -CheckOnly -Background" -- "$cur")
    )
    return 0
  fi

  return 0
}

# Register completion for `forgum` command
complete -F _forgum_complete forgum
