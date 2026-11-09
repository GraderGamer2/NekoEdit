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

The external `pt_BR.UTF-8`, `fi_FI.UTF-8`, and `sr_RS.UTF-8` datasets are generated from pinned X.Org sources; see [data/locales/README.md](../data/locales/README.md). The build workflow produces the `.nlp` asset separately from the editor binary, and the locale-pack workflow attaches it and its notice to a published GitHub Release. Settings now opens an in-menu dropdown populated with every installed `.nlp` pack, provides an explicit Base en_US option, imports a local pack through Add, and removes the selected pack after confirmation. Locale packs carry Multi_key rules and the supported one-following-scalar dead-key rules. System/user Compose-file import and longer dead-key chains remain future work.

## Explicit limits

This is a **static en_US.UTF-8-derived two-/three-symbol baseline**, not full locale-aware Compose support. It does not currently:

- load an arbitrary system-locale table without a matching installed NLP1 data pack (language/territory casing and common UTF-8 codeset spellings normalize to canonical pack names; unsupported/missing tags fall back to en_US);
- load `/usr/share/X11/locale/compose.dir` or locale-specific `Compose` files;
- process XCompose `include` directives, `%L` / `%S` / `%H` substitutions, or `$XCOMPOSEFILE`;
- read or merge `~/.XCompose`;
- add four-symbol sequences or multi-scalar results to the embedded static en_US table; optional NLP1 packs already support two- to four-scalar inputs and one- to eight-scalar outputs;
- import dead-key sequences that require two or more following symbols after the dead action; the current pack subset resolves one dead action plus one following Unicode scalar.

The XKB keysym table recognizes 39 named `dead_*` keysyms (including aliases) and maps them to the combining marks used by the keyboard path. Optional locale packs can override a dead-key-plus-scalar pair independently of `Multi_key`; for example, `pt_BR.UTF-8` maps dead acute plus `c` to `ç`, while Serbian packs include Cyrillic dead-key rules. The built-in fallback still uses the existing precomposed Latin mappings and base-plus-mark output. Full Unicode normalization and shaping are separate rendering work.

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

The Settings dropdown's locale row offers four actions: **Locale** opens the installed `.nlp` pack picker, **Base** selects embedded `en_US`, **Add** imports a local pack, and **Remove** deletes the currently selected non-built-in pack after confirmation. The selected tag is persisted as `compose_locale=<tag>` in `~/.nekoedit/preferences`. A saved choice takes precedence over environment selection. When no preference is saved, NekoEdit checks `NEKOEDIT_LOCALE`, then `LC_ALL`, `LC_CTYPE`, and `LANG` in that order; empty values are ignored. Locale normalization folds language/territory case, canonicalizes UTF8/utf-8 codeset spelling, and adds `.UTF-8` to bare language/territory tags. For example, `fi_FI.utf8` selects `fi_FI.UTF-8`, and `sr_RS.UTF8` selects `sr_RS.UTF-8`. `C`, `C.UTF-8`, `C.UTF8`, `C.utf8`, and `POSIX` select embedded en_US. `LC_MESSAGES` and `LANGUAGE` are ignored because they control message translation, not character input.

Add opens a local file picker filtered to `.nlp`. The selected file is structurally validated, copied into `~/.nekoedit/locales/` with private permissions, and only then activated. Remove acts on the persisted selected tag (or the effective installed locale when no saved preference exists), validates the installed file before deletion, and requires confirmation. Neither action downloads data. An absent or invalid selected pack leaves embedded en_US active and displays `MISSING`. Switching locales does not modify the active document.
