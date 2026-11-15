#!/bin/bash

# Source all required libraries in the correct order
source ../../lib/logger
source ../../lib/utils
source ../../lib/brew

# Install Homebrew if not already installed
brew_install

# Install the base Brewfile plus the Brewfiles of the active profiles
# (brew.profiles in config/dotfiles.conf, overridable per machine).
log_info "Brewfile profiles: base $(brew_profiles)"
while IFS= read -r brewfile; do
    log_info "Installing from $(basename "$brewfile")..."
    brew bundle --file="$brewfile"
done < <(brew_active_brewfiles)
