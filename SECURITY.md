# Security

This repository must contain references to secrets, never secret values.

- Store operational values in Bitwarden Secrets Manager.
- Store the BWS machine-account token in macOS Keychain with
  `dotfiles secrets bootstrap`.
- Use `dotfiles-secret NAME` to retrieve an allowed secret at runtime.
- Do not track AI authentication files, saved permissions, histories, session
  state, databases, logs, or caches.
- Run `./tests/validate.sh` before committing.

If a credential is committed, revoke it immediately, remove it from the
working tree, rewrite every affected unpublished commit, and run gitleaks over
all refs before pushing.
