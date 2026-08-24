#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
source "$ROOT/scripts/lib.sh"

skip_tools=0
dry_run=0
for argument in "$@"; do
  case "$argument" in
    --skip-tools) skip_tools=1 ;;
    --dry-run) dry_run=1 ;;
    -h|--help)
      printf 'usage: ./install.sh [--skip-tools] [--dry-run]\n'
      printf '  --skip-tools  configure dotfiles without installing system packages\n'
      printf '  --dry-run     show link and backup operations without changing files\n'
      exit 0
      ;;
    *) die "Unknown option: $argument" ;;
  esac
done

platform=$(detect_os)
printf 'Tilde installer\n\n'
info "Platform: $platform"
info "Repository: $ROOT"

if (( dry_run == 1 )); then
  info "Dry run: package installation is skipped"
elif (( skip_tools == 0 )); then
  "$ROOT/scripts/install-tools.sh"
else
  info "System package installation skipped"
fi

if (( dry_run == 1 )); then
  "$ROOT/scripts/setup-links.sh" --dry-run
else
  "$ROOT/scripts/setup-links.sh"
fi

printf '\n'
success "Tilde configuration complete"
if (( dry_run == 0 )); then
  info "Start a new Zsh session with: exec zsh"
  info "Check dependencies with: $ROOT/scripts/health-check.sh"
  info "Backups, if any, are under: $TILDE_STATE_DIR/backups"
fi
