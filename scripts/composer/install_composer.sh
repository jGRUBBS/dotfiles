#!/bin/bash

. helper_scripts/print_format

curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
report "composer installed successfully"