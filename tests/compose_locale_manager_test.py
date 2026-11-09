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
from compose_pack import encode_pack  # noqa: E402


def main() -> None:
    if len(sys.argv) != 2:
        raise SystemExit("usage: compose_locale_manager_test.py MANAGER_TEST_BINARY")
    with tempfile.TemporaryDirectory(prefix="nekoedit-locale-manager-") as home:
        valid = ROOT / "build" / "locale-manager-valid.nlp"
        invalid = ROOT / "build" / "locale-manager-invalid.nlp"
        symlink = ROOT / "build" / "locale-manager-link.nlp"
        document = {
            "locale": "pt_BR.UTF-8",
            "sequences": [
                {"input": [ord("o"), ord("i")], "output": [0x2603, 0xFE0F]},
            ],
        }
        packed = encode_pack(document)
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
                [sys.argv[1], home, str(valid), str(invalid), str(symlink)],
                check=True,
                cwd=ROOT,
            )
        finally:
            for path in (valid, invalid, symlink):
                try:
                    path.unlink()
                except FileNotFoundError:
                    pass


if __name__ == "__main__":
    main()
