#!/bin/bash

# Import helper functions
source "$(dirname "$0")/utils.sh"

# Begin setup message
env_title="Terminal Tools"
env_verb="setup"
echo "Starting $env_title $env_verb..."

# Update package list
sudo apt update

# Install necessary tools (extend as needed)
sudo apt install -y curl git wget jq tree htop fzf ripgrep

# Print completion message
print_env_setup_complete "Tools" \
    "Curl" "curl --version | head -n1" \
    "Git" "git --version" \
    "jq" "jq --version" \
    "tree" "tree --version" \
    "htop" "htop --version" \
    "fzf" "fzf --version" \
    "ripgrep" "rg --version | head -n1"
