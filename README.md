# dotfiles

Reusable Codespaces bootstrap for shell aliases, git config, Vim settings, and small helper scripts.

## Included files

- `install.sh`: idempotent installer for this template
- `.bash_aliases`: shell aliases/functions loaded from `~/.bashrc`
- `.gitconfig`: optional git defaults and aliases
- `.vimrc`: Vim defaults
- `.vim/colors/darkblack.vim`: preferred colorscheme
- `bootstrap-check.sh`: quick environment and auth checks
- `bin/mkcd`: create a directory path safely
- `bin/git-clean-branches`: delete merged local branches
- `bin/ports-in-use`: show listening ports/processes

## Install

Run from inside this directory:

```bash
./install.sh
```

Then reload your shell:

```bash
source ~/.bashrc
```

## Environment Notes

- `CDPATH` is set to `.:/workspaces` for Codespaces navigation.
- Shell history is synced across multiple open terminals via `history -a; history -n`.
- WSL-only GUI settings are applied conditionally, including `DISPLAY`, `XDG_RUNTIME_DIR`, `LIBGL_ALWAYS_INDIRECT`, and Windows Chrome as `BROWSER`.
- Optional local secrets can be loaded from files such as `~/.api.polygon`.

## Verify GitHub access

```bash
gh auth status -h github.com
gh repo view OWNER/REPO --json nameWithOwner,visibility,viewerPermission
gh repo clone OWNER/REPO
```

If private repos are not visible in Codespaces:

1. Verify exact `OWNER/REPO` on GitHub.
2. Check Codespaces repository access scope in GitHub settings.
3. Rebuild/recreate Codespace so token scope is refreshed.

## Pushing to repos other than the codespace repo

Codespaces injects a scoped `GITHUB_TOKEN` that only has write access to the
repo the codespace was opened from. Pushing to other repos (e.g. this dotfiles
repo) will fail with a 403 unless you set up a Personal Access Token (PAT).

### One-time setup (done on github.com, persists across all future codespaces)

1. **Create a PAT:**
   GitHub → Settings → Developer settings → Personal access tokens →
   Fine-grained tokens → Generate new token.
   Set access to **All repositories**, permission **Contents: Read and write**.

2. **Store it as a Codespaces secret:**
   GitHub → Settings → Codespaces → Secrets → New secret.
   Name: `GH_TOKEN`, value: your PAT, repository access: **All repositories**.

GitHub injects `GH_TOKEN` into every codespace you create. Because the gh CLI
prefers `GH_TOKEN` over `GITHUB_TOKEN`, and this repo's git config already uses
`credential.helper = !gh auth git-credential`, all pushes will work
automatically without any manual login step.

### Per-codespace workaround (if PAT is not set up yet)

```bash
# One-time login for this codespace session
env -u GITHUB_TOKEN -u GH_TOKEN gh auth login -h github.com -p https -w

# Push using personal auth
env -u GITHUB_TOKEN -u GH_TOKEN git push
```
