# Agent host

Reproducible, opt-in Linux execution environment for coding agents on an Apple
Silicon Mac. Paperclip can connect through its SSH environment driver; other
orchestrators can use their own SSH accounts. This is not a job scheduler.

## Install the command

From `~/.dotfiles`:

```bash
./dotfiles install agent-host
agent-host init
agent-host config
```

The plugin only links `~/bin/agent-host`. Installing it (including through
`--all`) does not install software, create machines, start services or authorize
access. Python 3 and OrbStack are prerequisites. OrbStack is already declared in
`plugins/brew/Brewfile.dev`; use the existing brew plugin for installation.
Uninstalling the plugin removes the symlink and preserves all machine data.

`init` creates `~/.config/agent-host/config.json` without replacing an existing
file. Review it before creating anything. The defaults are Ubuntu 24.04 ARM64,
6 CPUs, 24 GiB memory, a 150 GiB disk limit, and execution user `agent`. Resource
and identity changes require a new machine name; CLI version changes can be
applied with `provision`. XDG_CONFIG_HOME and XDG_STATE_HOME are supported.

## Create and provision

```bash
agent-host create
```

Creation explicitly allocates an OrbStack machine with `--isolated` and
`--isolate-network`: no host mounts, macOS command integration or SSH-agent
forwarding. It installs Ubuntu packages, Tailscale from its signed APT repository,
Node from a release archive checked against its published SHA256, and exact
Codex/Claude npm releases listed in the config. Package downloads access the
internet; no provider inference or authentication is performed.

The administrator `agent-admin` is for local management through `orb`; execution
accounts have locked passwords, private home directories and no sudo or Docker
group membership. Remote OpenSSH permits only the `agent-workers` group and
public keys. Root-owned authorized-key files prevent agents from granting
additional SSH access. An ingress firewall allows SSH only through `tailscale0`,
plus loopback, established connections, ICMP and Tailscale UDP transport.

If provisioning fails after creation, fix the cause and run:

```bash
agent-host provision
```

Creation refuses to overwrite/adopt existing machines. Management operations
require the matching creation record in `~/.local/state/agent-host/`. Keep that
record when migrating a machine. No deletion command is provided; deleting an
OrbStack machine is an explicit administrative operation and destroys its data.

## Connect and authorize a consumer

```bash
agent-host connect
agent-host authorize /path/to/consumer-key.pub
agent-host doctor
```

`connect` runs an interactive Tailscale login inside Linux. Use the intended
organization/trial account in the browser. It disables Tailscale SSH, route
acceptance and DNS takeover. It neither activates a trial nor changes billing.
No auth key is embedded in configuration or provision scripts.

Configure the tailnet policy separately: permit the orchestrator to reach this
machine on TCP 22, and permit your management access. Use a dedicated key for
each consumer. Keep the private key in that consumer's approved secret store;
only the public key is passed to `authorize`. SSH forwarding is disabled.

For Paperclip, configure the Linux Tailscale IP printed by `connect`, port 22,
user `agent`, a key secret reference and `/home/agent/workspaces` as the remote
base path. Pin/verify the SSH host key through the environment's supported
configuration; do not disable strict host-key verification. First prove access
from the actual Paperclip container. Production networking, credentials and
Paperclip changes remain a separate, approved operation in its repository.

For an additional trust scope:

```bash
agent-host add-user other-worker
agent-host authorize /path/to/other-consumer.pub --user other-worker
agent-host shell --user other-worker
```

Users separate credentials and private files, but share the kernel, tools,
resources and network. Use another isolated machine for stronger separation.
OrbStack machines also share a kernel with its other Linux machines/containers;
they are not independent full VMs. Use a dedicated VM if that boundary is needed.
See [OrbStack architecture](https://docs.orbstack.dev/architecture).

## Provider authentication and normal use

```bash
agent-host shell
# Inside Linux, as the execution user:
codex login
claude auth login
```

Complete browser/device login as required. Logins live in the Linux account;
your Mac credentials are not copied or forwarded. Paperclip may select its own
managed provider homes/authentication, so a successful manual login does not
prove that its adapter will use that login. Verify the effective auth and billing
mode through an orchestrator test before enabling unattended runs. Grant GitHub
access only to the repositories the account needs; no host AWS/GitHub access is
inherited intentionally.

```bash
agent-host status
agent-host start
agent-host doctor
agent-host stop
```

`status` does not start a stopped machine. `doctor` refuses to run on a stopped
machine and makes no model requests. It checks prerequisites, not successful
provider authentication or a complete security audit. Further acceptance checks:

1. Prove host file mounts, macOS commands, host SSH agent and host/other-machine
   network access are unavailable from an actual remote execution session.
2. Run one small task from the actual orchestrator and verify Git changes and
   workspace sync-back; test provider authentication in that context.
3. Disconnect networking during a run, stop/start the environment and test host
   sleep/wake. Record what the orchestrator retries and what needs intervention.
4. Start with one concurrent run. Two consumers' concurrency limits do not form
   a global limit; do not enable both unattended until coordinated.

No queue, automatic failover, global semaphore, sleep prevention or automatic
start-at-login is installed. Stopping the machine interrupts running work. During
the pilot keep the Mac awake on mains power. A later host-side availability
controller can drain work before sleep/battery transitions.

Docker is optional and is not installed. If needed, provision a guest-local
rootless engine separately. Never expose the Mac's Docker socket to this machine.

## What belongs in dotfiles

Versioned here: lifecycle commands, provisioning recipes, default limits/tool
versions and documentation. Outside Git: local config, creation records, Tailscale
state, private keys, provider logins, workspaces and the OrbStack disk. Update CLI
versions in local config (or defaults for future installs), then run `provision`
while idle. Ubuntu/Tailscale security updates come from APT during provisioning;
the OS image and transitive npm dependencies are not bit-for-bit locked.

Offline validation (no VM or network required):

```bash
python3 -m unittest discover -s plugins/agent-host/tests -v
bash -n plugins/agent-host/provision/*.sh
```
