#!/bin/bash

# Import all functions from utils.sh
source "$(dirname "$0")/../utils.sh"

# Check if bats is already on PATH
if command -v bats >/dev/null 2>&1; then
    echo "bats is already installed: $(bats --version)"
    exit 0
fi

env_title="BATS (Bash Automated Testing System) environment"
env_verb="setup"
echo "Starting $env_title $env_verb..."

# Detect package manager
_detect_package_manager || { echo "Failed to detect a supported package manager." >&2; exit 1; }
echo "Using package manager: $PKG_MANAGER"

# Try system package manager first
echo "Attempting to install bats via $PKG_MANAGER..."
if pm_install bats-core 2>/dev/null || pm_install bats 2>/dev/null; then
    echo "bats installed via $PKG_MANAGER."
else
    echo "Package manager install failed; falling back to npm..."
    if command -v npm >/dev/null 2>&1; then
        npm install -g bats
    else
        echo "ERROR: Neither package manager nor npm is available to install bats." >&2
        exit 1
    fi
fi

# Verify installation
if ! command -v bats >/dev/null 2>&1; then
    echo "ERROR: bats installation failed — 'bats' not found on PATH." >&2
    exit 1
fi

print_completion_message "$env_title" "$env_verb" \
    "BATS" "bats --version"
