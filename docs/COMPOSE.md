# Multi_key Compose coverage

## Implemented subset

The Wayland editor has a built-in, dependency-free Compose table for two or three symbols after the XKB `Multi_key` action. Its tables contain **2,140 distinct two-symbol input pairs** and **564 three-symbol sequences**:

- **2,133** distinct, one-scalar-output pairs extracted from the X.Org libX11 `en_US.UTF-8` Compose source.
- **7** additional two-symbol mappings retained from NekoEdit's original hand-written set because they are not present in that upstream source.
- All **40** original NekoEdit mappings take precedence on overlap, preserving established behavior (including its existing slash/slash mapping).

The pair table stores Unicode scalar triples (first input, second input, result), and the three-symbol table stores four-scalar records (three inputs plus result), all in read-only data. The input symbols are converted through NekoEdit's existing ASCII and Unicode keysym mappings. A successful pair inserts one UTF-8 scalar. An unlisted pair is inserted literally as the two original symbols. Backspace and Escape cancel an unfinished Compose sequence.

The regression mock exercises the existing `o e` ligature plus newly added `period period` → U+2026, `S S` → U+1E9E, `period greater` → U+203A, `minus minus period` → U+2013, and `minus minus minus` → U+2014 paths. It also verifies that a recognized triple prefix stays buffered until the third symbol and that Backspace cancels a pending two-symbol prefix. These tests inspect text insertion and document bytes, not font availability or visual glyph rendering.

## Optional locale packs

The core executable keeps **en_US.UTF-8 as its built-in default**. A bounded runtime loader now supports explicitly selected, data-only locale packs installed in `~/.nekoedit/locales/` and selected through `NEKOEDIT_LOCALE`. A selected pack replaces that locale's Compose table; it does not merge with en_US. It supports two- to four-scalar input sequences and one- to eight-scalar output strings. Missing or invalid packs fall back to the embedded en_US tables. No shared libraries, executable plugin code, or network access are required.

The binary layout, generator, validation rules, and installation example are documented in [COMPOSE_PACK_FORMAT.md](COMPOSE_PACK_FORMAT.md). The pack generator is a Python build/release tool; Python is not a runtime dependency.

The first complete external dataset, `pt_BR.UTF-8`, is generated from pinned X.Org sources; see [data/locales/README.md](../data/locales/README.md). The build workflow produces the `.nlp` asset separately from the editor binary, and the locale-pack workflow attaches the pack and its notice to a published GitHub Release. More locales, a Settings selector/installer, automatic system-locale discovery, locale-specific dead-key tables, and system/user Compose-file import remain future work.

## Explicit limits

This is a **static en_US.UTF-8-derived two-/three-symbol baseline**, not full locale-aware Compose support. It does not currently:

- select a Compose table from `LC_ALL`, `LC_CTYPE`, or `LANG`;
- load `/usr/share/X11/locale/compose.dir` or locale-specific `Compose` files;
- process XCompose `include` directives, `%L` / `%S` / `%H` substitutions, or `$XCOMPOSEFILE`;
- read or merge `~/.XCompose`;
- process four-symbol sequences or multi-scalar result strings;
- implement every dead-key keysym and locale-specific dead-key rule.

The separate dead-key path remains limited to six combining marks (grave, acute, circumflex, tilde, diaeresis, and cedilla) with 52 precomposed Latin-1 results and base-plus-mark fallback. Full Unicode normalization and shaping are separate rendering work.

## Source and attribution

The upstream sequence source is:

- Repository: [mirror/libX11](https://github.com/mirror/libX11)
- File: [nls/en_US.UTF-8/Compose.pre](https://github.com/mirror/libX11/blob/ff8706a5eae25b8bafce300527079f68a201d27f/nls/en_US.UTF-8/Compose.pre)
- Upstream commit: `ff8706a5eae25b8bafce300527079f68a201d27f`
- Source file Git blob: `84888ef02bc1aa0ecaa939f59fcf4b10e5e7b3df`

The source is distributed as part of X.Org libX11. Its repository `COPYING` file documents the applicable X.Org/MIT-style and legacy notices; see [COPYING](https://github.com/mirror/libX11/blob/ff8706a5eae25b8bafce300527079f68a201d27f/COPYING). NekoEdit embeds only the resulting scalar-to-scalar table, not libX11 code or a runtime library.

## Runtime impact

The embedded en_US tables remain static read-only data. Optional packs are opened and mapped only when a non-built-in `NEKOEDIT_LOCALE` is explicitly selected. The loader rejects files larger than 2 MiB and validates the header, locale tag, CRC-32, record ordering, prefix ambiguity, and Unicode scalar fields before enabling a locale. Lookups use a sorted bounded table and binary search. The executable gains no dynamic dependency and performs no automatic download.


## Selecting an installed locale

The Settings dropdown has a **COMPOSE LOCALE** row for the built-in `en_US` and optional `pt_BR` pack. The selection is persisted as `compose_locale=<tag>` in `~/.nekoedit/preferences`. A persisted choice takes precedence over `NEKOEDIT_LOCALE`; when no preference is saved, the environment variable remains a first-run override. Selecting a locale never downloads or installs it.

Install the separate Release asset before selecting it:

```sh
mkdir -p "$HOME/.nekoedit/locales"
install -m 600 pt_BR.UTF-8.nlp "$HOME/.nekoedit/locales/pt_BR.UTF-8.nlp"
```

If `pt_BR` is selected but its file is absent or invalid, Settings displays `MISSING` and the embedded en_US table remains active. Choose `en_US` in Settings to clear that selection. Switching locales does not modify the active document.
