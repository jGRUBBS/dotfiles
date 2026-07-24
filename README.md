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

Bitwarden Secrets Manager stores the operational values. The shared project
should contain these secrets:

- `BROWSERSTACK_USERNAME`
- `BROWSERSTACK_ACCESS_KEY`
- `AWS_SHARED_CREDENTIALS`
- `COMPOSER_AUTH_JSON`
- `SSH_CONFIG_PRIVATE`
- `SSH_PRIVATE_KEY_ID_ED25519`
- `SSH_PRIVATE_KEY_ID_RSA`

`AWS_SHARED_CREDENTIALS` is one multiline secret containing the complete
contents of `~/.aws/credentials`. To create it from an existing Mac:

1. In the shared Bitwarden Secrets Manager project, select **New**,
   then **Secret**.
2. Set the name to `AWS_SHARED_CREDENTIALS`.
3. Copy the existing file without displaying it:

   ```sh
   pbcopy < ~/.aws/credentials
   ```

4. Paste the clipboard into the secret's **Value** field and save it.
5. Confirm the dotfiles machine account has **Can read** access to the project.
6. Clear the clipboard:

   ```sh
   pbcopy < /dev/null
   ```

`COMPOSER_AUTH_JSON` contains the complete `~/.composer/auth.json` file. The
non-secret `~/.composer/config.json` is tracked directly by chezmoi. Create the
auth secret without displaying it:

```sh
pbcopy < ~/.composer/auth.json
# Paste into COMPOSER_AUTH_JSON and save it.
pbcopy < /dev/null
```

The SSH secrets contain two private keys:

- `SSH_PRIVATE_KEY_ID_ED25519` contains `~/.ssh/id_ed25519`.
- `SSH_PRIVATE_KEY_ID_RSA` contains `~/.ssh/id_rsa`.

The RSA key is also installed under `kingandpartners-ab.pem`,
`kingandpartners-gl.pem`, and `king-admin-2023.pem` because those four local
files are byte-for-byte identical. Keeping one Bitwarden value prevents the
aliases from drifting during rotation.

`SSH_CONFIG_PRIVATE` contains the complete private SSH client configuration,
including hostnames, usernames, ports, and host-specific identity settings.
The public repository manages only a one-line `~/.ssh/config` loader that
includes `~/.ssh/config.private`; no server inventory is stored in Git.

Create each SSH secret using the same clipboard-safe process:

```sh
pbcopy < ~/.ssh/config
# Paste into SSH_CONFIG_PRIVATE and save it.

pbcopy < ~/.ssh/id_ed25519
# Paste into SSH_PRIVATE_KEY_ID_ED25519 and save it.

pbcopy < ~/.ssh/id_rsa
# Paste into SSH_PRIVATE_KEY_ID_RSA and save it.

pbcopy < /dev/null
```

The two unique public keys and non-sensitive SSH config loader are installed
directly by chezmoi. Private keys and private host configuration never enter
the repository.

Create a separate access token for this Mac from a machine account with read
access to the project containing those secrets. A per-device token can be
revoked without disrupting other computers.

To create the token:

1. Open the Bitwarden web vault and select **Secrets Manager** from the product
   switcher.
2. Select **Machine accounts**, then create or open the machine account used
   for dotfiles.
3. In the **Projects** tab, give the machine account **Can read** access to the
   shared project containing the secrets above.
4. Open the **Access tokens** tab and select **Create access token**.
5. Name the token after this Mac, choose an expiration, and create it.
6. Copy the token before closing the window. Bitwarden cannot display it again
   later. If it is lost, revoke it and create a replacement.

See [Bitwarden's access-token documentation](https://bitwarden.com/help/secrets-manager-quick-start/#create-an-access-token)
for the current interface.

Save the token in macOS Keychain and verify secret retrieval:

```sh
dotfiles secrets bootstrap
dotfiles secrets test
dotfiles aws sync
dotfiles composer sync
dotfiles ssh sync
```

The token and AWS credential values are never written to the repository.
`dotfiles aws sync` validates the secret, backs up a differing local file, and
atomically installs it as `~/.aws/credentials` with mode `0600`; `~/.aws` is
mode `0700`. AWS requires its local shared credentials file to be plaintext,
so FileVault should remain enabled. Subsequent `dotfiles apply` runs refresh
the file whenever Bitwarden is connected and skip it cleanly before the token
has been configured on a new Mac.

`dotfiles ssh sync` validates the private SSH configuration and each private
key against its tracked public key, backs up differing managed files, installs
them atomically with mode `0600`, and enforces mode `0700` on `~/.ssh`. It
manages only the explicitly allowlisted filenames documented above.

`dotfiles composer sync` validates the Bitwarden value as JSON, backs up a
differing local auth file, and atomically installs it with mode `0600`;
`~/.composer` is mode `0700`. Composer credentials never enter the repository.

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
dotfiles aws sync   # refresh AWS credentials from Bitwarden
dotfiles composer sync  # refresh Composer auth from Bitwarden
dotfiles composer check # validate Composer config, auth, and permissions
dotfiles ssh sync   # refresh selected SSH private keys from Bitwarden
dotfiles ssh check  # validate managed SSH key matches and permissions
```

`dotfiles sync` never commits or pushes. To edit configuration, use
`chezmoi cd`, make and review the change, then commit it normally.

The legacy `./run` entrypoint remains as a compatibility wrapper.

## Intel Macs

The bootstrap supports both Apple Silicon and Intel Macs. It selects Homebrew's
standard prefix for the current architecture, downloads the matching Bitwarden
Secrets Manager CLI binary, and uses architecture-specific application
downloads where required.

A 2018 Intel MacBook Pro should be updated to the latest available macOS
Sequoia release before setup. Current package versions, including Docker
Desktop, may not install on older macOS releases.

Homebrew has announced that Intel support will become progressively more
limited as Apple ends Intel macOS support. Run `dotfiles doctor` after setup,
and expect application availability on Intel to change over time.

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
