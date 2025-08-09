#!/bin/bash

# Import helper functions
source "$(dirname "$0")/utils.sh"

# Begin setup message
env_title="C development"
env_verb="setup"
echo "Starting $env_title $env_verb..."

# Update package list
sudo apt update

# Install C development tools
sudo apt install -y build-essential gdb valgrind cmake

# Summary of versions
print_env_setup_complete "$env_title" "$env_verb" \
    "GCC" "gcc --version | head -n1" \
    "G++" "g++ --version | head -n1" \
    "Make" "make --version | head -n1" \
    "GDB" "gdb --version | head -n1" \
    "Valgrind" "valgrind --version" \
    "CMake" "cmake --version | head -n1" \
