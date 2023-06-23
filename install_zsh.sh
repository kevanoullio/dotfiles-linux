#!/bin/bash

# Install zsh and zsh-syntax-highlighting
sudo apt install zsh zsh-syntax-highlighting

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

