#!/usr/bin/env python3
"""Build validated, data-only NekoEdit Compose locale packs (NLP1)."""
from __future__ import annotations
import argparse
import json
import os
import struct
import sys
import zlib
from pathlib import Path
from typing import Any

MAGIC = b"NEKOLOC1"
VERSION = 1
HEADER_SIZE = 72
RECORD_SIZE = 52
MAX_RECORDS = 32768
MAX_PACK_SIZE = 2 * 1024 * 1024
MAX_INPUTS = 4
MAX_OUTPUTS = 8
RULE_KINDS = {"multi_key": 0, "dead_key": 1}


def scalar(value: Any, field: str) -> int:
    if isinstance(value, str):
        token = value.strip()
        if token.upper().startswith("U+"):
            token = token[2:]
        try:
            result = int(token, 16)
        except ValueError as exc:
            raise ValueError(f"{field}: invalid scalar {value!r}") from exc
    elif isinstance(value, int) and not isinstance(value, bool):
        result = value
    else:
        raise ValueError(f"{field}: expected integer or U+ hexadecimal string")
    if result <= 0 or result > 0x10FFFF or 0xD800 <= result <= 0xDFFF:
        raise ValueError(f"{field}: U+{result:04X} is not a Unicode scalar")
    return result


def locale_tag(value: Any) -> str:
    if not isinstance(value, str):
        raise ValueError("locale must be a string")
    try:
        value.encode("ascii")
    except UnicodeEncodeError as exc:
        raise ValueError("locale must be ASCII") from exc
    allowed = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_.@-"
    if not 1 <= len(value) <= 31 or value[0] == "." or value[-1] == ".":
        raise ValueError("locale tag must contain 1–31 safe ASCII characters")
    for i, char in enumerate(value):
        if char not in allowed or (char == "." and value[i:i + 2] == ".."):
            raise ValueError(f"unsafe locale-tag character: {char!r}")
    if value in {"en_US", "en_US.UTF-8", "C", "POSIX"}:
        raise ValueError("built-in en_US does not need an optional pack")
    return value


def normalize(document: Any):
    if not isinstance(document, dict):
        raise ValueError("JSON root must be an object")
    tag = locale_tag(document.get("locale"))
    entries = document.get("sequences")
    if not isinstance(entries, list) or not 1 <= len(entries) <= MAX_RECORDS:
        raise ValueError(f"sequences must contain 1–{MAX_RECORDS} records")
    records = []
    seen = set()
    for i, entry in enumerate(entries):
        if not isinstance(entry, dict):
            raise ValueError(f"sequences[{i}] must be an object")
        kind_name = entry.get("kind", "multi_key")
        if not isinstance(kind_name, str) or kind_name not in RULE_KINDS:
            raise ValueError(f"sequences[{i}].kind must be 'multi_key' or 'dead_key'")
        kind = RULE_KINDS[kind_name]
        inputs, outputs = entry.get("input"), entry.get("output")
        if not isinstance(inputs, list) or not 2 <= len(inputs) <= MAX_INPUTS:
            raise ValueError(f"sequences[{i}].input must contain 2–4 scalars")
        if not isinstance(outputs, list) or not 1 <= len(outputs) <= MAX_OUTPUTS:
            raise ValueError(f"sequences[{i}].output must contain 1–8 scalars")
        key = tuple(scalar(value, f"sequences[{i}].input") for value in inputs)
        result = tuple(scalar(value, f"sequences[{i}].output") for value in outputs)
        identity = (kind, key)
        if identity in seen:
            raise ValueError(f"duplicate {kind_name} input sequence {key!r}")
        seen.add(identity)
        records.append((kind, key, result))
    records.sort(key=lambda record: (record[0], record[1]))
    for previous, current in zip(records, records[1:]):
        previous_kind, previous_key, _ = previous
        current_kind, current_key, _ = current
        if previous_kind == current_kind:
            shared = min(len(previous_key), len(current_key))
            if previous_key[:shared] == current_key[:shared]:
                kind_name = "multi_key" if current_kind == 0 else "dead_key"
                raise ValueError(
                    f"prefix-ambiguous {kind_name} input sequences: "
                    f"{previous_key!r}, {current_key!r}"
                )
    return tag, records


def encode_pack(document: Any) -> bytes:
    tag, records = normalize(document)
    payload = bytearray()
    for kind, inputs, outputs in records:
        padded_inputs = inputs + (0,) * (MAX_INPUTS - len(inputs))
        padded_outputs = outputs + (0,) * (MAX_OUTPUTS - len(outputs))
        # The old 16-bit reserved field is now: low byte kind, high byte zero.
        payload.extend(struct.pack(
            "<BBH4I8I", len(inputs), len(outputs), kind,
            *padded_inputs, *padded_outputs
        ))
    if HEADER_SIZE + len(payload) > MAX_PACK_SIZE:
        raise ValueError("encoded pack exceeds 2 MiB")
    tag_bytes = tag.encode("ascii")
    tag_field = tag_bytes + bytes(32 - len(tag_bytes))
    header = struct.pack(
        "<8s7I32sI", MAGIC, VERSION, HEADER_SIZE, RECORD_SIZE,
        len(records), len(payload), zlib.crc32(payload) & 0xFFFFFFFF,
        0, tag_field, 0
    )
    return header + payload


def main(argv=None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="command", required=True)
    build = sub.add_parser("build", help="build a .nlp locale pack")
    build.add_argument("--input", required=True, type=Path)
    build.add_argument("--output", required=True, type=Path)
    args = parser.parse_args(argv)
    try:
        document = json.loads(args.input.read_text(encoding="utf-8"))
        packed = encode_pack(document)
        args.output.parent.mkdir(parents=True, exist_ok=True)
        temporary = args.output.with_name(args.output.name + ".tmp")
        try:
            temporary.write_bytes(packed)
            os.replace(temporary, args.output)
        finally:
            try:
                temporary.unlink()
            except FileNotFoundError:
                pass
    except (OSError, json.JSONDecodeError, ValueError) as exc:
        print(f"compose_pack.py: {exc}", file=sys.stderr)
        return 1
    print(
        f"wrote {len(packed)} bytes for {document['locale']} "
        f"({len(document['sequences'])} rules)"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
