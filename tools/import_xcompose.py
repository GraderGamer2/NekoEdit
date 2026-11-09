#!/usr/bin/env python3
"""Flatten a pinned X.Org Compose.pre locale into NekoEdit locale JSON."""
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
    # The pinned Compose.pre files use C-style quoted string escapes.
    try:
        value = ast.literal_eval('"' + raw + '"')
    except (SyntaxError, ValueError) as exc:
        raise ValueError(f"invalid quoted Compose result: {raw!r}") from exc
    if not isinstance(value, str):
        raise ValueError("Compose result did not decode to a string")
    return value


def _read_rules(text: str, keysyms: dict[str, int], stats: dict[str, int],
                *, allow_base_include: bool) -> dict[tuple[int, ...], tuple[int, ...]]:
    rules: dict[tuple[int, ...], tuple[int, ...]] = {}
    include_count = 0
    for line_number, line in enumerate(text.splitlines(), 1):
        stripped = line.strip()
        if not stripped or stripped.startswith("XCOMM") or stripped.startswith("#"):
            continue
        include = _INCLUDE.match(stripped)
        if include:
            target = include.group(1)
            if not allow_base_include or target != BASE_INCLUDE:
                raise ValueError(f"unsupported Compose include on line {line_number}: {target!r}")
            include_count += 1
            continue
        if not stripped.startswith("<") or ":" not in line:
            continue
        left, right = line.split(":", 1)
        names = _KEY.findall(left)
        if not names:
            continue
        if names[0] != "Multi_key":
            stats["unsupported_lead"] += 1
            continue
        count = len(names) - 1
        if count < 2:
            stats["short_sequence"] += 1
            continue
        if count > 4:
            stats["too_long"] += 1
            continue

        input_values: list[int] = []
        for name in names[1:]:
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
            if (not 1 <= len(output_values) <= 8 or
                    any(not _valid_scalar(value) for value in output_values)):
                stats["invalid_output"] += 1
                continue
            rules[tuple(input_values)] = output_values

    if allow_base_include and include_count != 1:
        raise ValueError(f"expected exactly one en_US Compose include, found {include_count}")
    return rules


def import_compose_sources(base_text: str, locale_text: str, keysym_text: str,
                           locale: str,
                           source_info: dict[str, Any] | None = None) -> dict[str, Any]:
    try:
        locale_bytes = locale.encode("ascii")
    except UnicodeEncodeError as exc:
        raise ValueError("locale tag must contain ASCII characters only") from exc
    if not 1 <= len(locale_bytes) <= 31:
        raise ValueError("locale tag must contain 1–31 ASCII characters")

    keysyms = parse_keysym_definitions(keysym_text)
    stats = {
        "unsupported_input": 0, "invalid_output": 0, "invalid_string": 0,
        "short_sequence": 0, "too_long": 0, "unsupported_lead": 0,
    }
    base_rules = _read_rules(base_text, keysyms, stats, allow_base_include=False)
    locale_rules = _read_rules(locale_text, keysyms, stats, allow_base_include=True)
    merged = dict(base_rules)
    overrides = 0
    for key, value in locale_rules.items():
        if key in merged:
            overrides += 1
        merged[key] = value

    # The runtime resolves a pair immediately. Remove any shorter rule which
    # prefixes a longer one, allowing the longer rule to use bounded buffering.
    dropped_prefixes: set[tuple[int, ...]] = set()
    for key in merged:
        for length in range(2, len(key)):
            prefix = key[:length]
            if prefix in merged:
                dropped_prefixes.add(prefix)
    for prefix in dropped_prefixes:
        del merged[prefix]

    records = [
        {"input": list(key), "output": list(value)}
        for key, value in sorted(merged.items())
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
            "Flatten the en_US include, apply pt_BR Multi_key overrides, retain only "
            "input keysyms mapped to Unicode scalars, and drop shorter sequences that "
            "prefix longer sequences."
        ),
    }
    if source_info:
        metadata.update(source_info)
    return {
        "locale": locale,
        "source": metadata,
        "statistics": {
            "base_rules": len(base_rules),
            "locale_rules": len(locale_rules),
            "locale_overrides": overrides,
            "dropped_shorter_prefix_rules": len(dropped_prefixes),
            "final_rules": len(records),
            "input_sequence_lengths": input_lengths,
            "multi_scalar_outputs": sum(len(record["output"]) > 1 for record in records),
            **stats,
        },
        "sequences": records,
    }


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--base", required=True, type=Path)
    parser.add_argument("--locale-source", required=True, type=Path)
    parser.add_argument("--keysymdef", required=True, type=Path)
    parser.add_argument("--locale", required=True)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args(argv)
    try:
        document = import_compose_sources(
            args.base.read_text(encoding="utf-8"),
            args.locale_source.read_text(encoding="utf-8"),
            args.keysymdef.read_text(encoding="utf-8"),
            args.locale,
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
        f"{stats['dropped_shorter_prefix_rules']} shorter prefixes dropped)"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
