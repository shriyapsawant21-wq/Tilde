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

# Debian-family packages expose these commands under collision-free names.
if command_exists fdfind && { ! command_exists fd || [[ -L "$HOME/.local/bin/fd" && "$(readlink -- "$HOME/.local/bin/fd")" == "$(command -v fdfind)" ]]; }; then
  sources+=("$(command -v fdfind)")
  targets+=("$HOME/.local/bin/fd")
elif source_path=$(recorded_link_source "$HOME/.local/bin/fd"); then
  sources+=("$source_path")
  targets+=("$HOME/.local/bin/fd")
fi
if command_exists batcat && { ! command_exists bat || [[ -L "$HOME/.local/bin/bat" && "$(readlink -- "$HOME/.local/bin/bat")" == "$(command -v batcat)" ]]; }; then
  sources+=("$(command -v batcat)")
  targets+=("$HOME/.local/bin/bat")
elif source_path=$(recorded_link_source "$HOME/.local/bin/bat"); then
  sources+=("$source_path")
  targets+=("$HOME/.local/bin/bat")
fi

# Validate the complete operation before changing the filesystem. This prevents
# an invalid later target from leaving earlier links installed but unrecorded.
for index in "${!sources[@]}"; do
  source_path=${sources[$index]}
  target=${targets[$index]}
  if [[ ! -e "$source_path" ]]; then
    [[ "$(recorded_link_source "$target" 2>/dev/null || true)" == "$source_path" ]] ||
      die "Missing managed source: $source_path"
  fi
  case "$target" in
    "$HOME"/*) ;;
    *) die "Refusing to manage a path outside HOME: $target" ;;
  esac
done

backup_root="$TILDE_STATE_DIR/backups/$(date +%Y%m%d-%H%M%S)"
manifest_tmp="${TILDE_MANIFEST}.tmp.$$"

if (( dry_run == 0 )); then
  mkdir -p -- "$TILDE_STATE_DIR"
  : > "$manifest_tmp"
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
        success "Backed up: $target"
      fi
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
  success "Recorded managed links in $TILDE_MANIFEST"
fi
