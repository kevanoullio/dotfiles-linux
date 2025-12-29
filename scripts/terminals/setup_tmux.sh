#!/bin/bash

# Import helper functions
source "$(dirname "$0")/../utils.sh"

# Begin setup message
env_title="tmux Terminal Multiplexer"
env_verb="setup"
echo "Starting $env_title $env_verb..."

# Detect package manager (safe if already detected by main_setup)
_detect_package_manager || { echo "Failed to detect a supported package manager." >&2; exit 1; }
echo "Using package manager: $PKG_MANAGER"

# Update package list and install tmux and session management plugins
pm_update || { echo "Package list update failed" >&2; exit 1; }
pm_install tmux xclip || { echo "Failed to install tmux" >&2; exit 1; }

# Install tmux plugin manager and session management plugins if not present
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi
# Optionally clone session plugins manually (if not using TPM)
# git clone https://github.com/tmux-plugins/tmux-resurrect ~/.tmux/plugins/tmux-resurrect
# git clone https://github.com/tmux-plugins/tmux-continuum ~/.tmux/plugins/tmux-continuum
# git clone https://github.com/omerxx/tmux-sessionx ~/.tmux/plugins/tmux-sessionx

# Copy my tmux configuration file
copy_file "$SCRIPT_DIR/../../home/.tmux.conf" ~/.tmux.conf

# Print completion message
print_completion_message "$env_title" "$env_verb" \
    "tmux" "tmux --version | head -n1" \
    "xclip" "xclip --version" \
    "tmux plugin manager (tpm)" "[ -d $TPM_DIR ] && echo 'installed' || echo 'not found'"

echo "xclip allows you to copy text from tmux to your system's clipboard.
Enter copy mode: Ctrl + B followed by [, press y after selecting text to copy it directly to system clipboard."

echo "\nTo enable automatic tmux session saving and restoring, the following plugins are used:"
echo "- tmux-resurrect: https://github.com/tmux-plugins/tmux-resurrect"
echo "- tmux-continuum: https://github.com/tmux-plugins/tmux-continuum"
echo "- tmux-sessionx: https://github.com/omerxx/tmux-sessionx (optional, for advanced session management)"
echo "These are managed by TPM (tmux plugin manager). Press prefix + I inside tmux to install plugins."
