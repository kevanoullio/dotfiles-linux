#!/bin/bash

# Source utils.sh for bashrc helpers
source "$(dirname "$0")/utils.sh"

# Begin setup message
env_title="Python environment"
env_verb="setup"
echo "Starting $env_title $env_verb..."

# Detect package manager (safe if already detected by main_setup)
_detect_package_manager || { echo "Failed to detect a supported package manager." >&2; exit 1; }
echo "Using package manager: $PKG_MANAGER"

# Ensure prerequisite packages are installed
echo "Updating package list and installing prerequisites..."
pm_update || { echo "Package list update failed" >&2; exit 1; }
pm_install wget || { echo "Failed to install wget" >&2; exit 1; }

# Install Miniconda (if not already installed)
if [ ! -d "$HOME/miniconda3" ]; then
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh
    bash ~/miniconda.sh -b -p "$HOME/miniconda3"
    rm ~/miniconda.sh
    # Initialize conda for current session
    eval "$("$HOME/miniconda3/bin/conda" shell.bash hook)"
    conda init
else
    echo "Miniconda is already installed."
    # Ensure conda is available in current shell
    command -v conda >/dev/null 2>&1 || eval "$("$HOME/miniconda3/bin/conda" shell.bash hook)"
fi

# Safety: if conda still not available, abort
if ! command -v conda >/dev/null 2>&1; then
    echo "Error: conda command not available. Aborting." >&2
    exit 1
fi

# Set up the base Conda environment with Python 3.12
conda install python=3.12 -y

# Install common Python packages in the base Conda environment
conda install -y numpy pandas

# Define initialization parameters
miniconda_title="Miniconda"
miniconda_verb="Initialization"
miniconda_setup_code='# !! Contents within this block are managed by '\''conda init'\'' !!
__miniconda_setup="$("$HOME/miniconda3/bin/conda" shell.bash hook 2>/dev/null)"
if [ $? -eq 0 ]; then
    eval "$__miniconda_setup"
elif [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
    . "$HOME/miniconda3/etc/profile.d/conda.sh"
else
    export PATH="$HOME/miniconda3/bin:$PATH"
fi
unset __miniconda_setup'

# Add Miniconda initialization to rc file (defaults to $MANAGED_SHELL_RC)
add_block_to_file "$miniconda_title" "$miniconda_verb" "$miniconda_setup_code"

# Print completion message
print_completion_message "$env_title" "$env_verb" \
    "Miniconda" "$HOME/miniconda3/bin/conda --version" \
    "Python" "$HOME/miniconda3/bin/python --version"
