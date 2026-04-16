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

    # claude — inject secrets via op run
    if has_cmd claude; then
        if grep -q "alias claude=" "$PLUGINS_FILE" 2>/dev/null; then
            log_info "1Password shell plugin already configured: claude"
        else
            echo "alias claude='op run --account $PERSONAL_ACCOUNT -- claude'" >> "$PLUGINS_FILE"
            log_info "1Password shell plugin configured: claude"
        fi
    fi

    # Check configured accounts
    for entry in \
        "ontopix:ontopix account (albert.puigsech@ontopix.ai)" \
        "personal:personal/family account (albert@puigsech.com)"
    do
        shorthand="${entry%%:*}"
        description="${entry#*:}"
        if op account list 2>/dev/null | grep -q "$shorthand"; then
            log_info "1Password CLI account configured: $shorthand"
        else
            log_warn "1Password CLI account not configured: $shorthand ($description)"
            log_warn "  Run: op account add --shorthand $shorthand"
        fi
    done
fi

# Check SSH agent socket
AGENT_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock
if [[ -S "$AGENT_SOCK" ]]; then
    log_info "1Password SSH agent is running"
else
    log_warn "1Password SSH agent is NOT active"
    log_warn "Enable it in: 1Password > Settings > Developer > Use the SSH agent"
fi

# Apply 1Password settings
SETTINGS_FILE=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/Library/Application\ Support/1Password/Data/settings/settings.json

if [[ ! -f "$SETTINGS_FILE" ]]; then
    log_warn "1Password settings file not found. Open 1Password first."
    exit 0
fi

log_info "Applying 1Password settings..."

python3 - "$SETTINGS_FILE" <<'EOF'
import json, sys

settings_file = sys.argv[1]

with open(settings_file, 'r') as f:
    settings = json.load(f)

desired = {
    "app.theme": "dark",
    "appearance.interfaceDensity": "compact",
    "app.zoomLevel": 90,
    "appearance.useSystemAccentColor": False,
    "security.authenticatedUnlock.enabled": True,
    "security.authenticatedUnlock.appleTouchId": True,
    "security.autolock.minutes": 240,
    "privacy.checkHibp": True,
    "passwordGenerator.size.characters": 16,
    "passwordGenerator.type": "password-generator-menu-entry-type-random-password",
    "passwordGenerator.includeSymbols": True,
    "sshAgent.enabled": True,
    "sshAgent.sshAuthorizatonModel": "application",
    "sidebar.showCategories": False,
    "sidebar.showTags": True,
    "browsers.extension.enabled": True,
    "updates.updateChannel": "PRODUCTION",
}

changed = []
for key, value in desired.items():
    if settings.get(key) != value:
        settings[key] = value
        # Remove stale authTag so 1Password regenerates it
        if 'authTags' in settings and key in settings['authTags']:
            del settings['authTags'][key]
        changed.append(key)

with open(settings_file, 'w') as f:
    json.dump(settings, f, indent=4)

if changed:
    print(f"Updated settings: {', '.join(changed)}")
else:
    print("Settings already up to date")
EOF

log_info "1Password settings applied. Restart 1Password to apply changes."
