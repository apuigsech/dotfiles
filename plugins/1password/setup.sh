#!/bin/bash

source ../../lib/logger
source ../../lib/utils

if ! is_macos; then
    log_info "Skipping 1Password setup: not running on macOS"
    exit 0
fi

# Check 1Password app
if [[ ! -d "/Applications/1Password.app" ]]; then
    log_warn "1Password app not found. Install it and sign in first."
    exit 0
fi

# Check op CLI
if ! has_cmd op; then
    log_warn "1Password CLI (op) not found. Install with: brew install 1password-cli"
else
    log_info "1Password CLI installed: $(op --version)"

    # Configure shell plugins
    PLUGINS_FILE=~/.config/op/plugins.sh
    mkdir -p "$(dirname "$PLUGINS_FILE")"
    if [[ ! -f "$PLUGINS_FILE" ]]; then
        echo 'export OP_PLUGIN_ALIASES_SOURCED=1' > "$PLUGINS_FILE"
    fi

    # The CLI authenticates through the desktop-app integration. Do NOT add
    # accounts manually (op account add): mixing both modes breaks
    # non-interactive auth (2026-07 incident).

    # Headless lane for agents (Claude Code hooks, AWS credential_process):
    # a read-only service-account token stored in the macOS Keychain, so no
    # biometric prompt is needed while the user session is unlocked.
    if security find-generic-password -s op-sa-agents >/dev/null 2>&1; then
        log_info "1Password service-account token present in Keychain (op-sa-agents)"
    else
        log_warn "1Password service-account token missing (Keychain item: op-sa-agents)"
        log_warn "  Create a service account with read access to the 'Agents' vault at"
        log_warn "  1password.com > Developer > Service Accounts, then store its token with:"
        log_warn "  security add-generic-password -s op-sa-agents -a claude -w '<token>'"
    fi
fi

# Check SSH agent socket
AGENT_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock
if [[ -S "$AGENT_SOCK" ]]; then
    log_info "1Password SSH agent is running"
else
    log_warn "1Password SSH agent is NOT active"
    log_warn "Enable it in: 1Password > Settings > Developer > Use the SSH agent"
fi

# 1Password app settings cannot be managed from here: settings.json entries are
# protected by authTags and the app detects and reverts external edits. The
# desired baseline must be set in the app UI (1Password > Settings):
#   - Security > Auto-lock: 4 hours. Every CLI/SSH/MCP authorization is revoked
#     when the app locks, so a short auto-lock multiplies biometric prompts.
#   - Developer > Integrate with 1Password CLI: enabled
#   - Developer > Use the SSH agent: enabled
log_info "Reminder: verify 1Password app settings in the UI (auto-lock 4h, CLI integration, SSH agent)."
