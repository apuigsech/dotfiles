#!/bin/bash

source ../../lib/logger
source ../../lib/utils

if ! has_cmd mise; then
    log_error "mise is not installed"
    exit 1
fi

eval "$(mise activate bash)"

# Install and set global node if not already set
if ! mise ls --current node &>/dev/null; then
    log_info "Installing node (latest LTS) via mise..."
    mise use --global node@lts
else
    log_info "node already configured globally: $(mise current node)"
fi
