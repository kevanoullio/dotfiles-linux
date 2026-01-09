# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# -----------------------------------------------------------------------------
# 1. Interactive Shell Check
# -----------------------------------------------------------------------------
# If not running interactively (like running scripts or commands automatically), don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# -----------------------------------------------------------------------------
# 2. Command Line Editing Mode
# -----------------------------------------------------------------------------
# Enable vi mode for command line editing
set -o vi

# -----------------------------------------------------------------------------
# 3. Bash History Settings
# -----------------------------------------------------------------------------
# Don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# Append to the history file, don't overwrite it
shopt -s histappend

# For setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# -----------------------------------------------------------------------------
# 4. Terminal & Window Settings
# -----------------------------------------------------------------------------
# Check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# Make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# -----------------------------------------------------------------------------
# 5. Prompt & Color Settings
# -----------------------------------------------------------------------------
# Set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# Uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi

# Sets the prompt (ps1) with or without color
if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# -----------------------------------------------------------------------------
# 6. Alias Definitions (Sourced from ~/.bash_aliases)
# -----------------------------------------------------------------------------
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# -----------------------------------------------------------------------------
# 7. Programmable Completion
# -----------------------------------------------------------------------------
# Enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# -----------------------------------------------------------------------------
# 8. SSH Agent Setup
# -----------------------------------------------------------------------------
# Start the ssh agent automatically when opening a new terminal
if [ -z "$SSH_AUTH_SOCK" ]; then
  eval "$(ssh-agent -s)" > /dev/null
  ssh-add
fi

# -----------------------------------------------------------------------------
# 9. Node & JavaScript Tooling
# -----------------------------------------------------------------------------
# Node Version Manager
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# pnpm
export PNPM_HOME="/home/kevano/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# -----------------------------------------------------------------------------
# 10. Conda Initialization
# -----------------------------------------------------------------------------
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/kevano/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/kevano/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/home/kevano/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/kevano/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup

# -----------------------------------------------------------------------------
# 11. GoLang Configuration
# -----------------------------------------------------------------------------
export GOROOT=/usr/lib/go
export GOPATH=$HOME/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

# -----------------------------------------------------------------------------
# 12. Starship Prompt Configuration
# -----------------------------------------------------------------------------
# Starship config
eval "$(starship init bash)"

# Starship nerd-font preset
starship preset nerd-font-symbols -o ~/.config/starship.toml

# -----------------------------------------------------------------------------
# 13. Miscellaneous Startup Commands
# -----------------------------------------------------------------------------
# Launch fastfetch at startup
fastfetch
