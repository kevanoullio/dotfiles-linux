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

# Update package list and install the packages
pm_update || { echo "Package list update failed" >&2; exit 1; }
pm_install neovim ripgrep unzip npm || { echo "Failed to install Neovim dependencies" >&2; exit 1; }
# ripgrep is a dependency for telescope (a faster alternative to grep)
# unzip is a dependency for installing stylua via :Mason (formatter for lsp stuff)
# npm is a dependency for installing prettier via :Mason (auto formatter)

# Create necessary directories for Neovim
mkdir -p $HOME/.config/nvim/lua/config $HOME/.config/nvim/lua/plugins

# Get the directory of the script
SCRIPT_DIR=$(get_script_dir)

# Copy my Neovim configuration files
copy_file "$SCRIPT_DIR/../../home.config/nvim/init.lua" $HOME/.config/nvim/init.lua
copy_directory "$SCRIPT_DIR/../../home.config/nvim/lua/config" $HOME/.config/nvim/lua/config
copy_directory "$SCRIPT_DIR/../../home.config/nvim/lua/plugins" $HOME/.config/nvim/lua/plugins

# lazy.nvim package manager: https://github.com/folke/lazy.nvim
# Install lazy.nvim package manager
if [ -d $HOME/.local/share/nvim/site/pack/packer/start/lazy.nvim ]; then
    echo "lazy.nvim already installed, skipping clone."
else
    git clone https://github.com/folke/lazy.nvim.git $HOME/.local/share/nvim/site/pack/packer/start/lazy.nvim && echo "Cloned lazy.nvim" || echo "Error cloning lazy.nvim"
fi

echo "Neovim setup complete!"

