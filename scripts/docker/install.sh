#!/bin/bash

. helper_scripts/print_format

marquee "Installing Docker"

if [[ $(arch) == 'arm64' ]]; then
  DMG=https://desktop.docker.com/mac/main/arm64/Docker.dmg
else
  DMG=https://desktop.docker.com/mac/main/amd64/Docker.dmg
fi

# skip if Docker is already installed
if [ -d "/Applications/Docker.app" ]; then
  skipping "Docker - already installed"
  exit 0
fi

doing "Installing Docker"

# download the latest Docker.dmg
curl -sL $DMG -o Docker.dmg

# https://docs.docker.com/desktop/install/mac-install/
sudo hdiutil attach Docker.dmg
sudo /Volumes/Docker/Docker.app/Contents/MacOS/install --accept-license
sudo hdiutil detach /Volumes/Docker

doing_complete
