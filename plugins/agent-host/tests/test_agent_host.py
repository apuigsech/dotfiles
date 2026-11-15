"""Exercise failure boundaries with an OrbStack stand-in; never create real VMs."""
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

CLI = Path(__file__).resolve().parents[1] / "bin/agent-host"
FAKE_ORB = '''#!/usr/bin/env python3
import json, os, pathlib, sys
root = pathlib.Path(os.environ["FAKE_ROOT"])
args = sys.argv[1:]
body = sys.stdin.read() if args[0] == "run" and "-s" in args else ""
with (root / "calls").open("a") as f:
    f.write(json.dumps({"args": args, "body": body, "orbenv": os.environ.get("ORBENV"),
                        "key": os.environ.get("OPENAI_API_KEY")}) + "\\n")
if args[0] == "list":
    if (root / "exists").exists() and ("--running" not in args or not (root / "stopped").exists()):
        print("agent-work")
elif args[0] == "create":
    (root / "exists").touch()
elif args[0] == "run" and os.environ.get("FAIL_PROVISION") == "1":
    sys.exit(7)
elif args[0] == "start":
    (root / "stopped").unlink(missing_ok=True)
elif args[0] == "stop":
    (root / "stopped").touch()
'''


class AgentHostTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.env = {**os.environ, "XDG_CONFIG_HOME": str(self.root / "config"),
                    "XDG_STATE_HOME": str(self.root / "state"), "FAKE_ROOT": str(self.root),
                    "ORBENV": "OPENAI_API_KEY", "OPENAI_API_KEY": "never-forward-this",
                    "PATH": str(self.root) + os.pathsep + os.environ["PATH"]}
        orb = self.root / "orb"
        orb.write_text(FAKE_ORB)
        orb.chmod(0o755)

    def cli(self, *args, ok=True):
        result = subprocess.run([sys.executable, str(CLI), *args], env=self.env,
                                capture_output=True, text=True)
        if ok:
            self.assertEqual(result.returncode, 0, result.stderr)
        else:
            self.assertNotEqual(result.returncode, 0)
        return result

    def calls(self):
        file = self.root / "calls"
        return [json.loads(line) for line in file.read_text().splitlines()] if file.exists() else []

    def edit(self, **values):
        config = self.root / "config/agent-host/config.json"
        config.write_text(json.dumps({**json.loads(config.read_text()), **values}))

    def test_init_is_non_operational_and_preserves_local_config(self):
        self.cli("init")
        self.edit(cpus=3)
        self.cli("init")
        self.assertEqual(json.loads(self.cli("config").stdout)["cpus"], 3)
        self.assertEqual(self.calls(), [])

    def test_rejects_injection_unknown_config_and_privileged_users(self):
        self.cli("init")
        for change in ({"machine": "evil;touch /tmp/x"}, {"user": "root"},
                       {"nodeVersion": "latest"}, {"cpus": True}):
            config = self.root / "config/agent-host/config.json"
            config.write_text("{}")
            self.edit(**change)
            self.cli("create", ok=False)
        self.edit(unexpected="value")
        self.cli("config", ok=False)
        self.assertEqual(self.calls(), [])

    def test_create_uses_isolation_and_does_not_connect_or_forward_auth(self):
        self.cli("init")
        self.cli("create")
        calls = self.calls()
        create = next(c["args"] for c in calls if c["args"][0] == "create")
        for flag in ("--isolated", "--isolate-network", "--arch"):
            self.assertIn(flag, create)
        self.assertNotIn("--mount", create)
        self.assertNotIn("--forward-ssh-agent", create)
        self.assertFalse(any("up" in c["args"] for c in calls))
        self.assertTrue(all(c["orbenv"] is None and c["key"] is None for c in calls))

    def test_does_not_adopt_an_existing_machine(self):
        self.cli("init")
        (self.root / "exists").touch()
        self.cli("create", ok=False)
        self.cli("provision", ok=False)
        self.assertTrue(all(c["args"][0] == "list" for c in self.calls()))

    def test_failed_provision_can_be_retried_without_recreation(self):
        self.cli("init")
        self.env["FAIL_PROVISION"] = "1"
        self.cli("create", ok=False)
        self.env.pop("FAIL_PROVISION")
        self.cli("provision")
        self.assertEqual(sum(c["args"][0] == "create" for c in self.calls()), 1)

    def test_status_and_doctor_do_not_start_stopped_machine(self):
        self.cli("init")
        self.cli("create")
        self.cli("stop")
        before = len(self.calls())
        self.cli("status")
        self.cli("doctor", ok=False)
        self.assertTrue(all(c["args"][0] in ("list", "info") for c in self.calls()[before:]))

    def test_authorization_rejects_private_keys_and_is_idempotent_recipe(self):
        self.cli("init")
        self.cli("create")
        key = self.root / "key"
        subprocess.run(["ssh-keygen", "-q", "-t", "ed25519", "-N", "", "-f", str(key)], check=True)
        self.cli("authorize", str(key), ok=False)
        self.cli("authorize", str(key) + ".pub", "--user", "root", ok=False)
        self.cli("authorize", str(key) + ".pub")
        body = self.calls()[-1]["body"]
        self.assertIn("/etc/ssh/agent-host-keys/agent", body)
        self.assertIn("grep -qxF", body)
        self.assertNotIn("PRIVATE KEY", body)

    def test_connect_requires_explicit_action_and_disables_forwarded_routes(self):
        self.cli("init")
        self.cli("create")
        self.cli("connect")
        command = next(c["args"] for c in self.calls() if "up" in c["args"])
        for flag in ("--ssh=false", "--accept-routes=false", "--accept-dns=false"):
            self.assertIn(flag, command)


if __name__ == "__main__":
    unittest.main()
