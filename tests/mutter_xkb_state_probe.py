#!/usr/bin/env python3
"""Read-only diagnostics for the XKB map and Compose state in a live NekoEdit process.

The Mutter smoke-test shell opens /proc/<pid>/mem as the target process's
ancestor and passes that already-authorized descriptor to this helper. The
helper adds no debug interface or runtime dependency to NekoEdit.
"""
from __future__ import annotations

import argparse
import json
import os
import re
import struct
import subprocess
import sys
import time
from typing import Any

WORD_SYMBOLS = (
    "keymap_format",
    "keymap_size",
    "keymap_processing_complete",
    "keyboard_group",
    "keyboard_focused",
    "last_object",
    "last_opcode",
    "last_size",
    "doc_length",
    "doc_pending_dead_mark",
    "doc_compose_active",
    "doc_compose_first",
    "doc_compose_second",
    "doc_compose_third",
    "doc_compose_fourth",
)
POINTER_SYMBOLS = ("keymap_mapping",)
BUFFER_SYMBOLS = ("event_payload", "xkb_unicode_levels")
ACTIONS = {
    0x00110007: "Multi_key",
    0x00110001: "dead_grave",
    0x00110003: "dead_circumflex",
}
XKB_TABLE_BYTES = 256 * 4 * 8 * 4
MAX_KEYMAP_BYTES = 1024 * 1024


def parse_symbols(binary: str) -> dict[str, int]:
    result = subprocess.run(
        ["nm", "-n", "--defined-only", binary],
        check=True,
        capture_output=True,
        text=True,
    )
    wanted = set(WORD_SYMBOLS) | set(POINTER_SYMBOLS) | set(BUFFER_SYMBOLS)
    addresses: dict[str, int] = {}
    for line in result.stdout.splitlines():
        fields = line.split()
        if len(fields) >= 3 and re.fullmatch(r"[0-9a-fA-F]+", fields[0]):
            name = fields[-1]
            if name in wanted:
                addresses[name] = int(fields[0], 16)
    missing = sorted(wanted - addresses.keys())
    if missing:
        raise RuntimeError("missing probe symbols in ELF: " + ", ".join(missing))
    return addresses


def read_exact(memory_fd: int, size: int, address: int, label: str) -> bytes:
    raw = os.pread(memory_fd, size, address)
    if len(raw) != size:
        raise RuntimeError(
            f"short process-memory read for {label}: expected {size}, got {len(raw)}"
        )
    return raw


def snapshot(memory_fd: int, addresses: dict[str, int]) -> dict[str, Any]:
    values = {
        name: struct.unpack("<I", read_exact(memory_fd, 4, addresses[name], name))[0]
        for name in WORD_SYMBOLS
    }
    mapping = struct.unpack(
        "<Q", read_exact(memory_fd, 8, addresses["keymap_mapping"], "keymap_mapping")
    )[0]
    table = read_exact(
        memory_fd,
        XKB_TABLE_BYTES,
        addresses["xkb_unicode_levels"],
        "xkb_unicode_levels",
    )
    entries = struct.unpack("<" + "I" * (XKB_TABLE_BYTES // 4), table)
    action_positions: dict[str, list[dict[str, int]]] = {}
    for keysym, name in ACTIONS.items():
        found: list[dict[str, int]] = []
        for index, value in enumerate(entries):
            if value == keysym:
                keycode, subindex = divmod(index, 32)
                group, level = divmod(subindex, 8)
                found.append({"xkb_keycode": keycode, "group": group, "level": level})
        action_positions[name] = found

    keymap_size = values["keymap_size"]
    raw_map = b""
    if mapping and 0 < keymap_size <= MAX_KEYMAP_BYTES:
        raw_map = read_exact(
            memory_fd, min(keymap_size, MAX_KEYMAP_BYTES), mapping, "keymap_mapping"
        )

    event_payload = read_exact(
        memory_fd, 16, addresses["event_payload"], "event_payload"
    )
    event_words = list(struct.unpack("<4I", event_payload))
    event_evdev = event_words[2]
    event_xkb = event_evdev + 8 if event_evdev else 0
    group = values["keyboard_group"]
    event_levels: list[int] = []
    if event_evdev and event_xkb < 256 and group < 4:
        base = event_xkb * 32 + group * 8
        event_levels = list(entries[base:base + 8])

    return {
        **values,
        "keymap_mapping_nonnull": bool(mapping),
        "keymap_header": raw_map[:10].decode("ascii", errors="replace"),
        "keymap_contains_compose_names": {
            name: (name.encode("ascii") in raw_map)
            for name in ("Multi_key", "dead_grave", "dead_circumflex")
        },
        "action_positions": action_positions,
        "last_event": {
            "object": values["last_object"],
            "opcode": values["last_opcode"],
            "payload_size": values["last_size"],
            "serial": event_words[0],
            "time_ms": event_words[1],
            "evdev_keycode": event_evdev,
            "xkb_keycode": event_xkb,
            "state": event_words[3],
            "current_group_symbols": event_levels,
        },
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("binary", help="unstripped NekoEdit ELF used by the smoke test")
    parser.add_argument("memory_fd", type=int, help="inherited /proc/<pid>/mem descriptor")
    parser.add_argument("--wait-field", help="wait until a returned numeric field matches")
    parser.add_argument("--equals", type=lambda value: int(value, 0), default=None)
    parser.add_argument("--nonzero", action="store_true")
    parser.add_argument("--timeout", type=float, default=3.0)
    parser.add_argument("--assert-keymap", action="store_true")
    args = parser.parse_args()

    try:
        os.fstat(args.memory_fd)
        addresses = parse_symbols(args.binary)
        deadline = time.monotonic() + max(0.0, args.timeout)
        state = snapshot(args.memory_fd, addresses)
        while args.wait_field:
            if args.wait_field not in state:
                raise RuntimeError(f"unknown wait field: {args.wait_field}")
            value = state[args.wait_field]
            matched = (
                value != 0
                if args.nonzero
                else args.equals is not None and value == args.equals
            )
            if matched:
                break
            if time.monotonic() >= deadline:
                raise RuntimeError(
                    f"timed out waiting for {args.wait_field}; last state: "
                    + json.dumps(state, sort_keys=True)
                )
            time.sleep(0.02)
            state = snapshot(args.memory_fd, addresses)

        if args.assert_keymap:
            missing_actions = [
                name
                for name, positions in state["action_positions"].items()
                if not positions
            ]
            if (
                state["keymap_processing_complete"] != 1
                or state["keymap_format"] != 1
                or missing_actions
            ):
                raise RuntimeError(
                    "Mutter-delivered XKB map was not parsed with required actions; "
                    + json.dumps(state, sort_keys=True)
                )

        print(json.dumps(state, sort_keys=True))
        return 0
    except (OSError, RuntimeError, subprocess.CalledProcessError) as error:
        print(f"Mutter XKB state probe failed: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
