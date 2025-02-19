#!/bin/bash

# Update package list and install prerequisites
sudo apt update
sudo apt install -y build-essential gdb valgrind cmake

echo "C development environment setup complete!"

