#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
test_root=$(mktemp -d /tmp/tilde-compat-test.XXXXXX)
case "$test_root" in
  /tmp/tilde-compat-test.*) ;;
  *) printf 'Unsafe temporary path: %s\n' "$test_root" >&2; exit 1 ;;
esac
cleanup() { rm -rf -- "$test_root"; }
trap cleanup EXIT

export HOME="$test_root/home"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_STATE_HOME="$HOME/.state"
mock_bin="$test_root/bin"
mkdir -p -- "$HOME" "$mock_bin"

for command_path in /usr/bin/dirname /usr/bin/date /usr/bin/mkdir /usr/bin/readlink /usr/bin/mv /usr/bin/ln; do
  ln -s -- "$command_path" "$mock_bin/${command_path##*/}"
done
ln -s -- /bin/true "$mock_bin/fdfind"

PATH="$mock_bin" /bin/bash "$ROOT/scripts/setup-links.sh" >/dev/null
manifest="$XDG_STATE_HOME/tilde/links.manifest"
fd_target="$HOME/.local/bin/fd"
fd_source="$mock_bin/fdfind"
/usr/bin/grep -Fxq "$fd_target|$fd_source" "$manifest"

# Simulate the distribution command becoming unavailable between setup runs.
/bin/rm -- "$mock_bin/fdfind"
PATH="$mock_bin" /bin/bash "$ROOT/scripts/setup-links.sh" >/dev/null

[[ -L "$fd_target" ]]
[[ "$(/usr/bin/readlink -- "$fd_target")" == "$fd_source" ]]
/usr/bin/grep -Fxq "$fd_target|$fd_source" "$manifest"

printf 'Compatibility ownership test passed.\n'
