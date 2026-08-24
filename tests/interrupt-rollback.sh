#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
test_root=$(mktemp -d /tmp/tilde-interrupt-test.XXXXXX)
case "$test_root" in
  /tmp/tilde-interrupt-test.*) ;;
  *) printf 'Unsafe temporary path: %s\n' "$test_root" >&2; exit 1 ;;
esac
cleanup() { rm -rf -- "$test_root"; }
trap cleanup EXIT

export HOME="$test_root/home"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_STATE_HOME="$HOME/.state"
export TILDE_TEST_LN_COUNT="$test_root/ln-count"
mock_bin="$test_root/bin"
mkdir -p -- "$HOME" "$mock_bin"
printf '%s\n' '# original zsh configuration' > "$HOME/.zshrc"

cp -- "$ROOT/tests/fixtures/interrupting-ln.sh" "$mock_bin/ln"
chmod +x -- "$mock_bin/ln"

if PATH="$mock_bin:$PATH" bash "$ROOT/scripts/setup-links.sh" >/dev/null 2>&1; then
  printf 'Expected setup interruption to return a failure status\n' >&2
  exit 1
fi

[[ ! -L "$HOME/.zshrc" ]]
grep -q 'original zsh configuration' "$HOME/.zshrc"
[[ ! -e "$HOME/.tmux.conf" ]]
[[ ! -e "$XDG_STATE_HOME/tilde/links.manifest" ]]

printf 'Interrupt rollback test passed.\n'
