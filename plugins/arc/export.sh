#!/bin/bash
# Export current Arc config into this plugin's config/ directory.
# Run this on the source machine before committing changes to the repo.
#
# Usage: ./export.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Source libs using absolute path (this script is run manually, not via run_plugin)
source "$SCRIPT_DIR/../../lib/logger"
source "$SCRIPT_DIR/../../lib/utils"

if ! is_macos; then
    log_error "Arc is only available on macOS."
    exit 1
fi

ARC_CONFIG="$HOME/Library/Application Support/Arc"
CONFIG_DIR="$SCRIPT_DIR/config"

if pgrep -x "Arc" > /dev/null 2>&1; then
    log_warn "Arc is running. Config files may be in an inconsistent state."
    log_warn "For a clean export, close Arc first. Continuing anyway..."
fi

mkdir -p "$CONFIG_DIR"

# machine-independent: StorableLinkRouting.json StorableKeyBindings.json
# machineID patched on install: StorableProfiles.json StorableLiveData.json
CONFIG_FILES=(
    StorableLinkRouting.json
    StorableProfiles.json
    StorableLiveData.json
    StorableKeyBindings.json
)

for file in "${CONFIG_FILES[@]}"; do
    src="$ARC_CONFIG/$file"
    if [[ ! -f "$src" ]]; then
        log_warn "$file not found in Arc config, skipping"
        continue
    fi
    cp "$src" "$CONFIG_DIR/$file"
    log_info "Exported $file"
done

log_info "Done. Review changes with 'git diff plugins/arc/config/' before committing."
