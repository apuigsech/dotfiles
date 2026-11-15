#!/bin/bash
#
# AWS credential_process backed by 1Password. Resolution order:
#   1. Fresh cache (< CACHE_TTL).
#   2. 1Password CLI — with a service-account token from the macOS Keychain
#      (item "op-sa-agents") when present, so no biometric prompt is needed;
#      otherwise via the desktop-app integration (Touch ID).
#   3. Stale cache. The mapped items hold static IAM keys, so serving an
#      expired cache keeps AWS working while 1Password is locked.

set -euo pipefail

CACHE_TTL=43200  # seconds; how often to re-read from 1Password, not a credential expiry
CACHE_DIR="${XDG_RUNTIME_DIR:-$HOME/.cache}/aws-op-credentials"
KEYCHAIN_SA_SERVICE="op-sa-agents"

get_item_id() {
    case "$1" in
        ontopix-dev) echo "4cjgz5n4wu4ysxawej5pjkl53a" ;;  # AWS Access Key (ontopix-dev), vault Agents
        *) echo "" ;;
    esac
}

# 1Password account (user ID) holding the item. Needed because the desktop-app
# integration exposes multiple accounts and item IDs are per-account. Ignored
# when a service-account token is in use.
get_item_account() {
    case "$1" in
        ontopix-dev) echo "JLIUDBL3DJGTXKPKM74GKKZUZM" ;;
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

# Prefer a scoped service-account token from the Keychain: headless, no
# biometric prompt. Falls back to the desktop-app integration if absent,
# pinning the account since the app may expose more than one.
if sa_token=$(security find-generic-password -s "$KEYCHAIN_SA_SERVICE" -w 2>/dev/null) && [[ -n "$sa_token" ]]; then
    export OP_SERVICE_ACCOUNT_TOKEN="$sa_token"
else
    item_account="$(get_item_account "$PROFILE")"
    [[ -n "$item_account" ]] && export OP_ACCOUNT="$item_account"
fi

if result=$(op item get "$ITEM_ID" --format json 2>/dev/null | jq '{
    Version: 1,
    AccessKeyId: (.fields[] | select(.label == "access key id") | .value),
    SecretAccessKey: (.fields[] | select(.label == "secret access key") | .value)
}') && [[ -n "$result" ]]; then
    echo "$result" > "$CACHE_FILE"
    chmod 600 "$CACHE_FILE"
    echo "$result"
    exit 0
fi

# 1Password unavailable (locked, no session, op missing). Static IAM keys
# don't expire, so a stale cache is still valid — keep AWS working.
if [[ -f "$CACHE_FILE" ]]; then
    echo "op-credentials: 1Password unavailable, serving stale cache for '$PROFILE'" >&2
    cat "$CACHE_FILE"
    exit 0
fi

echo "Error: could not read credentials for '$PROFILE' from 1Password and no cache exists" >&2
exit 1
