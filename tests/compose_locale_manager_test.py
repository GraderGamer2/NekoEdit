#!/usr/bin/env python3
"""Integration test for the freestanding Compose locale pack manager."""
from __future__ import annotations

import os
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
import compose_pack  # noqa: E402
from compose_pack import encode_pack  # noqa: E402
import import_user_xcompose  # noqa: E402


def main() -> None:
    if len(sys.argv) != 2:
        raise SystemExit("usage: compose_locale_manager_test.py MANAGER_TEST_BINARY")
    with tempfile.TemporaryDirectory(prefix="nekoedit-locale-manager-") as home:
        valid = ROOT / "build" / "locale-manager-valid.nlp"
        invalid = ROOT / "build" / "locale-manager-invalid.nlp"
        symlink = ROOT / "build" / "locale-manager-link.nlp"
        user_json = ROOT / "build" / "locale-manager-user.json"
        user_pack = ROOT / "build" / "user_TEST.UTF-8.nlp"
        document = {
            "locale": "pt_BR.UTF-8",
            "sequences": [
                {"kind": "multi_key", "input": [ord("o"), ord("i")],
                 "output": [0x2603, 0xFE0F]},
                {"kind": "dead_key", "input": [0x0301, ord("c")],
                 "output": [0x00E7]},
            ],
        }
        packed = encode_pack(document)

        # Convert a real selected-file fixture through the user importer and
        # pack CLI. The freestanding C test installs and looks up this result.
        source_home = Path(home) / "user-compose-home"
        system_root = Path(home) / "user-compose-system"
        fragments = source_home / "fragments"
        fragments.mkdir(parents=True)
        system_root.mkdir()
        (fragments / "basic").write_text(
            '<Multi_key> <e> <e> : "Ə" U018F\n',
            encoding="utf-8",
        )
        selected_compose = source_home / ".XCompose"
        selected_compose.write_text(
            'include "%H/fragments/basic"\n'
            + r'<dead_acute> <c> : "\xC3\xA7" ccedilla' + "\n",
            encoding="utf-8",
        )
        if import_user_xcompose.main([
            "--input", str(selected_compose),
            "--locale", "user_TEST.UTF-8",
            "--home", str(source_home),
            "--system-root", str(system_root),
            "--output", str(user_json),
        ]) != 0:
            raise AssertionError("user XCompose converter failed in manager integration test")
        if compose_pack.main([
            "build", "--input", str(user_json), "--output", str(user_pack)
        ]) != 0:
            raise AssertionError("user XCompose JSON did not build into an NLP1 pack")

        corrupt = bytearray(packed)
        corrupt[-1] ^= 0x01
        valid.parent.mkdir(parents=True, exist_ok=True)
        valid.write_bytes(packed)
        invalid.write_bytes(corrupt)
        try:
            try:
                symlink.unlink()
            except FileNotFoundError:
                pass
            symlink.symlink_to(valid)
            subprocess.run(
                [sys.argv[1], home, str(valid), str(invalid), str(symlink), str(user_pack)],
                check=True,
                cwd=ROOT,
            )
        finally:
            for path in (valid, invalid, symlink, user_json, user_pack):
                try:
                    path.unlink()
                except FileNotFoundError:
                    pass


if __name__ == "__main__":
    main()
