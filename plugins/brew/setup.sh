#!/bin/bash

# Source all required libraries in the correct order
source ../../lib/logger
source ../../lib/utils
source ../../lib/brew

# Install Homebrew if not already installed
brew_install

# Install packages from Brewfile
log_info "Installing packages from Brewfile..."
brew bundle --file="$(dirname "$0")/Brewfile"