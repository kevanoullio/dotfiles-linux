#!/bin/bash

# Import helper functions
source "$(dirname "$0")/utils.sh"

# Begin setup message
env_title="Starship"
env_verb="setup"
echo "Starting $env_title $env_verb..."

# Update package list and install prerequisites
echo "Updating package list and installing prerequisites..."
sudo apt update
sudo apt install -y curl

# Install Starship prompt if not already installed
if ! command -v starship >/dev/null 2>&1; then
    echo "Installing Starship prompt..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y
    echo "Starship installed."
else
    echo "Starship already installed."
fi

# Ensure config directory exists and copy config file (overwrite to keep dotfiles as source of truth)
mkdir -p ~/.config
if [ -f ~/dotfiles-linux/.config/starship.toml ]; then
    cp ~/dotfiles-linux/.config/starship.toml ~/.config/starship.toml
fi

# Add Starship initialization managed block to rc file
starship_title="Starship"
starship_verb="Initialization"
starship_block_code='# Starship prompt initialization
eval "$(starship init bash)"

# Ensure nerd-font symbols preset (idempotent)
command -v starship >/dev/null 2>&1 && starship preset nerd-font-symbols -o ~/.config/starship.toml'
add_block_to_file "$starship_title" "$starship_verb" "$starship_block_code"

# Print completion message
print_completion_message "$env_title" "$env_verb" \
  "Starship" "starship --version"

