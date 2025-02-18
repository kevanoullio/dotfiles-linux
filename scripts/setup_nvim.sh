#!/bin/bash

# Neovim download guide: https://github.com/neovim/neovim/wiki/Installing-Neovim/921fe8c40c34dd1f3fb35d5b48c484db1b8ae94b
# Update package list and install Neovim
sudo apt update
sudo apt install -y neovim

# Create necessary directories for Neovim
mkdir -p ~/.config/nvim

# Copy my Neovim configuration files
cp ~/dotfiles-linux/init.vim ~/.config/nvim/init.vim

# Install vim-plug for managing plugins
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Install plugins specified in init.vim
nvim +PlugInstall +qall

echo "Neovim setup complete!"
