#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

TILDE_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
TILDE_STATE_DIR=${XDG_STATE_HOME:-"$HOME/.local/state"}/tilde
TILDE_MANIFEST="$TILDE_STATE_DIR/links.manifest"

info() { printf '  \033[36m→\033[0m %s\n' "$*"; }
success() { printf '  \033[32m✓\033[0m %s\n' "$*"; }
warn() { printf '  \033[33m!\033[0m %s\n' "$*" >&2; }
die() { printf '  \033[31m✗\033[0m %s\n' "$*" >&2; exit 1; }

command_exists() { command -v "$1" >/dev/null 2>&1; }

detect_os() {
  [[ "$(uname -s)" == Linux ]] || die "Unsupported operating system: $(uname -s). V1 supports Linux and WSL."
  if grep -qi microsoft /proc/version 2>/dev/null; then
    printf 'wsl\n'
  else
    printf 'linux\n'
  fi
}

detect_package_manager() {
  local manager
  for manager in apt-get dnf pacman zypper; do
    if command_exists "$manager"; then
      printf '%s\n' "$manager"
      return 0
    fi
  done
  return 1
}
