# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source ~/.local/share/omarchy/default/bash/rc

# Add your own exports, aliases, and functions here.
#
# Make an alias for invoking commands you use constantly
# alias p='python'

. "$HOME/.local/share/../bin/env"
. "$HOME/.cargo/env"


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
# <<< conda initialize <<<

# Prevents bash: hash: hashing disabled warning from conda/Omarchy
export CONDA_DISABLE_HASH_R=1


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


# flutter
export PATH="$PATH:$HOME/Development/flutter/bin"
export CHROME_EXECUTABLE=chromium
# flutter end
