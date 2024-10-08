#!/bin/bash

. helper_scripts/print_format
. helper_scripts/link_file

marquee "Brew Dependencies"
link_file "$(pwd)/scripts/homebrew/Brewfile" "$HOME/Brewfile"
cd $HOME
RESULTS=$(brew bundle | grep Success)
note "$RESULTS"
cd - > /dev/null 2>&1
