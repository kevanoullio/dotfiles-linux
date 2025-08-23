#!/bin/bash

# Import helper functions
source "$(dirname "$0")/../utils.sh"

# Begin setup message
env_title="RC File"
env_verb="copying"
echo "Starting $env_title $env_verb..."

echo "Choose which RC Files you'd like to overrite"

# Copy the entire home directory with -i (interactive) -v (verbose)
cp -riv ~/dotfiles-linux/home/* ~/

# Source the new .bashrc for current session
source ~/.bashrc

# Print completion message
print_completion_message "$env_title" "$env_verb" \
  "Bash" "bash --version | head -n1"

