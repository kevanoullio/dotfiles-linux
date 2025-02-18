#!/bin/bash

# Run individual setup scripts
bash ~/dotfiles/scripts/setup_python.sh
bash ~/dotfiles/scripts/setup_c.sh
bash ~/dotfiles/scripts/setup_nvim.sh
bash ~/dotfiles/scripts/setup_starship.sh

echo "All setups complete!"
