#!/bin/bash

. helper_scripts/print_format

if [ -f "$DOTFILE_PATH/executables/wp" ]; then
  wp cli update
else
  doing "Installing WP-CLI"
  curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar> /dev/null 2>&1
  chmod +x wp-cli.phar
  mv wp-cli.phar executables/wp
  doing_complete
fi
