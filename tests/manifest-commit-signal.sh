#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
test_root=$(mktemp -d /tmp/tilde-manifest-signal-test.XXXXXX)
case "$test_root" in
  /tmp/tilde-manifest-signal-test.*) ;;
  *) printf 'Unsafe temporary path: %s\n' "$test_root" >&2; exit 1 ;;
esac
cleanup() { rm -rf -- "$test_root"; }
trap cleanup EXIT

export HOME="$test_root/home"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_STATE_HOME="$HOME/.state"
mock_bin="$test_root/bin"
mkdir -p -- "$HOME" "$mock_bin"

cp -- "$ROOT/tests/fixtures/signal-after-manifest-mv.sh" "$mock_bin/mv"
chmod +x -- "$mock_bin/mv"

PATH="$mock_bin:$PATH" bash "$ROOT/scripts/setup-links.sh" >/dev/null

manifest="$XDG_STATE_HOME/tilde/links.manifest"
[[ -f "$manifest" ]]
[[ -L "$HOME/.zshrc" ]]
grep -Fq "$HOME/.zshrc|$ROOT/zsh/.zshrc" "$manifest"

printf 'Manifest commit signal test passed.\n'
