#!/bin/bash

# Update package list and install prerequisites
sudo apt update
sudo apt install -y curl

# Configure and install starship prompt
curl -sS https://starship.rs/install.sh | sh -s -- -y

# Clone my dotfiles repository
git clone https://github.com/kevanoullio/dotfiles-linux.git ~/dotfiles

# Copy starship.toml configuration file
mkdir -p ~/.config
cp ~/dotfiles-linux/.config/starship.toml ~/.config/starship.toml

echo "Starship prompt setup complete!"
