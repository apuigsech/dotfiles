#!/bin/bash

set -euo pipefail

# Mapping: AWS profile name -> 1Password item ID
# Add new profiles here as needed
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

op item get "$ITEM_ID" --format json | jq '{
    Version: 1,
    AccessKeyId: (.fields[] | select(.label == "access key id") | .value),
    SecretAccessKey: (.fields[] | select(.label == "secret access key") | .value)
}'
