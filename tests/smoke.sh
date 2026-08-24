#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
cd "$ROOT"

for file in install.sh uninstall.sh scripts/*.sh tests/*.sh; do
  bash -n "$file"
done

bash ./tests/compat-ownership.sh >/dev/null

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

# Preflight must reject an external XDG target before touching ~/.zshrc.
safe_config_home="$XDG_CONFIG_HOME"
export XDG_CONFIG_HOME="$test_root/outside-home"
if bash ./scripts/setup-links.sh >/dev/null 2>&1; then
  printf 'Expected setup to reject XDG_CONFIG_HOME outside HOME\n' >&2
  exit 1
fi
[[ ! -L "$HOME/.zshrc" ]]
grep -q 'existing user config' "$HOME/.zshrc"
[[ ! -e "$XDG_STATE_HOME/tilde/links.manifest" ]]
export XDG_CONFIG_HOME="$safe_config_home"

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

if command -v zsh >/dev/null 2>&1; then
  mkdir -p -- "$test_root/one/project" "$test_root/two/project"
  zsh -d -c '
    source "$1"
    first=$(_tilde_session_name "$2/one/project")
    second=$(_tilde_session_name "$2/two/project")
    [[ "$first" != "$second" ]]
  ' _ "$ROOT/zsh/functions.zsh" "$test_root"
  ZDOTDIR="$HOME" zsh -d -i -c '[[ -n "$TILDE_ROOT" ]] && [[ -r "$TILDE_ROOT/zsh/functions.zsh" ]]'
fi

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

printf 'Tilde smoke test passed: %d managed links; repeated setup was idempotent.\n' "$first_links"
