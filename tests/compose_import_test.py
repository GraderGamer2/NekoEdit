#!/usr/bin/env python3
"""Tests for the bounded X.Org Compose.pre importer."""
from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tools"))
from compose_pack import encode_pack  # noqa: E402
from import_xcompose import import_compose_sources  # noqa: E402

KEYSYMS = """
#define XK_a 0x0061 /* U+0061 LATIN SMALL LETTER A */
#define XK_e 0x0065 /* U+0065 LATIN SMALL LETTER E */
#define XK_q 0x0071 /* U+0071 LATIN SMALL LETTER Q */
#define XK_z 0x007A /* U+007A LATIN SMALL LETTER Z */
#define XK_x 0x0078 /* U+0078 LATIN SMALL LETTER X */
#define XK_c 0x0063 /* U+0063 LATIN SMALL LETTER C */
#define XK_test_canonical 0x07AB /* U+1E9E CAPITAL SHARP S */
#define XK_test_legacy_alias 0x07AB
"""

BASE = r'''
XCOMM minimal base fixture
<Multi_key> <a> <e> : "æ" ae
<Multi_key> <q> <q> : "©" copyright
<Multi_key> <q> <q> : "®" registered
<Multi_key> <z> <z> : "u\u0301" U0075
<Multi_key> <test_canonical> <a> : "ẞ" U1E9E
<dead_acute> <c> : "ç" ccedilla
'''

LOCALE = r'''
XCOMM locale-specific overlay fixture
include "X11_LOCALEDATADIR/en_US.UTF-8/Compose"
<Multi_key> <q> <q> : "ø" oslash
<Multi_key> <a> <e> <x> : "★" U2605
<Multi_key> <test_legacy_alias> <a> : "ẞ" U1E9E
<Multi_key> <not_a_keysym> <a> : "x" x
<dead_acute> <c> : "ñ" ntilde
'''


def main() -> None:
    document = import_compose_sources(BASE, LOCALE, KEYSYMS, "xx_TEST.UTF-8")
    mapping = {
        (record["kind"], tuple(record["input"])): tuple(record["output"])
        for record in document["sequences"]
    }
    if document["statistics"]["base_rules"] != 5:
        raise AssertionError("base_rules must count valid Multi_key lines, including duplicates")
    if document["statistics"]["base_dead_key_rules"] != 1:
        raise AssertionError("the base dead-key rule was not imported")
    if document["statistics"]["locale_dead_key_rules"] != 1:
        raise AssertionError("the locale dead-key override was not imported")
    if document["statistics"]["dead_key_overrides"] != 1:
        raise AssertionError("the locale dead-key rule did not override its base mapping")
    if document["statistics"]["dropped_shorter_prefix_rules"] != 1:
        raise AssertionError("shorter prefix was not removed deterministically")
    if ("multi_key", (ord("a"), ord("e"))) in mapping:
        raise AssertionError("shorter pair prefix should yield to the longer locale rule")
    if mapping[("multi_key", (ord("a"), ord("e"), ord("x")))] != (0x2605,):
        raise AssertionError("three-input locale rule was not retained")
    if mapping[("multi_key", (ord("q"), ord("q")))] != (0x00F8,):
        raise AssertionError("locale rule did not override the base table")
    if mapping[("multi_key", (ord("z"), ord("z")))] != (ord("u"), 0x0301):
        raise AssertionError("multi-scalar output was not preserved")
    if mapping[("multi_key", (0x1E9E, ord("a")))] != (0x1E9E,):
        raise AssertionError("legacy keysym alias did not use the annotated canonical value")
    if mapping[("dead_key", (0x0301, ord("c")))] != (ord("ñ"),):
        raise AssertionError("locale dead_acute + c override was not retained as a typed rule")
    if ("multi_key", (0x0301, ord("c"))) in mapping:
        raise AssertionError("dead-key record leaked into the Multi_key namespace")
    if document["statistics"]["unsupported_input"] != 1:
        raise AssertionError("unmapped input keysym should be counted and skipped")
    if len(encode_pack(document)) <= 72:
        raise AssertionError("imported fixture did not produce a valid NLP1 pack")

    invalid_include = LOCALE.replace(
        "X11_LOCALEDATADIR/en_US.UTF-8/Compose",
        "other/unknown/Compose",
    )
    try:
        import_compose_sources(BASE, invalid_include, KEYSYMS, "xx_TEST.UTF-8")
    except ValueError:
        pass
    else:
        raise AssertionError("unsupported Compose include was silently accepted")
    source_override = import_compose_sources(
        BASE, LOCALE, KEYSYMS, "xx_TEST.UTF-8",
        source_info={"locale_compose_blob": "a" * 40},
    )
    if source_override["source"]["locale_compose_blob"] != "a" * 40:
        raise AssertionError("per-locale source blob metadata was not applied")
    if "xx_TEST.UTF-8 Multi_key and dead-key overrides" not in source_override["source"]["import_policy"]:
        raise AssertionError("import policy metadata is not locale-generic")
    print("X.Org Compose importer tests passed")


if __name__ == "__main__":
    main()
