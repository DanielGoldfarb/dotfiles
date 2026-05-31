#!/usr/bin/env bash
set -euo pipefail

TEMPLATE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
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

ensure_bashrc_source() {
  local line='[[ -f "$HOME/.bash_aliases" ]] && source "$HOME/.bash_aliases"'
  if [[ ! -f "$HOME/.bashrc" ]]; then
    printf '%s\n' "$line" > "$HOME/.bashrc"
    return
  fi
  if ! grep -Fq "$line" "$HOME/.bashrc"; then
    printf '\n%s\n' "$line" >> "$HOME/.bashrc"
  fi
}

install_link() {
  local src="$1"
  local dest="$2"
  backup_if_needed "$dest"
  ln -sfn "$src" "$dest"
  echo "Linked: $dest -> $src"
}

mkdir -p "$TARGET_BIN_DIR"
mkdir -p "$TARGET_VIM_DIR/colors"

install_link "$TEMPLATE_DIR/.bash_aliases" "$HOME/.bash_aliases"
install_link "$TEMPLATE_DIR/.gitconfig" "$HOME/.gitconfig"
install_link "$TEMPLATE_DIR/.vimrc" "$HOME/.vimrc"
install_link "$TEMPLATE_DIR/.vim/colors/darkblack.vim" "$TARGET_VIM_DIR/colors/darkblack.vim"

for script in "$TEMPLATE_DIR"/bin/*; do
  name="$(basename "$script")"
  install_link "$script" "$TARGET_BIN_DIR/$name"
  chmod +x "$script"
done

chmod +x "$TEMPLATE_DIR/install.sh" "$TEMPLATE_DIR/bootstrap-check.sh"
ensure_bashrc_source

echo
echo "Install complete."
echo "Next steps:"
echo "  source ~/.bashrc"
echo "  bootstrap-check.sh"
