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
  if command -v rg >/dev/null 2>&1; then
    rg -l --hidden \
      --glob '!.git/**' \
      --glob '!*.tmpl' \
      "${pattern}"
  else
    git grep -Il -E "${pattern}" -- . ':(exclude)*.tmpl'
  fi
}

bash_files=()
while IFS= read -r file; do
  bash_files+=("${file}")
done < <(
  matching_files '^#!.*(/|[[:space:]])(bash|sh)([[:space:]]|$)' |
    sort -u
)

check "bash syntax" bash -c '
  for file in "$@"; do
    bash -n "$file"
  done
' _ "${bash_files[@]}"

zsh_files=()
while IFS= read -r file; do
  zsh_files+=("${file}")
done < <(
  matching_files '^#!.*zsh' |
    sort -u
)

check "zsh syntax" zsh -c '
  for file in "$@"; do
    zsh -n "$file"
  done
' _ "${zsh_files[@]}"

if command -v shellcheck >/dev/null 2>&1; then
  check "shellcheck" shellcheck -x -e SC2016 "${bash_files[@]}"
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
  check "Homebrew Bundle manifest" env HOMEBREW_NO_AUTO_UPDATE=1 \
    brew bundle list \
    --file="${repo_root}/home/.chezmoitemplates/data/Brewfile"
else
  printf 'SKIP: Homebrew is not installed\n'
fi

if command -v chezmoi >/dev/null 2>&1; then
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
