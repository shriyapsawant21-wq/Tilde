#!/usr/bin/env bash

set -o nounset
set -o pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)/lib.sh"

printf 'Terminal Environment Health\n\n'

commands=(zsh git atuin zoxide fzf rg fd bat eza jq yq lazygit nvim tmux)
labels=(zsh git atuin zoxide fzf ripgrep fd bat eza jq yq lazygit neovim tmux)
missing=()

for index in "${!commands[@]}"; do
  command=${commands[$index]}
  label=${labels[$index]}
  if command_exists "$command"; then
    printf '\033[32m✓\033[0m %s\n' "$label"
  else
    printf '\033[31m✗\033[0m %s\n' "$label"
    missing+=("$command")
  fi
done

printf '\n'
if (( ${#missing[@]} == 0 )); then
  printf 'All systems ready.\n'
  exit 0
fi

printf '%d tool(s) missing: %s\n' "${#missing[@]}" "${missing[*]}"
if [[ " ${missing[*]} " == *' fd '* ]] && command_exists fdfind; then
  printf 'fd is installed as fdfind; run ./install.sh --skip-tools to create the managed compatibility link.\n'
fi
if [[ " ${missing[*]} " == *' bat '* ]] && command_exists batcat; then
  printf 'bat is installed as batcat; run ./install.sh --skip-tools to create the managed compatibility link.\n'
fi
if manager=$(detect_package_manager 2>/dev/null); then
  printf 'Run ./install.sh to install packages with %s, or install them through your trusted package source.\n' "$manager"
else
  printf 'Install the missing commands through your distribution package manager.\n'
fi
exit 1
