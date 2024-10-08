#!/bin/bash

. helper_scripts/print_format

gitconfig='gitconfig.local'
template="$DOTFILE_PATH/templates/$gitconfig.template"
symlink="$DOTFILE_PATH/config/$gitconfig.symlink"

if ! [ -f $symlink ]
then
  info 'setup gitconfig'

  git_credential='cache'
  if [ "$(uname -s)" == "Darwin" ]
  then
    git_credential='osxkeychain'
  fi

  user ' - What is your github author name?'
  read -e git_authorname
  user ' - What is your github author email?'
  read -e git_authoremail

  sed -e "s/AUTHORNAME/$git_authorname/g" \
      -e "s/AUTHOREMAIL/$git_authoremail/g" \
      -e "s/GIT_CREDENTIAL_HELPER/$git_credential/g" \
      $template > $symlink

  report 'gitconfig'
fi