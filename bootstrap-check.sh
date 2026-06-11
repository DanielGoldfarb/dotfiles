#!/usr/bin/env bash
set -euo pipefail

OK='  OK     '
MISS='  MISSING'

echo "== Core tools =="
for cmd in git gh jq curl vim python3; do
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "${OK}: $cmd"
  else
    echo "${MISS}: $cmd   (sudo apt install $cmd)"
  fi
done

echo
echo "== Git diff/merge tools =="
for cmd in xxdiff meld; do
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "${OK}: $cmd"
  else
    echo "${MISS}: $cmd   (sudo apt install $cmd)"
  fi
done
echo "  (xxdiff and meld are optional; configure preferred tool in .gitconfig)"

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
# pandas and matplotlib are libraries: check via import
for pkg in pandas matplotlib; do
  if python3 -c "import $pkg" >/dev/null 2>&1; then
    echo "${OK}: $pkg"
  else
    echo "${MISS}: $pkg   (pip install -r pip-packages.txt)"
  fi
done
# ipython, ruff, black are CLI tools: check via command -v
for tool in ipython ruff black; do
  if command -v "$tool" >/dev/null 2>&1; then
    echo "${OK}: $tool"
  else
    echo "${MISS}: $tool   (pip install -r pip-packages.txt  OR  pipx install $tool)"
  fi
done

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
  echo "Codespace token variables detected (GITHUB_TOKEN/GH_TOKEN)."
  echo "To force manual auth, run: env -u GITHUB_TOKEN -u GH_TOKEN gh auth login"
else
  echo "No injected GH token variables detected."
fi
