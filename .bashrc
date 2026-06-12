# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Ensure local user bin is on PATH first.
export PATH="$HOME/.local/bin:$PATH"

# Add ~/bin to PATH if it exists.
if [[ -d "$HOME/bin" ]]; then
    export PATH="$HOME/bin:$PATH"
fi

set -o vi
export PATH=".:$PATH"
export VISUAL=vim

# CDPATH: prefer ~/code on WSL/Linux; fall back to /workspaces in Codespaces.
if [[ -d "$HOME/code" ]]; then
    export CDPATH=.:~:~/code
elif [[ -d /workspaces ]]; then
    export CDPATH=.:/workspaces
else
    export CDPATH=.:~
fi

# ---------------------------------------------------------------------------
# WSL-specific GUI setup
# Detect WSL by checking for "microsoft" in the kernel release string.
# ---------------------------------------------------------------------------
if grep -qi microsoft /proc/sys/kernel/osrelease 2>/dev/null; then
  # Set DISPLAY so Linux GUI apps can render through an X server on Windows.
  # VcXsrv must be installed and running on the Windows side.
  # See: https://stackoverflow.com/questions/61110603/how-to-set-up-working-x11-forwarding-on-wsl2
  #
  # VcXsrv setup checklist:
  #   1. Run xlaunch: Multiple windows, Start no client,
  #      check Clipboard + Primary Selection + Native opengl + Disable access control
  #   2. Save config.xlaunch to your Windows Startup folder:
  #      C:\Users\<user>\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup
  #   3. Windows Firewall: allow VcXsrv on BOTH Private and Public networks.
  #      (WSL2 is a VM and is treated as an external network)
  export DISPLAY="$(grep -m 1 nameserver /etc/resolv.conf | awk '{print $2}'):0.0"
  export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp/runtime-${USER}}"
  export LIBGL_ALWAYS_INDIRECT=1
  export BROWSER='/mnt/c/Program Files/Google/Chrome/Application/chrome.exe'
  if [[ ! -d "$XDG_RUNTIME_DIR" ]]; then
    mkdir -p "$XDG_RUNTIME_DIR"
    chmod 0700 "$XDG_RUNTIME_DIR"
  fi
fi

# ---------------------------------------------------------------------------
# History
# ---------------------------------------------------------------------------
HISTCONTROL=ignoreboth
shopt -s histappend
export HISTSIZE=65534
export HISTFILESIZE=2*${HISTSIZE}
# Sync history across open terminals on every prompt.
history_sync_command='history -a; history -c; history -r'
case ";${PROMPT_COMMAND:-};" in
  *";${history_sync_command};"*) ;;
  ";;") PROMPT_COMMAND="${history_sync_command}" ;;
  *) PROMPT_COMMAND="${history_sync_command}; ${PROMPT_COMMAND}" ;;
esac

# ---------------------------------------------------------------------------
# Terminal / prompt
# ---------------------------------------------------------------------------
shopt -s checkwinsize

# make less more friendly for non-text input files
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# chroot label
if [[ -z "${debian_chroot:-}" ]] && [[ -r /etc/debian_chroot ]]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# Color prompt
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac
if [[ -n "$force_color_prompt" ]]; then
    if [[ -x /usr/bin/tput ]] && tput setaf 1 >&/dev/null; then
        color_prompt=yes
    else
        color_prompt=
    fi
fi
if [[ "$color_prompt" = yes ]]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# Set terminal title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
esac

# ---------------------------------------------------------------------------
# Colors for ls and grep
# ---------------------------------------------------------------------------
if [[ -x /usr/bin/dircolors ]]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# ---------------------------------------------------------------------------
# Aliases
# ---------------------------------------------------------------------------
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias gs='git status -sb'
alias gts='git status -uno'
alias gl='git log --oneline --graph --decorate -20'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gpull='git pull --ff-only'
alias da='deactivate'
alias ports='ports-in-use'
alias work='cd /workspaces'

lastok() {
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

# ---------------------------------------------------------------------------
# Bash completion
# ---------------------------------------------------------------------------
if ! shopt -oq posix; then
  if [[ -f /usr/share/bash-completion/bash_completion ]]; then
    . /usr/share/bash-completion/bash_completion
  elif [[ -f /etc/bash_completion ]]; then
    . /etc/bash_completion
  fi
fi

# ---------------------------------------------------------------------------
# API keys / secrets (loaded from files, never stored in this repo)
# ---------------------------------------------------------------------------
if [[ -r "$HOME/.api.polygon" ]]; then
  export POLYGON_API="$(<"$HOME/.api.polygon")"
fi

if [[ -r "$HOME/.api.claude" ]]; then
  export ANTHROPIC_API_KEY="$(<"$HOME/.api.claude")"
fi

# ---------------------------------------------------------------------------
# Mask API key values in diagnostic commands (env, printenv, set).
# Prevents accidental exposure when inspecting the environment interactively.
# These are safety nets only — keys are still readable via /proc/$$/environ,
# bash -x traces, etc.  Pattern matches any variable containing _API in name.
# ---------------------------------------------------------------------------
env() {
  if [[ $# -eq 0 ]]; then
    command env | sed 's/^\([^=]*_API[^=]*\)=.*$/\1=*****/'
  else
    command env "$@"
  fi
}

printenv() {
  if [[ $# -eq 0 ]]; then
    command printenv | sed 's/^\([^=]*_API[^=]*\)=.*$/\1=*****/'
  else
    command printenv "$@"
  fi
}

set() {
  if [[ $# -eq 0 ]]; then
    builtin set | sed 's/^\([^=]*_API[^=]*\)=.*$/\1=*****/'
  else
    builtin set "$@"
  fi
}

# ---------------------------------------------------------------------------
# Conda / miniconda (skip gracefully if not installed)
# ---------------------------------------------------------------------------
if [[ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]]; then
  . "$HOME/miniconda3/etc/profile.d/conda.sh"
fi

# ---------------------------------------------------------------------------
# Machine-local overrides (not committed to dotfiles)
# Put machine-specific settings here, e.g.:
#   source ~/.venvs/myproject/bin/activate
#   alias work='cd ~/code/myproject'
# ---------------------------------------------------------------------------
if [[ -f "$HOME/.bashrc.local" ]]; then
  source "$HOME/.bashrc.local"
fi
