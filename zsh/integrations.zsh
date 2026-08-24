export EDITOR=nvim
export VISUAL=nvim
export PAGER='less -FRX'
export BAT_PAGER='less -FRX'

# User-local binaries and Debian/Ubuntu compatibility links live here.
[[ -d "$HOME/.local/bin" ]] && path=("$HOME/.local/bin" $path)
export PATH

export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
export FZF_DEFAULT_OPTS='--height=60% --layout=reverse --border --info=inline --cycle'

if command -v fzf >/dev/null 2>&1; then
  if fzf --zsh >/dev/null 2>&1; then
    source <(fzf --zsh)
  elif [[ -r /usr/share/doc/fzf/examples/key-bindings.zsh ]]; then
    source /usr/share/doc/fzf/examples/key-bindings.zsh
  fi
fi

if command -v starship >/dev/null 2>&1; then
  export STARSHIP_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml"
  eval "$(starship init zsh)"
else
  PROMPT='%F{cyan}%1~%f %(?..%F{red}[%?]%f )%# '
fi

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh --cmd z)"
fi

# The official user-local Atuin installer exposes its binary through this file.
# Load it only when present, then keep initialization guarded and single-shot.
if [[ -r "$HOME/.atuin/bin/env" ]]; then
  source "$HOME/.atuin/bin/env"
fi
if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init zsh --disable-up-arrow)"
fi

# Distribution packages install these in different locations, so load only a
# readable installation. They are optional and never gate shell startup.
for _tilde_plugin in \
  /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
  /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh; do
  [[ -r "$_tilde_plugin" ]] && source "$_tilde_plugin" && break
done
for _tilde_plugin in \
  /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh; do
  [[ -r "$_tilde_plugin" ]] && source "$_tilde_plugin" && break
done
unset _tilde_plugin
