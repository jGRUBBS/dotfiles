#!/usr/bin/env python3

"""Merge allowlisted portable Codex settings without replacing local state."""

from __future__ import annotations

import json
import os
from pathlib import Path
import re
import sys
import tempfile
import tomllib

TOP_LEVEL_KEYS = (
    "approvals_reviewer",
    "model",
    "model_reasoning_effort",
)


def toml_value(value: object) -> str:
    if isinstance(value, bool):
        return "true" if value else "false"
    if isinstance(value, str):
        return json.dumps(value)
    if isinstance(value, int):
        return str(value)
    raise TypeError(f"unsupported portable TOML value: {value!r}")


def section_name(line: str) -> str | None:
    match = re.match(r"^\s*\[([^\]]+)\]\s*(?:#.*)?$", line)
    return match.group(1) if match else None


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: merge-codex-config.py PORTABLE TARGET", file=sys.stderr)
        return 2

    portable_path = Path(sys.argv[1])
    target_path = Path(sys.argv[2]).expanduser()
    portable = tomllib.loads(portable_path.read_text())
    plugins = portable.get("plugins", {})
    owned_sections = {f'plugins.{json.dumps(name)}' for name in plugins}

    original = target_path.read_text() if target_path.exists() else ""
    if original.strip():
        tomllib.loads(original)

    kept: list[str] = []
    skipping = False
    current_section: str | None = None
    top_key_pattern = re.compile(
        r"^\s*(" + "|".join(re.escape(key) for key in TOP_LEVEL_KEYS) + r")\s*="
    )

    for line in original.splitlines():
        found_section = section_name(line)
        if found_section is not None:
            current_section = found_section
            skipping = found_section in owned_sections
        if skipping:
            continue
        if current_section is None and top_key_pattern.match(line):
            continue
        kept.append(line)

    while kept and not kept[-1].strip():
        kept.pop()

    first_section = next(
        (index for index, line in enumerate(kept) if section_name(line) is not None),
        len(kept),
    )
    prefix = kept[:first_section]
    suffix = kept[first_section:]
    while prefix and not prefix[-1].strip():
        prefix.pop()
    while suffix and not suffix[0].strip():
        suffix.pop(0)

    portable_top = [
        f"{key} = {toml_value(portable[key])}"
        for key in TOP_LEVEL_KEYS
        if key in portable
    ]
    merged = prefix
    if merged and portable_top:
        merged.append("")
    merged.extend(portable_top)
    if suffix and merged:
        merged.append("")
    merged.extend(suffix)

    if merged and merged[-1].strip():
        merged.append("")
    for name, values in plugins.items():
        merged.append(f"[plugins.{json.dumps(name)}]")
        for key, value in values.items():
            merged.append(f"{key} = {toml_value(value)}")
        merged.append("")

    rendered = "\n".join(merged).rstrip() + "\n"
    tomllib.loads(rendered)

    target_path.parent.mkdir(parents=True, exist_ok=True)
    mode = target_path.stat().st_mode & 0o777 if target_path.exists() else 0o600
    with tempfile.NamedTemporaryFile(
        "w", dir=target_path.parent, delete=False, encoding="utf-8"
    ) as handle:
        handle.write(rendered)
        temporary = Path(handle.name)
    os.chmod(temporary, mode)
    os.replace(temporary, target_path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
