#!/bin/bash

# Import helper functions if needed
if [ -f "$(dirname "$0")/../utils.sh" ]; then
    source "$(dirname "$0")/../utils.sh"
fi

# Begin setup message
env_title="Font"
env_verb="install"
echo "Starting $env_title $env_verb..."

# Install CaskaydiaMono Nerd Font using dedicated script
"$(dirname "$0")/../fonts/install_nerd_font.sh"

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
