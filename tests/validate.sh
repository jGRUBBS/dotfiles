#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${repo_root}"

failed=0

check() {
  printf '==> %s\n' "$1"
  shift
  if ! "$@"; then
    failed=1
  fi
}

matching_files() {
  local pattern="$1"
  git grep -Il -E "${pattern}" -- . ':(exclude)*.tmpl'
}

check_syntax() {
  local shell_name="$1"
  local pattern="$2"
  local file
  local found=0
  local status=0

  while IFS= read -r file; do
    found=1
    "${shell_name}" -n "${file}" || status=1
  done < <(matching_files "${pattern}" | sort -u)

  if [[ "${found}" -eq 0 ]]; then
    printf 'No %s files were discovered.\n' "${shell_name}" >&2
    return 1
  fi
  return "${status}"
}

check_shellcheck() {
  local file
  local found=0
  local status=0

  while IFS= read -r file; do
    found=1
    shellcheck -x -e SC2016 "${file}" || status=1
  done < <(
    matching_files '^#!.*(/|[[:space:]])(bash|sh)([[:space:]]|$)' |
      sort -u
  )

  if [[ "${found}" -eq 0 ]]; then
    printf 'No Bash files were discovered for ShellCheck.\n' >&2
    return 1
  fi
  return "${status}"
}

check_script_templates() {
  local file
  local found=0
  local status=0

  while IFS= read -r file; do
    found=1
    chezmoi --source="${repo_root}/home" execute-template < "${file}" |
      bash -n || status=1
  done < <(git ls-files 'home/.chezmoiscripts/*.tmpl' | sort -u)

  if [[ "${found}" -eq 0 ]]; then
    printf 'No chezmoi script templates were discovered.\n' >&2
    return 1
  fi
  return "${status}"
}

check "bash syntax" check_syntax \
  bash '^#!.*(/|[[:space:]])(bash|sh)([[:space:]]|$)'
check "zsh syntax" check_syntax zsh '^#!.*zsh'

if command -v shellcheck >/dev/null 2>&1; then
  check "shellcheck" check_shellcheck
else
  printf 'SKIP: shellcheck is not installed\n'
fi

check "Claude settings JSON" python3 -c \
  'import json,pathlib; json.loads(pathlib.Path("home/.chezmoitemplates/data/ai/claude-settings.json").read_text())'
check "Copilot settings JSON" python3 -c \
  'import json,pathlib; json.loads(pathlib.Path("home/.chezmoitemplates/data/ai/copilot-settings.json").read_text())'
check "Codex portable TOML" python3 -c \
  'import pathlib,tomllib; tomllib.loads(pathlib.Path("home/.chezmoitemplates/data/ai/codex-config.toml").read_text())'
check "AI config merge tests" python3 tests/test_merge.py

if command -v brew >/dev/null 2>&1; then
  check "Homebrew Bundle formula manifest" env HOMEBREW_NO_AUTO_UPDATE=1 \
    brew bundle list \
    --file="${repo_root}/home/.chezmoitemplates/data/Brewfile"
  check "Homebrew Bundle cask manifest" env HOMEBREW_NO_AUTO_UPDATE=1 \
    brew bundle list \
    --cask \
    --file="${repo_root}/home/.chezmoitemplates/data/Brewfile"
else
  printf 'SKIP: Homebrew is not installed\n'
fi

if command -v chezmoi >/dev/null 2>&1; then
  check "rendered chezmoi script syntax" check_script_templates

  temp_home="$(mktemp -d)"
  temp_source="$(mktemp -d)"
  trap 'rm -rf "${temp_home}" "${temp_source}"' EXIT
  check "chezmoi bootstrap handoff and idempotence" bash -c '
    set -euo pipefail
    test_home="$1"
    source_dir="$2"
    test_source="$3"

    cp -R "${source_dir}/." "${test_source}/"
    rm -f "${test_source}/home/.chezmoiexternal.toml"

    env HOME="${test_home}" chezmoi \
      --no-tty \
      init --source "${test_source}" --apply --exclude=scripts
    configured_source="$(
      env HOME="${test_home}" chezmoi source-path
    )"
    [[ "${configured_source}" == "${test_source}/home" ]]

    drift="$(
      env HOME="${test_home}" chezmoi \
        --destination "${test_home}" \
        diff --exclude=scripts
    )"
    [[ -z "${drift}" ]]
  ' _ "${temp_home}" "${repo_root}" "${temp_source}"
else
  printf 'SKIP: chezmoi is not installed\n'
fi

if command -v gitleaks >/dev/null 2>&1; then
  check "working-tree secret scan" gitleaks dir --redact --no-banner .
else
  printf 'SKIP: gitleaks is not installed\n'
fi

if [[ "${failed}" -ne 0 ]]; then
  exit 1
fi
