#!/usr/bin/env bash

set -euo pipefail

if ! command -v pipx >/dev/null 2>&1; then
  printf 'pipx is unavailable after Homebrew bundle.\n' >&2
  exit 1
fi

for package in awscli awsebcli; do
  if pipx list --short 2>/dev/null | grep -Fq "${package}"; then
    pipx upgrade "${package}"
  else
    pipx install "${package}"
  fi
done
