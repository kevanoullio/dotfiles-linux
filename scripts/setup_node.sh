#!/bin/bash

# Import all functions from utils.sh
source "$(dirname "$0")/utils.sh"

# Begin setup message
env_title="Node.js environment"
env_verb="setup"
echo "Starting $env_title $env_verb..."

# Detect package manager (safe if already detected by main_setup)
_detect_package_manager || { echo "Failed to detect a supported package manager." >&2; exit 1; }
echo "Using package manager: $PKG_MANAGER"

# Ensure prerequisite packages are installed
echo "Updating package list and installing prerequisites..."
pm_update || { echo "Package list update failed" >&2; exit 1; }
pm_install curl || { echo "Failed to install curl" >&2; exit 1; }

# Install NVM (Node Version Manager) if not already installed
if [ ! -d "$HOME/.nvm" ]; then
    echo "Installing NVM (Node Version Manager)..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
    echo "NVM installed successfully!"
else
    echo "NVM is already installed."
fi

# Define NVM initialization block parameters
node_title="Node Version Manager"
node_verb="Initialization"
node_setup_code='export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"'

# Add NVM initialization block to managed rc file
add_block_to_file "$node_title" "$node_verb" "$node_setup_code"

# Source NVM for current session so we can run nvm commands below
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Install Node.js LTS version
echo "Installing Node.js LTS version..."
nvm install --lts
nvm use --lts
nvm alias default node

# Update npm to latest version
echo "Updating npm to latest version..."
npm install -g npm@latest

# # Optional: install common global packages (uncomment to enable)
# npm install -g \
#     nodemon \
#     eslint \
#     prettier \
#     typescript \
#     ts-node \
#     @types/node \
#     http-server \
#     pm2

# # Verify installations
# echo "Verifying package installations..."
# packages=("nodemon" "eslint" "prettier" "typescript" "ts-node" "http-server" "pm2")
# for package in "${packages[@]}"; do
#     if npm list -g "$package" &> /dev/null; then
#         echo "✓ $package installed successfully"
#     else
#         echo "✗ Failed to install $package"
#     fi
# done

# Print completion message
print_completion_message "$env_title" "$env_verb" \
  "Node.js" "node --version" \
  "npm" "npm --version"
