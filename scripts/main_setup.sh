#!/bin/bash

# Get the directory of the script
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

# Run individual setup scripts
bash $SCRIPT_DIR/setup_common.sh
bash $SCRIPT_DIR/setup_nvim.sh
bash $SCRIPT_DIR/setup_starship.sh
bash $SCRIPT_DIR/setup_c.sh
bash $SCRIPT_DIR/setup_python.sh

echo "All setups complete!"

