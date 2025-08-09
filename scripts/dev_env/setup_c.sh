#!/bin/bash

# Import helper functions
source "$(dirname "$0")/../utils.sh"

# Begin setup message
env_title="C development"
env_verb="setup"
echo "Starting $env_title $env_verb..."

# Detect package manager (safe if already detected by main_setup)
_detect_package_manager || { echo "Failed to detect a supported package manager." >&2; exit 1; }
echo "Using package manager: $PKG_MANAGER"

# Update package list and install C development tools
pm_update || { echo "Package list update failed" >&2; exit 1; }
pm_install build-essential gdb valgrind cmake || { echo "Failed to install C development tools" >&2; exit 1; }

# Print completion message
print_completion_message "$env_title" "$env_verb" \
    "GCC" "gcc --version | head -n1" \
    "G++" "g++ --version | head -n1" \
    "Make" "make --version | head -n1" \
    "GDB" "gdb --version | head -n1" \
    "Valgrind" "valgrind --version" \
    "CMake" "cmake --version | head -n1"
