# Multi_key Compose coverage

## Implemented subset

The Wayland editor has a built-in, dependency-free Compose table for two or three symbols after the XKB `Multi_key` action. Its tables contain **2,140 distinct two-symbol input pairs** and **564 three-symbol sequences**:

- **2,133** distinct, one-scalar-output pairs extracted from the X.Org libX11 `en_US.UTF-8` Compose source.
- **7** additional two-symbol mappings retained from NekoEdit's original hand-written set because they are not present in that upstream source.
- All **40** original NekoEdit mappings take precedence on overlap, preserving established behavior (including its existing slash/slash mapping).

The pair table stores Unicode scalar triples (first input, second input, result), and the three-symbol table stores four-scalar records (three inputs plus result), all in read-only data. The input symbols are converted through NekoEdit's existing ASCII and Unicode keysym mappings. A successful pair inserts one UTF-8 scalar. An unlisted pair is inserted literally as the two original symbols. Backspace and Escape cancel an unfinished Compose sequence.

The regression mock exercises the existing `o e` ligature plus newly added `period period` → U+2026, `S S` → U+1E9E, `period greater` → U+203A, `minus minus period` → U+2013, and `minus minus minus` → U+2014 paths. It also verifies that a recognized triple prefix stays buffered until the third symbol and that Backspace cancels a pending two-symbol prefix. These tests inspect text insertion and document bytes, not font availability or visual glyph rendering.

## Locale-pack direction

The product default will remain **en_US.UTF-8** and its Compose baseline will be built into the core executable. Other locales are planned as optional, separately downloadable locale packs attached to GitHub Releases. The editor will load an installed pack at runtime and fall back to built-in en_US when no matching pack is installed or a pack fails validation.

These packs are data, not executable plugins: no native shared objects, arbitrary code, or third-party runtime dependencies. A versioned, bounded format should permit the runtime loader to reject incompatible, oversized, malformed, or out-of-range records before they are used. The editor itself should remain usable offline; downloading/installing packs belongs to a separate release workflow, not an automatic network dependency in the core editor.

This architecture is planned, not implemented by the current static en_US tables.

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

The expanded table is static read-only data. It adds no build-time or runtime library dependency and does not alter Wayland keyboard protocol handling. The linear table search runs only while the user is in an active Compose sequence.
