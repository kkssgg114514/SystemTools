#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  printf 'Usage: %s "<file-path>"\n' "$(basename "$0")" >&2
  exit 1
fi

path="$1"

if [[ ! -e "$path" ]]; then
  printf 'Path does not exist: %s\n' "$path" >&2
  exit 1
fi

if [[ -d "$path" ]]; then
  printf 'Directory input is not supported. Please provide a file path.\n' >&2
  exit 1
fi

md5sum -- "$path" | awk '{print toupper($1)}'
