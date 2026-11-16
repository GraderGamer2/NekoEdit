#!/usr/bin/env python3
"""Run paired NekoEdit glyph-draw benchmarks and compare output checksums."""

from __future__ import annotations

import re
import subprocess
import sys
import tempfile
from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class Result:
    label: str
    output: str
    cold_ns: float
    fill_ns: float
    warm_ns: float
    fill_checksum: str
    checksum: str


def run(label: str, executable: str) -> Result:
    completed = subprocess.run(
        [executable],
        check=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
    )
    output = completed.stdout
    cold = re.search(
        r"cold rasterization: .*?median ([0-9.]+) ns/iteration", output
    )
    fill = re.search(
        r"cold 128-glyph cache fill and draw: .*?median ([0-9.]+) ns/iteration",
        output,
    )
    warm = re.search(
        r"warm 128-glyph cache draw: .*?median ([0-9.]+) ns/iteration",
        output,
    )
    fill_checksum = re.search(r"cache fill framebuffer checksum: ([0-9]+)", output)
    checksum = re.search(r"^framebuffer checksum: ([0-9]+)$", output, re.MULTILINE)
    if not cold or not fill or not warm or not fill_checksum or not checksum:
        raise RuntimeError(f"{label}: benchmark output is missing a required metric")
    if "cache correctness:" not in output:
        raise RuntimeError(f"{label}: cache correctness checks did not report success")
    return Result(
        label=label,
        output=output,
        cold_ns=float(cold.group(1)),
        fill_ns=float(fill.group(1)),
        warm_ns=float(warm.group(1)),
        fill_checksum=fill_checksum.group(1),
        checksum=checksum.group(1),
    )


def reduction(before: float, after: float) -> str:
    if before <= 0:
        return "n/a"
    return f"{(before - after) * 100.0 / before:.1f}%"


def main() -> int:
    if len(sys.argv) != 7:
        print(
            "usage: compare_rasterizer_bench.py LINEAR HASH_GENERIC "
            "HASH_IDENTITY_REFERENCE HASH_OPAQUE_STORAGE_REFERENCE "
            "HASH_COMPACT_AOS HASH_COMPACT_SOA",
            file=sys.stderr,
        )
        return 2

    labels = (
        ("point-in-contour: linear LRU + generic transform + reference blend/storage", sys.argv[1]),
        ("point-in-contour: hash cache + generic transform + reference blend/storage", sys.argv[2]),
        ("point-in-contour: hash cache + identity path + reference blend/storage", sys.argv[3]),
        ("point-in-contour: hash cache + identity + opaque blend + legacy mask storage", sys.argv[4]),
        ("point-in-contour: hash cache + identity + opaque blend + compact mask + AoS metadata", sys.argv[5]),
        ("active-edge scanline: hash cache + identity + opaque blend + compact mask + SoA metadata", sys.argv[6]),
    )
    results = [run(label, executable) for label, executable in labels]
    checksums = {result.checksum for result in results}
    fill_checksums = {result.fill_checksum for result in results}
    if len(checksums) != 1 or len(fill_checksums) != 1:
        for result in results:
            print(f"--- {result.label} ---\n{result.output}", file=sys.stderr)
        # Dump the cache-fill framebuffer from each variant so a checksum
        # mismatch can be localized to exact pixel coordinates and values.
        with tempfile.TemporaryDirectory(prefix="nekoedit-raster-diff-") as temp_dir:
            dump_paths = []
            for index, (_, executable) in enumerate(labels):
                dump_path = Path(temp_dir) / f"variant-{index}.rgba"
                subprocess.run(
                    [executable, "--dump-cache-fill", str(dump_path)],
                    check=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True,
                )
                dump_paths.append(dump_path)
            baseline = dump_paths[0].read_bytes()
            print("=== cache-fill framebuffer differences vs. first variant ===", file=sys.stderr)
            for index, dump_path in enumerate(dump_paths[1:], start=1):
                candidate = dump_path.read_bytes()
                differences = [
                    (offset // 4, int.from_bytes(baseline[offset:offset+4], "little"),
                     int.from_bytes(candidate[offset:offset+4], "little"))
                    for offset in range(0, min(len(baseline), len(candidate)), 4)
                    if baseline[offset:offset+4] != candidate[offset:offset+4]
                ]
                print(
                    f"{labels[index][0]}: bytes={len(candidate)}, differing_pixels={len(differences)}, "
                    f"first={differences[:16]}",
                    file=sys.stderr,
                )
                if len(candidate) != len(baseline):
                    print(f"  size mismatch: reference={len(baseline)}", file=sys.stderr)
        print("error: benchmark variants produced different framebuffers", file=sys.stderr)
        return 1

    for result in results:
        print(f"=== {result.label} ===")
        print(result.output, end="" if result.output.endswith("\n") else "\n")

    (
        linear, hash_generic, hash_identity_reference, opaque_legacy_storage,
        compact_aos_metadata, compact_soa_metadata,
    ) = results
    print("=== paired median comparison ===")
    print(
        "warm draw: linear -> hash cache: "
        f"{reduction(linear.warm_ns, hash_generic.warm_ns)} lower"
    )
    print(
        "warm draw: generic -> identity fast path: "
        f"{reduction(hash_generic.warm_ns, hash_identity_reference.warm_ns)} lower"
    )
    print(
        "warm draw: identity reference -> opaque-pixel fast path: "
        f"{reduction(hash_identity_reference.warm_ns, opaque_legacy_storage.warm_ns)} lower"
    )
    print(
        "warm draw: opaque blend/legacy storage -> compact SoA renderer: "
        f"{reduction(opaque_legacy_storage.warm_ns, compact_soa_metadata.warm_ns)} lower"
    )
    print(
        "warm draw: compact AoS -> compact SoA metadata: "
        f"{reduction(compact_aos_metadata.warm_ns, compact_soa_metadata.warm_ns)} lower"
    )
    print(
        "warm draw: linear -> current renderer: "
        f"{reduction(linear.warm_ns, compact_soa_metadata.warm_ns)} lower"
    )
    print(
        "cold rasterization: point-in-contour -> active-edge scanline: "
        f"{reduction(opaque_legacy_storage.cold_ns, compact_soa_metadata.cold_ns)} lower"
    )
    print(
        "cold cache fill: point-in-contour + legacy storage -> scanline + compact storage: "
        f"{reduction(opaque_legacy_storage.fill_ns, compact_soa_metadata.fill_ns)} lower"
    )
    print(f"identical cache-fill checksum: {linear.fill_checksum}")
    print(f"identical warm framebuffer checksum: {linear.checksum}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
