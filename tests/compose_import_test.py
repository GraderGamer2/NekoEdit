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
<dead_acute> <dead_circumflex> <a> : "B3CHAIN"
<dead_grave> <dead_acute> <dead_circumflex> <a> : "B4CHAIN"
<dead_acute> <dead_circumflex> <dead_grave> <dead_tilde> <dead_macron> <dead_breve> <dead_caron> <a> : "B8CHAIN"
'''

LOCALE = r'''
XCOMM locale-specific overlay fixture
include "X11_LOCALEDATADIR/en_US.UTF-8/Compose"
<Multi_key> <q> <q> : "ø" oslash
<Multi_key> <a> <e> <x> : "★" U2605
<Multi_key> <test_legacy_alias> <a> : "ẞ" U1E9E
<Multi_key> <not_a_keysym> <a> : "x" x
<dead_acute> <c> : "ñ" ntilde
<dead_acute> <dead_circumflex> <a> : "L3CHAIN"
'''


def main() -> None:
    document = import_compose_sources(BASE, LOCALE, KEYSYMS, "xx_TEST.UTF-8")
    mapping = {
        (record["kind"], tuple(record["input"])): tuple(record["output"])
        for record in document["sequences"]
    }
    if document["statistics"]["base_rules"] != 5:
        raise AssertionError("base_rules must count valid Multi_key lines, including duplicates")
    if document["statistics"]["base_dead_key_rules"] != 4:
        raise AssertionError("base one-, two-mark, and three-mark dead-key rules were not imported")
    if document["statistics"]["locale_dead_key_rules"] != 2:
        raise AssertionError("the locale dead-key rules were not imported")
    if document["statistics"]["dead_key_overrides"] != 2:
        raise AssertionError("locale dead-key overrides were not applied to both chain and single-mark rules")
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
    if mapping[("dead_key", (0x0301, 0x0302, ord("a")))] != tuple(map(ord, "L3CHAIN")):
        raise AssertionError("locale two-mark dead-key override was not retained")
    if mapping[("dead_key", (0x0300, 0x0301, 0x0302, ord("a")))] != tuple(map(ord, "B4CHAIN")):
        raise AssertionError("three-mark dead-key chain was not retained")
    if mapping[("dead_key", (0x0301, 0x0302, 0x0300, 0x0303, 0x0304, 0x0306, 0x030C, ord("a")))] != tuple(map(ord, "B8CHAIN")):
        raise AssertionError("seven-mark dead-key chain was not retained")
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

    standalone = r'''
<Multi_key> <q> <x> : "Ω" U03A9
<dead_acute> <c> : "ć" U0107
<dead_acute> <dead_circumflex> <dead_grave> <a> : "δ" U03B4
<dead_acute> <dead_circumflex> <dead_grave> <dead_tilde> <dead_macron> <dead_breve> <dead_caron> <a> : "Ω" U03A9
'''
    standalone_document = import_compose_sources(
        BASE, standalone, KEYSYMS, "el_TEST.UTF-8",
        locale_has_base_include=False,
    )
    standalone_map = {
        (record["kind"], tuple(record["input"])): tuple(record["output"])
        for record in standalone_document["sequences"]
    }
    if standalone_map[("multi_key", (ord("a"), ord("e")))] != (0x00E6,):
        raise AssertionError("standalone locale import dropped the en_US baseline")
    if standalone_map[("multi_key", (ord("q"), ord("x")))] != (0x03A9,):
        raise AssertionError("standalone locale Multi_key rule was not merged")
    if standalone_map[("dead_key", (0x0301, ord("c")))] != (0x0107,):
        raise AssertionError("standalone locale dead-key rule was not merged")
    if standalone_map[("dead_key", (0x0301, 0x0302, 0x0300, ord("a")))] != (0x03B4,):
        raise AssertionError("standalone three-mark dead-key chain was not merged")
    if standalone_map[("dead_key", (0x0301, 0x0302, 0x0300, 0x0303, 0x0304, 0x0306, 0x030C, ord("a")))] != (0x03A9,):
        raise AssertionError("standalone seven-mark dead-key chain was not merged")
    if "standalone el_TEST.UTF-8" not in standalone_document["source"]["import_policy"]:
        raise AssertionError("standalone import policy metadata is missing")

    try:
        import_compose_sources(BASE, standalone, KEYSYMS, "el_TEST.UTF-8")
    except ValueError:
        pass
    else:
        raise AssertionError("source missing its required include was accepted by default")
    try:
        import_compose_sources(
            BASE,
            standalone + 'include "X11_LOCALEDATADIR/en_US.UTF-8/Compose"\n',
            KEYSYMS,
            "el_TEST.UTF-8",
            locale_has_base_include=False,
        )
    except ValueError:
        pass
    else:
        raise AssertionError("standalone mode accepted a synthetic include")
    print("X.Org Compose importer tests passed")


if __name__ == "__main__":
    main()
