#!/bin/bash

# Import helper functions
source "$(dirname "$0")/utils.sh"

# Begin setup message
env_title="Addons"
env_verb="setup"
echo "Starting $env_title $env_verb..."

# Add external repositories (one per addon as required)
# Fastfetch repository (only add if not present)
if [ ! -f /etc/apt/sources.list.d/fastfetch.list ]; then
  echo "Adding Fastfetch repository..."
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://raw.githubusercontent.com/fastfetch-cli/fastfetch/master/repo/KEY.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/fastfetch.gpg
  echo "deb [signed-by=/etc/apt/keyrings/fastfetch.gpg] https://fastfetch-cli.github.io/deb stable main" | sudo tee /etc/apt/sources.list.d/fastfetch.list > /dev/null
fi

# Update package
sudo apt update

# Install addon packages
sudo apt install -y fastfetch

# Add a block to rc file to run fastfetch at shell start
fastfetch_title="Fastfetch"
fastfetch_verb="Startup"
fastfetch_block_code='command -v fastfetch >/dev/null 2>&1 && fastfetch'
add_block_to_file "$fastfetch_title" "$fastfetch_verb" "$fastfetch_block_code"

# Print completion summary
print_completion_message "$env_title" "$env_verb" \
  "Fastfetch" "fastfetch --version | head -n1"
