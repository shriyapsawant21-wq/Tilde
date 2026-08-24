#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
source "$ROOT/scripts/lib.sh"

printf 'Tilde uninstaller\n\n'

if [[ ! -f "$TILDE_MANIFEST" ]]; then
  info "No managed-link manifest found; nothing to remove"
  exit 0
fi

removed=0
preserved=0
while IFS='|' read -r target source_path; do
  [[ -n "$target" && -n "$source_path" ]] || continue
  if [[ -L "$target" && "$(readlink -- "$target")" == "$source_path" ]]; then
    rm -- "$target"
    success "Removed managed link: $target"
    removed=$((removed + 1))
  elif [[ -e "$target" || -L "$target" ]]; then
    warn "Preserved changed or unrelated path: $target"
    preserved=$((preserved + 1))
  fi
done < "$TILDE_MANIFEST"

rm -- "$TILDE_MANIFEST"
printf '\nRemoved %d managed link(s); preserved %d changed path(s).\n' "$removed" "$preserved"
info "Backups and persistent application data were not deleted"
info "System packages installed for Tilde were not removed"
