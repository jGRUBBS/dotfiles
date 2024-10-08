#!/usr/bin/env zsh

. helper_scripts/print_format

if [ -f "$DOTFILE_PATH/executables/antigen.zsh" ]; then
  skipping "antigen - already installed"
else
  doing "Installing antigen"
  antigen_url="git.io/antigen"
  dst_path="$DOTFILE_PATH/executables/antigen.zsh"
  curl -sL $antigen_url > $dst_path
  source $dst_path
  doing_complete
fi
