#!/bin/bash

# Source all required libraries in the correct order
source ../../lib/logger
source ../../lib/utils
source ../../lib/brew

# Install Homebrew if not already installed
brew_install

# Install packages from lists
brew_install_pkgs packages.lst
brew_install_pkgs packages-cask.lst cask