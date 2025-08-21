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
pm_install tmux || { echo "Failed to install tmux" >&2; exit 1; }

# Print completion message
print_completion_message "$env_title" "$env_verb" \
    "tmux" "tmux --version | head -n1"
