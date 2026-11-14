# ELF size optimization experiment

This experiment lives on the dedicated `optimization-early-alpha` branch. It does not change the normal application build flags or strip the normal `build/nekoedit` executable.

## Comparison order

The matrix uses the current freestanding ELF as its O2 reference, then measures:

1. O2, unstripped (the normal build)
2. O2, stripped with GNU `strip --strip-all`
3. O2 with linker section garbage collection (unstripped)
4. O2 with linker section garbage collection (stripped)
5. Os, unstripped
6. Os, stripped
7. Os with linker section garbage collection (unstripped)
8. Os with linker section garbage collection (stripped)

For GC profiles, C compilation additionally uses `-ffunction-sections -fdata-sections`. The matrix builder also makes temporary copies of the assembly sources with each typed function placed in a separate `.text.<function>` input section. The normal repository assembly sources are not rewritten. GNU ld links these GC profiles with `--gc-sections --print-gc-sections`.

This makes the unused-code comparison more complete than applying GC to the existing monolithic assembly `.text` sections alone. Assembly data tables remain grouped in their existing input sections; this first collection experiment focuses on assembly functions and C function/data items. The report records the exact sections GNU ld discards.

## Interpreting the report

- **File bytes** is the executable's on-disk size.
- **.text** is executable code size.
- **.rodata** is read-only data and lookup tables.
- **.data** is initialized writable data.
- **.bss** is zero-initialized runtime storage; it contributes to memory footprint but is not stored as equivalent bytes in the executable.
- Stripping removes symbol/string-table metadata; it should not change executable instructions or runtime data.
- GC may change section layout and alignment. Compare unstripped and stripped pairs to separate code/data collection from symbol-table removal.

The ordinary O2 executable remains available with its symbol table for tests that inspect process symbols. Stripped binaries receive CLI smoke tests, while both O2-GC and Os-GC binaries receive the complete Wayland protocol mock. The usual full build, host tests, renderer benchmark, baseline Wayland test, and Mutter integration test remain in the workflow.

## Toolchain and repeatability

The workflow prints the C compiler, assembler, linker, strip, size, and readelf versions. Run `make size-compare` to create `build/size-matrix/SIZE_REPORT.md` and eight executable variants. Section sizes use GNU `size -A`; the default GNU `size` format is not used because its `text` field combines `.text` and `.rodata`. All variants are uploaded as a separate Actions artifact.

## Measured results — CI #927 passed all 23 steps

Actions [Build and test #927](https://github.com/GraderGamer2/NekoEdit/actions/runs/43544881549) passed all 23 workflow steps with no failures. The matrix compares the exact normal O2 build against stripped copies, dead-section collection, and the equivalent Os profiles.

| Variant | File bytes | .text | .rodata | .data | .bss |
|---|---:|---:|---:|---:|---:|
| O2 | 345,016 | 138,902 | 90,976 | 64 | 3,645,568 |
| O2 stripped | 234,944 | 138,902 | 90,976 | 64 | 3,645,568 |
| O2 + section GC | 344,536 | 138,630 | 90,960 | 64 | 3,645,624 |
| O2 + section GC stripped | 234,928 | 138,630 | 90,960 | 64 | 3,645,624 |
| Os | 337,656 | 127,224 | 90,492 | 64 | 3,645,568 |
| Os stripped | 226,264 | 127,224 | 90,492 | 64 | 3,645,568 |
| Os + section GC | 337,168 | 126,983 | 90,478 | 64 | 3,645,624 |
| Os + section GC stripped | 226,256 | 126,983 | 90,478 | 64 | 3,645,624 |

### Findings

- **Stripping is the largest win.** O2 falls from 345,016 to 234,944 bytes, saving 110,072 bytes (31.9%). Os falls from 337,656 to 226,264 bytes, saving 111,392 bytes. The loadable .text, .rodata, .data, and .bss sections are unchanged by stripping; the reduction is ELF symbol/string metadata.
- **Os is smaller than O2.** Before stripping the reduction is 7,360 bytes (2.13%); after stripping it is 8,680 bytes (3.69%). Compiler optimization flags apply to the five C translation units only: rasterizer.c, clipboard.c, compose_locale.c, history.c, and preferences.c. The Wayland, XKB, SFNT, syscall, and entry sources are hand-written assembly, so -Os does not optimize those files.
- **Section GC works, but is not a meaningful size lever here.** GNU ld discarded five input sections: .text.begin_path_prompt, .text.draw_bounded_ascii, .text.font_draw_codepoint, .text.preferences_locale_is_pt_br, and .rodata.target.13. After stripping, GC saves only 16 bytes at O2 and 8 bytes at Os. Its section splitting increases reported BSS by 56 bytes through alignment.
- All eight variants passed ELF no-interpreter/no-DT_NEEDED checks. Stripped O2/Os binaries passed CLI smoke tests; O2-GC and Os-GC passed the full Wayland protocol mock. The normal O2 build passed the full 11 MiB Open/Save Wayland suite, renderer benchmark, XKB/importer tests, locale-pack build, and Mutter integration.

### Recommendation

Keep the normal build at **O2 and unstripped** for development and symbol-based testing. Stripping is a strong release-packaging candidate because it changes only ELF metadata. Os is a worthwhile smaller-build candidate, but should not replace O2 until representative rendering, scrolling, and editing benchmarks establish whether its size reduction affects performance. Section GC should not be adopted solely to save file bytes; its measured benefit after stripping is negligible.

The experiment remains isolated on optimization-early-alpha. No application source or default compiler flags were changed. The next step is a runtime comparison of O2 and Os on actual rendering and editing workloads.
