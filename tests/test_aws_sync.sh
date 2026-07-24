#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
sync_script="${repo_root}/home/dot_local/bin/executable_dotfiles-aws-sync"
test_home="$(mktemp -d)"
trap 'rm -rf "${test_home}"' EXIT

mkdir -p "${test_home}/.local/bin"

write_valid_secret() {
  cat > "${test_home}/secret" <<'EOF'
[default]
aws_access_key_id = example-access-key
aws_secret_access_key = example-secret-key

[work]
aws_access_key_id = another-example-access-key
aws_secret_access_key = another-example-secret-key
EOF
}

cat > "${test_home}/.local/bin/dotfiles-secret" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
[[ "${1:-}" == "AWS_SHARED_CREDENTIALS" ]]
cat "${HOME}/secret"
EOF
chmod 700 "${test_home}/.local/bin/dotfiles-secret"

write_valid_secret
HOME="${test_home}" bash "${sync_script}" >/dev/null
cmp -s "${test_home}/secret" "${test_home}/.aws/credentials"

mode_of() {
  if stat -f '%Lp' "$1" >/dev/null 2>&1; then
    stat -f '%Lp' "$1"
  else
    stat -c '%a' "$1"
  fi
}

[[ "$(mode_of "${test_home}/.aws")" == "700" ]]
[[ "$(mode_of "${test_home}/.aws/credentials")" == "600" ]]
HOME="${test_home}" bash "${sync_script}" --check >/dev/null
HOME="${test_home}" bash "${sync_script}" >/dev/null

cp "${test_home}/.aws/credentials" "${test_home}/before-invalid"
cat > "${test_home}/secret" <<'EOF'
[default]
aws_access_key_id = incomplete
EOF
if HOME="${test_home}" bash "${sync_script}" >/dev/null 2>&1; then
  printf 'Invalid AWS credentials were accepted.\n' >&2
  exit 1
fi
cmp -s "${test_home}/before-invalid" "${test_home}/.aws/credentials"

rm -f "${test_home}/.local/bin/dotfiles-secret"
HOME="${test_home}" bash "${sync_script}" --optional >/dev/null
