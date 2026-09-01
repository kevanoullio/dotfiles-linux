#!/bin/bash

# Import helper functions
source "$(dirname "$0")/../utils.sh"

# Begin setup message
env_title="Git-related Tools"
env_verb="setup"
echo "Starting $env_title $env_verb..."

# Detect package manager (safe if already detected by main_setup)
_detect_package_manager || { echo "Failed to detect a supported package manager." >&2; exit 1; }
echo "Using package manager: $PKG_MANAGER"

# Update package list and install necessary tools
pm_update || { echo "Package list update failed" >&2; exit 1; }
pm_install git || { echo "Failed to install terminal tools" >&2; exit 1; }

# Get the directory of the script
SCRIPT_DIR=$(get_script_dir)

# Ensure ~/.config/git/ directory exists
GIT_CONFIG_DIR="$HOME/.config/git"
create_directory "$GIT_CONFIG_DIR"

# Copy release.gitconfig (release alias configuration)
RELEASE_GITCONFIG_SRC="$SCRIPT_DIR/../../git_projects/release.gitconfig"
RELEASE_GITCONFIG_DEST="$GIT_CONFIG_DIR/release.gitconfig"
copy_file "$RELEASE_GITCONFIG_SRC" "$RELEASE_GITCONFIG_DEST"

# Create hooks directory if it doesn't exist
HOOKS_DIR="$GIT_CONFIG_DIR/hooks"
create_directory "$HOOKS_DIR"

# Copy pre-push hook
PRE_PUSH_SRC="$SCRIPT_DIR/../../git_projects/hooks/pre-push"
PRE_PUSH_DEST="$HOOKS_DIR/pre-push"
copy_file "$PRE_PUSH_SRC" "$PRE_PUSH_DEST"

# Copy release-common.sh (shared helper for release alias and pre-push hook)
RELEASE_COMMON_SRC="$SCRIPT_DIR/../../git_projects/hooks/release-common.sh"
RELEASE_COMMON_DEST="$HOOKS_DIR/release-common.sh"
copy_file "$RELEASE_COMMON_SRC" "$RELEASE_COMMON_DEST"

# Copy release.sh (standalone script for the git release alias)
RELEASE_SCRIPT_SRC="$SCRIPT_DIR/../../git_projects/hooks/release.sh"
RELEASE_SCRIPT_DEST="$HOOKS_DIR/release.sh"
copy_file "$RELEASE_SCRIPT_SRC" "$RELEASE_SCRIPT_DEST"

# Set git global config for release workflow
# Include the release.gitconfig (idempotent - overwrites silently if exists)
echo "Configuring git to include release.gitconfig..."
git config --global include.path "$RELEASE_GITCONFIG_DEST"

# Point git at the hooks directory (idempotent)
echo "Configuring core.hooksPath..."
git config --global core.hooksPath "$HOOKS_DIR"

# Set release.libdir so the release alias knows where to find release-common.sh
echo "Configuring release.libdir..."
git config --global release.libdir "$HOOKS_DIR"

# Check if release key exists; prompt for optional setup
RELEASE_KEY_FILE="$GIT_CONFIG_DIR/release-key"
if [ ! -f "$RELEASE_KEY_FILE" ]; then
    echo ""
    echo "No release bypass key found at $RELEASE_KEY_FILE."
    echo "This is needed for the 'git release' workflow to push to production."
    echo "You can either:"
    echo "  1. Create a key file now (interactive)"
    echo "  2. Set it via environment variable: export GIT_RELEASE_KEY='<your-key>'"
    echo ""
    read -p "Create release key file now? (y/n): " create_key
    if [ "$create_key" = "y" ] || [ "$create_key" = "Y" ]; then
        echo "Enter your release bypass key (or press Enter to generate a random one):"
        read -r key_input
        if [ -z "$key_input" ]; then
            key_input=$(openssl rand -hex 16 2>/dev/null || head -c 32 /dev/urandom | xxd -p | head -c 32)
            echo "Generated random key: $key_input"
        fi
        printf '%s' "$key_input" > "$RELEASE_KEY_FILE"
        chmod 600 "$RELEASE_KEY_FILE"
        echo "Release key saved to $RELEASE_KEY_FILE (mode 600)"
    else
        echo "Skipping release key setup."
        echo "Remember to set GIT_RELEASE_KEY env var or create $RELEASE_KEY_FILE before using 'git release'."
    fi
else
    echo "Release key already exists at $RELEASE_KEY_FILE."
fi

# Print completion message
print_completion_message "$env_title" "$env_verb" \
    "Git" "git --version" \
    "release alias" "[ -f $RELEASE_GITCONFIG_DEST ] && echo 'installed' || echo 'not found'" \
    "pre-push hook" "[ -f $PRE_PUSH_DEST ] && echo 'installed' || echo 'not found'" \
    "release-common.sh" "[ -f $RELEASE_COMMON_DEST ] && echo 'installed' || echo 'not found'" \
    "release.sh" "[ -f $RELEASE_SCRIPT_DEST ] && echo 'installed' || echo 'not found'"

echo ""
echo "Setup complete! To use in new terminal sessions, restart your terminal or run:"
echo "  source $MANAGED_SHELL_RC"
