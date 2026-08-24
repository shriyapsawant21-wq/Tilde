# Keybindings

## Zsh and Atuin

| Key | Action |
| --- | --- |
| `Ctrl+R` | Open Atuin fuzzy history search |
| `Ctrl+T` | fzf file selection when the distribution's fzf shell binding is enabled |
| `Alt+C` | fzf directory selection when the distribution's fzf shell binding is enabled |

Tilde sets the fzf data-source environment variables but does not source an unverified, distribution-specific binding path. `ff` and `dev` provide portable alternatives.

## tmux

The prefix is `Ctrl+A`.

| Key | Action |
| --- | --- |
| `Ctrl+A`, `|` | Split horizontally in the current directory |
| `Ctrl+A`, `-` | Split vertically in the current directory |
| `Ctrl+A`, `c` | Create a window in the current directory |
| `Ctrl+A`, `r` | Reload `~/.tmux.conf` |
| `Ctrl+H/J/K/L` | Move across tmux panes or Neovim splits |
| `v` in copy mode | Begin selection |
| `y` in copy mode | Copy and leave copy mode |

## Neovim

The leader key is `Space`.

| Key | Action |
| --- | --- |
| `<leader>w` | Write the current file |
| `<leader>q` | Close the current window |
| `<leader>e` | Open the built-in file explorer |
| `<leader>ff` | Find files with fd and fzf |
| `<leader>fg` | Search text with ripgrep and fzf |
| `<leader>gg` | Open lazygit in a terminal split |
| `Ctrl+H/J/K/L` | Move between splits; tmux handles the outer edge |
| `gd` | Go to LSP definition |
| `gr` | List LSP references |
| `K` | Show LSP hover documentation |
| `<leader>rn` | Rename an LSP symbol |
| `<leader>ca` | Request an LSP code action |
