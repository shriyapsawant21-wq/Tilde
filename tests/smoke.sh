#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
cd "$ROOT"

for file in install.sh uninstall.sh scripts/*.sh tests/*.sh; do
  bash -n "$file"
done

test_root=$(mktemp -d /tmp/tilde-test.XXXXXX)
case "$test_root" in
  /tmp/tilde-test.*) ;;
  *) printf 'Unsafe temporary path: %s\n' "$test_root" >&2; exit 1 ;;
esac
cleanup() { rm -rf -- "$test_root"; }
trap cleanup EXIT

export HOME="$test_root/home"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_STATE_HOME="$HOME/.state"
mkdir -p -- "$HOME"
printf '%s\n' '# existing user config' > "$HOME/.zshrc"

bash ./install.sh --dry-run >/dev/null
bash ./scripts/setup-links.sh >/dev/null
first_links=$(wc -l < "$XDG_STATE_HOME/tilde/links.manifest")
first_backups=$(find "$XDG_STATE_HOME/tilde/backups" -type f | wc -l)

(( first_links >= 5 ))
[[ -L "$HOME/.zshrc" ]]
find "$XDG_STATE_HOME/tilde/backups" -type f -name .zshrc | grep -q .

bash ./scripts/setup-links.sh >/dev/null
second_links=$(wc -l < "$XDG_STATE_HOME/tilde/links.manifest")
second_backups=$(find "$XDG_STATE_HOME/tilde/backups" -type f | wc -l)
[[ "$first_links" -eq "$second_links" ]]
[[ "$first_backups" -eq "$second_backups" ]]

# A user replacement must survive uninstall.
rm -- "$HOME/.tmux.conf"
printf '%s\n' '# user replacement' > "$HOME/.tmux.conf"

bash ./uninstall.sh >/dev/null
[[ ! -e "$HOME/.zshrc" ]]
[[ ! -e "$XDG_CONFIG_HOME/nvim" ]]
[[ -f "$HOME/.tmux.conf" ]]
grep -q 'user replacement' "$HOME/.tmux.conf"
[[ ! -e "$XDG_STATE_HOME/tilde/links.manifest" ]]
find "$XDG_STATE_HOME/tilde/backups" -type f -name .zshrc | grep -q .

if command -v zsh >/dev/null 2>&1; then
  ZDOTDIR="$HOME" zsh -i -c '[[ -n "$TILDE_ROOT" ]] && [[ -r "$TILDE_ROOT/zsh/functions.zsh" ]]'
fi

printf 'Tilde smoke test passed: %d managed links; repeated setup was idempotent.\n' "$first_links"
