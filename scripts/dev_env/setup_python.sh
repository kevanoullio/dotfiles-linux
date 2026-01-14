#!/bin/bash
# This line makes the script exit immediately if any command returns a non-zero (error) status, except in certain contexts (like within if statements or command lists with || or &&). This helps catch errors early and prevents the script from continuing after a failure.
set -e

# ------------------------------------------------------------
# Python / Conda environment setup
# ------------------------------------------------------------

# Source utils.sh for bashrc helpers
source "$(dirname "$0")/../utils.sh"

# Define environment parameters
ENV_NAME="ai_models"
ENV_PYTHON_VERSION="3.11"

# Define directory variables
MINICONDA_DIR="$HOME/miniconda3"
CONDA_BIN="$MINICONDA_DIR/bin/conda"

# Begin setup message
ENV_TITLE="Python environment"
ENV_VERB="setup"

echo "Starting $ENV_TITLE $ENV_VERB..."

# ------------------------------------------------------------
# Detect package manager (safe if already detected by main_setup)
# ------------------------------------------------------------
_detect_package_manager || {
    echo "Failed to detect a supported package manager." >&2
    exit 1
}
echo "Using package manager: $PKG_MANAGER"

# ------------------------------------------------------------
# Ensure prerequisite packages are installed
# ------------------------------------------------------------
echo "Updating package list and installing prerequisites..."
pm_update || {
    echo "Package list update failed" >&2
    exit 1
}
pm_install wget || {
    echo "Failed to install wget" >&2
    exit 1
}

# ------------------------------------------------------------
# Install Miniconda (if missing)
# ------------------------------------------------------------
if [ ! -d "$MINICONDA_DIR" ]; then
    echo "Installing Miniconda..."
    wget -q https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
        -O /tmp/miniconda.sh
    bash /tmp/miniconda.sh -b -p "$MINICONDA_DIR"
    rm /tmp/miniconda.sh
else
    echo "Miniconda already installed."
fi

# ------------------------------------------------------------
# Make conda available in this script session
# ------------------------------------------------------------
if ! command -v conda >/dev/null 2>&1; then
    eval "$("$CONDA_BIN" shell.bash hook)"
fi

# Safety check
if ! command -v conda >/dev/null 2>&1; then
    echo "Error: conda command not available." >&2
    exit 1
fi

# ------------------------------------------------------------
# Initialize conda for future shells (ONLY ONCE)
# ------------------------------------------------------------
if ! grep -q '>>> conda initialize >>>' "$HOME/.bashrc"; then
    echo "Initializing conda in .bashrc..."
    conda init bash
else
    echo "Conda already initialized in .bashrc."
fi

# Silence Omarchy hashing warning (optional but recommended)
if ! grep -q 'CONDA_DISABLE_HASH_R' "$HOME/.bashrc"; then
    echo '# Prevents bash: hash: hashing disabled warning from conda/Omarchy' >> "$HOME/.bashrc"
    echo 'export CONDA_DISABLE_HASH_R=1' >> "$HOME/.bashrc"
fi

# ------------------------------------------------------------
# Conda configuration (safe, does not touch base packages)
# ------------------------------------------------------------
conda config --add channels conda-forge || true
conda config --set channel_priority strict || true

# ------------------------------------------------------------
# Create project environment (micromamba-style)
# ------------------------------------------------------------
if ! conda env list | awk '{print $1}' | grep -qx "$ENV_NAME"; then
    echo "Creating conda environment: $ENV_NAME (Python $ENV_PYTHON_VERSION)"
    conda create -y -n "$ENV_NAME" python="$ENV_PYTHON_VERSION"
else
    echo "Conda environment '$ENV_NAME' already exists."
fi

# ------------------------------------------------------------
# Completion message
# ------------------------------------------------------------
print_completion_message "$ENV_TITLE" "$ENV_VERB" \
    "Conda" "$CONDA_BIN --version" \
    "Env" "conda activate $ENV_NAME"
