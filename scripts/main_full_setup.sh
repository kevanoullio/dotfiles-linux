#!/bin/bash

# Get the directory of the script
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

# Source utils for package manager detection and exports
source "$SCRIPT_DIR/utils.sh" || { echo "Failed to source utils.sh" >&2; exit 1; }

# Detect and export package manager variables
_detect_package_manager || exit 1

echo "Using package manager: $PKG_MANAGER"

# Run individual setup scripts (they will reuse exported vars)
bash "$SCRIPT_DIR/dotfiles/main_dotfiles.sh" || exit 1
bash "$SCRIPT_DIR/cli_tools/main_cli_tools.sh" || exit 1
bash "$SCRIPT_DIR/terminals/main_terminals.sh" || exit 1
bash "$SCRIPT_DIR/dev_env/main_dev_env.sh" || exit 1

# THIS DOES NOT INSTALL ALL SHELLS AUTOMATICALLY!!!
# PLEASE INSTALL YOUR DESIRED SHELL MANUALLY.

echo "All setups complete!"

