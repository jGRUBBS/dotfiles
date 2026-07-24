#!/usr/bin/env bash

set -euo pipefail

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

if ! command -v pipx >/dev/null 2>&1; then
  printf 'pipx is unavailable after Homebrew bundle.\n' >&2
  exit 1
fi

# AWS CLI v2 is managed by Homebrew. Remove the old pipx-managed v1 package so
# ~/.local/bin/aws cannot take precedence over Homebrew on PATH.
if pipx list --short 2>/dev/null | grep -Eq '^awscli([[:space:]]|$)'; then
  pipx uninstall awscli
fi

if pipx list --short 2>/dev/null | grep -Eq '^awsebcli([[:space:]]|$)'; then
  pipx upgrade awsebcli
else
  pipx install awsebcli
fi
