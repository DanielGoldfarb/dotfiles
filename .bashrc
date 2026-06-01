# Codespaces aliases and shell helpers

# Ensure local user bin is available first.
export PATH="$HOME/.local/bin:$PATH"
set -o vi
export VISUAL=vim
export CDPATH=.:/workspaces

# Keep interactive history shared across open terminals without duplicating the
# history sync hook when this file is sourced more than once.
HISTCONTROL=ignoreboth
HISTSIZE=10000
HISTFILESIZE=20000
shopt -s histappend
history_sync_command='history -a; history -n'
case ";${PROMPT_COMMAND:-};" in
  *";${history_sync_command};"*)
    ;;
  ";;")
    PROMPT_COMMAND="${history_sync_command}"
    ;;
  *)
    PROMPT_COMMAND="${history_sync_command}; ${PROMPT_COMMAND}"
    ;;
esac

if [[ -r "$HOME/.api.polygon" ]]; then
  export POLYGON_API="$(<"$HOME/.api.polygon")"
fi

if grep -qi microsoft /proc/sys/kernel/osrelease 2>/dev/null; then
  export DISPLAY="$(grep -m 1 nameserver /etc/resolv.conf | awk '{print $2}'):0.0"
  export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp/runtime-${USER}}"
  export LIBGL_ALWAYS_INDIRECT=1
  export BROWSER='/mnt/c/Program Files/Google/Chrome/Application/chrome.exe'
  if [[ ! -d "$XDG_RUNTIME_DIR" ]]; then
    mkdir -p "$XDG_RUNTIME_DIR"
    chmod 0700 "$XDG_RUNTIME_DIR"
  fi
fi

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias gs='git status -sb'
alias gl='git log --oneline --graph --decorate -20'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gpull='git pull --ff-only'
alias ports='ports-in-use'
lastok () {
  awk '{print $NF}'
}

# mkcd as a shell function so it can change the current shell directory.
mkcd() {
  if [[ -z "$1" ]]; then
    echo "Usage: mkcd <dir>"
    return 1
  fi
  mkdir -p -- "$1" && cd -- "$1"
}
