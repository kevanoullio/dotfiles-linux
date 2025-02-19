#!/bin/bash

# Run individual setup scripts
bash ~/dotfiles/scripts/setup_common.sh
bash ~/dotfiles/scripts/setup_nvim.sh
bash ~/dotfiles/scripts/setup_starship.sh
bash ~/dotfiles/scripts/setup_c.sh
bash ~/dotfiles/scripts/setup_python.sh

echo "All setups complete!"

