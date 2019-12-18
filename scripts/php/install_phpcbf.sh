#!/bin/bash

. helper_scripts/print_format

if [ -f "$DOTFILE_PATH/executables/phpcbf" ]; then
  skipping "phpcbf - already installed"
else
  doing "Installing phpcbf"
  curl -OL https://squizlabs.github.io/PHP_CodeSniffer/phpcbf.phar
  chmod +x phpcbf.phar
  mv phpcbf.phar executables/phpcbf
  doing_complete
fi
