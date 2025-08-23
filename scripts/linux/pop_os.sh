#!/bin/bash

# Import helper functions
source "$(dirname "$0")/../utils.sh"

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
print_completion_message "$env_title" "$env_verb" \
    "Font" "fc-list | grep -i 'CaskaydiaMono' | head -n1"


# Configure Pop_OS! settings
echo "Configuring Pop_OS! settings..."

# Configure keybindings
echo "Configuring keybindings..."

# Set 'Show Workspaces' to only Super+Tab
# Remove all other bindings for this action
# The default key is '<Super>D'
echo "Setting 'Show Workspaces' to only Super+Tab"
gsettings set org.gnome.shell.keybindings toggle-overview "[]"
gsettings set org.gnome.shell.keybindings toggle-overview "['<Super>Tab']"

# Remove all key commands assigned to 'Switch applications' and set only Alt+Tab
echo "Setting 'Switch applications' to only Alt+Tab"
gsettings set org.gnome.desktop.wm.keybindings switch-applications "[]"
gsettings set org.gnome.desktop.wm.keybindings switch-applications "['<Alt>Tab']"

echo "Workspace and application switching keybindings updated."
