#!/bin/bash
#
# SessionStart hook: ensure gh is authenticated for github.com.
# Never triggers a 1Password biometric prompt: auth is only repaired through
# the headless service-account lane (Keychain item "op-sa-agents"); without
# that token it just warns and leaves gh untouched.

GH=/opt/homebrew/bin/gh

"$GH" auth status --hostname github.com >/dev/null 2>&1 && exit 0

if sa_token=$(security find-generic-password -s op-sa-agents -w 2>/dev/null) && [[ -n "$sa_token" ]]; then
    OP_SERVICE_ACCOUNT_TOKEN="$sa_token" op read "op://Agents/GitHub/token" 2>/dev/null \
        | "$GH" auth login --with-token >/dev/null 2>&1 \
        || echo "gh-auth: could not restore github.com auth from op://Agents/GitHub/token" >&2
else
    echo "gh-auth: github.com auth broken and no op-sa-agents token in Keychain; run: gh auth login" >&2
fi

exit 0
