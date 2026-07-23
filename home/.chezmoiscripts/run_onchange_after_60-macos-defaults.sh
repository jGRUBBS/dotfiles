#!/usr/bin/env bash

set -euo pipefail

if [[ "$(defaults read -g KeyRepeat 2>/dev/null || true)" != "1" ]]; then
  defaults write -g KeyRepeat -int 1
fi

if [[ "$(defaults read -g InitialKeyRepeat 2>/dev/null || true)" != "10" ]]; then
  defaults write -g InitialKeyRepeat -int 10
fi
