#!/bin/bash

# Set 'Show Workspaces' to only Super+Tab
# Remove all other bindings for this action
# The default key is '<Super>D'
gsettings set org.gnome.shell.keybindings toggle-overview "[]"
gsettings set org.gnome.shell.keybindings toggle-overview "['<Super>Tab']"

# Remove all key commands assigned to 'Switch applications' and set only Alt+Tab
gsettings set org.gnome.desktop.wm.keybindings switch-applications "[]"
gsettings set org.gnome.desktop.wm.keybindings switch-applications "['<Alt>Tab']"

echo "Workspace and application switching keybindings updated."
