#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)/lib.sh"

dry_run=0
[[ "${1:-}" == --dry-run ]] && dry_run=1

recorded_link_source() {
  local wanted_target=$1 recorded_target recorded_source
  [[ -f "$TILDE_MANIFEST" && -L "$wanted_target" ]] || return 1
  while IFS='|' read -r recorded_target recorded_source; do
    if [[ "$recorded_target" == "$wanted_target" && "$(readlink -- "$wanted_target")" == "$recorded_source" ]]; then
      printf '%s\n' "$recorded_source"
      return 0
    fi
  done < "$TILDE_MANIFEST"
  return 1
}

sources=(
  "$TILDE_ROOT/zsh/.zshrc"
  "$TILDE_ROOT/tmux/.tmux.conf"
  "$TILDE_ROOT/nvim"
  "$TILDE_ROOT/atuin/config.toml"
  "$TILDE_ROOT/starship/starship.toml"
)
targets=(
  "$HOME/.zshrc"
  "$HOME/.tmux.conf"
  "${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
  "${XDG_CONFIG_HOME:-$HOME/.config}/atuin/config.toml"
  "${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml"
)
allow_missing_sources=(0 0 0 0 0)

# Debian-family packages expose these commands under collision-free names.
if command_exists fdfind && { ! command_exists fd || [[ -L "$HOME/.local/bin/fd" && "$(readlink -- "$HOME/.local/bin/fd")" == "$(command -v fdfind)" ]]; }; then
  sources+=("$(command -v fdfind)")
  targets+=("$HOME/.local/bin/fd")
  allow_missing_sources+=(0)
elif source_path=$(recorded_link_source "$HOME/.local/bin/fd"); then
  sources+=("$source_path")
  targets+=("$HOME/.local/bin/fd")
  allow_missing_sources+=(1)
fi
if command_exists batcat && { ! command_exists bat || [[ -L "$HOME/.local/bin/bat" && "$(readlink -- "$HOME/.local/bin/bat")" == "$(command -v batcat)" ]]; }; then
  sources+=("$(command -v batcat)")
  targets+=("$HOME/.local/bin/bat")
  allow_missing_sources+=(0)
elif source_path=$(recorded_link_source "$HOME/.local/bin/bat"); then
  sources+=("$source_path")
  targets+=("$HOME/.local/bin/bat")
  allow_missing_sources+=(1)
fi

# Validate the complete operation before changing the filesystem. This prevents
# an invalid later target from leaving earlier links installed but unrecorded.
for index in "${!sources[@]}"; do
  source_path=${sources[$index]}
  target=${targets[$index]}
  if [[ ! -e "$source_path" ]]; then
    if (( allow_missing_sources[$index] == 0 )) ||
      [[ "$(recorded_link_source "$target" 2>/dev/null || true)" != "$source_path" ]]; then
      die "Missing managed source: $source_path"
    fi
  fi
  case "$target" in
    "$HOME"/*) ;;
    *) die "Refusing to manage a path outside HOME: $target" ;;
  esac
done

backup_root="$TILDE_STATE_DIR/backups/$(date +%Y%m%d-%H%M%S)"
manifest_tmp="${TILDE_MANIFEST}.tmp.$$"
rollback_targets=()
rollback_sources=()
rollback_backups=()

rollback_setup() {
  local original_status=$1 index target source_path backup
  trap - ERR
  set +o errexit
  for (( index=${#rollback_targets[@]} - 1; index >= 0; index-- )); do
    target=${rollback_targets[$index]}
    source_path=${rollback_sources[$index]}
    backup=${rollback_backups[$index]}
    if [[ -L "$target" && "$(readlink -- "$target")" == "$source_path" ]]; then
      rm -- "$target"
    fi
    if [[ -n "$backup" && ( -e "$backup" || -L "$backup" ) && ! -e "$target" && ! -L "$target" ]]; then
      mkdir -p -- "$(dirname -- "$target")"
      mv -- "$backup" "$target"
    fi
  done
  rm -f -- "$manifest_tmp"
  warn "Setup failed; rolled back changes from this run"
  exit "$original_status"
}

if (( dry_run == 0 )); then
  mkdir -p -- "$TILDE_STATE_DIR"
  : > "$manifest_tmp"
  trap 'rollback_setup $?' ERR
fi

for index in "${!sources[@]}"; do
  source_path=${sources[$index]}
  target=${targets[$index]}

  if [[ -L "$target" && "$(readlink -- "$target")" == "$source_path" ]]; then
    success "Already linked: $target"
  else
    if [[ -e "$target" || -L "$target" ]]; then
      relative=${target#"$HOME"/}
      backup="$backup_root/$relative"
      if (( dry_run == 1 )); then
        info "Would back up $target to $backup"
      else
        mkdir -p -- "$(dirname -- "$backup")"
        mv -- "$target" "$backup"
        rollback_targets+=("$target")
        rollback_sources+=("$source_path")
        rollback_backups+=("$backup")
        success "Backed up: $target"
      fi
    elif (( dry_run == 0 )); then
      rollback_targets+=("$target")
      rollback_sources+=("$source_path")
      rollback_backups+=("")
    fi

    if (( dry_run == 1 )); then
      info "Would link $target -> $source_path"
    else
      mkdir -p -- "$(dirname -- "$target")"
      ln -s -- "$source_path" "$target"
      success "Linked: $target"
    fi
  fi

  if (( dry_run == 0 )); then
    printf '%s|%s\n' "$target" "$source_path" >> "$manifest_tmp"
  fi
done

if (( dry_run == 0 )); then
  mv -- "$manifest_tmp" "$TILDE_MANIFEST"
  trap - ERR
  success "Recorded managed links in $TILDE_MANIFEST"
fi
