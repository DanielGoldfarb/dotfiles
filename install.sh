#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_BIN_DIR="$HOME/.local/bin"
TARGET_VIM_DIR="$HOME/.vim"

backup_if_needed() {
  local target="$1"
  if [[ -e "$target" && ! -L "$target" ]]; then
    local backup="${target}.bak.$(date +%Y%m%d%H%M%S)"
    mv "$target" "$backup"
    echo "Backed up existing file: $target -> $backup"
  fi
}

install_link() {
  local src="$1"
  local dest="$2"
  backup_if_needed "$dest"
  ln -sfn "$src" "$dest"
  echo "Linked: $dest -> $src"
}

ensure_bashrc_loads_dotfiles() {
  # On a fresh Linux/WSL2 machine the system .bashrc already exists and we
  # don't want to replace it.  Instead we make sure it sources our dotfiles
  # .bashrc via .bash_aliases (the conventional hook most distros already
  # include).  In Codespaces the system .bashrc is minimal and the same
  # approach works.
  local line='[[ -f "$HOME/.bash_aliases" ]] && source "$HOME/.bash_aliases"'
  if [[ ! -f "$HOME/.bashrc" ]]; then
    printf '%s\n' "$line" > "$HOME/.bashrc"
    echo "Created ~/.bashrc with dotfiles source line"
    return
  fi
  if ! grep -Fq "$line" "$HOME/.bashrc"; then
    printf '\n%s\n' "$line" >> "$HOME/.bashrc"
    echo "Added dotfiles source line to ~/.bashrc"
  else
    echo "~/.bashrc already sources dotfiles (no change needed)"
  fi
}

install_vim_plugins() {
  # Uses Vim 8+ native package manager — no plugin manager needed.
  # Plugins placed in ~/.vim/pack/*/start/ are loaded automatically by Vim.
  local pack_dir="$HOME/.vim/pack/plugins/start"
  mkdir -p "$pack_dir"

  # python-syntax: extended Python highlighting incl. f-strings, builtins,
  # operators, indent/space errors. Activates 'let g:python_highlight_all = 1'
  # in .vimrc.
  if [[ ! -d "$pack_dir/python-syntax" ]]; then
    if command -v git >/dev/null 2>&1; then
      echo "Installing vim plugin: python-syntax ..."
      git clone --depth=1 https://github.com/vim-python/python-syntax.git \
        "$pack_dir/python-syntax"
    else
      echo "WARNING: git not found — skipping python-syntax plugin install"
    fi
  else
    echo "vim plugin python-syntax already installed (no change needed)"
  fi
}

configure_github_git_auth() {
  if command -v gh >/dev/null 2>&1 && gh auth status -h github.com >/dev/null 2>&1; then
    gh auth setup-git >/dev/null 2>&1 || true
  fi
}

mkdir -p "$TARGET_BIN_DIR"
mkdir -p "$TARGET_VIM_DIR/colors"

# Core dotfiles
install_link "$DOTFILES_DIR/.bashrc"  "$HOME/.bash_aliases"
install_link "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
install_link "$DOTFILES_DIR/.vimrc"   "$HOME/.vimrc"
install_link "$DOTFILES_DIR/.vim/colors/darkblack.vim" "$TARGET_VIM_DIR/colors/darkblack.vim"

# All scripts in bin/
for script in "$DOTFILES_DIR"/bin/*; do
  name="$(basename "$script")"
  chmod +x "$script"
  install_link "$script" "$TARGET_BIN_DIR/$name"
done

chmod +x "$DOTFILES_DIR/install.sh" "$DOTFILES_DIR/bootstrap-check.sh"

ensure_bashrc_loads_dotfiles
install_vim_plugins
configure_github_git_auth

echo
echo "Install complete."
echo
echo "Next steps:"
echo "  1. Reload your shell:      source ~/.bashrc"
echo "  2. Verify environment:     bootstrap-check.sh"
echo "  3. Install system packages (if needed):"
echo "       sudo apt update && xargs sudo apt install -y < apt-packages.txt"
echo
echo "For machine-specific settings (venv activation, project aliases, etc.),"
echo "create ~/.bashrc.local — it will be sourced automatically."
