# Dotfiles

Personal macOS configuration managed by [chezmoi](https://www.chezmoi.io/)
and Homebrew.

## New Mac

### 1. Install Apple's command-line tools

Start the installer:

```sh
xcode-select --install
```

Wait for it to finish before continuing.

### 2. Bootstrap from GitHub

Run:

```sh
sh -c "$(curl -fsLS https://get.chezmoi.io)" -- \
  init --apply https://github.com/jGRUBBS/dotfiles.git
```

The first apply installs Homebrew, command-line tools, applications, the zsh
configuration and theme, VS Code settings and extensions, and portable AI
configuration. It is safe to rerun the command if setup is interrupted.

Package and extension installation only reruns when the corresponding manifest
changes.

### 3. Start the configured shell

Open a new terminal window or reload the current shell:

```sh
exec zsh
```

### 4. Connect Bitwarden Secrets Manager

Bitwarden Secrets Manager is used for operational secrets. After rotating the
credentials that were previously committed, store the replacement values as
Bitwarden Secrets named:

- `SUCURI_API_KEY`
- `SUCURI_APP_KEY_CHARLESTONPLACE_COM`
- `SUCURI_APP_KEY_AMERICANGARDENSCHS_COM`
- `SUCURI_APP_KEY_THECOOPER_COM`
- `BROWSERSTACK_USERNAME`
- `BROWSERSTACK_ACCESS_KEY`

Create a separate access token for this Mac from a machine account with read
access to the project containing those secrets. A per-device token can be
revoked without disrupting other computers.

Save the token in macOS Keychain and verify secret retrieval:

```sh
dotfiles secrets bootstrap
dotfiles secrets test
```

The token is never written to the repository or a plaintext config file.

### 5. Authenticate local applications

Authentication state is intentionally not synchronized. Authenticate GitHub:

```sh
gh auth login
```

Then launch and sign in to Codex, Claude, GitHub Copilot, VS Code, Docker, and
any other applications that require an account.

### 6. Validate the installation

Run:

```sh
dotfiles doctor
```

Resolve any reported failures before relying on the configuration. Warnings
identify optional tools or authentication that still need attention.

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
