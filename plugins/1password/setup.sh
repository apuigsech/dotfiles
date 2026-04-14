#!/bin/bash

source ../../lib/logger
source ../../lib/utils

if ! is_macos; then
    log_info "Skipping 1Password setup: not running on macOS"
    exit 0
fi

# Check 1Password app
if [[ ! -d "/Applications/1Password.app" ]]; then
    log_warn "1Password app not found. Install it from: https://1password.com/downloads/mac/"
else
    log_info "1Password app installed"
fi

# Check op CLI
if ! has_cmd op; then
    log_warn "1Password CLI (op) not found. Install with: brew install 1password-cli"
else
    log_info "1Password CLI installed: $(op --version)"
fi

# Check SSH agent socket
AGENT_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock
if [[ -S "$AGENT_SOCK" ]]; then
    log_info "1Password SSH agent is running"
else
    log_warn "1Password SSH agent is NOT active"
    log_warn "Enable it in: 1Password > Settings > Developer > Use the SSH agent"
fi

# Check op-ssh-sign
if [[ -f "/Applications/1Password.app/Contents/MacOS/op-ssh-sign" ]]; then
    log_info "op-ssh-sign available for commit signing"
else
    log_warn "op-ssh-sign not found -- git commit signing via 1Password won't work"
fi
