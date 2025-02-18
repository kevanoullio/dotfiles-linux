#!/bin/bash

# Update package list and install Neovim
sudo apt update
sudo apt install -y neovim curl git

# Clone my dotfiles repository
git clone https://github.com/kevanoullio/dotfiles-linux.git ~/dotfiles

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
