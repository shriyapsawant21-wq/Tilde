#!/usr/bin/env bash

set -o errexit
set -o nounset

count=0
[[ -f "$TILDE_TEST_LN_COUNT" ]] && read -r count < "$TILDE_TEST_LN_COUNT"
count=$((count + 1))
printf '%d\n' "$count" > "$TILDE_TEST_LN_COUNT"

if (( count == 2 )); then
  kill -TERM "$PPID"
  exit 0
fi

exec /usr/bin/ln "$@"
