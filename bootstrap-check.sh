#!/usr/bin/env bash
set -euo pipefail

OK='  OK     '
MISS='  MISSING'
NOTE='  NOTE   '
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Detect environment
if [[ -n "${CODESPACES:-}" ]] || [[ -n "${GITHUB_CODESPACE_TOKEN:-}" ]]; then
  ENV="codespace"
elif grep -qi microsoft /proc/version 2>/dev/null; then
  ENV="wsl2"
else
  ENV="linux"
fi

echo "======================================================"
case "$ENV" in
  codespace) echo "  Environment: GitHub Codespaces"
    echo "  - pip install works directly (no venv needed)"
    echo "  - GITHUB_TOKEN is injected and scoped to this repo only"
    echo "  - To push to OTHER repos: ensure GH_TOKEN secret is set to your PAT"
    echo "  - bootstrap-check.sh is most useful here to catch missing packages" ;;
  wsl2)      echo "  Environment: WSL2"
    echo "  - Ubuntu 24+: activate a venv before pip install (PEP 668)"
    echo "  - DISPLAY/VcXsrv needed for GUI apps (xxdiff, meld)"
    echo "  - GITHUB_TOKEN/GH_TOKEN should NOT be set here (check below)" ;;
  linux)     echo "  Environment: Plain Linux"
    echo "  - Ubuntu 24+: activate a venv before pip install (PEP 668)"
    echo "  - GITHUB_TOKEN/GH_TOKEN should NOT be set here (check below)" ;;
esac
echo "======================================================"
echo

echo "== apt packages (apt-packages.txt) =="
while IFS= read -r line; do
  pkg="${line%%#*}"          # strip inline comment
  pkg="${pkg//[[:space:]]/}"  # strip whitespace
  [[ -z "$pkg" ]] && continue
  if command -v "$pkg" >/dev/null 2>&1; then
    echo "${OK}: $pkg"
  else
    echo "${MISS}: $pkg   (sudo apt install $pkg)"
  fi
done < "$SCRIPT_DIR/apt-packages.txt"
echo "  (xxdiff and meld are optional; configure preferred tool in .gitconfig)"
# gh is not in apt-packages.txt (requires its own install method)
if command -v gh >/dev/null 2>&1; then
  echo "${OK}: gh"
else
  echo "${MISS}: gh   (https://cli.github.com/manual/installation)"
fi

echo
echo "== Vim python-syntax plugin =="
PYSYN="$HOME/.vim/pack/plugins/start/python-syntax/syntax/python.vim"
if [[ -f "$PYSYN" ]]; then
  echo "${OK}: python-syntax plugin (~/.vim/pack/plugins/start/python-syntax)"
else
  echo "${MISS}: python-syntax plugin"
  echo "  Run install.sh to install it, or:"
  echo "  git clone --depth=1 https://github.com/vim-python/python-syntax.git \\"
  echo "    ~/.vim/pack/plugins/start/python-syntax"
fi

echo
echo "== dotfiles bin scripts =="
for script in gitlog glog gitbranchv gitbranchvs gitlogfs git-clean-branches ports-in-use; do
  if command -v "$script" >/dev/null 2>&1; then
    echo "${OK}: $script"
  else
    echo "${MISS}: $script   (run install.sh)"
  fi
done

echo
echo "== Python packages (pip-packages.txt) =="
# Annotations in pip-packages.txt drive the check type:
#   # lib  ->  python3 -c "import ..."
#   # cli  ->  command -v
while IFS= read -r line; do
  pkg="${line%%#*}"
  pkg="${pkg//[[:space:]]/}"
  [[ -z "$pkg" ]] && continue
  annotation="${line#*#}"
  annotation="${annotation//[[:space:]]/}"
  if [[ "$annotation" == "cli" ]]; then
    if command -v "$pkg" >/dev/null 2>&1; then
      echo "${OK}: $pkg"
    else
      echo "${MISS}: $pkg   (pip install $pkg  OR  pipx install $pkg)"
    fi
  else
    if python3 -c "import $pkg" >/dev/null 2>&1; then
      echo "${OK}: $pkg"
    else
      echo "${MISS}: $pkg   (pip install -r pip-packages.txt)"
    fi
  fi
done < "$SCRIPT_DIR/pip-packages.txt"

echo
echo "== GitHub auth status =="
if command -v gh >/dev/null 2>&1; then
  gh auth status -h github.com || true
else
  echo "gh is not installed"
fi

echo
echo "== Token mode check =="
if [[ -n "${GITHUB_TOKEN:-}" ]] || [[ -n "${GH_TOKEN:-}" ]]; then
  if [[ "$ENV" == "codespace" ]]; then
    echo "${NOTE}: GITHUB_TOKEN is set (normal for Codespaces — scoped to this repo only)."
    echo "  To push to OTHER repos, ensure GH_TOKEN secret is set to your PAT, then:"
    echo "  env -u GITHUB_TOKEN gh auth status"
  else
    echo "${MISS}: GITHUB_TOKEN or GH_TOKEN is set — unexpected outside Codespaces."
    echo "  This may cause gh/git to use the wrong credentials."
    echo "  To fix: unset GITHUB_TOKEN GH_TOKEN  (or remove from your shell config)"
  fi
else
  if [[ "$ENV" == "codespace" ]]; then
    echo "${NOTE}: No injected token — relying on 'gh auth login' credentials."
    echo "  This is fine if you ran 'gh auth login' manually."
  else
    echo "${OK}: No injected GH token variables (correct for $ENV)."
  fi
fi
