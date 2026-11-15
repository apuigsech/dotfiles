#!/usr/bin/env bash
set -euo pipefail
user=${1:?execution user required}
[[ "$user" =~ ^[a-z][a-z0-9-]{0,30}$ ]]
case "$user" in root|admin|ubuntu|tailscale|agent-admin) exit 1 ;; esac
install -d -m 755 /etc/agent-host/users
groupadd -f agent-workers
if id "$user" >/dev/null 2>&1; then
    # Never adopt an existing account, including system service accounts.
    test -f "/etc/agent-host/users/$user"
else
    useradd --create-home --user-group --shell /bin/bash "$user"
    touch "/etc/agent-host/users/$user"
fi
usermod -a -G agent-workers "$user"
chmod 700 "/home/$user"
runuser -u "$user" -- bash -c 'umask 077; mkdir -p "$HOME/workspaces"'
printf 'Execution user ready: %s (no sudo, locked password)\n' "$user"
