#!/usr/bin/env bash

set -o errexit
set -o nounset

count=0
[[ -f "$TILDE_TEST_MV_COUNT" ]] && read -r count < "$TILDE_TEST_MV_COUNT"
count=$((count + 1))
printf '%d\n' "$count" > "$TILDE_TEST_MV_COUNT"

/usr/bin/mv "$@"
if (( count == 1 )); then
  kill -TERM "$PPID"
fi
