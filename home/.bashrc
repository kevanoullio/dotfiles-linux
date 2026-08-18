# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
# /etc/omarchy.conf is written by omarchy-dev-link. When absent, force the
# package default instead of preserving a stale inherited dev-link value before
# we decide which rc file to source.
if [[ -f /etc/omarchy.conf ]]; then
  source /etc/omarchy.conf
  export OMARCHY_PATH="${OMARCHY_PATH:-/usr/share/omarchy}"
else
  export OMARCHY_PATH=/usr/share/omarchy
fi
source "$OMARCHY_PATH/default/bash/rc"

# Add your own exports, aliases, and functions here.
#
# Make an alias for invoking commands you use constantly
# alias p='python'

. "$HOME/.local/share/../bin/env"
. "$HOME/.cargo/env"


# ==============================================================================
# SSH AGENT AUTO-START & PROCESS REUSE
# ==============================================================================
# Find an existing ssh-agent process owned by the current user
SSH_AGENT_PID=$(pgrep -u "$USER" -x ssh-agent | head -n 1)

if [ -n "$SSH_AGENT_PID" ]; then
    # Agent is running: recover its socket path dynamically from /tmp
    SSH_AUTH_SOCK=$(find /tmp/ssh-* -type s -u "$USER" -name "agent.*" 2>/dev/null | head -n 1)
    export SSH_AUTH_SOCK
    export SSH_AGENT_PID
else
    # No agent running: spawn a new one silently
    eval "$(ssh-agent -s)" > /dev/null
fi

# If no keys are currently loaded in memory, prompt for passphrase
if ! ssh-add -l > /dev/null 2>&1; then
    ssh-add ~/.ssh/id_ed25519
fi
# <<< ssh-agent end <<<


# yazi defaults
export EDITOR="nvim"
export VISUAL="nvim"
# yazi defaults end


# ==============================================================================
# CONDA RELATED ACTIVITIES
# ==============================================================================
# Disable conda automatic activation of base python
export CONDA_AUTO_ACTIVATE_BASE=false

# >>> conda initialize >>>
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
# <<< conda initialize end <<<

# Prevents bash: hash: hashing disabled warning from conda/Omarchy
#export CONDA_DISABLE_HASH_R=1


# >>> mise initialize >>>
eval "$(mise activate bash)"
# <<< mise initialize <<<


# Added by LM Studio CLI (lms)
export PATH="$PATH:/home/kevano/.lmstudio/bin"
# End of LM Studio CLI section


# pnpm
export PNPM_HOME="/home/kevano/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end


# go
export GOPATH=$HOME/Development/
export GOMODCACHE=$HOME/Development/go/pkg/mod/
export GOCACHE=$HOME/Development/go/cache/
# go end


# flutter
export PATH="$PATH:$HOME/Development/flutter/bin"
export CHROME_EXECUTABLE=chromium
# flutter end
