#!/bin/bash

# Import helper functions
source "$(dirname "$0")/../utils.sh"

# Begin setup message
env_title="Zsh"
env_verb="setup"
echo "Starting $env_title $env_verb..."

# Detect package manager (safe if already detected by main_setup)
_detect_package_manager || { echo "Failed to detect a supported package manager." >&2; exit 1; }
echo "Using package manager: $PKG_MANAGER"

# Install zsh and zsh-syntax-highlighting
pm_install zsh zsh-syntax-highlighting || { echo "Failed to install zsh or zsh-syntax-highlighting" >&2; exit 1; }

# Make zsh the default shell
chsh -s $(which zsh)

# Create the zsh config directory
mkdir -p ~/.config/zsh

# Move zsh config files to the new directory
mv ~/.zshrc ~/.config/zsh/

# Update .zprofile to source the moved config files
echo "source ~/.config/zsh/.zshrc" >> ~/.zprofile

# Enable zsh-syntax-highlighting
echo "source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ~/.config/zsh/.zshrc

# Print completion message
print_completion_message "$env_title" "$env_verb" \
  "Zsh" "zsh --version | head -n1"

