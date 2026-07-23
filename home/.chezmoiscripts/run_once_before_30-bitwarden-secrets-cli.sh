#!/usr/bin/env bash

set -euo pipefail

version="2.1.0"
install_dir="${HOME}/.local/bin"
binary="${install_dir}/bws"

if [[ -x "${binary}" ]] && "${binary}" --version 2>/dev/null | grep -q "${version}"; then
  exit 0
fi

case "$(uname -m)" in
  arm64)
    target="aarch64-apple-darwin"
    ;;
  x86_64)
    target="x86_64-apple-darwin"
    ;;
  *)
    printf 'Unsupported macOS architecture: %s\n' "$(uname -m)" >&2
    exit 1
    ;;
esac

archive="bws-${target}-${version}.zip"
url="https://github.com/bitwarden/sdk/releases/download/bws-v${version}/${archive}"
temp_dir="$(mktemp -d)"
trap 'rm -rf "${temp_dir}"' EXIT

curl --fail --location --silent --show-error \
  "${url}" \
  --output "${temp_dir}/${archive}"
ditto -x -k "${temp_dir}/${archive}" "${temp_dir}/unpacked"

downloaded="$(find "${temp_dir}/unpacked" -type f -name bws -print -quit)"
if [[ -z "${downloaded}" ]]; then
  printf 'The Bitwarden archive did not contain bws.\n' >&2
  exit 1
fi

mkdir -p "${install_dir}"
install -m 0755 "${downloaded}" "${binary}"
"${binary}" --version
