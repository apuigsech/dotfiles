#!/usr/bin/env bash
set -euo pipefail
umask 022
user=${1:?user required}
node_version=${2:?Node version required}
codex_version=${3:?Codex version required}
claude_version=${4:?Claude version required}
. /etc/os-release
[[ "$ID" == ubuntu && "$VERSION_ID" == 24.04 ]]
[[ "$(uname -m)" == aarch64 ]]
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y ca-certificates curl gnupg xz-utils nftables

# A separate table: do not flush Tailscale's own rules. Only SSH on tailscale0.
cat > /etc/agent-host-firewall.nft <<'EOF'
table inet agent_host {
    chain input {
        type filter hook input priority 10; policy drop;
        iifname "lo" accept
        ct state established,related accept
        ip protocol icmp accept
        ip6 nexthdr ipv6-icmp accept
        udp dport 41641 accept
        iifname "tailscale0" tcp dport 22 accept
    }
}
EOF
cat > /usr/local/sbin/agent-host-firewall <<'EOF'
#!/bin/sh
set -eu
# Replace atomically: there must be no interval without filtering.
if nft list table inet agent_host >/dev/null 2>&1; then
    { echo 'delete table inet agent_host'; cat /etc/agent-host-firewall.nft; } | nft -f -
else
    nft -f /etc/agent-host-firewall.nft
fi
EOF
chmod 755 /usr/local/sbin/agent-host-firewall
cat > /etc/systemd/system/agent-host-firewall.service <<'EOF'
[Unit]
Description=Agent host ingress firewall
Before=ssh.service ssh.socket
After=network-pre.target
Wants=network-pre.target
[Service]
Type=oneshot
ExecStart=/usr/local/sbin/agent-host-firewall
RemainAfterExit=yes
[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable agent-host-firewall
systemctl restart agent-host-firewall

apt-get install -y openssh-server git build-essential python3 python3-venv \
    ripgrep jq unzip
install -d -m 755 /etc/apt/keyrings
curl --fail --silent --show-error --location \
    https://pkgs.tailscale.com/stable/ubuntu/noble.noarmor.gpg \
    -o /etc/apt/keyrings/tailscale.gpg
printf '%s\n' 'deb [signed-by=/etc/apt/keyrings/tailscale.gpg] https://pkgs.tailscale.com/stable/ubuntu noble main' \
    > /etc/apt/sources.list.d/tailscale.list
apt-get update
apt-get install -y tailscale
systemctl enable --now tailscaled

# Node/npm are guest-local; macOS packages and credentials are not imported.
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
archive="node-v${node_version}-linux-arm64.tar.xz"
curl --fail --silent --show-error --location "https://nodejs.org/dist/v${node_version}/$archive" -o "$tmp/$archive"
curl --fail --silent --show-error --location "https://nodejs.org/dist/v${node_version}/SHASUMS256.txt" -o "$tmp/SHASUMS256.txt"
(cd "$tmp"; grep "  $archive\$" SHASUMS256.txt | sha256sum --check --strict -)
install -d /opt/agent-host/node /opt/agent-host/npm
tar -xJf "$tmp/$archive" --strip-components=1 -C /opt/agent-host/node
for tool in node npm npx; do
    ln -sfn "/opt/agent-host/node/bin/$tool" "/usr/local/bin/$tool"
done
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
npm install --global --prefix /opt/agent-host/npm \
    "@openai/codex@$codex_version" "@anthropic-ai/claude-code@$claude_version"
for tool in codex claude; do
    ln -sfn "/opt/agent-host/npm/bin/$tool" "/usr/local/bin/$tool"
done

# The bootstrap administrator is only reachable through the local orb command.
install -d -m 755 /etc/ssh/sshd_config.d /etc/ssh/agent-host-keys
for unit in ssh.service ssh.socket; do
    install -d -m 755 "/etc/systemd/system/$unit.d"
    cat > "/etc/systemd/system/$unit.d/agent-host.conf" <<'EOF'
[Unit]
Requires=agent-host-firewall.service
After=agent-host-firewall.service
EOF
done
cat > /etc/ssh/sshd_config.d/00-agent-host.conf <<'EOF'
PermitRootLogin no
PasswordAuthentication no
KbdInteractiveAuthentication no
PubkeyAuthentication yes
AuthenticationMethods publickey
AuthorizedKeysFile /etc/ssh/agent-host-keys/%u
AllowGroups agent-workers
AllowAgentForwarding no
AllowTcpForwarding no
X11Forwarding no
PermitTunnel no
PermitUserEnvironment no
EOF
groupadd -f agent-workers
# sshd validates before systemd has started it and created RuntimeDirectory.
# Minimal OrbStack images do not necessarily have /run/sshd yet.
install -d -m 755 /run/sshd
sshd -t
# Fail closed if another image-provided setting took precedence.
effective_ssh_config=$(sshd -T)
grep -qx 'passwordauthentication no' <<< "$effective_ssh_config"
grep -qx 'permitrootlogin no' <<< "$effective_ssh_config"
grep -qx 'authorizedkeysfile /etc/ssh/agent-host-keys/%u' <<< "$effective_ssh_config"
systemctl daemon-reload
systemctl enable --now ssh
systemctl restart ssh
printf 'Base setup complete; no Tailscale login or provider login has been performed.\n'
