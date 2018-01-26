# Dotfiles

## Getting Started

From the project root run the following command:
```sh
$ ./run
```

## About

The objectives:
- setup a complete development environment from a scratch install of Mac OS X
  with one simple command
- keep a development environment up-to-date

#### Base Dependencies
1. Installs xcode
2. Installs rvm
3. Installs ruby 2.3
4. Installs homebrew
5. Configures git
#### Brew Dependencies
6. Installs Brew Dependencies & Cask Apps (`brew bundle`)
```
# brew dependencies
autoconf, automake, elasticsearch, ffmpeg, fontconfig, freetype, fribidi,
git-flow, graphviz, hub, imagemagick, lame, libass, libgpg-error, libksba,
libogg, libpng, libquvi, libtool, libvo-aacenc, libvorbis, libvpx, libyaml,
lua, mysql, node, openssl, phantomjs, pkg-config, pv, python, qt@5.5,
qtfaststart, readline, redis, s3cmd, sdl, texi2html, theora, x264, xvid, yasm,
zsh, zsh-completions, zstd

# cask apps
air-video-server-hd, cyberduck, divvy, dropbox, harvest, hex-fiend, java,
openoffice, owncloud, postman, screenhero, sequel-pro, skype, slack, spotify,
vlc, zeplin
```
#### Install useful system libraries (not part of brew) and system settings
7. Installs aws cli
8. Installs aws eb cli
9. Installs oh my zsh
10. Set fast system key repeat
11. Force brew link qt, a hack since we have to install an old version of qt
#### Configure Apache
12.
#### Set Launch Services
13. Start mysql and add launch daemon
14. Start redis and add launch daemon
15. Start elasticsearch and add launch daemon
#### Set Symlinks
14. Symlink .zshrc

## Todo
- install SourceCodePro font and set as terminal font