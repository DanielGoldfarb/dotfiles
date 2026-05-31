# Codespaces aliases and shell helpers

# Ensure local user bin is available first.
export PATH="$HOME/.local/bin:$PATH"

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias gs='git status -sb'
alias gl='git log --oneline --graph --decorate -20'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gpull='git pull --ff-only'
alias ports='ports-in-use'

# mkcd as a shell function so it can change the current shell directory.
mkcd() {
  if [[ -z "$1" ]]; then
    echo "Usage: mkcd <dir>"
    return 1
  fi
  mkdir -p -- "$1" && cd -- "$1"
}
