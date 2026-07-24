#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
sync_script="${repo_root}/home/dot_local/bin/executable_dotfiles-ssh-sync"
test_home="$(mktemp -d)"
trap 'rm -rf "${test_home}"' EXIT

mkdir -p \
  "${test_home}/.fixtures" \
  "${test_home}/.local/bin" \
  "${test_home}/.ssh"
chmod 700 "${test_home}/.ssh"
printf 'Include %s\n' "${test_home}/.ssh/config.private" \
  > "${test_home}/.ssh/config"
chmod 600 "${test_home}/.ssh/config"
printf 'Host example\n  HostName example.test\n  User deploy\n' \
  > "${test_home}/.fixtures/config.private"

ssh-keygen -q -t ed25519 -N '' \
  -f "${test_home}/.fixtures/id_ed25519"
ssh-keygen -q -t rsa -b 2048 -N '' \
  -f "${test_home}/.fixtures/id_rsa"
cp \
  "${test_home}/.fixtures/id_ed25519.pub" \
  "${test_home}/.ssh/id_ed25519.pub"
cp \
  "${test_home}/.fixtures/id_rsa.pub" \
  "${test_home}/.ssh/id_rsa.pub"

cat > "${test_home}/.local/bin/dotfiles-secret" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
case "${1:-}" in
  SSH_PRIVATE_KEY_ID_ED25519)
    cat "${HOME}/.fixtures/id_ed25519"
    ;;
  SSH_PRIVATE_KEY_ID_RSA)
    [[ "${DOTFILES_TEST_MISSING_RSA:-0}" != "1" ]] || exit 1
    cat "${HOME}/.fixtures/id_rsa"
    ;;
  SSH_CONFIG_PRIVATE)
    cat "${HOME}/.fixtures/config.private"
    ;;
  *)
    exit 1
    ;;
esac
EOF
chmod 700 "${test_home}/.local/bin/dotfiles-secret"

HOME="${test_home}" bash "${sync_script}" >/dev/null
HOME="${test_home}" bash "${sync_script}" --check >/dev/null
DOTFILES_TEST_MISSING_RSA=1 \
  HOME="${test_home}" \
  bash "${sync_script}" --optional >/dev/null

mode_of() {
  if stat -f '%Lp' "$1" >/dev/null 2>&1; then
    stat -f '%Lp' "$1"
  else
    stat -c '%a' "$1"
  fi
}

for destination in \
  id_ed25519 \
  id_rsa \
  kingandpartners-ab.pem \
  kingandpartners-gl.pem \
  king-admin-2023.pem; do
  [[ "$(mode_of "${test_home}/.ssh/${destination}")" == "600" ]]
done
cmp -s \
  "${test_home}/.ssh/id_rsa" \
  "${test_home}/.ssh/kingandpartners-ab.pem"
cmp -s \
  "${test_home}/.ssh/id_rsa" \
  "${test_home}/.ssh/kingandpartners-gl.pem"
cmp -s \
  "${test_home}/.ssh/id_rsa" \
  "${test_home}/.ssh/king-admin-2023.pem"

chmod 644 "${test_home}/.ssh/id_rsa"
if HOME="${test_home}" bash "${sync_script}" --check >/dev/null 2>&1; then
  printf 'Unsafe SSH private-key permissions were accepted.\n' >&2
  exit 1
fi
HOME="${test_home}" bash "${sync_script}" >/dev/null
[[ "$(mode_of "${test_home}/.ssh/id_rsa")" == "600" ]]

ssh-keygen -q -t ed25519 -N '' \
  -f "${test_home}/.fixtures/wrong-key"
cp \
  "${test_home}/.fixtures/wrong-key.pub" \
  "${test_home}/.ssh/id_ed25519.pub"
if HOME="${test_home}" bash "${sync_script}" >/dev/null 2>&1; then
  printf 'An SSH private/public key mismatch was accepted.\n' >&2
  exit 1
fi
