#!/usr/bin/env python3

"""Recursively merge a portable JSON object into a machine-local JSON file."""

from __future__ import annotations

import json
import os
from pathlib import Path
import sys
import tempfile


def merge(current: object, portable: object) -> object:
    if isinstance(current, dict) and isinstance(portable, dict):
        result = dict(current)
        for key, value in portable.items():
            result[key] = merge(result.get(key), value)
        return result
    return portable


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: merge-json-config.py PORTABLE TARGET", file=sys.stderr)
        return 2

    portable_path = Path(sys.argv[1])
    target_path = Path(sys.argv[2]).expanduser()
    portable = json.loads(portable_path.read_text())
    current = json.loads(target_path.read_text()) if target_path.exists() else {}
    merged = merge(current, portable)

    target_path.parent.mkdir(parents=True, exist_ok=True)
    mode = target_path.stat().st_mode & 0o777 if target_path.exists() else 0o600
    with tempfile.NamedTemporaryFile(
        "w", dir=target_path.parent, delete=False, encoding="utf-8"
    ) as handle:
        json.dump(merged, handle, indent=2, sort_keys=False)
        handle.write("\n")
        temporary = Path(handle.name)
    os.chmod(temporary, mode)
    os.replace(temporary, target_path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
