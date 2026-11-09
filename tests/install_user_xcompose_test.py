#!/usr/bin/env python3
"""Tests for the one-command private user XCompose -> NLP1 installer."""
from __future__ import annotations

import stat
import struct
import tempfile
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
from install_user_xcompose import install_user_xcompose  # noqa: E402
from compose_pack import HEADER_SIZE, MAGIC, RECORD_SIZE, VERSION  # noqa: E402


def write(path: Path, text: str) -> Path:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")
    return path


def inspect_pack(path: Path, locale: str) -> bytes:
    packed = path.read_bytes()
    if len(packed) < HEADER_SIZE:
        raise AssertionError("installed pack is shorter than its header")
    header = struct.unpack("<8s7I32sI", packed[:HEADER_SIZE])
    if (
        header[0] != MAGIC
        or header[1] != VERSION
        or header[2] != HEADER_SIZE
        or header[3] != RECORD_SIZE
        or header[4] < 2
        or header[5] != header[4] * RECORD_SIZE
        or len(packed) != HEADER_SIZE + header[5]
        or header[8].split(bytes(1), 1)[0].decode("ascii") != locale
    ):
        raise AssertionError("installed file is not a valid matching NLP1 pack")
    if stat.S_IMODE(path.stat().st_mode) != 0o600:
        raise AssertionError("installed locale pack is not mode 0600")
    return packed


def main() -> None:
    with tempfile.TemporaryDirectory(prefix="nekoedit-user-xcompose-install-") as root_text:
        root = Path(root_text)
        home = root / "home"
        system = root / "system"
        home.mkdir(mode=0o700)
        system.mkdir(mode=0o700)
        source = write(
            home / ".XCompose",
            '<Multi_key> <e> <e> : "Ə" U018F\n'
            '<dead_acute> <c> : "ç" ccedilla\n',
        )
        original_source = source.read_bytes()

        installed, stats = install_user_xcompose(
            input_path=source,
            locale="custom.UTF-8",
            home=home,
            system_root=system,
        )
        expected = home / ".nekoedit" / "locales" / "custom.UTF-8.nlp"
        if installed != expected:
            raise AssertionError(f"installer wrote outside the fixed locale directory: {installed}")
        first_pack = inspect_pack(installed, "custom.UTF-8")
        if stats["final_rules"] != 2 or stats["files_read"] != 1:
            raise AssertionError(f"unexpected importer statistics: {stats!r}")
        for directory in (home / ".nekoedit", home / ".nekoedit" / "locales"):
            if stat.S_IMODE(directory.stat().st_mode) != 0o700:
                raise AssertionError(f"private directory mode is not 0700: {directory}")
        if source.read_bytes() != original_source:
            raise AssertionError("installer modified or moved the selected source file")

        # Existing packs are not silently overwritten. A second import with
        # --replace is an explicit, atomic update.
        write(
            source,
            '<Multi_key> <e> <e> : "A" A\n'
            '<dead_acute> <c> : "Ç" Ccedilla\n',
        )
        try:
            install_user_xcompose(
                input_path=source,
                locale="custom.UTF-8",
                home=home,
                system_root=system,
            )
        except FileExistsError:
            pass
        else:
            raise AssertionError("installer silently replaced an existing locale pack")
        if installed.read_bytes() != first_pack:
            raise AssertionError("failed no-replace install modified the existing pack")

        install_user_xcompose(
            input_path=source,
            locale="custom.UTF-8",
            home=home,
            system_root=system,
            replace=True,
        )
        second_pack = inspect_pack(installed, "custom.UTF-8")
        if second_pack == first_pack:
            raise AssertionError("--replace did not atomically update the compiled pack")
        if sorted(path.name for path in installed.parent.iterdir()) != ["custom.UTF-8.nlp"]:
            raise AssertionError("installer left temporary files in the locale directory")

        # An attacker-controlled .nekoedit symlink must not redirect an
        # install to a directory outside the chosen home.
        other_home = root / "other-home"
        outside = root / "outside"
        other_home.mkdir(mode=0o700)
        outside.mkdir(mode=0o700)
        (other_home / ".nekoedit").symlink_to(outside, target_is_directory=True)
        try:
            install_user_xcompose(
                input_path=source,
                locale="escape.UTF-8",
                home=other_home,
                system_root=system,
            )
        except (OSError, ValueError):
            pass
        else:
            raise AssertionError("installer followed a symlinked .nekoedit directory")
        if (outside / "locales").exists():
            raise AssertionError("symlinked output redirected the install outside HOME")

        unsafe = write(home / "unsafe.XCompose", 'include "%H/../outside"\n')
        try:
            install_user_xcompose(
                input_path=unsafe,
                locale="../bad",
                home=home,
                system_root=system,
            )
        except ValueError:
            pass
        else:
            raise AssertionError("unsafe locale tag or include was accepted")

    print("Private one-command user XCompose installer tests passed")


if __name__ == "__main__":
    main()
