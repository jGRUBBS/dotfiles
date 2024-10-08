#!/bin/bash

. helper_scripts/print_format

if which brew>/dev/null; then
  skipping "homebrew - already installed"
else
  doing "Installing homebrew"
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"> /dev/null 2>&1
  doing_complete
fi