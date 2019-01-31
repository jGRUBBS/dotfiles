#!/bin/bash

. helper_scripts/print_format

echo "installing node 0.12"
nvm install 0.12
report "node 0.12 installed successfully"
