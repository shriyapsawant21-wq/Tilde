# Tools and integrations

| Tool | Role in Tilde | Integration |
| --- | --- | --- |
| Atuin | Local shell history | Initializes Zsh history search on `Ctrl+R`; cloud sync and update checks are disabled |
| zoxide | Smart directory navigation | Provides `z`; powers project discovery in `dev` |
| fzf | Fuzzy selection | Used by `ff`, `frg`, `dev`, and Neovim pickers |
| ripgrep | Text search | Feeds matching files and lines into fzf |
| fd | File search | Feeds `.gitignore`-aware file lists into fzf |
| bat | File preview | Shows highlighted fzf previews and powers `bcat` |
| eza | Directory listing | Powers `l`, `ll`, `la`, and `lt` |
| jq | JSON processing | Installed as a focused data utility; no alias changes its interface |
| yq | YAML processing | Installed as a focused data utility; no alias changes its interface |
| lazygit | Git TUI | Available as `lg` and `<leader>gg` in Neovim |
| Neovim | Editor | Set as `EDITOR` and `VISUAL`; includes plugin-free file/text pickers and LSP mappings |
| tmux | Sessions | Provides persistent project sessions and Neovim-aware navigation |
| Starship | Optional prompt | Shows directory, Git state, failure status, and a small prompt character |

## Optional shell enhancements

Zsh autosuggestions and syntax highlighting are loaded from common distribution package locations when installed. They are optional and guarded so shell startup remains reliable.

Icons are off by default. Set `TILDE_ICONS=1` before `.zshrc` loads if a Nerd Font and compatible terminal are available.
