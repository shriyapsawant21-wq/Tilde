# Find a file and open it in Neovim. Pass a query to seed fzf: ff config.
ff() {
  local selected
  _tilde_require fd fzf bat nvim || return 1
  selected=$(fd --type f --hidden --exclude .git --strip-cwd-prefix . |
    fzf --query "${*:-}" --select-1 --exit-0 \
      --preview 'bat --color=always --style=numbers,changes --line-range=:500 -- {}') || return
  [[ -n "$selected" ]] && nvim -- "$selected"
}

# Search file contents, preview the selected line, and open it in Neovim.
frg() {
  local query selection file line
  setopt localoptions extendedglob
  _tilde_require rg fzf bat nvim || return 1
  query="$*"
  if [[ -z "$query" ]]; then
    print -u2 'usage: frg <query>'
    return 2
  fi

  selection=$(rg --line-number --column --no-heading --color=always --smart-case -- "$query" . 2>/dev/null |
    fzf --ansi --delimiter=: --nth=1,2,4.. \
      --preview 'bat --color=always --style=numbers,changes --highlight-line {2} --line-range {2}: -- {1}' \
      --preview-window '+{2}-/2') || return
  selection=${selection//$'\e'\[[0-9;]##m/}
  file=${selection%%:*}
  line=${${selection#*:}%%:*}
  [[ -n "$file" && "$line" == <-> ]] && nvim "+${line}" -- "$file"
}

# Open a project in a stable, project-named tmux session.
dev() {
  local project session
  _tilde_require zoxide fzf tmux || return 1

  if (( $# > 0 )); then
    project=$(zoxide query -- "$@" 2>/dev/null) ||
      project=$(zoxide query -i -- "$@") || return
  else
    project=$(zoxide query -i) || return
  fi

  [[ -d "$project" ]] || {
    print -u2 "dev: not a directory: $project"
    return 1
  }

  session=${project:t}
  session=${session//[^A-Za-z0-9_-]/_}
  [[ -n "$session" ]] || session=project

  if [[ -n "$TMUX" ]]; then
    tmux has-session -t "=$session" 2>/dev/null ||
      tmux new-session -d -s "$session" -c "$project"
    tmux switch-client -t "=$session"
  else
    tmux new-session -A -s "$session" -c "$project"
  fi
}

_tilde_require() {
  local tool missing=0
  for tool in "$@"; do
    if ! command -v "$tool" >/dev/null 2>&1; then
      print -u2 "Tilde: required command not found: $tool"
      missing=1
    fi
  done
  return "$missing"
}
