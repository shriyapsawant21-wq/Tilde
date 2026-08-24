# Tilde's Zsh entry point. `%N` identifies this file even when it is sourced;
# `:A` resolves the managed symlink before finding the repository root.
export TILDE_ROOT="${${(%):-%N}:A:h:h}"

setopt AUTO_CD
setopt AUTO_PUSHD
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt INTERACTIVE_COMMENTS
setopt NO_BEEP
setopt PUSHD_IGNORE_DUPS

autoload -Uz compinit
_tilde_zcompdump="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
mkdir -p -- "${_tilde_zcompdump:h}"
if [[ ! -s "$_tilde_zcompdump" || "$_tilde_zcompdump" -ot "${ZDOTDIR:-$HOME}/.zshrc" ]]; then
  compinit -d "$_tilde_zcompdump" 2>/dev/null || compinit -C -d "$_tilde_zcompdump" 2>/dev/null
else
  compinit -C -d "$_tilde_zcompdump" 2>/dev/null
fi
unset _tilde_zcompdump

source "$TILDE_ROOT/zsh/aliases.zsh"
source "$TILDE_ROOT/zsh/functions.zsh"
source "$TILDE_ROOT/zsh/integrations.zsh"

. "$HOME/.atuin/bin/env"

eval "$(atuin init zsh)"
