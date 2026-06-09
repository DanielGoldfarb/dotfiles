# dotfiles

Personal shell environment for Codespaces, WSL2, and plain Linux.

## What's included

| File | Purpose |
|---|---|
| `.bashrc` | Main shell config (sourced via `.bash_aliases`) |
| `.gitconfig` | Git defaults, aliases, xxdiff tool config |
| `.vimrc` | Vim settings + Python syntax highlighting |
| `.vim/colors/darkblack.vim` | Preferred colorscheme |
| `install.sh` | Idempotent installer — safe to re-run |
| `bootstrap-check.sh` | Quick environment and auth checks |
| `bin/gitlog` | Pretty `git log` with graph and timestamps |
| `bin/glog` | Alternate compact `git log` view |
| `bin/gitbranchv` | Colorized `git branch` with hash, date, message |
| `bin/gitbranchvs` | Like `gitbranchv` + sorted by date + upstream tracking |
| `bin/gitlogfs` | Per-file last-commit view, sorted by date (requires Python) |
| `bin/mkcd` | `mkdir` + `cd` in one step |
| `bin/git-clean-branches` | Delete merged local branches |
| `bin/ports-in-use` | Show listening ports and processes |

## Install

```bash
git clone https://github.com/DanielGoldfarb/dotfiles.git ~/dotfiles
cd ~/dotfiles
bash install.sh
source ~/.bashrc
```

`install.sh` is idempotent — safe to re-run on an existing machine.
Existing files are backed up (e.g. `.gitconfig.bak.20260101120000`) before being replaced.

## Machine-specific settings

Put anything machine-specific in `~/.bashrc.local` — it is sourced automatically
at the end of `.bashrc` but is **never committed to this repo**. For example:

```bash
# ~/.bashrc.local
source ~/.venvs/myproject/bin/activate
alias work='cd ~/code/myproject'
```

## Environment behaviour by platform

- **WSL2**: `DISPLAY`, `XDG_RUNTIME_DIR`, `LIBGL_ALWAYS_INDIRECT`, and Windows Chrome
  as `BROWSER` are set automatically. VcXsrv must be installed and running on Windows
  for GUI apps to work — see the comments in `.bashrc` for the full setup checklist.
- **Codespaces**: WSL block is skipped. `CDPATH` falls back to `.:/workspaces`.
- **Plain Linux**: WSL block is skipped. `CDPATH` uses `.:~:~/code` if `~/code` exists.

## Verify GitHub access

```bash
gh auth status -h github.com
bootstrap-check.sh
```

## Pushing to repos other than the Codespace repo

Codespaces injects a scoped `GITHUB_TOKEN` that only has write access to the
repo the Codespace was opened from. To push to other repos (e.g. this dotfiles
repo), set up a Personal Access Token (PAT):

1. **Create a PAT:** GitHub → Settings → Developer settings → Personal access tokens →
   Fine-grained tokens → Generate new token.
   Set access to **All repositories**, permission **Contents: Read and write**.

2. **Store it as a Codespaces secret:** GitHub → Settings → Codespaces → Secrets →
   New secret. Name: `GH_TOKEN`, value: your PAT, repository access: **All repositories**.

GitHub injects `GH_TOKEN` into every Codespace. Because the `gh` CLI prefers `GH_TOKEN`
over `GITHUB_TOKEN`, and `.gitconfig` uses `gh auth git-credential`, all pushes work
automatically.

### Per-Codespace workaround (if PAT not set up yet)

```bash
env -u GITHUB_TOKEN -u GH_TOKEN gh auth login -h github.com -p https -w
env -u GITHUB_TOKEN -u GH_TOKEN git push
```
