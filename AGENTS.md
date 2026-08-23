# Contributor and Agent Guide

## Role and context

You are an assistant to the contributor, not an autonomous maintainer. Help the contributor understand, review, and safely implement each change. Agents may accelerate the work, but they must not replace human understanding or approval.

Tilde is a local-first dotfiles project that integrates existing open-source terminal tools. It is not a terminal emulator, a shell, or a general-purpose package manager. Linux and WSL are the V1 targets; keep future macOS support possible without prematurely implementing it.

Read `README.md` first. When present, consult relevant files in `docs/` before changing architecture, supported platforms, install behavior, commands, keybindings, or tool configuration.

## Current phase

The repository is currently in the documentation and design phase. Do not implement the terminal environment, create its planned file structure, or install tools unless the user explicitly asks to begin implementation. Keep documentation honest about what exists today versus what is planned.

## Non-negotiable rules

Do not:

- make broad changes before inspecting the relevant files and existing patterns
- stage, commit, push, create branches, or open pull requests unless explicitly requested
- bypass hooks or validation with options such as `--no-verify`
- expose secrets, commit credentials, or add machine-specific private data
- add telemetry, cloud services, paid services, AI APIs, accounts, or API keys
- enable Atuin cloud sync or require an Atuin account
- add arbitrary shell execution or unreviewed remote-script execution
- overwrite or delete existing user dotfiles
- delete persistent user data, including Atuin history, without explicit confirmation
- require `sudo` when a user-level alternative is practical
- hardcode values that should be configurable
- create a duplicate mechanism when an existing module or script already owns the behavior
- add a dependency without a clear, documented purpose
- claim a command, configuration, installer, or platform was tested when it was not

## Workflow

Before editing:

1. Inspect the repository state and the files relevant to the request.
2. Read `README.md` and any applicable documentation.
3. Separate current behavior from planned behavior.
4. State material assumptions and clarify choices that would significantly change scope or safety.
5. Choose the smallest coherent change that satisfies the request.

While editing:

- Follow existing style and keep changes scoped.
- Prefer simple, auditable shell over clever abstractions.
- Quote shell variables and paths safely.
- Validate inputs and handle errors explicitly.
- Keep repeated installation and uninstallation safe.
- Add comments only where intent or safety is not obvious from the code.
- Update documentation alongside changes to behavior, architecture, commands, keybindings, dependencies, or supported platforms.

After editing:

- Review the diff for unrelated or machine-specific changes.
- Run checks proportional to the change.
- Report exactly what was and was not validated.
- Give the contributor a concise handoff using the format below.

```text
Assumptions:
Files changed:
What changed:
Why:
How it works:
How to test manually:
Validation performed:
Risks and known limitations:
What you should understand before committing:
Alternatives considered:
```

## Project-specific quality standards

### Installation and file safety

- Installation must be idempotent: reruns must not duplicate entries or damage configuration.
- Detect the operating system and package manager; fail clearly on unsupported environments.
- Back up a conflicting file before replacing it or creating a link.
- Track what Tilde manages so uninstallation removes only Tilde-owned links and configuration.
- Prefer symlinks where they make ownership clear and remain portable.
- Never use broad or unvalidated destructive paths.
- Explain every privileged operation before it runs.
- Avoid opaque `curl | sh` installation. Prefer trusted package managers or verified, documented release artifacts.

### Shell configuration

- Zsh is the primary shell; keep startup lightweight and measure performance when adding initialization code.
- Avoid a heavy dependency on Oh My Zsh.
- Preserve standard utilities such as `cat`; expose enhancements through predictable aliases such as `bcat`.
- Guard optional integrations so a missing tool does not make the shell unusable.
- Every custom alias, function, environment variable, and keybinding must be documented.

### Tool integration

- Favor cohesive workflows over a large plugin collection.
- Use fd, fzf, and bat together for file search and previews.
- Use ripgrep, fzf, bat, and Neovim for interactive text search.
- Use zoxide with fzf for directory and project selection.
- Keep the first `dev <project>` implementation reliable: locating a directory and attaching to or creating a tmux session is sufficient.
- Add automatic pane layouts only after the simpler workflow is stable and tested.

### Neovim and tmux

- Keep Neovim minimal, understandable, and LSP-ready; do not build a large distribution from scratch.
- Keep plugins few, pinned or reproducible where practical, and documented.
- Make tmux and Neovim navigation consistent without fragile keybinding tricks.
- Treat session persistence as optional unless it can be implemented cleanly.

## Validation expectations

Use the checks relevant to the files changed. Before calling V1 complete, validate:

- shell script syntax
- a clean installation in a supported environment
- repeated installation
- backup and link behavior
- conservative uninstallation
- health-check output for present and missing tools
- aliases and custom functions
- Atuin, zoxide, and fzf initialization
- tmux configuration loading
- Neovim startup without errors

Prefer an isolated test home or disposable Linux/WSL environment for installer tests. Never test destructive behavior against the contributor's real dotfiles. If a required tool or platform is unavailable, say so and document the untested path.

## Scope discipline

V1 should be polished, small, and dependable. Do not turn Tilde into its own shell, terminal emulator, operating system, plugin manager, or general dotfiles framework. When a feature threatens reliability, implement the simpler version and document the extension as future work.
