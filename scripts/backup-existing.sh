#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)/lib.sh"

(( $# > 0 )) || die "usage: backup-existing.sh <path> [path ...]"

backup_root="$TILDE_STATE_DIR/backups/$(date +%Y%m%d-%H%M%S)"
created=0

for target in "$@"; do
  [[ -e "$target" || -L "$target" ]] || continue
  relative=${target#"$HOME"/}
  [[ "$relative" != "$target" ]] || die "Refusing to back up a path outside HOME: $target"
  destination="$backup_root/$relative"
  mkdir -p -- "$(dirname -- "$destination")"
  mv -- "$target" "$destination"
  success "Backed up $target to $destination"
  created=1
done

(( created == 1 )) || info "Nothing needed a backup"
