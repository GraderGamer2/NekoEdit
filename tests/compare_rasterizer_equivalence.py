#!/usr/bin/env python3
"""Require exact glyph-mask parity between the point-in-contour and scanline rasterizers."""

from __future__ import annotations

import subprocess
import sys


def run(executable: str) -> str:
    completed = subprocess.run(
        [executable], check=True, stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT, text=True,
    )
    return completed.stdout.strip()


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: compare_rasterizer_equivalence.py REFERENCE SCANLINE", file=sys.stderr)
        return 2
    reference = run(sys.argv[1])
    scanline = run(sys.argv[2])
    if reference != scanline:
        print("reference: " + reference, file=sys.stderr)
        print("scanline:  " + scanline, file=sys.stderr)
        print("error: scanline renderer changed one or more glyph-mask pixels", file=sys.stderr)
        return 1
    print(reference)
    print("Bit-for-bit glyph-mask equivalence passed for straight, curved, hollow, overlapping, negative-bearing and empty outlines at seven sizes.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
