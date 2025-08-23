#!/bin/bash

# Import helper functions
source "$(dirname "$0")/../utils.sh"

# Begin setup message
env_title="tmux Terminal Multiplexer"
env_verb="setup"
echo "Starting $env_title $env_verb..."

# Detect package manager (safe if already detected by main_setup)
_detect_package_manager || { echo "Failed to detect a supported package manager." >&2; exit 1; }
echo "Using package manager: $PKG_MANAGER"

# Update package list and install tmux
pm_update || { echo "Package list update failed" >&2; exit 1; }
pm_install tmux xclip || { echo "Failed to install tmux" >&2; exit 1; }

# Copy my tmux configuration file
copy_file "$SCRIPT_DIR/../../home/.tmux.conf" ~/.tmux.conf

# Print completion message
print_completion_message "$env_title" "$env_verb" \
    "tmux" "tmux --version | head -n1" \
    "xclip" "xclip --version"

echo "xclip allows you to copy text from tmux to your system's clipboard.
Enter copy mode: Ctrl + B followed by [, press y after selecting text to copy it directly to system clipboard."
