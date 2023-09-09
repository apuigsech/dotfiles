#!/bin/bash

BASE_DIR="$(dirname "$0")"
LIB_DIR="${BASE_DIR}/lib"

for file in ${LIB_DIR}/*.sh; do
    if [ -f $file ]; then
        source $file
    fi
done

# sudo -v

brew_install
brew_install_packages brew/packages.lst
brew_install_packages brew/packages-cask.lst cask

# cp -rT bin ~/bin
# chmod +x ~/bin/*

# cp -rT zsh ~/.zsh
# mv ~/.zshrc ~/.zshrc.old
# ln -s ~/.zsh/zshrc ~/.zshrc

# cp -rT hammerspoon ~/.hammerspoon

# cp -rT envrc ~/.envrc

# cp config/iterm2/com.googlecode.iterm2.plist ~/Library/Preferences/com.googlecode.iterm2.plist

# mkdir -p ~/.bluereset/
# cp config/bluereset/bluereset.conf ~/.bluereset/bluereset.conf