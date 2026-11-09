# Named XKB Unicode keysyms

NekoEdit resolves named character keysyms without a runtime X11, Fontconfig, FreeType, or libxkbcommon dependency. The name-to-scalar table is embedded in `src/backend/xkb.S` and is consulted while a compositor-provided XKB text-v1 keymap is parsed.

## Coverage

The static table includes the printable Unicode mappings from the pinned X.Org `keysymdef.h` data, including legacy aliases that share a keysym value with a Unicode-annotated canonical entry. It also maps named non-character actions used by the editor: `Multi_key` and the standard combining dead-key actions below.

The 2026.1 additions include `SSHARP` (U+1E9E), `leftsingleanglequotemark` / `rightsingleanglequotemark` (U+2039/U+203A), `XF86XK_Numeric0` through `XF86XK_Numeric9`, `XF86XK_NumericStar`, `XF86XK_NumericPound`, and `dead_apostrophe` (an alias for the acute action).

### Combining dead-key actions

The first six action markers remain ABI-stable: `dead_grave` U+0300, `dead_acute` / `dead_apostrophe` U+0301, `dead_circumflex` U+0302, `dead_tilde` / `dead_perispomeni` U+0303, `dead_diaeresis` U+0308, and `dead_cedilla` U+0327. The additional named actions map to these canonical combining marks:

| Keysym names | Combining scalar |
|---|---:|
| `dead_macron` | U+0304 |
| `dead_breve` | U+0306 |
| `dead_abovedot` | U+0307 |
| `dead_abovering` | U+030A |
| `dead_doubleacute` | U+030B |
| `dead_caron` | U+030C |
| `dead_ogonek` | U+0328 |
| `dead_iota` | U+0345 |
| `dead_voiced_sound` / `dead_semivoiced_sound` | U+3099 / U+309A |
| `dead_belowdot` | U+0323 |
| `dead_hook` / `dead_horn` | U+0309 / U+031B |
| `dead_stroke` / `dead_longsolidusoverlay` | U+0338 |
| `dead_abovecomma` / `dead_psili` | U+0313 |
| `dead_abovereversedcomma` / `dead_dasia` | U+0314 |
| `dead_doublegrave` | U+030F |
| `dead_belowring` | U+0325 |
| `dead_belowmacron` | U+0331 |
| `dead_belowcircumflex` | U+032D |
| `dead_belowtilde` | U+0330 |
| `dead_belowbreve` | U+032E |
| `dead_belowdiaeresis` | U+0324 |
| `dead_invertedbreve` | U+0311 |
| `dead_belowcomma` | U+0326 |
| `dead_lowline` | U+0332 |
| `dead_aboveverticalline` / `dead_belowverticalline` | U+030D / U+0329 |

An entered dead key arms its combining mark without inserting bytes. The next scalar uses a curated precomposition table where a known Unicode character exists; otherwise the editor inserts the base scalar followed by the combining mark. The precomposition table currently covers the original 52 Latin-1 pairs plus curated Latin Extended-A macron, breve, caron, ogonek, and below-dot pairs. This is generic XKB dead-key behavior, not locale-specific Compose data.

`dead_currency` and the `dead_a`/vowel-style syllable-entry actions are deliberately not mapped to combining marks. They have different semantics and must not be treated as ordinary diacritics. `Multi_key` retains its separate marker and sequence-buffering path.

The Wayland mock checks parser marker storage and real document insertion for the additional macron, caron, and below-dot actions. It verifies two precomposed results and the base-plus-mark fallback. Existing tests continue to cover Arabic, Hebrew, Thai, Hangul, Armenian, Georgian, Kana, Sinhala, Braille, German capital sharp S, angle quotation marks, and phone-numeric keysyms.

This is not a claim of complete XKB/libxkbcommon support. Named function keysyms without Unicode character mappings stay on the editor's command/key-action paths. General XKB key actions and compatibility indicators are not executed by the client; Wayland modifier/group state remains compositor-owned. Rendering still depends on the selected font containing the corresponding glyph, and complete locale Compose import, full shaping, and advanced IME behavior remain separate work.

## Source and licensing

The mapping names and Unicode annotations are derived from X.Org's `include/X11/keysymdef.h` data in the `xorgproto` project. The 2026.1 aliases listed above are taken from the published X.Org `xorgproto 2026.1` update. The generated table contains only static names and scalar values; no header or external library is needed to build or run NekoEdit.

The source header carries these notices:

Copyright 1987, 1994, 1998 The Open Group.

Permission to use, copy, modify, distribute, and sell this software and its documentation for any purpose is hereby granted without fee, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation.

Copyright 1987 by Digital Equipment Corporation, Maynard, Massachusetts. All Rights Reserved.

Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Digital not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
