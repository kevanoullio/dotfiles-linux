#!/bin/bash

# Instructions:
# https://medium.com/quick-programming/managing-dotfiles-with-gnu-stow-9b04c155ebad

# Import helper functions
source "$(dirname "$0")/../utils.sh"

# Begin setup message
env_title="GNU Stow"
env_verb="setup"
echo "Starting $env_title $env_verb..."

# Detect package manager (safe if already detected by main_setup)
_detect_package_manager || { echo "Failed to detect a supported package manager." >&2; exit 1; }
echo "Using package manager: $PKG_MANAGER"

# Update package list and install stow
pm_update || { echo "Package list update failed" >&2; exit 1; }
pm_install stow || { echo "Failed to install stow" >&2; exit 1; }

# Print completion message
print_completion_message "$env_title" "$env_verb" \
    "stow" "stow --version | head -n1"
