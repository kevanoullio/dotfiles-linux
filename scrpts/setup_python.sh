#!/bin/bash

# Install Miniconda
if [ ! -d "$HOME/miniconda3" ]; then
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh
    bash ~/miniconda.sh -b -p $HOME/miniconda3
    rm ~/miniconda.sh
    eval "$($HOME/miniconda3/bin/conda shell.bash hook)"
    conda init
else
    echo "Miniconda is already installed."
fi

echo "Python setup complete!"
