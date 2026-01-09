#!/bin/bash
# Super installer for multiple Nerd Fonts
SCRIPT_DIR="$(dirname "$0")"

bash "$SCRIPT_DIR/install_nerd_cascadiamono.sh"
bash "$SCRIPT_DIR/install_nerd_firamono.sh"
bash "$SCRIPT_DIR/install_nerd_firacode.sh"
