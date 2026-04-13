#!/bin/bash

source ../../lib/logger
source ../../lib/utils

# Install Oh My Zsh
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    log_info "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    log_info "Oh My Zsh already installed"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# Install Powerlevel10k theme
if [[ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]]; then
    log_info "Installing Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
else
    log_info "Powerlevel10k already installed"
fi

# Install custom plugins
for entry in \
    "zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions" \
    "zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting"
do
    plugin="${entry%% *}"
    url="${entry#* }"
    if [[ ! -d "$ZSH_CUSTOM/plugins/$plugin" ]]; then
        log_info "Installing $plugin..."
        git clone --depth=1 "$url" "$ZSH_CUSTOM/plugins/$plugin"
    else
        log_info "$plugin already installed"
    fi
done
