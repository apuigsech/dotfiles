#!/bin/bash

source ../../lib/logger
source ../../lib/utils

if ! is_macos; then
    log_info "Skipping Arc setup: not running on macOS"
    exit 0
fi

ARC_CONFIG="$HOME/Library/Application Support/Arc"
ARC_PREFS="$HOME/Library/Preferences/company.thebrowser.Browser.plist"
PLUGIN_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_DIR="$PLUGIN_DIR/config"

# Arc must be closed — its atomic writes (write+rename) would overwrite any
# files we put in place while it's running.
if pgrep -x "Arc" > /dev/null 2>&1; then
    log_error "Arc is running. Close Arc before installing config."
    exit 1
fi

if [[ ! -d "$CONFIG_DIR" ]] || [[ -z "$(ls -A "$CONFIG_DIR" 2>/dev/null)" ]]; then
    log_warn "No config files found in plugin/config. Run export.sh on the source machine first."
    exit 0
fi

# Read this machine's Arc-generated UUID. Arc must have been launched at least
# once so it exists in the prefs plist.
ARC_MACHINE_ID=$(python3 -c "
import plistlib, sys
try:
    with open('$ARC_PREFS', 'rb') as f:
        d = plistlib.load(f)
    print(d.get('machineID', ''))
except Exception as e:
    sys.exit(1)
" 2>/dev/null)

if [[ -z "$ARC_MACHINE_ID" ]]; then
    log_warn "Could not read Arc machineID from preferences."
    log_warn "Launch Arc once, close it, then re-run this installer."
    log_warn "Skipping profile-aware files; ATC and keybindings will still be installed."
fi

mkdir -p "$ARC_CONFIG"

install_file() {
    local file="$1"
    local patch_machine_id="${2:-false}"
    local src="$CONFIG_DIR/$file"
    local dst="$ARC_CONFIG/$file"

    if [[ ! -f "$src" ]]; then
        log_warn "$file not found in plugin/config, skipping"
        return
    fi
    if [[ -f "$dst" ]]; then
        cp "$dst" "${dst}.bak"
        log_debug "Backed up $file"
    fi

    if [[ "$patch_machine_id" == "true" ]] && [[ -n "$ARC_MACHINE_ID" ]]; then
        # Replace every machineID value found in the source file with this
        # machine's UUID, so Arc treats the profiles as locally owned.
        python3 -c "
import json, re, sys
new_id = sys.argv[1]
with open(sys.argv[2]) as f:
    content = f.read()
old_ids = re.findall(r'\"machineID\"\s*:\s*\"([^\"]+)\"', content)
for old_id in set(old_ids):
    content = content.replace(old_id, new_id)
with open(sys.argv[3], 'w') as f:
    f.write(content)
" "$ARC_MACHINE_ID" "$src" "$dst"
        log_info "Installed $file (machineID patched)"
    elif [[ "$patch_machine_id" == "true" ]] && [[ -z "$ARC_MACHINE_ID" ]]; then
        log_warn "Skipping $file (machineID unavailable)"
    else
        cp "$src" "$dst"
        log_info "Installed $file"
    fi
}

# Files that reference machineID and need patching on the destination machine
install_file "StorableProfiles.json"   true
install_file "StorableLiveData.json"   true

# Files that are machine-independent
install_file "StorableLinkRouting.json"  false
install_file "StorableKeyBindings.json"  false

log_info "Arc config installed. Extensions must be installed manually (see plugins/arc/extensions/)."
