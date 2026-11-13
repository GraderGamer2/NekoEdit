#!/usr/bin/env python3
"""Run paired NekoEdit glyph-draw benchmarks and compare output checksums."""

from __future__ import annotations

import re
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class Result:
    label: str
    output: str
    cold_ns: float
    warm_ns: float
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
    warm = re.search(
        r"warm 128-glyph cache draw: .*?median ([0-9.]+) ns/iteration",
        output,
    )
    checksum = re.search(r"framebuffer checksum: ([0-9]+)", output)
    if not cold or not warm or not checksum:
        raise RuntimeError(f"{label}: benchmark output is missing a required metric")
    if "cache correctness:" not in output:
        raise RuntimeError(f"{label}: cache correctness checks did not report success")
    return Result(
        label=label,
        output=output,
        cold_ns=float(cold.group(1)),
        warm_ns=float(warm.group(1)),
        checksum=checksum.group(1),
    )


def reduction(before: float, after: float) -> str:
    if before <= 0:
        return "n/a"
    return f"{(before - after) * 100.0 / before:.1f}%"


def main() -> int:
    if len(sys.argv) != 4:
        print(
            "usage: compare_rasterizer_bench.py LINEAR HASH_GENERIC HASH_FAST",
            file=sys.stderr,
        )
        return 2

    labels = (
        ("linear LRU + generic transform", sys.argv[1]),
        ("hash cache + generic transform", sys.argv[2]),
        ("hash cache + identity fast path", sys.argv[3]),
    )
    results = [run(label, executable) for label, executable in labels]
    checksums = {result.checksum for result in results}
    if len(checksums) != 1:
        for result in results:
            print(f"--- {result.label} ---\n{result.output}", file=sys.stderr)
        print("error: benchmark variants produced different framebuffers", file=sys.stderr)
        return 1

    for result in results:
        print(f"=== {result.label} ===")
        print(result.output, end="" if result.output.endswith("\n") else "\n")

    linear, hash_generic, hash_fast = results
    print("=== paired median comparison ===")
    print(
        "warm draw: linear -> hash cache: "
        f"{reduction(linear.warm_ns, hash_generic.warm_ns)} lower"
    )
    print(
        "warm draw: generic -> identity fast path: "
        f"{reduction(hash_generic.warm_ns, hash_fast.warm_ns)} lower"
    )
    print(
        "warm draw: linear -> current renderer: "
        f"{reduction(linear.warm_ns, hash_fast.warm_ns)} lower"
    )
    print(
        "cold rasterization: linear -> current renderer: "
        f"{reduction(linear.cold_ns, hash_fast.cold_ns)} lower"
    )
    print(f"identical framebuffer checksum: {linear.checksum}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
