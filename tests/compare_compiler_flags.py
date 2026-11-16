#!/usr/bin/env python3
"""Compare NekoEdit build profiles using stripped ELF size and rasterizer timings.

The application is mostly handwritten x86-64 assembly. Compiler flags therefore
affect only the freestanding C modules; the deterministic rasterizer benchmark
isolates the principal C rendering hot path and checks framebuffer equivalence.
"""

from __future__ import annotations

import os
import re
import shlex
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Sequence

ROOT = Path(__file__).resolve().parents[1]
SWEEP_ROOT = ROOT / "build" / "compiler-sweep"

@dataclass(frozen=True)
class Variant:
    name: str
    optimization_flags: tuple[str, ...]
    link_time_optimization: bool = False
    benchmark_gate: str | None = None

@dataclass(frozen=True)
class Result:
    variant: Variant
    app_bytes_before_strip: int
    app_bytes_after_strip: int
    text_bytes: int
    data_bytes: int
    bss_bytes: int
    cold_ns: float | None
    fill_ns: float | None
    warm_ns: float | None
    fill_checksum: str | None
    framebuffer_checksum: str | None
    status: str

VARIANTS = (
    Variant("Os", ("-Os",)),
    Variant("O2", ("-O2",)),
    Variant("O3", ("-O3",)),
    Variant("O2-znver3-tune", ("-O2", "-mtune=znver3")),
    Variant("O3-x86-64-v3", ("-O3", "-march=x86-64-v3", "-mtune=znver3"), benchmark_gate="x86-64-v3"),
    Variant("O3-znver3", ("-O3", "-march=znver3"), benchmark_gate="znver3"),
    Variant("O2-LTO", ("-O2", "-flto"), link_time_optimization=True),
    Variant("O2-LTO-znver3", ("-O2", "-flto", "-march=znver3"), link_time_optimization=True, benchmark_gate="znver3"),
    Variant("O3-LTO", ("-O3", "-flto"), link_time_optimization=True),
)

def run_checked(command: Sequence[str], *, cwd: Path = ROOT,
                timeout: int = 240) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        list(command), cwd=cwd, check=True, text=True,
        stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=timeout
    )

def cpu_details() -> tuple[str, str, set[str]]:
    vendor = "unknown"
    model = "unknown"
    flags: set[str] = set()
    try:
        cpu_text = Path("/proc/cpuinfo").read_text(encoding="utf-8", errors="replace")
        for line in cpu_text.splitlines():
            if line.startswith("vendor_id") and vendor == "unknown":
                vendor = line.split(":", 1)[1].strip()
            elif line.startswith("model name") and model == "unknown":
                model = line.split(":", 1)[1].strip()
            elif line.startswith("flags") and not flags:
                flags = set(line.split(":", 1)[1].split())
    except OSError:
        pass
    return vendor, model, flags

def benchmark_allowed(gate: str | None, vendor: str, flags: set[str]) -> bool:
    if gate is None:
        return True
    # Linux exposes AVX only when the OS has enabled the required XSAVE state;
    # OSXSAVE itself is a CPUID feature bit, not a dependable /proc/cpuinfo flag.
    v3 = {"avx", "avx2", "bmi1", "bmi2", "f16c", "fma", "lzcnt", "movbe", "popcnt", "xsave"}
    if not v3.issubset(flags):
        return False
    if gate == "x86-64-v3":
        return True
    if gate == "znver3":
        znver3 = v3 | {"clzero", "mwaitx", "rdpru", "sse4a"}
        return vendor == "AuthenticAMD" and znver3.issubset(flags)
    return False

def elf_sizes(binary: Path, size_tool: str) -> tuple[int, int, int]:
    output = run_checked([size_tool, "-B", str(binary)]).stdout
    lines = output.splitlines()
    if len(lines) < 2:
        raise RuntimeError(f"could not parse size output for {binary}: {output}")
    fields = lines[-1].split()
    if len(fields) < 4:
        raise RuntimeError(f"could not parse ELF sections for {binary}: {output}")
    return int(fields[0]), int(fields[1]), int(fields[2])

def parse_benchmark(output: str) -> tuple[float, float, float, str, str]:
    patterns = (
        r"cold rasterization: .*?median ([0-9.]+) ns/iteration",
        r"cold 128-glyph cache fill and draw: .*?median ([0-9.]+) ns/iteration",
        r"warm 128-glyph cache draw: .*?median ([0-9.]+) ns/iteration",
        r"cache fill framebuffer checksum: ([0-9]+)",
        r"^framebuffer checksum: ([0-9]+)$",
    )
    matches = [re.search(pattern, output, re.MULTILINE) for pattern in patterns]
    if any(match is None for match in matches):
        raise RuntimeError("rasterizer benchmark output omitted a required metric")
    if "cache correctness:" not in output:
        raise RuntimeError("rasterizer benchmark correctness checks did not complete")
    return (
        float(matches[0].group(1)), float(matches[1].group(1)),
        float(matches[2].group(1)), matches[3].group(1), matches[4].group(1)
    )

def build_variant(variant: Variant, base_flags: str, make_tool: str,
                  cc: list[str], as_tool: str, ld_tool: str,
                  strip_tool: str, size_tool: str) -> tuple[int, int, int, int, int, Path]:
    build_dir = Path("build") / "compiler-sweep" / variant.name
    cflags = " ".join([base_flags, *variant.optimization_flags])
    app_linker = ld_tool
    app_ldflags = "-static -no-pie -z noexecstack -e _start --gc-sections"
    if variant.link_time_optimization:
        # GCC's driver loads its LTO plugin. -nostdlib preserves the project's
        # direct-syscall, freestanding link model and adds no runtime libraries.
        app_linker = " ".join(cc)
        app_ldflags = "-flto -nostdlib -static -no-pie -Wl,-z,noexecstack -Wl,-e,_start -Wl,--gc-sections"

    common = [
        make_tool, "--no-print-directory", "-C", str(ROOT),
        f"BUILD_DIR={build_dir.as_posix()}",
        f"CFLAGS={cflags}", f"CC={' '.join(cc)}",
        f"AS={as_tool}", f"LD={ld_tool}", f"APP_LINKER={app_linker}",
        f"APP_LDFLAGS={app_ldflags}", f"STRIP={strip_tool}",
        f"LDFLAGS=-static -no-pie -z noexecstack -e _start --gc-sections",
    ]
    build_output = run_checked(common + ["check"]).stdout
    binary = ROOT / build_dir / "nekoedit"
    before_strip = binary.stat().st_size
    run_checked(common + ["strip-binary"])
    after_strip = binary.stat().st_size
    text_bytes, data_bytes, bss_bytes = elf_sizes(binary, size_tool)

    sections = run_checked(["readelf", "-S", str(binary)]).stdout
    if ".symtab" in sections:
        raise RuntimeError(f"{variant.name}: --strip-all did not remove .symtab")
    if "ELF check passed:" not in build_output:
        raise RuntimeError(f"{variant.name}: production check did not run")

    return before_strip, after_strip, text_bytes, data_bytes, bss_bytes, binary

def compile_and_run_benchmark(variant: Variant, base_flags: str, cc: list[str],
                              binary_dir: Path) -> tuple[float, float, float, str, str, str]:
    binary_dir.mkdir(parents=True, exist_ok=True)
    executable = binary_dir / "rasterizer_bench"
    command = cc + shlex.split(base_flags) + list(variant.optimization_flags) + [
        "tests/rasterizer_bench.c", "src/font/rasterizer.c",
        "-no-pie", "-Wl,--gc-sections", "-o", str(executable)
    ]
    run_checked(command, timeout=240)
    completed = run_checked([str(executable)], timeout=120)
    metrics = parse_benchmark(completed.stdout)
    return (*metrics, completed.stdout)

def main() -> int:
    if len(sys.argv) != 6:
        print(
            "usage: compare_compiler_flags.py CC AS LD STRIP BASE_CFLAGS",
            file=sys.stderr
        )
        return 2

    cc = shlex.split(sys.argv[1])
    as_tool, ld_tool, strip_tool = sys.argv[2:5]
    base_flags = sys.argv[5]
    make_tool = os.environ.get("MAKE", "make")
    size_tool = os.environ.get("SIZE", "size")
    if not cc:
        raise RuntimeError("CC resolved to an empty command")

    SWEEP_ROOT.mkdir(parents=True, exist_ok=True)
    vendor, model, host_flags = cpu_details()
    compiler_version = run_checked(cc + ["--version"]).stdout.splitlines()[0]

    results: list[Result] = []
    benchmark_checksums: set[tuple[str, str]] = set()
    for variant in VARIANTS:
        try:
            before, after, text_bytes, data_bytes, bss_bytes, _ = build_variant(
                variant, base_flags, make_tool, cc, as_tool, ld_tool,
                strip_tool, size_tool
            )
            if not benchmark_allowed(variant.benchmark_gate, vendor, host_flags):
                results.append(Result(
                    variant, before, after, text_bytes, data_bytes, bss_bytes,
                    None, None, None, None, None,
                    f"built; benchmark skipped (host does not advertise {variant.benchmark_gate})"
                ))
                continue

            cold, fill, warm, fill_sum, frame_sum, output = compile_and_run_benchmark(
                variant, base_flags, cc, SWEEP_ROOT / "bench" / variant.name
            )
            benchmark_checksums.add((fill_sum, frame_sum))
            results.append(Result(
                variant, before, after, text_bytes, data_bytes, bss_bytes,
                cold, fill, warm, fill_sum, frame_sum, "built and benchmarked"
            ))
            print(f"--- {variant.name} ---")
            print(f"app ELF bytes before/after strip: {before}/{after}")
            print(output, end="" if output.endswith("\n") else "\n")
        except subprocess.CalledProcessError as error:
            details = error.stdout or str(error)
            if variant.name in {"Os", "O2", "O3"}:
                print(details, file=sys.stderr)
                raise
            results.append(Result(
                variant, 0, 0, 0, 0, 0, None, None, None, None, None,
                f"candidate unavailable: {details[-1200:].replace(chr(10), ' ')}"
            ))
            print(f"WARNING: {variant.name} was unavailable: {details[-1200:]}", file=sys.stderr)

    if len(benchmark_checksums) != 1:
        raise RuntimeError(
            "compiler profiles produced different benchmark framebuffers: "
            + repr(sorted(benchmark_checksums))
        )

    baseline = next((item for item in results if item.variant.name == "O2"), None)
    if baseline is None or baseline.warm_ns is None:
        raise RuntimeError("generic -O2 baseline benchmark did not run")

    lines = [
        "# NekoEdit compiler optimization comparison",
        "",
        f"- Compiler: {compiler_version}",
        f"- Host: {vendor} / {model}",
        "- Benchmark: synthetic deterministic 8-point glyph outlines; cold rasterization, cache fill, and 50,000 warm draws per sample; seven internal samples; median reported.",
        "- All executed variants produced identical cache-fill and warm-framebuffer checksums.",
        "- Application executable is mostly handwritten x86-64 assembly; C compiler flags affect the freestanding C modules, not the assembly renderer/layout routines.",
        "",
        "| Profile | C flags | ELF bytes before strip | ELF bytes stripped | Text / data / BSS | Cold raster ns | Cache fill ns | Warm draw ns | Warm vs O2 | Status |",
        "|---|---|---:|---:|---:|---:|---:|---:|---:|---|",
    ]
    for item in results:
        flags = " ".join(item.variant.optimization_flags)
        sections = f"{item.text_bytes:,} / {item.data_bytes:,} / {item.bss_bytes:,}" if item.app_bytes_after_strip else "—"
        if item.warm_ns is None:
            timings = "— | — | — | —"
        else:
            delta = (baseline.warm_ns - item.warm_ns) * 100.0 / baseline.warm_ns
            timings = f"{item.cold_ns:,.1f} | {item.fill_ns:,.1f} | {item.warm_ns:,.1f} | {delta:+.1f}%"
        lines.append(
            f"| {item.variant.name} | {flags} | "
            f"{item.app_bytes_before_strip:,} | {item.app_bytes_after_strip:,} | "
            f"{sections} | {timings} | {item.status} |"
        )

    lines += [
        "",
        f"Identical framebuffer checksums: {next(iter(benchmark_checksums))[0]} (cache fill), {next(iter(benchmark_checksums))[1]} (warm draw).",
        "",
        "Interpretation: benchmark timings are compiler-profile microbenchmarks, not end-to-end editor scrolling measurements. Stripping affects file size/symbol metadata, not execution speed. --gc-sections removes unreachable function/data sections; strip --strip-all removes the remaining non-runtime symbol/debug tables.",
        "",
    ]
    report = "\n".join(lines)
    report_path = SWEEP_ROOT / "report.md"
    report_path.write_text(report, encoding="utf-8")
    print(report)
    summary_path = os.environ.get("GITHUB_STEP_SUMMARY")
    if summary_path:
        with open(summary_path, "a", encoding="utf-8") as summary:
            summary.write(report + "\n")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
