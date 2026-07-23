#!/usr/bin/env bash

set -euo pipefail

timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
backup_root="${HOME}/.local/state/dotfiles/backups/${timestamp}"
backed_up=0

targets=(
  "${HOME}/.zshrc"
  "${HOME}/.gitconfig"
  "${HOME}/.tmux.conf"
  "${HOME}/.codex/AGENTS.md"
  "${HOME}/.claude/CLAUDE.md"
  "${HOME}/.copilot/copilot-instructions.md"
  "${HOME}/Library/Application Support/Code/User/settings.json"
  "${HOME}/Library/Application Support/Code/User/keybindings.json"
)

for target in "${targets[@]}"; do
  [[ -e "${target}" || -L "${target}" ]] || continue
  relative="${target#"${HOME}/"}"
  destination="${backup_root}/${relative}"
  mkdir -p "$(dirname "${destination}")"
  cp -a "${target}" "${destination}"
  backed_up=1
done

if [[ "${backed_up}" -eq 1 ]]; then
  printf 'Backed up existing managed files to %s\n' "${backup_root}"
fi
