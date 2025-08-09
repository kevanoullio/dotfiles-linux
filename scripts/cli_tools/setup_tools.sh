#!/bin/bash

# Import helper functions
source "$(dirname "$0")/../utils.sh"

# Begin setup message
env_title="Common Terminal Tools"
env_verb="setup"
echo "Starting $env_title $env_verb..."

# Detect package manager (safe if already detected by main_setup)
_detect_package_manager || { echo "Failed to detect a supported package manager." >&2; exit 1; }
echo "Using package manager: $PKG_MANAGER"

# Update package list and install necessary tools
pm_update || { echo "Package list update failed" >&2; exit 1; }
pm_install curl wget jq tree htop fzf ripgrep || { echo "Failed to install terminal tools" >&2; exit 1; }

# Print completion message
print_completion_message "$env_title" "$env_verb" \
    "Curl" "curl --version | head -n1" \
    "jq" "jq --version" \
    "tree" "tree --version" \
    "htop" "htop --version" \
    "fzf" "fzf --version" \
    "ripgrep" "rg --version | head -n1"
