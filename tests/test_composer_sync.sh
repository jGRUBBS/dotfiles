#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
sync_script="${repo_root}/home/dot_local/bin/executable_dotfiles-composer-sync"
test_home="$(mktemp -d)"
trap 'rm -rf "${test_home}"' EXIT

mkdir -p "${test_home}/.composer" "${test_home}/.local/bin"
chmod 700 "${test_home}/.composer"
printf '{"config":{"preferred-install":"dist"}}\n' \
  > "${test_home}/.composer/config.json"
chmod 600 "${test_home}/.composer/config.json"
printf '{"http-basic":{"example.test":{"username":"example-user","password":"example-password"}}}\n' \
  > "${test_home}/auth-secret.json"

cat > "${test_home}/.local/bin/dotfiles-secret" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
[[ "${1:-}" == "COMPOSER_AUTH_JSON" ]]
[[ "${DOTFILES_TEST_MISSING_AUTH:-0}" != "1" ]] || exit 1
cat "${HOME}/auth-secret.json"
EOF
chmod 700 "${test_home}/.local/bin/dotfiles-secret"

HOME="${test_home}" bash "${sync_script}" >/dev/null
HOME="${test_home}" bash "${sync_script}" --check >/dev/null
DOTFILES_TEST_MISSING_AUTH=1 \
  HOME="${test_home}" \
  bash "${sync_script}" --optional >/dev/null

mode_of() {
  if stat -f '%Lp' "$1" >/dev/null 2>&1; then
    stat -f '%Lp' "$1"
  else
    stat -c '%a' "$1"
  fi
}

[[ "$(mode_of "${test_home}/.composer")" == "700" ]]
[[ "$(mode_of "${test_home}/.composer/config.json")" == "600" ]]
[[ "$(mode_of "${test_home}/.composer/auth.json")" == "600" ]]
cmp -s "${test_home}/auth-secret.json" "${test_home}/.composer/auth.json"

cp "${test_home}/.composer/auth.json" "${test_home}/before-invalid"
printf 'not json\n' > "${test_home}/auth-secret.json"
if HOME="${test_home}" bash "${sync_script}" >/dev/null 2>&1; then
  printf 'Invalid Composer auth JSON was accepted.\n' >&2
  exit 1
fi
cmp -s "${test_home}/before-invalid" "${test_home}/.composer/auth.json"
