#!/usr/bin/env bash

set -o errexit
set -o nounset

source_path=${1:-}
/usr/bin/mv "$@"

if [[ "$source_path" == *'/links.manifest.tmp.'* ]]; then
  kill -TERM "$PPID"
fi
