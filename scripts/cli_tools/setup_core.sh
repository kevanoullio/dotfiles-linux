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
# pm_install curl wget jq bat tree fzf fd ripgrep htop cloc xclip || { echo "Failed to install core cli tools" >&2; exit 1; }
pm_install curl wget jq bat tree fzf fd ripgrep htop cloc || { echo "Failed to install core cli tools" >&2; exit 1; }

# Print completion message
print_completion_message "$env_title" "$env_verb" \
    "curl" "curl --version | head -n1" \
    "wget" "wget --version | head -n1" \
    "jq" "jq --version" \
    "bat" "bat --version | head -n1" \
    "tree" "tree --version" \
    "fzf" "fzf --version" \
    "fd" "fd --version | head -n1" \
    "ripgrep" "rg --version | head -n1" \
    "htop" "htop --version" \
    "cloc" "cloc --version" \
    # "xclip" "xclip --version"
