#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)/lib.sh"

[[ "$(uname -s)" == Linux ]] || die "Tool installation supports Linux and WSL only."
manager=$(detect_package_manager) || die "No supported package manager found (apt, dnf, pacman, or zypper)."

if (( EUID == 0 )); then
  elevate=()
elif command_exists sudo; then
  elevate=(sudo)
else
  die "Installing system packages requires root or sudo. Re-run with --skip-tools to configure only."
fi

case "$manager" in
  apt-get)
    packages=(zsh git fzf ripgrep fd-find bat eza jq yq lazygit neovim tmux atuin zoxide starship zsh-autosuggestions zsh-syntax-highlighting)
    info "Refreshing apt metadata (may prompt for your password)"
    "${elevate[@]}" apt-get update
    install_command=("${elevate[@]}" apt-get install -y)
    ;;
  dnf)
    packages=(zsh git fzf ripgrep fd-find bat eza jq yq lazygit neovim tmux atuin zoxide starship zsh-autosuggestions zsh-syntax-highlighting)
    install_command=("${elevate[@]}" dnf install -y)
    ;;
  pacman)
    packages=(zsh git fzf ripgrep fd bat eza jq yq lazygit neovim tmux atuin zoxide starship zsh-autosuggestions zsh-syntax-highlighting)
    info "Refreshing pacman package metadata (may prompt for your password)"
    "${elevate[@]}" pacman -Sy
    install_command=("${elevate[@]}" pacman -S --needed --noconfirm)
    ;;
  zypper)
    packages=(zsh git fzf ripgrep fd bat eza jq yq lazygit neovim tmux atuin zoxide starship zsh-autosuggestions zsh-syntax-highlighting)
    install_command=("${elevate[@]}" zypper --non-interactive install)
    ;;
esac

failed=()
for package in "${packages[@]}"; do
  if "${install_command[@]}" "$package"; then
    success "Package ready: $package"
  else
    failed+=("$package")
    warn "Package unavailable from configured repositories: $package"
  fi
done

if (( ${#failed[@]} > 0 )); then
  printf '\nSome optional or recently packaged tools were unavailable:\n  %s\n' "${failed[*]}" >&2
  printf 'Tilde did not run third-party remote installers. Install these tools from their official packages, then run scripts/health-check.sh.\n' >&2
fi
