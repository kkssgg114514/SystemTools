#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
  printf 'Usage: %s "<text>" ["<salt>"]\n' "$(basename "$0")" >&2
  exit 1
fi

text="$1"
salt="${2-}"

printf '%s' "${text}${salt}" | sha256sum | awk '{print toupper($1)}'
