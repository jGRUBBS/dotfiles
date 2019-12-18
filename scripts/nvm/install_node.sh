#!/bin/bash

. helper_scripts/print_format
. $(brew --prefix nvm)/nvm.sh

echo "installing node"
nvm use lts/dubnium
nvm alias default lts/dubnium
report "node installed successfully"
