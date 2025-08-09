#!/bin/bash

# Import helper functions
source "$(dirname "$0")/../utils.sh"

# Begin setup message
env_title="RC File"
env_verb="copying"
echo "Starting $env_title $env_verb..."

# Copy .rc files (overwrite to ensure latest from dotfiles repo)
cp ~/dotfiles-linux/rc_files/.bashrc ~/.bashrc
cp ~/dotfiles-linux/rc_files/.vimrc ~/.vimrc
cp ~/dotfiles-linux/rc_files/.sqliterc ~/.sqliterc

# Copy the entire .config directory (merge/overwrite)
cp -r ~/dotfiles-linux/.config ~/.config

# Source the new .bashrc for current session
source ~/.bashrc

# Print completion message
print_completion_message "$env_title" "$env_verb" \
  "Bash" "bash --version | head -n1"

