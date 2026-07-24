#!/usr/bin/env bash

set -u

failures=0
warnings=0

pass() {
  printf 'PASS  %s\n' "$1"
}

fail() {
  printf 'FAIL  %s\n' "$1" >&2
  failures=$((failures + 1))
}

warn() {
  printf 'WARN  %s\n' "$1" >&2
  warnings=$((warnings + 1))
}

for command in aws brew chezmoi git gh jq python3 shellcheck ssh ssh-keygen zsh; do
  if command -v "${command}" >/dev/null 2>&1; then
    pass "${command} is installed"
  else
    fail "${command} is missing"
  fi
done

if command -v aws >/dev/null 2>&1; then
  if aws --version 2>&1 | grep -Eq '^aws-cli/2\.'; then
    pass 'AWS CLI v2 is installed'
  else
    fail 'AWS CLI is not version 2'
  fi
fi

for command in bws code codex claude copilot docker; do
  if command -v "${command}" >/dev/null 2>&1; then
    pass "${command} is installed"
  else
    warn "${command} is missing or not on PATH"
  fi
done

if zsh -dfc 'source ~/.zshrc' >/dev/null 2>&1; then
  pass 'zsh configuration loads'
else
  fail 'zsh configuration does not load'
fi

if python3 -c \
  'import pathlib,tomllib; tomllib.loads(pathlib.Path.home().joinpath(".codex/config.toml").read_text())' \
  >/dev/null 2>&1; then
  pass 'Codex configuration is valid TOML'
else
  fail 'Codex configuration is missing or invalid'
fi

for config in "${HOME}/.claude/settings.json" "${HOME}/.copilot/settings.json"; do
  if python3 -m json.tool "${config}" >/dev/null 2>&1; then
    pass "${config} is valid JSON"
  else
    fail "${config} is missing or invalid"
  fi
done

if security find-generic-password \
  -a "${USER}" \
  -s dotfiles-bws-access-token \
  -w >/dev/null 2>&1; then
  pass 'BWS access token is present in Keychain'
else
  warn 'BWS access token is absent; run dotfiles secrets bootstrap'
fi

aws_credentials="${HOME}/.aws/credentials"
if [[ ! -f "${aws_credentials}" ]]; then
  warn 'AWS credentials are missing; run dotfiles aws sync'
elif "${HOME}/.local/bin/dotfiles-aws-sync" --check >/dev/null 2>&1; then
  pass 'AWS shared credentials are valid and permission-locked'
else
  fail 'AWS shared credentials are invalid or have unsafe permissions'
fi

composer_sync="${HOME}/.local/bin/dotfiles-composer-sync"
if [[ ! -x "${composer_sync}" ]]; then
  warn 'Composer auth sync is not installed; run dotfiles apply'
else
  "${composer_sync}" --check >/dev/null 2>&1
  composer_status=$?
  case "${composer_status}" in
    0) pass 'Composer config and auth are valid and permission-locked' ;;
    3) warn 'Composer config or auth is missing; run dotfiles composer sync' ;;
    *) fail 'Composer config or auth is invalid or has unsafe permissions' ;;
  esac
fi

ssh_sync="${HOME}/.local/bin/dotfiles-ssh-sync"
if [[ ! -x "${ssh_sync}" ]]; then
  warn 'SSH key sync is not installed; run dotfiles apply'
else
  "${ssh_sync}" --check >/dev/null 2>&1
  ssh_status=$?
  case "${ssh_status}" in
    0) pass 'Managed SSH keys are valid and permission-locked' ;;
    3) warn 'Managed SSH keys are missing; run dotfiles ssh sync' ;;
    *) fail 'Managed SSH keys are invalid or have unsafe permissions' ;;
  esac
fi

if [[ -n "$(chezmoi diff 2>/dev/null)" ]]; then
  warn 'chezmoi reports unapplied configuration drift'
else
  pass 'chezmoi target state is current'
fi

repo="$(git -C "$(chezmoi source-path)" rev-parse --show-toplevel 2>/dev/null ||
  git -C "$(chezmoi source-path)/.." rev-parse --show-toplevel 2>/dev/null)"
if [[ -n "$(git -C "${repo}" status --porcelain)" ]]; then
  warn 'dotfiles source contains uncommitted changes'
else
  pass 'dotfiles source is clean'
fi

legacy_hook="${repo}/.git/hooks/pre-commit"
if [[ -f "${legacy_hook}" ]] &&
  grep -Fq 'vscode/save_extensions' "${legacy_hook}"; then
  warn 'obsolete local pre-commit hook remains at .git/hooks/pre-commit'
else
  pass 'obsolete VS Code auto-capture hook is absent'
fi

printf '\n%d failure(s), %d warning(s)\n' "${failures}" "${warnings}"
[[ "${failures}" -eq 0 ]]
