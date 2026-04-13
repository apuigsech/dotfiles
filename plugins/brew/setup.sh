#!/bin/bash

# Source all required libraries in the correct order
source ../../lib/logger
source ../../lib/utils
source ../../lib/brew

# Install Homebrew if not already installed
brew_install

# Install packages from all Brewfiles
for brewfile in "$(dirname "$0")"/Brewfile*; do
    log_info "Installing from $(basename "$brewfile")..."
    brew bundle --file="$brewfile"
done