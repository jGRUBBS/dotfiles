#!/bin/bash

. helper_scripts/print_format
. helper_scripts/link_file

marquee "Configure System Apache"

if $(readlink /usr/local/etc/httpd &> /dev/null)
then
  report "apache is already configured"
elif [ -d /usr/local/etc/httpd ]
then
  report "moving original apache to /usr/local/etc/httpd-old"
  sudo mv /usr/local/etc/httpd /usr/local/etc/httpd-old
fi

if [ ! -d /usr/local/etc/httpd ]
then
  report "linking apache"
  link_file "$DOTFILE_PATH/apache" "/usr/local/etc/httpd"
fi
