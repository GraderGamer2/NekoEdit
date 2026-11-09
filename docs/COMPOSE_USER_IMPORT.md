# Offline user XCompose import

NekoEdit now has a **manual, offline converter** for a bounded subset of user-authored XCompose files. It converts a selected text file and its explicitly permitted includes into JSON records that the existing NLP1 pack builder can validate and encode. It does not alter the running editor or discover user files at startup.

The converter is separate from the pinned X.Org Compose.pre dataset importer. It does not download source data, run shell commands, evaluate environment variables, load executable plugins, or add a runtime library.

## Supported rules

Examples of accepted rule shapes:

    <Multi_key> <e> <e> : "Ə" U018F
    <dead_acute> <c> : "ç" ccedilla

- The first event must be Multi_key or a recognized dead_* action.
- A Multi_key rule accepts two to four following keysyms. A dead-key rule accepts exactly one following keysym; the importer normalizes the action to its combining mark and emits a kind-1 NLP1 record.
- Input keysyms are retained only when they resolve to Unicode scalar values. ASCII and Uxxxx–Uxxxxxx values work without an additional file. A Unicode-annotated X.Org keysymdef.h can be supplied for other named character keysyms.
- Results may be a quoted string of one to eight Unicode scalars, optionally followed by a keysym annotation, or a Unicode-resolvable keysym alone. Octal and hexadecimal byte escapes use the selected source encoding. Unicode scalar escapes are accepted as a convenience extension.
- Later identical rules replace earlier ones, following include expansion order. Shorter rules that prefix longer rules are dropped within the same NLP1 rule kind.
- Modifier-qualified entries are counted and skipped: NLP1 does not represent modifier-state constraints. Unsupported leading keysyms and non-Unicode input symbols are also skipped and counted. Malformed syntax, unsafe includes, and resource-limit violations fail the import.

This is not full libX11/libxkbcommon Compose interpretation. It does not support arbitrary modifier semantics, relative include names, wildcards, compose.dir locale mapping, arbitrary environment substitution, or dead-key chains with multiple following events.

## Include policy

Includes expand depth-first at the point where they occur. Only these quoted forms are accepted:

- include "%H/path/inside/home" — a relative path under the canonical home root.
- include "%S/path/inside/system-root" — a relative path under the canonical system Compose root (default /usr/share/X11/locale).
- include "%L" — one explicit locale Compose file supplied with --locale-compose; the resolved file must remain inside the system root.

Each include target is canonicalized before use. Symlinks that resolve outside their allowlisted root are rejected. An active include cycle is rejected; a repeated include that is no longer active is allowed and re-applied in textual order. Absolute paths, .., ~, $, unknown percent substitutions, relative include names, and nested substitutions are rejected. The converter never invokes a shell.

The fixed resource bounds are in tools/import_user_xcompose.py: 512 KiB per file, 4 MiB total expanded input, 32 unique files, 64 include expansions, depth 16, 64 KiB per line, 32,768 unique records, at most four following Multi_key inputs, and eight output scalars.

## Convert and install a selected file

The output JSON and generated pack belong in NekoEdit's existing private locale directory. For a typical UTF-8 user file that includes a system locale Compose file:

    mkdir -p "$HOME/.nekoedit/locales"

    python3 tools/import_user_xcompose.py \
      --input "$HOME/.XCompose" \
      --locale custom.UTF-8 \
      --home "$HOME" \
      --system-root /usr/share/X11/locale \
      --locale-compose /usr/share/X11/locale/en_US.UTF-8/Compose \
      --output "$HOME/.nekoedit/locales/custom.UTF-8.json"

    python3 tools/compose_pack.py build \
      --input "$HOME/.nekoedit/locales/custom.UTF-8.json" \
      --output "$HOME/.nekoedit/locales/custom.UTF-8.nlp"

    chmod 0600 "$HOME/.nekoedit/locales/custom.UTF-8.nlp"

Omit --locale-compose when the selected file does not use %L. Use --keysymdef /usr/include/X11/keysymdef.h when that header is installed and named non-ASCII keysyms need to be resolved. Select another permitted input encoding with --encoding when required; the default is strict UTF-8.

The JSON writer creates missing output directories privately (mode 0700), atomically replaces the selected output, and writes the file with mode 0600. It refuses to overwrite a file that contributed to the import or the supplied keysym header.

## Not integrated into the editor yet

This is a build-time/user-invoked conversion tool only. NekoEdit does not automatically read $XCOMPOSEFILE, search for ~/.XCompose, merge it with system data at startup, or expose an importer in Settings. After conversion and pack building, the resulting .nlp file can be installed and selected through the existing Settings locale dropdown. Conversion does not move, delete, or modify the source file.
