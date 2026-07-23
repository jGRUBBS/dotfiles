# Dotfiles

Personal macOS configuration managed by [chezmoi](https://www.chezmoi.io/)
and Homebrew.

## New Mac

Install the Xcode Command Line Tools if macOS asks for them, then run:

```sh
sh -c "$(curl -fsLS https://get.chezmoi.io)" -- \
  init --apply https://github.com/jGRUBBS/dotfiles.git
```

The first apply installs Homebrew and the packages in
`home/.chezmoitemplates/data/Brewfile`. Package installation and extension installation
only rerun when their manifests change.

Bitwarden Secrets Manager is used for operational secrets. After rotating the
credentials that were previously committed, store the replacement values as
Bitwarden Secrets named:

- `SUCURI_API_KEY`
- `SUCURI_APP_KEY_CHARLESTONPLACE_COM`
- `SUCURI_APP_KEY_AMERICANGARDENSCHS_COM`
- `SUCURI_APP_KEY_THECOOPER_COM`
- `BROWSERSTACK_USERNAME`
- `BROWSERSTACK_ACCESS_KEY`

Then save the replacement BWS machine-account token in macOS Keychain:

```sh
dotfiles secrets bootstrap
```

The token is never written to the repository or a plaintext config file.

## Daily use

```sh
dotfiles diff       # preview configuration drift
dotfiles apply      # apply the checked-out source
dotfiles sync       # fast-forward from Git, preview, and apply
dotfiles doctor     # validate the installation
```

`dotfiles sync` never commits or pushes. To edit configuration, use
`chezmoi cd`, make and review the change, then commit it normally.

The legacy `./run` entrypoint remains as a compatibility wrapper.

## AI configuration

Only portable, human-owned configuration is synchronized:

- Codex: global instructions, personal skills, selected defaults, and plugin
  enablement.
- Claude Code: global instructions, personal skills, and selected user
  settings.
- GitHub Copilot CLI: personal instructions, personal skills, and selected
  user settings.

Authentication files, histories, sessions, memories, databases, caches,
project trust, saved permissions, and generated plugin state remain local.
The merge scripts in `scripts/` update allowlisted values without replacing
machine-owned state.

## Validation

Run:

```sh
./tests/validate.sh
```

CI runs the same static checks plus a full-history gitleaks scan.
