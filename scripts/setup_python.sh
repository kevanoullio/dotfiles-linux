#!/bin/bash

# Update package list and install prerequisites
sudo apt update
sudo apt install -y wget

# Install Miniconda (if not already installed)
if [ ! -d "$HOME/miniconda3" ]; then
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh
    bash ~/miniconda.sh -b -p $HOME/miniconda3
    rm ~/miniconda.sh
    eval "$($HOME/miniconda3/bin/conda shell.bash hook)"
    conda init
else
    echo "Miniconda is already installed."
fi

# Set up the base Conda environment with Python 3.11.4
conda install python=3.11.4 -y

# Install common Python packages
conda install -y numpy pandas matplotlib

echo "Python environment setup complete!"
