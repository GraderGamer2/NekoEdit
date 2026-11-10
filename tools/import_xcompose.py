#!/usr/bin/env python3
"""Flatten pinned X.Org Compose.pre data into NekoEdit locale JSON."""
from __future__ import annotations

import argparse
import ast
import json
import os
import re
import sys
from pathlib import Path
from typing import Any

LIBX11_COMMIT = "ff8706a5eae25b8bafce300527079f68a201d27f"
BASE_COMPOSE_BLOB = "84888ef02bc1aa0ecaa939f59fcf4b10e5e7b3df"
LOCALE_COMPOSE_BLOB = "29846c63171d944c34a320376051591da2a2df3b"
XORGPROTO_COMMIT = "6d3907b6d5dc4aa7d7ee6ee5d7d8714e7466630b"
KEYSYMDEF_BLOB = "96d056662e822701a591f461842ac8c0e17fb560"
BASE_INCLUDE = "X11_LOCALEDATADIR/en_US.UTF-8/Compose"

_DEFINE = re.compile(
    r"^\s*#\s*define\s+XK_([A-Za-z0-9_]+)\s+(0x[0-9a-fA-F]+)"
    r"(?:\s*/\*\s*U\+([0-9a-fA-F]{4,6})\b[^*]*\*/)?"
)
_INCLUDE = re.compile(r'^\s*include\s+"([^"]+)"\s*$')
_KEY = re.compile(r"<([^>]+)>")
_STRING = re.compile(r'"((?:\\.|[^"\\])*)"')

# These values are the combining marks represented by NekoEdit's existing
# XKB dead-key action IDs. The action itself never enters the scalar input.
DEAD_KEY_MARKS = {
    "dead_abovecomma": 0x0313,
    "dead_abovedot": 0x0307,
    "dead_abovereversedcomma": 0x0314,
    "dead_abovering": 0x030A,
    "dead_aboveverticalline": 0x030D,
    "dead_acute": 0x0301,
    "dead_apostrophe": 0x0301,
    "dead_belowbreve": 0x032E,
    "dead_belowcircumflex": 0x032D,
    "dead_belowcomma": 0x0326,
    "dead_belowdiaeresis": 0x0324,
    "dead_belowdot": 0x0323,
    "dead_belowmacron": 0x0331,
    "dead_belowring": 0x0325,
    "dead_belowtilde": 0x0330,
    "dead_belowverticalline": 0x0329,
    "dead_breve": 0x0306,
    "dead_caron": 0x030C,
    "dead_cedilla": 0x0327,
    "dead_circumflex": 0x0302,
    "dead_dasia": 0x0314,
    "dead_diaeresis": 0x0308,
    "dead_doubleacute": 0x030B,
    "dead_doublegrave": 0x030F,
    "dead_grave": 0x0300,
    "dead_hook": 0x0309,
    "dead_horn": 0x031B,
    "dead_invertedbreve": 0x0311,
    "dead_iota": 0x0345,
    "dead_longsolidusoverlay": 0x0338,
    "dead_lowline": 0x0332,
    "dead_macron": 0x0304,
    "dead_ogonek": 0x0328,
    "dead_perispomeni": 0x0303,
    "dead_psili": 0x0313,
    "dead_semivoiced_sound": 0x309A,
    "dead_stroke": 0x0338,
    "dead_tilde": 0x0303,
    "dead_voiced_sound": 0x3099,
}


def _valid_scalar(value: int) -> bool:
    return 0 < value <= 0x10FFFF and not 0xD800 <= value <= 0xDFFF


def parse_keysym_definitions(source: str) -> dict[str, int]:
    definitions: list[tuple[str, int, int]] = []
    annotated_by_value: dict[int, int] = {}
    for line in source.splitlines():
        match = _DEFINE.match(line)
        if not match:
            continue
        name, raw_value, raw_annotation = match.groups()
        value = int(raw_value, 16)
        annotation = int(raw_annotation, 16) if raw_annotation else 0
        definitions.append((name, value, annotation))
        if annotation:
            annotated_by_value.setdefault(value, annotation)

    result: dict[str, int] = {}
    for name, value, annotation in definitions:
        unicode_keysym = value - 0x01000000 if 0x01000000 <= value <= 0x0110FFFF else 0
        scalar = annotation or (value if 0x20 <= value <= 0x7E else 0)
        scalar = scalar or annotated_by_value.get(value, 0) or unicode_keysym
        if _valid_scalar(scalar):
            result.setdefault(name, scalar)
    return result


def _decode_compose_string(raw: str) -> str:
    # Compose.pre string values follow C string escape syntax.
    try:
        value = ast.literal_eval('"' + raw + '"')
    except (SyntaxError, ValueError) as exc:
        raise ValueError(f"invalid quoted Compose result: {raw!r}") from exc
    if not isinstance(value, str):
        raise ValueError("Compose result did not decode to a string")
    return value


def _read_rules(
    text: str,
    keysyms: dict[str, int],
    stats: dict[str, int],
    *,
    allow_base_include: bool,
    require_base_include: bool = True,
) -> dict[tuple[int, tuple[int, ...]], tuple[int, ...]]:
    rules: dict[tuple[int, tuple[int, ...]], tuple[int, ...]] = {}
    include_count = 0
    valid_multi_key_lines = 0
    valid_dead_key_lines = 0

    for line_number, line in enumerate(text.splitlines(), 1):
        stripped = line.strip()
        if not stripped or stripped.startswith("XCOMM") or stripped.startswith("#"):
            continue
        include = _INCLUDE.match(stripped)
        if include:
            target = include.group(1)
            if not allow_base_include or target != BASE_INCLUDE:
                raise ValueError(
                    f"unsupported Compose include on line {line_number}: {target!r}"
                )
            include_count += 1
            continue
        if not stripped.startswith("<") or ":" not in line:
            continue

        left, right = line.split(":", 1)
        names = _KEY.findall(left)
        if not names:
            continue

        if names[0] == "Multi_key":
            kind = 0
            input_names = names[1:]
            if len(input_names) < 2:
                stats["short_sequence"] += 1
                continue
            if len(input_names) > 4:
                stats["too_long"] += 1
                continue
        elif names[0] in DEAD_KEY_MARKS:
            kind = 1
            input_names = names[1:]
            if len(input_names) < 1:
                stats["short_sequence"] += 1
                continue
            # The current input path resolves a dead action plus one scalar.
            if len(input_names) != 1:
                stats["too_long"] += 1
                continue
        else:
            stats["unsupported_lead"] += 1
            continue

        input_values: list[int] = []
        if kind == 1:
            input_values.append(DEAD_KEY_MARKS[names[0]])
        for name in input_names:
            if re.fullmatch(r"U[0-9A-Fa-f]{4,6}", name):
                scalar = int(name[1:], 16)
            else:
                scalar = keysyms.get(name, 0)
            if not _valid_scalar(scalar):
                stats["unsupported_input"] += 1
                break
            input_values.append(scalar)
        else:
            output_match = _STRING.search(right)
            if not output_match:
                stats["invalid_string"] += 1
                continue
            try:
                output_text = _decode_compose_string(output_match.group(1))
            except ValueError:
                stats["invalid_string"] += 1
                continue
            output_values = tuple(ord(char) for char in output_text)
            if (
                not 1 <= len(output_values) <= 8
                or any(not _valid_scalar(value) for value in output_values)
            ):
                stats["invalid_output"] += 1
                continue
            rules[(kind, tuple(input_values))] = output_values
            if kind == 0:
                valid_multi_key_lines += 1
            else:
                valid_dead_key_lines += 1

    stats["locale_rule_lines" if allow_base_include else "base_rule_lines"] = valid_multi_key_lines
    stats[
        "locale_dead_key_lines" if allow_base_include else "base_dead_key_lines"
    ] = valid_dead_key_lines
    if allow_base_include:
        expected_include_count = 1 if require_base_include else 0
        if include_count != expected_include_count:
            expectation = "exactly one" if require_base_include else "no"
            raise ValueError(
                f"expected {expectation} en_US Compose include, found {include_count}"
            )
    return rules


def import_compose_sources(
    base_text: str,
    locale_text: str,
    keysym_text: str,
    locale: str,
    source_info: dict[str, Any] | None = None,
    *,
    locale_has_base_include: bool = True,
) -> dict[str, Any]:
    try:
        locale_bytes = locale.encode("ascii")
    except UnicodeEncodeError as exc:
        raise ValueError("locale tag must contain ASCII characters only") from exc
    if not 1 <= len(locale_bytes) <= 31:
        raise ValueError("locale tag must contain 1–31 ASCII characters")

    keysyms = parse_keysym_definitions(keysym_text)
    stats = {
        "unsupported_input": 0,
        "invalid_output": 0,
        "invalid_string": 0,
        "short_sequence": 0,
        "too_long": 0,
        "unsupported_lead": 0,
        "base_rule_lines": 0,
        "locale_rule_lines": 0,
        "base_dead_key_lines": 0,
        "locale_dead_key_lines": 0,
    }
    base_rules = _read_rules(base_text, keysyms, stats, allow_base_include=False)
    locale_rules = _read_rules(
        locale_text,
        keysyms,
        stats,
        allow_base_include=True,
        require_base_include=locale_has_base_include,
    )
    merged = dict(base_rules)
    overrides = 0
    dead_key_overrides = 0
    for identity, value in locale_rules.items():
        if identity in merged:
            overrides += 1
            if identity[0] == 1:
                dead_key_overrides += 1
        merged[identity] = value

    # Prefix ambiguity is scoped to a rule kind. A dead-key sequence and a
    # Multi_key sequence may legitimately contain the same scalar tuple.
    dropped_prefixes: set[tuple[int, tuple[int, ...]]] = set()
    for kind, key in merged:
        for length in range(2, len(key)):
            prefix = (kind, key[:length])
            if prefix in merged:
                dropped_prefixes.add(prefix)
    for prefix in dropped_prefixes:
        del merged[prefix]

    records = [
        {"kind": "multi_key" if kind == 0 else "dead_key",
         "input": list(key), "output": list(value)}
        for (kind, key), value in sorted(merged.items())
    ]
    input_lengths = {
        str(length): sum(len(record["input"]) == length for record in records)
        for length in (2, 3, 4)
        if any(len(record["input"]) == length for record in records)
    }
    metadata = {
        "upstream": "X.Org libX11 Compose data and xorgproto keysym definitions",
        "libx11_repository": "mirror/libX11",
        "libx11_commit": LIBX11_COMMIT,
        "base_compose_path": "nls/en_US.UTF-8/Compose.pre",
        "base_compose_blob": BASE_COMPOSE_BLOB,
        "locale_compose_path": f"nls/{locale}/Compose.pre",
        "locale_compose_blob": LOCALE_COMPOSE_BLOB,
        "xorgproto_repository": "X11Libre/mirror.fdo.xorgproto",
        "xorgproto_commit": XORGPROTO_COMMIT,
        "keysymdef_path": "include/X11/keysymdef.h",
        "keysymdef_blob": KEYSYMDEF_BLOB,
        "import_policy": (
            (
                f"Flatten the en_US include, apply {locale} Multi_key and dead-key overrides, "
                if locale_has_base_include
                else f"Merge the pinned en_US baseline, then apply standalone {locale} Multi_key and dead-key rules and overrides, "
            )
            + "retain only input keysyms mapped to Unicode scalars, and drop shorter "
            "sequences that prefix longer sequences."
        ),
    }
    if source_info:
        metadata.update(source_info)
    return {
        "locale": locale,
        "source": metadata,
        "statistics": {
            "base_rules": stats["base_rule_lines"],
            "locale_rules": stats["locale_rule_lines"],
            "locale_overrides": overrides,
            "dropped_shorter_prefix_rules": len(dropped_prefixes),
            "final_rules": len(records),
            "input_sequence_lengths": input_lengths,
            "multi_scalar_outputs": sum(len(record["output"]) > 1 for record in records),
            "base_dead_key_rules": stats["base_dead_key_lines"],
            "locale_dead_key_rules": stats["locale_dead_key_lines"],
            "dead_key_overrides": dead_key_overrides,
            **{
                key: value
                for key, value in stats.items()
                if key not in {
                    "base_rule_lines", "locale_rule_lines",
                    "base_dead_key_lines", "locale_dead_key_lines",
                }
            },
        },
        "sequences": records,
    }


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--base", required=True, type=Path)
    parser.add_argument("--locale-source", required=True, type=Path)
    parser.add_argument("--keysymdef", required=True, type=Path)
    parser.add_argument("--locale", required=True)
    parser.add_argument(
        "--locale-compose-blob",
        default=LOCALE_COMPOSE_BLOB,
        help="Git blob SHA for the locale Compose.pre source",
    )
    parser.add_argument(
        "--locale-standalone",
        action="store_true",
        help="The locale Compose.pre has no en_US include; merge its rules over --base.",
    )
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args(argv)
    if not re.fullmatch(r"[0-9a-f]{40}", args.locale_compose_blob):
        parser.error("--locale-compose-blob must be a 40-character lowercase Git SHA")
    try:
        document = import_compose_sources(
            args.base.read_text(encoding="utf-8"),
            args.locale_source.read_text(encoding="utf-8"),
            args.keysymdef.read_text(encoding="utf-8"),
            args.locale,
            source_info={"locale_compose_blob": args.locale_compose_blob},
            locale_has_base_include=not args.locale_standalone,
        )
        encoded = json.dumps(document, ensure_ascii=True, indent=2) + "\n"
        args.output.parent.mkdir(parents=True, exist_ok=True)
        temporary = args.output.with_name(args.output.name + ".tmp")
        try:
            temporary.write_text(encoded, encoding="utf-8")
            os.replace(temporary, args.output)
        finally:
            try:
                temporary.unlink()
            except FileNotFoundError:
                pass
    except (OSError, UnicodeError, ValueError) as exc:
        print(f"import_xcompose.py: {exc}", file=sys.stderr)
        return 1
    stats = document["statistics"]
    print(
        f"wrote {stats['final_rules']} {args.locale} rules "
        f"({stats['locale_overrides']} locale overrides; "
        f"{stats['dead_key_overrides']} dead-key overrides; "
        f"{stats['dropped_shorter_prefix_rules']} shorter prefixes dropped)"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
