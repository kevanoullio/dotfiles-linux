#!/bin/bash

# Neovim install guide: https://youtu.be/zHTeCSVAFNY?si=FonpL2CO8R85TGe4
# Neovim download guide: https://github.com/neovim/neovim/wiki/Installing-Neovim/921fe8c40c34dd1f3fb35d5b48c484db1b8ae94b

# Update package list and install Neovim
sudo apt update
sudo apt install -y neovim

# Create necessary directories for Neovim
mkdir -p ~/.config/nvim/lua/config ~/.config/nvim/lua/plugins

# Function to copy files with prompt
copy_file() {
    local src=$1
    local dest=$2

    if [ -f "$dest" ]; then
        read -p "$dest already exists. Do you want to overwrite it? (y/n): " choice
        case "$choice" in
            y|Y ) cp -u "$src" "$dest" && echo "Copied $src to $dest" || echo "Error copying $src to $dest";;
            n|N ) echo "Skipped $src";;
            * ) echo "Invalid choice. Skipped $src";;
        esac
    else
        cp -u "$src" "$dest" && echo "Copied $src to $dest" || echo "Error copying $src to $dest"
    fi
}

# Copy my Neovim configuration files
copy_file ../.config/nvim/init.lua ~/.config/nvim/init.lua
copy_file ../.config/nvim/lua/config/keymappings.lua ~/.config/nvim/lua/config/keymappings.lua
copy_file ../.config/nvim/lua/plugins/plugins.lua ~/.config/nvim/lua/plugins/plugins.lua
copy_file ../.config/nvim/lua/config/settings.lua ~/.config/nvim/lua/config/settings.lua
copy_file ../.config/nvim/lua/config/theme.lua ~/.config/nvim/lua/config/theme.lua
copy_file ../.config/nvim/lua/plugins/lazy.lua ~/.config/nvim/lua/plugins/lazy.lua

# lazy.nvim package manager: https://github.com/folke/lazy.nvim 
# Install lazy.nvim package manager
if [ -d ~/.local/share/nvim/site/pack/packer/start/lazy.nvim ]; then
    echo "lazy.nvim already installed, skipping clone."
else
    git clone https://github.com/folke/lazy.nvim.git ~/.local/share/nvim/site/pack/packer/start/lazy.nvim && echo "Cloned lazy.nvim" || echo "Error cloning lazy.nvim"
fi

echo "Neovim setup complete!"
