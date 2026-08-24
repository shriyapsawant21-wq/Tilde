# Intentionally small and predictable. Icons are opt-in with TILDE_ICONS=1.
if [[ "${TILDE_ICONS:-0}" == 1 ]]; then
  alias l='eza --group-directories-first --icons=auto'
  alias ll='eza --long --header --git --group-directories-first --icons=auto'
  alias la='eza --long --header --git --all --group-directories-first --icons=auto'
  alias lt='eza --tree --level=2 --group-directories-first --icons=auto'
else
  alias l='eza --group-directories-first'
  alias ll='eza --long --header --git --group-directories-first'
  alias la='eza --long --header --git --all --group-directories-first'
  alias lt='eza --tree --level=2 --group-directories-first'
fi
alias bcat='bat --paging=auto --style=numbers,changes,header'
alias lg='lazygit'
alias v='nvim'
