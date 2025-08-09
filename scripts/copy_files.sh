#!/bin/bash

# Import helper functions
source "$(dirname "$0")/utils.sh"

# Begin setup message
env_title="RC File"
env_verb="copying"
echo "Starting $env_title $env_verb..."

# Copy .rc files (overwrite to ensure latest from dotfiles repo)
cp ~/dotfiles-linux/.bashrc ~/.bashrc
cp ~/dotfiles-linux/.vimrc ~/.vimrc
cp ~/dotfiles-linux/.sqliterc ~/.sqliterc

# Copy the entire .config directory (merge/overwrite)
cp -r ~/dotfiles-linux/.config ~/.config

# Source the new .bashrc for current session
source ~/.bashrc

# Print completion message
print_env_setup_complete "$env_title $env_verb" \
  "Bash" "bash --version | head -n1"

