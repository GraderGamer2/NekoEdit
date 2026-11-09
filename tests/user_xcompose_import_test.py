#!/usr/bin/env python3
"""Tests for the bounded, offline user XCompose importer."""
from __future__ import annotations

import json
import os
import stat
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
import import_user_xcompose as user_import  # noqa: E402
from compose_pack import encode_pack  # noqa: E402

KEYSYMS = r'''
#define XK_e 0x0065 /* U+0065 LATIN SMALL LETTER E */
#define XK_g 0x0067 /* U+0067 LATIN SMALL LETTER G */
#define XK_c 0x0063 /* U+0063 LATIN SMALL LETTER C */
#define XK_x 0x0078 /* U+0078 LATIN SMALL LETTER X */
#define XK_a 0x0061 /* U+0061 LATIN SMALL LETTER A */
#define XK_non_unicode 0xFFFF /* no Unicode mapping */
'''


def write(path: Path, text: str) -> Path:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")
    return path


def importer(home: Path, system: Path, keys: dict[str, int] | None = None,
             locale_file: Path | None = None, encoding: str = "utf-8"):
    return user_import.ComposeImporter(
        keysyms=keys or user_import.parse_keysym_definitions(KEYSYMS),
        locale="custom.UTF-8",
        home_root=home,
        system_root=system,
        locale_compose=locale_file,
        encoding=encoding,
    )


def mapping(document):
    return {
        (entry["kind"], tuple(entry["input"])): tuple(entry["output"])
        for entry in document["sequences"]
    }


def expect_failure(callback, label: str, contains: str | None = None) -> None:
    try:
        callback()
    except ValueError as exc:
        if contains and contains not in str(exc):
            raise AssertionError(f"{label}: expected {contains!r}, got {str(exc)!r}") from exc
        return
    raise AssertionError(f"{label}: unsafe or invalid input was accepted")


def fixture_tree(root: Path):
    home = root / "home"
    system = root / "system"
    locale_file = system / "fi_FI.UTF-8" / "Compose"
    write(system / "base" / "Compose", r'''
<Multi_key> <a> <e> : "B" b
<Multi_key> <g> <g> : "S" s
<Multi_key> <a> <e> <x> : "S3" s
''')
    write(system / "nested" / "Compose", r'''
<Multi_key> <x> <x> : "N" n
''')
    write(locale_file, r'''
include "%S/nested/Compose"
<Multi_key> <g> <g> : "L" l
<Multi_key> <e> <e> : "\xC6\x8F" U018F
<dead_acute> <c> : "\xC3\xA7" ccedilla
''')
    write(home / "fragments" / "common", r'''
<Multi_key> <a> <e> : "H" h
<Multi_key> <a> <e> <x> : "H3" h
''')
    root_file = write(home / ".XCompose", r'''
# Includes expand in source order; later matching rules replace earlier ones.
include "%S/base/Compose"
include "%H/fragments/common"
include "%L"
<Multi_key> <a> <e> : "U" u
<Multi_key> <a> <e> <x> : "T" t
<Multi_key> <a> <a> : U1E9E
<dead_acute> <c> : "ñ" ntilde
<Multi_key> <non_unicode> <a> : "skip" skip
Shift <Multi_key> <g> <g> : "modifier" modifier
<unknown_lead> <a> <e> : "lead" lead
<Multi_key> <a> <e> <x> <g> <g> : "too deep" deep
<Multi_key> <a> <x> : "123456789" too_long
''')
    return home, system, locale_file, root_file


def main() -> None:
    with tempfile.TemporaryDirectory(prefix="nekoedit-xcompose-") as directory:
        root = Path(directory)
        home, system, locale_file, root_file = fixture_tree(root)
        document = importer(home, system, locale_file=locale_file).import_file(root_file)
        result = mapping(document)

        if document["locale"] != "custom.UTF-8":
            raise AssertionError("locale tag was not retained")
        if document["statistics"]["files_read"] != 5:
            raise AssertionError("nested %S/%H/%L includes were not loaded exactly once")
        if document["statistics"]["include_directives"] != 4:
            raise AssertionError("nested include count changed")
        if document["statistics"]["rule_overrides"] < 4:
            raise AssertionError("later file/root rules did not override included entries")
        if document["statistics"]["modifier_rules_skipped"] != 1:
            raise AssertionError("modifier-qualified entries were not explicitly skipped")
        if document["statistics"]["unsupported_input"] != 1:
            raise AssertionError("non-Unicode input keysym was not filtered")
        if document["statistics"]["unsupported_lead"] != 1:
            raise AssertionError("unsupported leading keysym was not filtered")
        if document["statistics"]["too_long_input"] != 1:
            raise AssertionError("over-depth sequence was not filtered")
        if document["statistics"]["too_long_output"] != 1:
            raise AssertionError("overlong output string was not filtered")

        # Later root entries override the system, home, and %L copies.
        if result[("multi_key", (ord("g"), ord("g")))] != (ord("L"),):
            raise AssertionError("%L include was not processed after %S")
        if result[("multi_key", (ord("a"), ord("e"), ord("x")))] != (ord("T"),):
            raise AssertionError("later root rule did not override included triple")
        if ("multi_key", (ord("a"), ord("e"))) in result:
            raise AssertionError("shorter same-kind prefix was not dropped")
        if result[("multi_key", (ord("e"), ord("e")))] != (0x018F,):
            raise AssertionError("escaped UTF-8 bytes were not decoded to U+018F")
        if result[("multi_key", (ord("a"), ord("a")))] != (0x1E9E,):
            raise AssertionError("keysym-only Unicode result did not resolve")
        if result[("dead_key", (0x0301, ord("c")))] != (ord("ñ"),):
            raise AssertionError("locale dead-key record was not imported")
        if ("multi_key", (0x0301, ord("c"))) in result:
            raise AssertionError("dead-key record leaked into Multi_key namespace")
        packed = encode_pack(document)
        if len(packed) <= 72:
            raise AssertionError("user import did not produce a valid NLP1 payload")
        serialized_source = json.dumps(document["source"])
        if str(home) in serialized_source or str(root) in serialized_source:
            raise AssertionError("private source paths leaked into generated metadata")

        # A repeated, non-recursive include is allowed and bounded; active
        # recursion through a canonical path is always rejected.
        root_cycle = write(home / ".XCompose", 'include "%H/.XCompose"\n')
        expect_failure(
            lambda: importer(home, system, locale_file=locale_file).import_file(root_cycle),
            "self include",
            "cycle",
        )

        # Unknown substitutions, arbitrary absolute paths, and traversal
        # outside the allowlisted roots fail closed.
        invalid_specs = [
            'include "$HOME/secret"\n',
            'include "%X/private"\n',
            'include "/etc/passwd"\n',
            'include "%H/../outside"\n',
            'include "%S/../../etc/passwd"\n',
        ]
        for index, content in enumerate(invalid_specs):
            candidate = write(home / f"bad-{index}", content)
            expect_failure(
                lambda candidate=candidate: importer(
                    home, system, locale_file=locale_file
                ).import_file(candidate),
                f"unsafe include variant {index}",
                "include",
            )

        # A symlink cannot use an allowlisted path to escape its canonical root.
        outside = write(root / "outside", '<Multi_key> <a> <e> : "escape" escape\n')
        link = home / "escape"
        try:
            link.symlink_to(outside)
        except (OSError, NotImplementedError):
            pass
        else:
            symlink_file = write(home / "symlink-root", 'include "%H/escape"\n')
            expect_failure(
                lambda: importer(home, system, locale_file=locale_file).import_file(symlink_file),
                "symlink escape",
                "outside",
            )

        # A %L include must be explicitly supplied and remain under %S.
        no_locale_file = write(home / "needs-L", 'include "%L"\n')
        expect_failure(
            lambda: importer(home, system).import_file(no_locale_file),
            "implicit %L",
            "--locale-compose",
        )
        outside_locale = write(root / "locale-outside", '<Multi_key> <a> <e> : "x" x\n')
        expect_failure(
            lambda: importer(home, system, locale_file=outside_locale).import_file(no_locale_file),
            "%L outside system root",
            "outside",
        )

        # The resource policy is enforced independently at each boundary.
        oversized = write(home / "oversized", "#" * (user_import.MAX_FILE_BYTES + 1))
        expect_failure(
            lambda: importer(home, system).import_file(oversized),
            "per-file byte limit",
            "per-file limit",
        )
        long_line = write(home / "long-line", "#" + "x" * user_import.MAX_LINE_BYTES)
        expect_failure(
            lambda: importer(home, system).import_file(long_line),
            "line byte limit",
            "line exceeds",
        )

        # Include recursion and repeated expansion are bounded.
        depth_root = write(home / "depth-root", 'include "%H/depth-1"\n')
        for number in range(1, user_import.MAX_INCLUDE_DEPTH + 3):
            following = (
                f'include "%H/depth-{number + 1}"\n'
                if number < user_import.MAX_INCLUDE_DEPTH + 2
                else '<Multi_key> <a> <e> : "x" x\n'
            )
            write(home / f"depth-{number}", following)
        expect_failure(
            lambda: importer(home, system).import_file(depth_root),
            "include depth limit",
            "depth",
        )

        # Override/record limits can be lowered in a unit test to exercise
        # the deterministic guard without constructing a huge input fixture.
        original_limit = user_import.MAX_RECORDS
        try:
            user_import.MAX_RECORDS = 2
            too_many = write(
                home / "too-many",
                '<Multi_key> <a> <e> : "1" one\n'
                '<Multi_key> <g> <g> : "2" two\n'
                '<Multi_key> <x> <x> : "3" three\n',
            )
            expect_failure(
                lambda: importer(home, system).import_file(too_many),
                "record limit",
                "unique Compose records",
            )
        finally:
            user_import.MAX_RECORDS = original_limit

        # Latin-1 sources and octal escapes are explicit, not guessed.
        latin1 = home / "latin1"
        latin1.write_bytes('<Multi_key> <a> <e> : "\351" eacute\n'.encode("latin-1"))
        latin_doc = importer(home, system, encoding="latin-1").import_file(latin1)
        if mapping(latin_doc)[("multi_key", (ord("a"), ord("e")))] != (0x00E9,):
            raise AssertionError("Latin-1 octal escape was not decoded with the selected encoding")

        output = home / ".nekoedit" / "locales" / "custom.json"
        user_import._atomic_write(output, json.dumps(document))
        if stat.S_IMODE(output.stat().st_mode) != 0o600:
            raise AssertionError("generated user data file is not mode 0600")

    print("Bounded offline user XCompose importer tests passed")


if __name__ == "__main__":
    main()
