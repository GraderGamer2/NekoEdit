#!/usr/bin/env python3
"""Build a reproducible O2/Os ELF size matrix without changing the normal build.

GC profiles isolate C functions/data and typed assembly functions in separate
input sections. Assembly transformations exist only in the temporary build tree.
"""
from __future__ import annotations

import argparse
import re
import shlex
import shutil
import subprocess
import sys
from pathlib import Path

FUNCTION_TYPE_RE = re.compile(
    r"(?m)^[ \t]*\.type[ \t]+([A-Za-z_.$][A-Za-z0-9_.$]*),[ \t]*@function[ \t]*$"
)
OPT_LEVEL_RE = re.compile(r"^-O(?:[0-3]|g|s|z|fast)$")


def words(value: str) -> list[str]:
    result = shlex.split(value)
    if not result:
        raise ValueError("empty tool or flag argument")
    return result


def run(command: list[str], capture: bool = False) -> subprocess.CompletedProcess[str]:
    result = subprocess.run(
        command, check=False, text=True,
        stdout=subprocess.PIPE if capture else None,
        stderr=subprocess.PIPE if capture else None,
    )
    if result.returncode:
        if capture:
            if result.stdout:
                sys.stdout.write(result.stdout)
            if result.stderr:
                sys.stderr.write(result.stderr)
        raise RuntimeError(
            f"command exited {result.returncode}: {shlex.join(command)}"
        )
    return result


def optimization_flags(flags: list[str], requested: str) -> list[str]:
    return [flag for flag in flags if not OPT_LEVEL_RE.match(flag)] + [requested]


def sectionize_assembly(source: Path, destination: Path) -> int:
    content = source.read_text(encoding="utf-8")
    matches = list(FUNCTION_TYPE_RE.finditer(content))
    total = re.findall(
        r"(?m)^[ \t]*\.type[ \t]+[^,\s]+,[ \t]*@function\b", content
    )
    if len(matches) != len(total):
        raise RuntimeError(
            f"{source}: unable to parse every function .type directive"
        )
    if not matches:
        raise RuntimeError(f"{source}: no typed functions found")

    # Some older Wayland routines intentionally repeat .type declarations.
    # Insert exactly one section switch at the actual function label.
    insertions: list[tuple[int, str]] = []
    seen: set[str] = set()
    for match in matches:
        symbol = match.group(1)
        if symbol in seen:
            continue
        seen.add(symbol)
        label = re.compile(
            r"(?m)^[ \t]*" + re.escape(symbol) + r":[ \t]*(?:#.*)?$"
        )
        label_match = label.search(content, match.end())
        if not label_match:
            raise RuntimeError(
                f"{source}: function label for {symbol} does not follow its .type"
            )
        line_start = content.rfind("\n", 0, label_match.start()) + 1
        insertions.append((
            line_start,
            f'.section .text.{symbol},"ax",@progbits\n',
        ))

    for position, directive in reversed(insertions):
        content = content[:position] + directive + content[position:]
    destination.parent.mkdir(parents=True, exist_ok=True)
    destination.write_text(content, encoding="utf-8")
    return len(seen)

def compile_profile(
    name: str,
    optimization: str,
    gc_sections: bool,
    args: argparse.Namespace,
    root: Path,
    output_dir: Path,
) -> tuple[Path, list[str]]:
    work = output_dir / "work" / name
    object_root = work / "obj"
    generated_root = work / "sectionized"
    cc = words(args.cc)
    assembler = words(args.as_tool)
    linker = words(args.ld)
    cflags = optimization_flags(words(args.cflags), optimization)
    if gc_sections:
        cflags += ["-ffunction-sections", "-fdata-sections"]
    asflags = words(args.asflags)
    ldflags = words(args.ldflags)
    if gc_sections:
        ldflags += ["--gc-sections", "--print-gc-sections"]

    objects: list[str] = []
    assembly_function_count = 0
    for source_name in args.asm_source:
        source = root / source_name
        if not source.is_file():
            raise RuntimeError(f"assembly source not found: {source}")
        actual_source = source
        if gc_sections:
            actual_source = generated_root / source_name
            assembly_function_count += sectionize_assembly(source, actual_source)
        obj = object_root / (source_name + ".o")
        obj.parent.mkdir(parents=True, exist_ok=True)
        run(assembler + asflags + ["-o", str(obj), str(actual_source)])
        objects.append(str(obj))

    for source_name in args.c_source:
        source = root / source_name
        if not source.is_file():
            raise RuntimeError(f"C source not found: {source}")
        obj = object_root / (source_name + ".o")
        obj.parent.mkdir(parents=True, exist_ok=True)
        run(cc + cflags + ["-c", "-o", str(obj), str(source)])
        objects.append(str(obj))

    executable = output_dir / f"nekoedit-{name}"
    link = run(
        linker + ldflags + ["-o", str(executable)] + objects,
        capture=gc_sections,
    )
    removed = []
    if gc_sections:
        diagnostics = (link.stdout or "") + (link.stderr or "")
        removed = [
            line.strip() for line in diagnostics.splitlines()
            if "removing unused section" in line
        ]
    print(
        f"Built {executable.name}: {optimization}; "
        f"{'section GC' if gc_sections else 'no section GC'}"
        + (f"; isolated {assembly_function_count} assembly functions" if gc_sections else "")
    )
    if gc_sections:
        print(f"  GNU ld discarded {len(removed)} input sections.")
        for line in removed:
            print("  " + line)
    return executable, removed


def verify_elf(binary: Path, readelf: list[str]) -> None:
    headers = run(readelf + ["-l", str(binary)], capture=True).stdout
    if re.search(r"\bINTERP\b", headers):
        raise RuntimeError(f"{binary.name}: unexpected PT_INTERP segment")
    dynamic = run(readelf + ["-d", str(binary)], capture=True)
    if "NEEDED" in (dynamic.stdout or "") + (dynamic.stderr or ""):
        raise RuntimeError(f"{binary.name}: unexpected DT_NEEDED dependency")


def size_fields(
    binary: Path, size_tool: list[str]
) -> tuple[int, int, int, int, int]:
    # GNU size's default Berkeley format combines .text and .rodata into its
    # single "text" field. Use section-oriented output to report them separately.
    output = run(size_tool + ["-A", str(binary)], capture=True).stdout
    sections: dict[str, int] = {}
    for line in output.splitlines():
        fields = line.split()
        if len(fields) >= 2 and fields[0].startswith("."):
            try:
                sections[fields[0]] = sections.get(fields[0], 0) + int(fields[1], 10)
            except ValueError:
                continue
    return (
        binary.stat().st_size,
        sections.get(".text", 0),
        sections.get(".rodata", 0),
        sections.get(".data", 0),
        sections.get(".bss", 0),
    )

def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--baseline", required=True)
    parser.add_argument("--output-dir", required=True)
    parser.add_argument("--cc", default="cc")
    parser.add_argument("--as-tool", default="as")
    parser.add_argument("--ld", default="ld")
    parser.add_argument("--strip", default="strip")
    parser.add_argument("--readelf", default="readelf")
    parser.add_argument("--size", default="size")
    parser.add_argument("--cflags", required=True)
    parser.add_argument("--asflags", required=True)
    parser.add_argument("--ldflags", required=True)
    parser.add_argument("--asm-source", action="append", required=True)
    parser.add_argument("--c-source", action="append", required=True)
    args = parser.parse_args()

    root = Path.cwd()
    baseline = (root / args.baseline).resolve()
    if not baseline.is_file():
        raise RuntimeError(f"baseline executable not found: {baseline}")
    output_dir = (root / args.output_dir).resolve()
    output_dir.mkdir(parents=True, exist_ok=True)
    strip_tool = words(args.strip)
    readelf_tool = words(args.readelf)
    size_tool = words(args.size)

    # O2 is the exact, already-built normal executable.
    o2 = output_dir / "nekoedit-o2"
    shutil.copy2(baseline, o2)
    profiles: dict[str, Path] = {"O2": o2}
    discarded: dict[str, list[str]] = {}

    for name, level, use_gc in (
        ("o2-gc", "-O2", True),
        ("os", "-Os", False),
        ("os-gc", "-Os", True),
    ):
        binary, sections = compile_profile(
            name, level, use_gc, args, root, output_dir
        )
        profiles[name.upper()] = binary
        if use_gc:
            discarded[name.upper()] = sections

    sequence = [
        ("O2", profiles["O2"]),
        ("O2 stripped", None),
        ("O2 + section GC", profiles["O2-GC"]),
        ("O2 + section GC stripped", None),
        ("Os", profiles["OS"]),
        ("Os stripped", None),
        ("Os + section GC", profiles["OS-GC"]),
        ("Os + section GC stripped", None),
    ]
    binaries: list[tuple[str, Path]] = []
    for label, binary in sequence:
        if binary is None:
            unstripped = (
                profiles["O2"] if label == "O2 stripped"
                else profiles["O2-GC"] if label == "O2 + section GC stripped"
                else profiles["OS"] if label == "Os stripped"
                else profiles["OS-GC"]
            )
            binary = output_dir / (unstripped.stem + "-stripped")
            shutil.copy2(unstripped, binary)
            run(strip_tool + ["--strip-all", str(binary)])
        verify_elf(binary, readelf_tool)
        binaries.append((label, binary))

    rows = [(label, *size_fields(binary, size_tool)) for label, binary in binaries]
    print("\nELF size comparison (bytes)")
    print(
        f"{'Variant':34} {'File bytes':>12} {'.text':>10} "
        f"{'.rodata':>10} {'.data':>8} {'.bss':>12}"
    )
    print("-" * 100)
    for label, file_bytes, text_bytes, rodata_bytes, data_bytes, bss_bytes in rows:
        print(
            f"{label:34} {file_bytes:12,d} {text_bytes:10,d} "
            f"{rodata_bytes:10,d} {data_bytes:8,d} {bss_bytes:12,d}"
        )

    report = [
        "# NekoEdit ELF size matrix",
        "",
        "All sizes are bytes. .bss is runtime zero-initialized storage and is not stored as equivalent file bytes.",
        "",
        "| Variant | File bytes | .text | .rodata | .data | .bss |",
        "|---|---:|---:|---:|---:|---:|",
    ]
    for label, file_bytes, text_bytes, rodata_bytes, data_bytes, bss_bytes in rows:
        report.append(
            f"| {label} | {file_bytes} | {text_bytes} | {rodata_bytes} | "
            f"{data_bytes} | {bss_bytes} |"
        )
    for profile, sections in discarded.items():
        report.extend(["", f"## Discarded sections: {profile}", ""])
        report.extend(
            [f"- {line}" for line in sections]
            if sections
            else ["No input sections were reported as discarded by GNU ld."]
        )
    report_path = output_dir / "SIZE_REPORT.md"
    report_path.write_text("\n".join(report) + "\n", encoding="utf-8")
    print(f"\nDetailed report: {report_path}")
    print("All eight ELF variants passed the freestanding/no-dynamic-dependency checks.")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, ValueError, RuntimeError) as error:
        print(f"size matrix error: {error}", file=sys.stderr)
        raise SystemExit(1)
