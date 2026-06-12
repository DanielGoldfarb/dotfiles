#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_BIN_DIR="$HOME/.local/bin"
TARGET_VIM_DIR="$HOME/.vim"

# Tee all output (stdout + stderr) to a log file.
LOG="$DOTFILES_DIR/dotfiles.install.log"
[[ -f "$LOG" ]] && mv "$LOG" "${LOG}.bak"
exec > >(tee "$LOG") 2>&1

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

setup_bashrc() {
  # ~/.bashrc strategy: on first run, rename the distro ~/.bashrc to
  # ~/.bashrc_distro and create a clean managed ~/.bashrc that sources it
  # followed by dotfiles/.bashrc.  Opening ~/.bashrc then immediately shows
  # exactly what it does — no hunting for a source line buried at the bottom
  # of a long distro file.
  #
  # dotfiles settings take precedence because they are sourced second.
  #
  # Idempotency: the rename only happens when ~/.bashrc_distro does not yet
  # exist.  On subsequent runs, only ~/.bashrc is updated if its content has
  # changed (e.g. a new source line added here).  The managed file is never
  # confused with the distro original, so updates never clobber
  # ~/.bashrc_distro.
  #
  # Future distro upgrades: apt never overwrites an existing ~/.bashrc — it
  # drops the new version as ~/.bashrc.dpkg-new (or ~/.bashrc.ucf-new).
  # bootstrap-check.sh will alert you if one appears.  Review it and apply
  # any relevant changes to ~/.bashrc_distro manually.
  #
  # Path portability: DOTFILES_DIR is an absolute path resolved from this
  # script's location, so the embedded source path is correct on WSL2, plain
  # Linux, Codespaces, or anywhere else the repo is cloned.
  local distro_bashrc="$HOME/.bashrc_distro"
  local dotfiles_bashrc="$DOTFILES_DIR/.bashrc"

  # First run: preserve the existing distro ~/.bashrc under its permanent name.
  if [[ ! -e "$distro_bashrc" ]]; then
    if [[ -f "$HOME/.bashrc" || -L "$HOME/.bashrc" ]]; then
      mv "$HOME/.bashrc" "$distro_bashrc"
      echo "Renamed ~/.bashrc -> ~/.bashrc_distro"
    fi
  fi

  # Define the exact managed content.
  local expected
  expected=$(cat <<EOF
# Managed by dotfiles/install.sh -- do not edit by hand.
[[ -f "$distro_bashrc" ]] && source "$distro_bashrc"
[[ -f "$dotfiles_bashrc" ]] && source "$dotfiles_bashrc"
EOF
)

  if [[ -f "$HOME/.bashrc" ]] && [[ "$(cat "$HOME/.bashrc")" == "$expected" ]]; then
    echo "~/.bashrc already configured correctly (no change needed)"
    return
  fi

  # Back up whatever is currently there before overwriting.
  if [[ -f "$HOME/.bashrc" && ! -L "$HOME/.bashrc" ]]; then
    local backup="$HOME/.bashrc.bak.$(date +%Y%m%d%H%M%S)"
    cp "$HOME/.bashrc" "$backup"
    echo "Backed up ~/.bashrc -> $backup"
  fi

  printf '%s\n' "$expected" > "$HOME/.bashrc"
  echo "Wrote managed ~/.bashrc (sources ~/.bashrc_distro then dotfiles/.bashrc)"
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

# Core dotfiles (symlinked — backed up automatically if real files exist)
install_link "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
install_link "$DOTFILES_DIR/.vimrc"     "$HOME/.vimrc"
install_link "$DOTFILES_DIR/.vim/colors/darkblack.vim" "$TARGET_VIM_DIR/colors/darkblack.vim"

# All scripts in bin/
for script in "$DOTFILES_DIR"/bin/*; do
  name="$(basename "$script")"
  chmod +x "$script"
  install_link "$script" "$TARGET_BIN_DIR/$name"
done

chmod +x "$DOTFILES_DIR/install.sh" "$DOTFILES_DIR/bootstrap-check.sh"

# ~/.bashrc: rename the distro original to ~/.bashrc_distro and write a clean
# managed ~/.bashrc that sources it followed by dotfiles/.bashrc.
setup_bashrc
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
echo "  4. Install Python packages (if needed):"
echo "       # Ubuntu 24+: activate a venv first, then:"
echo "       pip install -r pip-packages.txt"
echo "       # Codespaces: pip install -r pip-packages.txt directly"
echo
echo "For machine-specific settings (venv activation, project aliases, etc.),"
echo "create ~/.bashrc.local — it will be sourced automatically."
