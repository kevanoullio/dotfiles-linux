# ============================================================================
# ~/.bash_aliases: Bash alias definitions (sourced from ~/.bashrc)
# ============================================================================

# -----------------------------------------------------------------------------
# 1. Safer File Deletion
# -----------------------------------------------------------------------------
# Alias to ensure bash always asks confirmation when deleting files and directories
alias rm='rm -i'

# -----------------------------------------------------------------------------
# 2. ls Aliases
# -----------------------------------------------------------------------------
# Enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# -----------------------------------------------------------------------------
# 3. Alert Alias
# -----------------------------------------------------------------------------
# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# -----------------------------------------------------------------------------
# 4. More Aliases
# -----------------------------------------------------------------------------
# Add more aliases below this line
