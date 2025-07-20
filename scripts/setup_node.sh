#!/bin/bash

# Update package list and install prerequisites
echo "Updating package list and installing prerequisites..."
sudo apt update
sudo apt install -y curl wget build-essential

# Install NVM (Node Version Manager) if not already installed
if [ ! -d "$HOME/.nvm" ]; then
    echo "Installing NVM (Node Version Manager)..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash

    # Source nvm to make it available in current session
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

    echo "NVM installed successfully!"
else
    echo "NVM is already installed."
    # Source nvm to make it available in current session
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
fi

# Install Node.js LTS version
echo "Installing Node.js LTS version..."
nvm install --lts
nvm use --lts
nvm alias default node

# Verify Node.js and npm installation
echo "Verifying installation..."
node_version=$(node --version)
npm_version=$(npm --version)
echo "Node.js version: $node_version"
echo "npm version: $npm_version"

# Update npm to latest version
echo "Updating npm to latest version..."
npm install -g npm@latest

# # Install common Node.js packages globally
# echo "Installing common Node.js packages..."
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

echo ""
echo "Node.js environment setup complete!"
echo "Installed Node.js version: $node_version"
echo "Installed npm version: $(npm --version)"
echo ""
echo "To use Node.js in new terminal sessions, make sure to restart your terminal"
echo "or run: source ~/.bashrc"
