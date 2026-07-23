#!/usr/bin/env python3

from __future__ import annotations

import json
from pathlib import Path
import subprocess
import tempfile
import tomllib
import unittest

ROOT = Path(__file__).resolve().parents[1]


class MergeTests(unittest.TestCase):
    def test_json_merge_preserves_local_keys_and_is_idempotent(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            target = Path(directory) / "settings.json"
            target.write_text(
                json.dumps({"theme": "old", "localOnly": {"keep": True}})
            )
            command = [
                "python3",
                str(ROOT / "scripts/merge-json-config.py"),
                str(
                    ROOT
                    / "home/.chezmoitemplates/data/ai/copilot-settings.json"
                ),
                str(target),
            ]
            subprocess.run(command, check=True)
            first = target.read_bytes()
            subprocess.run(command, check=True)
            self.assertEqual(first, target.read_bytes())
            merged = json.loads(first)
            self.assertEqual(merged["theme"], "auto")
            self.assertTrue(merged["localOnly"]["keep"])

    def test_codex_merge_preserves_machine_sections_and_is_idempotent(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            target = Path(directory) / "config.toml"
            target.write_text(
                'notify = ["/local/app"]\n\n'
                '[projects."/local/repo"]\n'
                'trust_level = "trusted"\n\n'
                "[mcp_servers.local]\n"
                'command = "/local/bin/server"\n'
            )
            command = [
                "python3",
                str(ROOT / "scripts/merge-codex-config.py"),
                str(
                    ROOT
                    / "home/.chezmoitemplates/data/ai/codex-config.toml"
                ),
                str(target),
            ]
            subprocess.run(command, check=True)
            first = target.read_bytes()
            subprocess.run(command, check=True)
            self.assertEqual(first, target.read_bytes())
            merged = tomllib.loads(first.decode())
            self.assertEqual(merged["notify"], ["/local/app"])
            self.assertEqual(
                merged["projects"]["/local/repo"]["trust_level"], "trusted"
            )
            self.assertEqual(
                merged["mcp_servers"]["local"]["command"],
                "/local/bin/server",
            )
            self.assertTrue(
                merged["plugins"]["gmail@openai-curated"]["enabled"]
            )


if __name__ == "__main__":
    unittest.main()
