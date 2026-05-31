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
