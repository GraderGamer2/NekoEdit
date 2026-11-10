#!/usr/bin/env python3
"""Exercise the bounded importer against an installed X.Org Compose database."""
from __future__ import annotations

import os
import tempfile
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
import import_user_xcompose as user_import  # noqa: E402
from compose_pack import encode_pack  # noqa: E402


DEFAULT_COMPOSE = Path("/usr/share/X11/locale/en_US.UTF-8/Compose")
DEFAULT_SYSTEM_ROOT = Path("/usr/share/X11/locale")
DEFAULT_KEYSYMDEF = Path("/usr/include/X11/keysymdef.h")


def mapping(document: dict) -> dict[tuple[str, tuple[int, ...]], tuple[int, ...]]:
    return {
        (entry["kind"], tuple(entry["input"])): tuple(entry["output"])
        for entry in document["sequences"]
    }


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def main() -> int:
    compose_file = Path(
        os.environ.get("NEKOEDIT_SYSTEM_COMPOSE_FILE", str(DEFAULT_COMPOSE))
    ).expanduser()
    system_root = Path(
        os.environ.get("NEKOEDIT_SYSTEM_COMPOSE_ROOT", str(DEFAULT_SYSTEM_ROOT))
    ).expanduser()
    keysymdef = Path(
        os.environ.get("NEKOEDIT_KEYSYMDEF", str(DEFAULT_KEYSYMDEF))
    ).expanduser()

    missing = [
        str(path) for path in (compose_file, system_root, keysymdef)
        if not path.exists()
    ]
    if missing:
        print(
            "SKIP: installed X.Org Compose corpus is unavailable ("
            + ", ".join(missing)
            + ")"
        )
        return 0

    compose_file = compose_file.resolve(strict=True)
    system_root = system_root.resolve(strict=True)
    keysymdef = keysymdef.resolve(strict=True)
    require(compose_file.is_file(), f"system Compose path is not a file: {compose_file}")
    require(system_root.is_dir(), f"system Compose root is not a directory: {system_root}")
    require(keysymdef.is_file(), f"keysymdef path is not a file: {keysymdef}")
    require(
        compose_file.is_relative_to(system_root),
        "system Compose file must remain beneath the configured system root",
    )

    keysyms = user_import.parse_keysym_definitions(
        keysymdef.read_text(encoding="utf-8")
    )

    with tempfile.TemporaryDirectory(prefix="nekoedit-system-xcompose-") as temp:
        home = Path(temp) / "home"
        home.mkdir(mode=0o700)
        user_file = home / ".XCompose"
        user_file.write_text(
            'include "%L"\n'
            '<Multi_key> <o> <c> : "Neko" N\n'
            '<Multi_key> <a> <z> : "Ω" U03A9\n',
            encoding="utf-8",
        )

        importer = user_import.ComposeImporter(
            keysyms=keysyms,
            locale="custom.UTF-8",
            home_root=home,
            system_root=system_root,
            locale_compose=compose_file,
        )
        document = importer.import_file(user_file)
        records = mapping(document)
        stats = document["statistics"]

        # These mappings are present in the installed X.Org en_US corpus.
        # The second one exercises the separate dead-key record namespace.
        require(
            records.get(("multi_key", (ord("o"), ord("c")))) == (0x004E, 0x0065, 0x006B, 0x006F),
            "user rule did not override the installed Multi_key o+c rule after %L",
        )
        require(
            records.get(("dead_key", (0x0301, ord("e")))) == (0x00E9,),
            "installed dead_acute+e rule was not imported",
        )
        require(
            records.get(("multi_key", (ord("a"), ord("z")))) == (0x03A9,),
            "user-only rule was not imported after the system include",
        )
        require(stats["files_read"] >= 2, "the user file and installed Compose file were not both read")
        require(stats["include_directives"] >= 1, "the explicit %L include was not expanded")
        require(stats["rule_overrides"] >= 1, "the user override was not counted")
        require(stats["rules_seen"] >= 3000, "the installed system corpus was not fully traversed")
        require(stats["final_rules"] >= 1000, "too few system/user rules survived filtering")

        packed = encode_pack(document)
        require(72 < len(packed) <= 2 * 1024 * 1024, "generated NLP1 pack is outside runtime size bounds")
        require(
            not (home / ".nekoedit").exists(),
            "system-corpus test unexpectedly installed or wrote a locale pack",
        )

        print(
            "Installed X.Org Compose import passed: "
            f"{stats['final_rules']} final rules from {stats['files_read']} files; "
            f"{stats['rules_seen']} rules scanned; "
            f"{stats['rule_overrides']} user/system overrides; "
            f"{len(packed)} bytes validated in memory"
        )

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
