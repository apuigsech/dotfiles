#!/usr/bin/env bash
set -uo pipefail
user=${1:?execution user required}
failed=0
check() {
    local label=$1
    shift
    if "$@" >/dev/null 2>&1; then
        printf 'OK    %s\n' "$label"
    else
        printf 'FAIL  %s\n' "$label"
        failed=1
    fi
}
check 'Ingress firewall loaded' nft list table inet agent_host
check 'OpenSSH configuration valid' /usr/sbin/sshd -t
check 'SSH service active' systemctl is-active ssh
check 'Tailscale connected (IPv4 assigned)' tailscale ip -4
check 'Execution account managed by agent-host' test -f "/etc/agent-host/users/$user"
check 'At least one SSH key authorized' test -s "/etc/ssh/agent-host-keys/$user"
check 'No host filesystem mount' bash -c '! findmnt -rn -o FSTYPE,TARGET | grep -Eq "virtiofs|9p|/mnt/mac|/Users/"'
check 'No SSH agent forwarded to execution account' runuser -u "$user" -- bash -c 'test -z "${SSH_AUTH_SOCK:-}"'
check 'No sudo/docker/admin group membership' bash -c '! id -nG "$1" | tr " " "\n" | grep -Eq "^(sudo|admin|docker|wheel)$"' _ "$user"
check 'No sudo grants for execution account' runuser -u "$user" -- bash -c '! sudo -n -l 2>/dev/null'
check 'Node executable' runuser -u "$user" -- /usr/local/bin/node --version
check 'Codex executable' runuser -u "$user" -- /usr/local/bin/codex --version
check 'Claude executable' runuser -u "$user" -- /usr/local/bin/claude --version
printf '\nNot verified here: tailnet ACLs, EC2/container connectivity, provider login, Paperclip runs, resume or sync-back.\n'
printf 'No provider request was made. Authenticate as the execution user, then test the orchestrator separately.\n'
exit "$failed"
