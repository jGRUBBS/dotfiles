#!/usr/bin/env bash

set -euo pipefail

if xcode-select -p >/dev/null 2>&1; then
  exit 0
fi

printf 'The Xcode Command Line Tools are required.\n' >&2
printf 'Starting the Apple installer. Re-run the bootstrap after it finishes.\n' >&2
xcode-select --install
exit 1
