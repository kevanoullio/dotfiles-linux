#!/bin/bash

# Neovim install guide: https://youtu.be/zHTeCSVAFNY?si=FonpL2CO8R85TGe4
# Neovim download guide: https://github.com/neovim/neovim/wiki/Installing-Neovim/921fe8c40c34dd1f3fb35d5b48c484db1b8ae94b

# Update package list and install Neovim
sudo apt update
sudo apt install -y neovim

# Create necessary directories for Neovim
mkdir -p ~/.config/nvim/lua/config ~/.config/nvim/lua/plugins

# Copy my Neovim configuration files
# Copy my init.lua file
cp -u ~/dotfiles-linux/.config/nvim/init.lua ~/.config/nvim/
# Copy my keymappings.lua file
cp -u ~/dotfiles-linux/.config/nvim/lua/config/keymappings.lua ~/.config/nvim/lua/config/
# Copy my plugins.lua file
cp -u ~/dotfiles-linux/.config/nvim/lua/plugins/plugins.lua ~/.config/nvim/lua/plugins/
# Copy my plugin_setup.lua file
cp -u ~/dotfiles-linux/.config/nvim/lua/config/plugin_setup.lua ~/.config/nvim/lua/config/
# Copy my settings.lua file
cp -u ~/dotfiles-linux/.config/nvim/lua/config/settings.lua ~/.config/nvim/lua/config/
# Copy my theme.lua file
cp -u ~/dotfiles-linux/.config/nvim/lua/config/theme.lua ~/.config/nvim/lua/config/
# Copy my lazy.lua file
cp -u ~/dotfiles-linux/.config/nvim/lua/plugins/lazy.lua ~/.config/nvim/lua/plugins/

# lazy.nvim package manager: https://github.com/folke/lazy.nvim 

# Install lazy.nvim package manager
git clone https://github.com/folke/lazy.nvim.git ~/.local/share/nvim/site/pack/packer/start/lazy.nvim

echo "Neovim setup complete!"
