#!/usr/bin/env python3
"""Validate the committed pt_BR dataset and its NLP1 encoding."""
from __future__ import annotations

import json
import struct
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
from compose_pack import HEADER_SIZE, MAGIC, RECORD_SIZE, VERSION, encode_pack  # noqa: E402


def main() -> None:
    document = json.loads(
        (ROOT / "data/locales/pt_BR.UTF-8.json").read_text(encoding="utf-8")
    )
    stats = document["statistics"]
    if document["locale"] != "pt_BR.UTF-8":
        raise AssertionError("unexpected locale tag")
    if stats["final_rules"] != 2908 or len(document["sequences"]) != 2908:
        raise AssertionError("pt_BR rule count changed; re-import and review upstream differences")
    if stats["input_sequence_lengths"] != {"2": 2220, "3": 582, "4": 106}:
        raise AssertionError("pt_BR sequence-length distribution changed")
    if stats["multi_scalar_outputs"] != 100 or stats["dropped_shorter_prefix_rules"] != 1:
        raise AssertionError("pt_BR multi-output/prefix policy changed")

    mapping = {
        tuple(record["input"]): tuple(record["output"])
        for record in document["sequences"]
    }
    expected = {
        (ord("e"), ord("e")): (0x018F,),
        (ord('"'), ord("\\")): (0x301D,),
        (ord('"'), ord("/")): (0x301E,),
        (ord(","), ord("E")): (0x0228,),
        (ord(","), ord("e")): (0x0229,),
        (ord("U"), ord(","), ord("E")): (0x1E1C,),
        (ord("U"), ord(","), ord("e")): (0x1E1D,),
        (0x00B4, 0x03D2): (0x03D3,),
        (ord("'"), 0x03D2): (0x03D3,),
    }
    for key, result in expected.items():
        if mapping.get(key) != result:
            raise AssertionError(f"pt_BR mapping changed: {key!r} -> {mapping.get(key)!r}")
    if (ord("U"), ord(",")) in mapping:
        raise AssertionError("ambiguous shorter U-comma prefix should be omitted")

    packed = encode_pack(document)
    header = struct.unpack("<8s7I32sI", packed[:HEADER_SIZE])
    if (
        header[0] != MAGIC or header[1] != VERSION
        or header[2] != HEADER_SIZE or header[3] != RECORD_SIZE
        or header[4] != 2908 or len(packed) != HEADER_SIZE + 2908 * RECORD_SIZE
        or header[8].split(bytes(1), 1)[0] != b"pt_BR.UTF-8"
    ):
        raise AssertionError("generated pt_BR NLP1 header is incorrect")
    print(f"pt_BR locale data validated: {len(packed)} byte NLP1 pack")


if __name__ == "__main__":
    main()
