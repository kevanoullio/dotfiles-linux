#!/bin/bash

# Import helper functions if needed
if [ -f "$(dirname "$0")/../utils.sh" ]; then
    source "$(dirname "$0")/../utils.sh"
fi

# Begin setup message
env_title="Font"
env_verb="install"
echo "Starting $env_title $env_verb..."

# Install CaskaydiaMono Nerd Font to get Font Awesome, Material Design, Devicons, etc
FONT_FOLDER="CascadiaMono"
FONT_DIR="$HOME/.local/share/fonts"
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/CascadiaMono.zip"

install_from_zip "$FONT_URL" "$FONT_DIR" "$FONT_FOLDER"

# Print completion message
if command -v print_completion_message &>/dev/null; then
    print_completion_message "$env_title" "$env_verb" \
        "Font" "fc-list | grep -i 'CaskaydiaMono' | head -n1"
else
    echo "CaskaydiaMono Nerd Font installation complete."
    fc-list | grep -i 'CaskaydiaMono' | head -n1
fi
