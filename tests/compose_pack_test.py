#!/usr/bin/env python3
"""Unit tests for the typed NLP1 Compose locale-pack generator."""
from __future__ import annotations
import struct
import sys
import zlib
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tools"))
from compose_pack import HEADER_SIZE, MAGIC, RECORD_SIZE, VERSION, encode_pack  # noqa: E402


def rejected(document, reason):
    try:
        encode_pack(document)
    except ValueError:
        return
    raise AssertionError("accepted invalid pack input: " + reason)


def main():
    shared_input = ["U+0301", "U+0063"]
    document = {"locale": "fr_FR.UTF-8", "sequences": [
        {"kind": "multi_key", "input": ["U+006F", "U+0069"],
         "output": ["U+2603", "U+FE0F"]},
        {"kind": "multi_key", "input": ["U+0079", "U+0075", "U+0069"],
         "output": ["U+2605"]},
        {"kind": "multi_key", "input": ["U+0077", "U+0065", "U+0072", "U+0074"],
         "output": ["U+1F642"]},
        {"kind": "multi_key", "input": shared_input, "output": ["U+0023"]},
        {"kind": "dead_key", "input": shared_input, "output": ["U+00E7"]},
    ]}
    packed = encode_pack(document)
    header = struct.unpack("<8s7I32sI", packed[:HEADER_SIZE])
    if (
        header[0] != MAGIC or header[1] != VERSION or header[2] != HEADER_SIZE
        or header[3] != RECORD_SIZE or header[4] != 5
        or header[5] != 5 * RECORD_SIZE
        or header[6] != (zlib.crc32(packed[HEADER_SIZE:]) & 0xFFFFFFFF)
        or header[7] != 0 or header[8].split(bytes(1), 1)[0] != b"fr_FR.UTF-8"
        or header[9] != 0 or len(packed) != HEADER_SIZE + header[5]
    ):
        raise AssertionError("NLP1 header or payload mismatch")
    records = [
        struct.unpack_from("<BBH4I8I", packed, HEADER_SIZE + i * RECORD_SIZE)
        for i in range(5)
    ]
    keys = [(record[2], record[3:3 + record[0]]) for record in records]
    if keys != sorted(keys) or [record[2] for record in records] != [0, 0, 0, 0, 1]:
        raise AssertionError("records were not sorted by kind and input sequence")
    if records[0][3:5] != (0x006F, 0x0069) or records[0][7:9] != (0x2603, 0xFE0F):
        raise AssertionError("legacy Multi_key record layout changed")
    if records[-1][3:5] != (0x0301, ord("c")) or records[-1][7] != 0x00E7:
        raise AssertionError("dead-key record encoding or output mismatch")

    # Equal scalar inputs in different namespaces are legal.
    if records[-1][2] == records[-2][2]:
        raise AssertionError("dead-key record was not isolated from Multi_key")
    rejected({"locale": "fr_FR", "sequences": [
        {"kind": "multi_key", "input": [97, 98], "output": [65]},
        {"kind": "multi_key", "input": [97, 98, 99], "output": [66]},
    ]}, "same-kind prefix ambiguity")
    rejected({"locale": "fr_FR", "sequences": [
        {"kind": "dead_key", "input": [97, 98], "output": [65]},
        {"kind": "dead_key", "input": [97, 98], "output": [66]},
    ]}, "same-kind duplicate")
    rejected({"locale": "fr_FR", "sequences": [
        {"kind": "unexpected", "input": [97, 98], "output": [65]},
    ]}, "unknown record kind")
    rejected({"locale": "fr_FR", "sequences": [
        {"input": [0xD800, 98], "output": [65]},
    ]}, "surrogate")
    rejected({"locale": "../escape", "sequences": [
        {"input": [97, 98], "output": [65]},
    ]}, "path traversal")
    rejected({"locale": "fr_FR", "sequences": [
        {"input": [97, 98], "output": [65] * 9},
    ]}, "output too long")
    rejected({"locale": "en_US.UTF-8", "sequences": [
        {"input": [97, 98], "output": [65]},
    ]}, "built-in locale")
    print("NLP1 typed locale-pack generator tests passed")


if __name__ == "__main__":
    main()
