# Tilde

> Forge your terminal.

Tilde is a planned, reproducible, local-first developer terminal environment for Linux and WSL. It will bring a focused set of open-source CLI and TUI tools together behind one safe, idempotent setup—without replacing your terminal emulator or shell.

> **Project status:** documentation and design phase. The installer and configurations described below have not been implemented yet.

## Why Tilde?

Excellent terminal tools are easy to install individually but harder to make cohesive, portable, and safe. Tilde aims to provide a fast, keyboard-driven environment that can be cloned onto a fresh machine and configured with one command while preserving existing dotfiles.

The project is guided by a few principles:

- Local-first: no accounts, cloud services, paid APIs, telemetry, or AI APIs.
- Safe: existing configuration is backed up and never blindly overwritten.
- Reproducible: setup is scripted, documented, and idempotent.
- Focused: every dependency has a clear purpose; integrations matter more than quantity.
- Maintainable: lightweight Zsh and Neovim configurations instead of large frameworks.

## Demo

<!-- Replace this placeholder with a screenshot or short terminal recording once V1 is implemented. -->

_Demo coming with the first working release._

## Planned features

- Local shell history search with Atuin and `Ctrl+R`
- Smart directory navigation with zoxide
- Fuzzy file, directory, and text search using fzf, fd, ripgrep, and bat
- Predictable directory-listing aliases powered by eza
- JSON and YAML workflows with jq and yq
- Git workflows through lazygit
- A minimal, LSP-ready Neovim configuration
- Persistent development sessions with tmux
- A `dev <project>` workflow for opening projects in named tmux sessions
- Safe installation, uninstallation, backups, and a readable health check

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

Zsh will be the primary shell. Starship may provide a small prompt if it adds enough value without hurting startup time.

## Planned architecture

The repository will use a conventional dotfiles layout with configuration grouped by tool and orchestration kept in auditable shell scripts:

```text
.
├── README.md
├── AGENTS.md
├── LICENSE
├── install.sh
├── uninstall.sh
├── zsh/
├── tmux/
├── nvim/
├── atuin/
├── starship/
├── scripts/
│   ├── install-tools.sh
│   ├── setup-links.sh
│   ├── health-check.sh
│   └── backup-existing.sh
└── docs/
    ├── tools.md
    ├── keybindings.md
    └── architecture.md
```

This layout may evolve during implementation when a simpler structure improves safety or maintainability.

## Installation

Installation is not available yet. The planned entry point is:

```sh
./install.sh
```

The installer will target Linux and WSL first. It will detect the platform and available package manager, install missing tools where appropriate, back up conflicting configuration, create managed links, and summarize any manual follow-up. Running it repeatedly must be safe.

Do not run installation commands copied from this README until the scripts are present and reviewed.

## Usage

The following interface is planned for V1:

| Command | Planned behavior |
| --- | --- |
| `ff` | Find a file with fd and fzf, with a bat preview |
| `frg <query>` | Search text with ripgrep, preview a match, and open it in Neovim |
| `dev <project>` | Find a project and create or attach to its tmux session |
| `l` | Compact eza listing |
| `ll` | Detailed eza listing with useful Git information |
| `la` | Listing including hidden files |
| `lt` | Tree view |
| `bcat` | View a file with bat without replacing `cat` |
| `lg` | Open lazygit |
| `v` | Open Neovim |

`EDITOR` and `VISUAL` will both be set to `nvim`.

## Keybindings

Exact bindings will be documented and tested during implementation. The intended defaults include:

- `Ctrl+R` for Atuin history search
- Consistent navigation between tmux panes and Neovim splits
- Standard tmux windows, splits, and mouse support

Bindings will avoid surprising overrides and will be collected in `docs/keybindings.md`.

## Configuration

Tilde will keep tool-specific configuration in this repository and link it into the appropriate user configuration directories. Machine-specific credentials and secrets must never be committed. Optional features such as icons will only be enabled when terminal and font support are available.

Atuin will operate locally in V1; cloud sync and account setup will not be configured.

## Updating

The planned update workflow is to pull reviewed repository changes and rerun `./install.sh`. The installer must reconcile managed configuration without duplicating entries or damaging unrelated user files.

## Uninstallation

The planned uninstaller is:

```sh
./uninstall.sh
```

It will remove only links and configuration managed by Tilde. Persistent user data, including Atuin history, will remain untouched unless the user explicitly requests its deletion.

## Troubleshooting

A planned `./scripts/health-check.sh` command will report the availability of Zsh, Git, and every tool in the stack, then provide actionable installation guidance for anything missing.

Until implementation begins, please open an issue with your operating system, distribution, shell version, and the behavior you expected.

## Roadmap

- [ ] Define and document the V1 architecture
- [ ] Add safe backup and symlink management
- [ ] Implement an idempotent Linux/WSL installer
- [ ] Configure Zsh and the core CLI integrations
- [ ] Add minimal Neovim and tmux configurations
- [ ] Implement `ff`, `frg`, and the simple `dev` workflow
- [ ] Add health checks and a conservative uninstaller
- [ ] Validate clean and repeated installations
- [ ] Add screenshots and a short demo
- [ ] Evaluate macOS support after V1 stabilizes

## Contributing

Read [AGENTS.md](./AGENTS.md) before making changes. Keep contributions small, explain new dependencies, preserve user configuration, and document every custom command or binding.

## License

A license has not been selected yet. Add a `LICENSE` file before distributing a release.
