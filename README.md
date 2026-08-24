# Tilde

> Forge your terminal.

Tilde is a reproducible, local-first terminal development environment for Linux and WSL. It configures a focused set of open-source CLI and TUI tools as one cohesive workflow without replacing your terminal emulator or shell.

No account, cloud service, telemetry, paid API, or AI API is required. Atuin history stays local.

## Demo

<!-- Add a screenshot or terminal recording after validating V1 on representative Linux and WSL systems. -->

_Screenshot and terminal demo coming after cross-distribution validation._

## Features

- Safe, idempotent setup with timestamped backups before any conflicting path is replaced
- Local fuzzy shell history through Atuin and `Ctrl+R`
- Smart `z` navigation and project lookup through zoxide
- Integrated file and text workflows using fd, ripgrep, fzf, bat, and Neovim
- A focused set of eza, lazygit, and editor aliases
- Persistent project sessions through `dev <project>` and tmux
- Consistent `Ctrl+H/J/K/L` navigation across Neovim splits and tmux panes
- Minimal, plugin-free Neovim configuration with built-in LSP-ready mappings
- Readable dependency health check and conservative uninstaller

## Tool stack

| Tool | Purpose |
| --- | --- |
| [Atuin](https://atuin.sh/) | Local, context-aware shell history |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Smart directory navigation |
| [fzf](https://github.com/junegunn/fzf) | General-purpose fuzzy finding |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | Fast recursive text search |
| [fd](https://github.com/sharkdp/fd) | Fast, `.gitignore`-aware file search |
| [bat](https://github.com/sharkdp/bat) | Syntax-highlighted file previews |
| [eza](https://github.com/eza-community/eza) | Modern directory listings and trees |
| [jq](https://jqlang.github.io/jq/) | JSON querying and formatting |
| [yq](https://github.com/mikefarah/yq) | YAML querying and formatting |
| [lazygit](https://github.com/jesseduffield/lazygit) | Terminal Git interface |
| [Neovim](https://neovim.io/) | Primary terminal editor |
| [tmux](https://github.com/tmux/tmux) | Persistent sessions and workspaces |
| [Starship](https://starship.rs/) | Small, optional contextual prompt |

See [docs/tools.md](docs/tools.md) for how these tools interact.

## Architecture

```text
.
├── install.sh                 setup entry point
├── uninstall.sh               managed-link removal
├── zsh/                       shell, aliases, functions, integrations
├── tmux/                      session and navigation configuration
├── nvim/                      plugin-free Lua configuration
├── atuin/                     local-only history configuration
├── starship/                  minimal prompt
├── scripts/                   packages, backups, links, health check
├── tests/                     isolated lifecycle smoke test
└── docs/                      architecture, tools, and keybindings
```

Configuration remains in the repository and is linked into the home directory. Tilde records those links under `${XDG_STATE_HOME:-$HOME/.local/state}/tilde`; see [docs/architecture.md](docs/architecture.md) for the ownership and backup model.

## Installation

V1 supports Linux and WSL. Review the scripts, then run:

```sh
./install.sh
```

The installer detects apt, dnf, pacman, or zypper, requests packages from configured distribution repositories, backs up conflicting configuration, and creates managed symlinks. Package installation may prompt for `sudo`; configuration itself does not need it.

Useful modes:

```sh
./install.sh --dry-run       # preview links and backups; install nothing
./install.sh --skip-tools    # configure only; install no system packages
```

Tilde deliberately does not run third-party `curl | sh` installers. Some tools may be absent from an older distribution repository; the installer reports each unavailable package and continues. Install any remaining tools from their official package source, then run the health check.

Start a fresh shell after installation:

```sh
exec zsh
```

## Usage and custom commands

| Command | Behavior |
| --- | --- |
| `ff [query]` | Find a file with fd and fzf, preview it with bat, and open it in Neovim |
| `frg <query>` | Search with ripgrep, preview a selected match, and open Neovim at its line |
| `dev [project]` | Select a zoxide directory and create or attach to a path-unique tmux session |
| `z <directory>` | Jump to a frequently used directory through zoxide |
| `l` | Compact eza listing |
| `ll` | Detailed eza listing with Git information |
| `la` | Detailed listing including hidden files |
| `lt` | Two-level tree view |
| `bcat` | View with bat while preserving normal `cat` |
| `lg` | Open lazygit |
| `v` | Open Neovim |

`EDITOR` and `VISUAL` are set to `nvim`. File icons remain off unless `TILDE_ICONS=1` is exported before Zsh starts.

## Keybindings

- `Ctrl+R` opens Atuin history search.
- `Ctrl+H/J/K/L` moves across Neovim splits and tmux panes.
- tmux uses `Ctrl+A` as its prefix.
- Neovim uses `Space` as its leader; `<leader>ff`, `<leader>fg`, and `<leader>gg` open files, text search, and lazygit.

The complete reference is in [docs/keybindings.md](docs/keybindings.md).

## Configuration

Edit the tracked source files in this repository; linked user paths reflect changes immediately. Rerun `./install.sh --skip-tools` if a managed link is missing.

Atuin is configured with sync and network update checks disabled. Zsh autosuggestions and syntax highlighting load only when their distribution packages are present. Starship is optional; a small native Zsh prompt is the fallback.

Neovim does not install plugins or language servers. It provides fd/fzf file selection, ripgrep/fzf text selection, lazygit access, and standard mappings whenever a separately configured LSP client attaches.

## Updating

Review repository changes, update your checkout, and reconcile links without reinstalling packages:

```sh
./install.sh --skip-tools
./scripts/health-check.sh
```

## Uninstallation

```sh
./uninstall.sh
```

Uninstall removes only links that still point to their recorded Tilde sources. Changed or unrelated paths, timestamped backups, Atuin history, other persistent data, and system packages are preserved. Backups are not restored automatically; inspect `${XDG_STATE_HOME:-$HOME/.local/state}/tilde/backups` and restore the desired version manually.

## Health check

```sh
./scripts/health-check.sh
```

The check reports Zsh, Git, Atuin, zoxide, fzf, ripgrep, fd, bat, eza, jq, yq, lazygit, Neovim, and tmux. It exits nonzero when anything is missing.

## Testing

Run the Linux-native lifecycle test with:

```sh
bash ./tests/smoke.sh
```

It uses a temporary home directory to verify dry-run behavior, conflict backup, link creation, repeated setup, conservative uninstall, and Zsh startup when Zsh is installed. It never targets real user dotfiles.

## Troubleshooting

### A command is missing after installation

Run the health check. Distribution releases differ, and newer tools such as Atuin, eza, or lazygit may not exist in an older configured repository. Use the tool's official package instructions rather than an unreviewed remote script.

### `fd` or `bat` has a different name on Debian/Ubuntu

Those distributions may install `fdfind` and `batcat`. During link setup, Tilde creates managed user-level command aliases in `~/.local/bin` when needed. Ensure that directory is in `PATH`.

### Existing dotfiles disappeared

They were moved, not deleted. Look under `${XDG_STATE_HOME:-$HOME/.local/state}/tilde/backups/<timestamp>/`.

### tmux and Neovim navigation does not cross a boundary

Confirm `ps` and `grep` are installed, reload tmux with `Ctrl+A`, `r`, and verify the current program name is recognizable as Neovim.

### A search path contains a colon

The V1 `frg` and Neovim text picker use ripgrep's colon-delimited output. Linux filenames may legally contain colons, but matches in such paths cannot be parsed reliably yet. Use `rg` directly for that uncommon case.

## Roadmap

- [x] Safe link ownership, backups, and conservative uninstall
- [x] Lightweight Zsh and local-only Atuin configuration
- [x] Integrated file, text, directory, Git, editor, and tmux workflows
- [x] Minimal plugin-free Neovim configuration
- [x] Health check and distribution-package installer
- [ ] Validate on representative Ubuntu, Fedora, Arch, openSUSE, and WSL images
- [ ] Add automated container-based installation tests
- [ ] Add a screenshot and terminal recording
- [ ] Evaluate optional tmux session persistence
- [ ] Evaluate macOS support after V1 stabilizes

## Contributing

Read [AGENTS.md](AGENTS.md) before changing the project. Keep work scoped, explain new dependencies, preserve user configuration, and document every custom command and binding.

## License

Tilde is available under the [MIT License](LICENSE).
