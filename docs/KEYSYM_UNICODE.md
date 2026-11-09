# Named XKB Unicode keysyms

NekoEdit resolves named character keysyms without a runtime X11, Fontconfig, FreeType, or libxkbcommon dependency. The name-to-scalar table is embedded in `src/backend/xkb.S` and is consulted while a compositor-provided XKB text-v1 keymap is parsed.

## Coverage

The static table includes all printable Unicode mappings in the X.Org `keysymdef.h` data used to generate it, including legacy aliases that share a keysym value with a Unicode-annotated canonical entry. The current table also retains NekoEdit's dedicated `Multi_key` and six dead-accent action markers.

The 2026.1 additions include `SSHARP` (U+1E9E), `leftsingleanglequotemark` / `rightsingleanglequotemark` (U+2039/U+203A), `XF86XK_Numeric0` through `XF86XK_Numeric9`, `XF86XK_NumericStar`, `XF86XK_NumericPound`, and `dead_apostrophe` (handled through the existing acute-accent path).

The Wayland mock checks both parser scalar storage and actual UTF-8 insertion for Arabic, Hebrew, Thai, Hangul, Armenian, Georgian, Kana, Sinhala, Braille, German capital sharp S, single-angle quotation marks, and phone-numeric keysyms. It separately checks that `dead_apostrophe` activates the supported acute accent behavior.

This is not a claim of complete XKB/libxkbcommon support. Named function keysyms without Unicode character mappings stay on the editor's command/key-action paths. General XKB key actions and compatibility indicators are not executed by the client; Wayland modifier/group state remains compositor-owned. Rendering still depends on the selected font containing the corresponding glyph, and complete shaping, locale Compose, and advanced IME behavior remain separate work.

## Source and licensing

The mapping names and Unicode annotations are derived from X.Org's `include/X11/keysymdef.h` data in the `xorgproto` project. The 2026.1 aliases listed above are taken from the published X.Org `xorgproto 2026.1` update. The generated table contains only static names and scalar values; no header or external library is needed to build or run NekoEdit.

The source header carries these notices:

Copyright 1987, 1994, 1998 The Open Group.

Permission to use, copy, modify, distribute, and sell this software and its documentation for any purpose is hereby granted without fee, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation.

Copyright 1987 by Digital Equipment Corporation, Maynard, Massachusetts. All Rights Reserved.

Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Digital not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
