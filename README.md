# dotfiles

Personal shell environment for Codespaces, WSL2, and plain Linux.

## What's included

| File | Purpose |
|---|---|
| `.bashrc` | Main shell config (sourced via a line appended to `~/.bashrc` by `install.sh`) |
| `.gitconfig` | Git defaults, aliases, xxdiff tool config |
| `.vimrc` | Vim settings + Python syntax highlighting |
| `.vim/colors/darkblack.vim` | Preferred colorscheme |
| `install.sh` | Idempotent installer — safe to re-run |
| `bootstrap-check.sh` | Quick environment and auth checks |
| `apt-packages.txt` | Recommended system packages (vim, git, jq, xxdiff, meld, …) |
| `pip-packages.txt` | Recommended Python packages (pandas, ipython, ruff, matplotlib) |
| `bin/gitlog` | Pretty `git log` with graph and timestamps |
| `bin/glog` | Alternate compact `git log` view |
| `bin/gitbranchv` | Colorized `git branch` with hash, date, message |
| `bin/gitbranchvs` | Like `gitbranchv` + sorted by date + upstream tracking |
| `bin/gitlogfs` | Per-file last-commit view, sorted by date (requires Python) |
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

## System and Python packages

Neither file is auto-installed. They are reference lists you run manually.

```bash
# System packages
sudo apt update && xargs sudo apt install -y < apt-packages.txt

# Python packages
# Ubuntu 24+ blocks system-wide pip (PEP 668) — activate a venv first:
python3 -m venv ~/.venvs/base
source ~/.venvs/base/bin/activate
pip install -r pip-packages.txt

# Codespaces: no venv needed
pip install -r pip-packages.txt
```

Use `bootstrap-check.sh` to see what is already present.

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
