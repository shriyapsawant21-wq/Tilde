# Architecture

## Goals

Tilde is a small integration layer over established terminal tools. Configuration lives in this repository, user-facing paths are symlinks, and lifecycle behavior is implemented in auditable Bash scripts.

## Components

```text
install.sh
├── scripts/install-tools.sh   distribution packages only
└── scripts/setup-links.sh     backup, link, and record ownership
    ├── zsh/                   shell entry point and integrations
    ├── atuin/                 local history settings
    ├── starship/              optional minimal prompt
    ├── tmux/                  sessions and pane navigation
    └── nvim/                  plugin-free editor configuration

uninstall.sh
└── links.manifest             removes only unchanged managed links
```

## Link ownership and backups

The link manifest is stored at `${XDG_STATE_HOME:-$HOME/.local/state}/tilde/links.manifest`. Each entry records an absolute target and source. On rerun, an already-correct link is retained. Any conflicting file, directory, or link is moved beneath a timestamped `backups/` directory before the Tilde link is created.

Uninstall compares every current link with its recorded source. A changed link, regular file, or unrelated path is preserved. Backups are not automatically restored because choosing which historical version to restore requires human judgment.

## Package installation

`install-tools.sh` detects apt, dnf, pacman, or zypper. Packages are requested individually so one unavailable newer tool does not prevent installation of the core stack. Tilde does not execute remote installer scripts. Package names and availability vary by distribution release; the health check is the source of truth after installation.

## Configuration loading

`.zshrc` resolves the repository from its own symlink target and loads three focused files. Optional programs are guarded with command checks, so missing Atuin, zoxide, Starship, or shell plugins cannot prevent an interactive shell from starting.

Neovim intentionally has no plugin bootstrap in V1. It uses built-in Lua APIs plus the installed fd, ripgrep, and fzf binaries. Language servers remain user-selected: `LspAttach` adds common mappings whenever an LSP client is configured by the user or a future Tilde module.

## Supported platforms

V1 accepts Linux kernels and detects WSL through `/proc/version`. Native Windows and macOS are rejected. The configuration itself avoids Linux-only paths except for optional distribution-installed Zsh plugins and tmux process inspection.
