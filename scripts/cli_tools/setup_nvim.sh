#!/bin/bash

# Neovim install guide: https://youtu.be/zHTeCSVAFNY?si=FonpL2CO8R85TGe4
# Neovim download guide: https://github.com/neovim/neovim/wiki/Installing-Neovim/921fe8c40c34dd1f3fb35d5b48c484db1b8ae94b

# Import helper functions
source "$(dirname "$0")/../utils.sh"

# Begin setup message
env_title="Neovim"
env_verb="setup"
echo "Starting $env_title $env_verb..."

# Detect package manager (safe if already detected by main_setup)
_detect_package_manager || { echo "Failed to detect a supported package manager." >&2; exit 1; }
echo "Using package manager: $PKG_MANAGER"

# Update package list and install dependencies
pm_update || { echo "Package list update failed" >&2; exit 1; }
pm_install neovim ripgrep unzip npm || { echo "Failed to install Neovim dependencies" >&2; exit 1; }
# ripgrep is used by fzf-lua for live grep
# unzip is used by Mason for installing LSP servers/formatters
# npm is used by Mason for installing tools like prettier

# Get the directory of the script
SCRIPT_DIR=$(get_script_dir)

# Copy Neovim configuration files
copy_file "$SCRIPT_DIR/../../home/.config/nvim/init.lua" "$HOME/.config/nvim/init.lua"
copy_directory "$SCRIPT_DIR/../../home/.config/nvim/lua" "$HOME/.config/nvim/lua"
copy_file "$SCRIPT_DIR/../../home/.config/nvim/lazyvim.json" "$HOME/.config/nvim/lazyvim.json"
copy_directory "$SCRIPT_DIR/../../home/.config/nvim/plugin" "$HOME/.config/nvim/plugin"

# lazy.nvim is bootstrapped automatically by lazy.lua on first launch
echo "lazy.nvim will be installed automatically on first Neovim launch."

echo "Neovim setup complete!"
