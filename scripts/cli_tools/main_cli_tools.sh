#!/bin/bash

# Get the directory of the script
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

# Source utils for package manager detection and exports
source "$SCRIPT_DIR/../utils.sh" || { echo "Failed to source utils.sh" >&2; exit 1; }

# Detect and export package manager variables
_detect_package_manager || exit 1

echo "Using package manager: $PKG_MANAGER"

# Run individual setup scripts (they will reuse exported vars)
bash "$SCRIPT_DIR/setup_ssh.sh" || exit 1
bash "$SCRIPT_DIR/setup_git.sh" || exit 1
bash "$SCRIPT_DIR/setup_core.sh" || exit 1
bash "$SCRIPT_DIR/setup_nvim.sh" || exit 1
bash "$SCRIPT_DIR/setup_addons.sh" || exit 1

echo "All cli tools setups complete!"

