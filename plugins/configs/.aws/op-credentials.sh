#!/bin/bash

set -euo pipefail

CACHE_TTL=3600  # seconds
CACHE_DIR="${XDG_RUNTIME_DIR:-$HOME/.cache}/aws-op-credentials"

get_item_id() {
    case "$1" in
        ontopix-dev) echo "f6adss6uzqjuzjxlcu32mvfpbe" ;;
        *) echo "" ;;
    esac
}

PROFILE="${1:-}"

if [[ -z "$PROFILE" ]]; then
    echo "Error: profile name required" >&2
    echo "Usage: $(basename "$0") <profile>" >&2
    exit 1
fi

ITEM_ID="$(get_item_id "$PROFILE")"

if [[ -z "$ITEM_ID" ]]; then
    echo "Error: no 1Password item mapped for profile '$PROFILE'" >&2
    exit 1
fi

mkdir -p "$CACHE_DIR"
chmod 700 "$CACHE_DIR"
CACHE_FILE="$CACHE_DIR/${PROFILE}.json"

now=$(date +%s)
if [[ -f "$CACHE_FILE" ]]; then
    cache_mtime=$(stat -f %m "$CACHE_FILE" 2>/dev/null || stat -c %Y "$CACHE_FILE")
    if (( now - cache_mtime < CACHE_TTL )); then
        cat "$CACHE_FILE"
        exit 0
    fi
fi

result=$(op item get "$ITEM_ID" --format json | jq '{
    Version: 1,
    AccessKeyId: (.fields[] | select(.label == "access key id") | .value),
    SecretAccessKey: (.fields[] | select(.label == "secret access key") | .value)
}')

echo "$result" > "$CACHE_FILE"
chmod 600 "$CACHE_FILE"
echo "$result"
