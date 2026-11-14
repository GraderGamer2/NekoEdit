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
- **.data** is initialized writable data.
- **.bss** is zero-initialized runtime storage; it contributes to memory footprint but is not stored as equivalent bytes in the executable.
- Stripping removes symbol/string-table metadata; it should not change executable instructions or runtime data.
- GC may change section layout and alignment. Compare unstripped and stripped pairs to separate code/data collection from symbol-table removal.

The ordinary O2 executable remains available with its symbol table for tests that inspect process symbols. Stripped binaries receive CLI smoke tests, while both O2-GC and Os-GC binaries receive the complete Wayland protocol mock. The usual full build, host tests, renderer benchmark, baseline Wayland test, and Mutter integration test remain in the workflow.

## Toolchain and repeatability

The workflow prints the C compiler, assembler, linker, strip, size, and readelf versions. Run `make size-compare` to create `build/size-matrix/SIZE_REPORT.md` and eight executable variants. All variants are uploaded as a separate Actions artifact.

No size result is assumed in advance. Keep the default optimization/release policy unchanged until the measured matrix and regression tests have been reviewed.
