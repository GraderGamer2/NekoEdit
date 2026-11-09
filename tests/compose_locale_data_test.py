#!/usr/bin/env python3
"""Validate the committed typed Compose locale tables and NLP1 encodings."""
from __future__ import annotations

import json
import struct
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
from compose_pack import HEADER_SIZE, MAGIC, RECORD_SIZE, VERSION, encode_pack  # noqa: E402


def load(tag: str):
    document = json.loads(
        (ROOT / "data/locales" / f"{tag}.json").read_text(encoding="utf-8")
    )
    mapping = {
        (record.get("kind", "multi_key"), tuple(record["input"])): tuple(record["output"])
        for record in document["sequences"]
    }
    if document["locale"] != tag:
        raise AssertionError(f"{tag}: wrong locale label")
    if document["source"]["locale_compose_blob"] == document["source"]["base_compose_blob"]:
        raise AssertionError(f"{tag}: locale source incorrectly points at en_US")
    packed = encode_pack(document)
    header = struct.unpack("<8s7I32sI", packed[:HEADER_SIZE])
    if (
        header[0] != MAGIC or header[1] != VERSION
        or header[2] != HEADER_SIZE or header[3] != RECORD_SIZE
        or header[4] != document["statistics"]["final_rules"]
        or len(packed) != HEADER_SIZE + header[4] * RECORD_SIZE
        or header[8].split(bytes(1), 1)[0].decode("ascii") != tag
    ):
        raise AssertionError(f"{tag}: malformed NLP1 pack output")
    return document, mapping


def expect(mapping, kind: str, key: tuple[int, ...], value: tuple[int, ...], tag: str):
    actual = mapping.get((kind, key))
    if actual != value:
        raise AssertionError(f"{tag} {kind} mapping changed: {key!r} -> {actual!r}")


def main() -> None:
    pt, pt_map = load("pt_BR.UTF-8")
    pt_stats = pt["statistics"]
    if (
        pt_stats["final_rules"] != 4136
        or pt_stats["input_sequence_lengths"] != {"2": 3448, "3": 582, "4": 106}
        or pt_stats["base_dead_key_rules"] != 1228
        or pt_stats["locale_dead_key_rules"] != 2
    ):
        raise AssertionError("pt_BR typed rule count or input-depth distribution changed")
    if (
        pt_stats["locale_overrides"] != 5
        or pt_stats["dead_key_overrides"] != 2
        or pt_stats["multi_scalar_outputs"] != 246
    ):
        raise AssertionError("pt_BR override or multi-scalar count changed")
    pt_expected = {
        (ord("e"), ord("e")): (0x018F,),
        (ord('"'), ord("\\")): (0x301D,),
        (ord('"'), ord("/")): (0x301E,),
        (ord(","), ord("E")): (0x0228,),
        (ord(","), ord("e")): (0x0229,),
        (ord("U"), ord(","), ord("E")): (0x1E1C,),
        (ord("U"), ord(","), ord("e")): (0x1E1D,),
    }
    for key, value in pt_expected.items():
        expect(pt_map, "multi_key", key, value, "pt_BR")
    if ("multi_key", (ord("U"), ord(","))) in pt_map:
        raise AssertionError("pt_BR ambiguous shorter U-comma prefix should be omitted")
    expect(pt_map, "dead_key", (0x0301, ord("c")), (0x00E7,), "pt_BR")
    expect(pt_map, "dead_key", (0x0301, ord("C")), (0x00C7,), "pt_BR")

    fi, fi_map = load("fi_FI.UTF-8")
    fi_stats = fi["statistics"]
    if (
        fi_stats["final_rules"] != 4132 or fi_stats["locale_rules"] != 6
        or fi_stats["locale_dead_key_rules"] != 278
        or fi_stats["dead_key_overrides"] != 278
    ):
        raise AssertionError("fi_FI typed rule counts changed")
    if (
        fi_stats["locale_overrides"] != 283
        or fi_stats["input_sequence_lengths"] != {"2": 3445, "3": 581, "4": 106}
        or fi_stats["multi_scalar_outputs"] != 246
    ):
        raise AssertionError("fi_FI override or sequence-depth counts changed")
    fi_expected = {
        (ord("f"), ord("i")): (0xFB01,),
        (ord("f"), ord("l")): (0xFB02,),
        (ord("i"), ord("j")): (0x0133,),
        (ord("I"), ord("J")): (0x0132,),
        (ord("f"), ord("s")): (0x017F,),
        (ord("'"), ord(" "), ord("n")): (0x0149,),
    }
    for key, value in fi_expected.items():
        expect(fi_map, "multi_key", key, value, "fi_FI")
    expect(fi_map, "dead_key", (0x0301, ord("a")), (0x00E1,), "fi_FI")
    expect(fi_map, "dead_key", (0x0301, 0x043A), (0x045C,), "fi_FI")

    sr, sr_map = load("sr_RS.UTF-8")
    sr_stats = sr["statistics"]
    if (
        sr_stats["final_rules"] != 4147 or sr_stats["locale_rules"] != 40
        or sr_stats["locale_dead_key_rules"] != 50
        or sr_stats["dead_key_overrides"] != 38
    ):
        raise AssertionError("sr_RS typed rule counts changed")
    if (
        sr_stats["locale_overrides"] != 74
        or sr_stats["input_sequence_lengths"] != {"2": 3461, "3": 580, "4": 106}
        or sr_stats["multi_scalar_outputs"] != 278
    ):
        raise AssertionError("sr_RS override, sequence-depth, or multi-scalar counts changed")
    sr_expected = {
        (0x0060, 0x0430): (0x0430, 0x0300),
        (0x00B4, 0x0410): (0x0410, 0x0301),
        (0x0027, 0x0435): (0x0435, 0x0301),
        (0x005E, 0x0438): (0x0438, 0x0302),
    }
    for key, value in sr_expected.items():
        expect(sr_map, "multi_key", key, value, "sr_RS")
    expect(sr_map, "dead_key", (0x0300, 0x0430), (0x0430, 0x0300), "sr_RS")
    expect(sr_map, "dead_key", (0x0301, 0x043A), (0x045C,), "sr_RS")

    print("pt_BR, fi_FI, and sr_RS typed locale tables and NLP1 encodings passed")


if __name__ == "__main__":
    main()
