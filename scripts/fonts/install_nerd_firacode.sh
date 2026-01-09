#!/bin/bash
# Import helper functions if needed
if [ -f "$(dirname "$0")/../utils.sh" ]; then
    source "$(dirname "$0")/../utils.sh"
fi

# Begin setup message
env_title="Font"
env_verb="install"
echo "Starting $env_title $env_verb..."

# Set generic variables
FONT_BASEDIR="$HOME/.local/share/fonts"
FC_LIST_BIN="fc-list"
FC_CACHE_BIN="fc-cache"
if [ -x /usr/bin/fc-list ]; then
    FC_LIST_BIN="/usr/bin/fc-list"
fi
if [ -x /usr/bin/fc-cache ]; then
    FC_CACHE_BIN="/usr/bin/fc-cache"
fi

# Install FiraCode Nerd Font using the generic font installer
FIRACODE_FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/FiraCode.zip"
FIRA_FONT_FOLDER="FiraCode"
install_font_zip_to_dir "$FIRACODE_FONT_URL" "$FONT_BASEDIR" "$FIRA_FONT_FOLDER"

if command -v print_completion_message &>/dev/null; then
    print_completion_message "$env_title" "$env_verb" \
        "FiraCode Nerd Font" "fc-list | grep -i 'FiraCode' | head -n1"
else
    echo "FiraCode Nerd Font installation complete."
    fc-list | grep -i 'FiraCode' | head -n1
fi

# Update font cache for the base font directory
echo "Updating font cache for $FONT_BASEDIR ..."
$FC_CACHE_BIN -fv "$FONT_BASEDIR"
fc_cache_status=$?
if [ $fc_cache_status -eq 0 ]; then
    echo "Font cache updated successfully."
else
    echo "Warning: Font cache update failed (exit code $fc_cache_status)."
fi
