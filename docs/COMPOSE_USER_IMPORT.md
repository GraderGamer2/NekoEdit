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

## One-command install into NekoEdit

For a typical UTF-8 user file that includes a system locale Compose file, run the optional host-side installer:

~~~sh
python3 tools/install_user_xcompose.py \
  --input "$HOME/.XCompose" \
  --locale custom.UTF-8 \
  --home "$HOME" \
  --system-root /usr/share/X11/locale \
  --locale-compose /usr/share/X11/locale/en_US.UTF-8/Compose
~~~

The installer imports and validates the selected file in memory, builds the NLP1 binary, and atomically places it at:

~~~text
~/.nekoedit/locales/custom.UTF-8.nlp
~~~

The .nekoedit and locales directories are created or tightened to mode 0700, and the pack is mode 0600. Existing locale packs are never silently overwritten. Pass --replace to atomically replace an existing regular pack with the same locale tag. The source and included files are never moved, modified, or deleted. NekoEdit's Settings locale dropdown discovers the installed pack the next time Settings refreshes its list.

Omit --locale-compose when the selected file does not use %L. Use --keysymdef /usr/include/X11/keysymdef.h when that header is installed and named non-ASCII keysyms need to be resolved. Select another permitted input encoding with --encoding when required; the default is strict UTF-8. The tool uses Python's standard library only and is not launched by the editor.

## Optional JSON intermediate

The lower-level converter remains available when you want to inspect or edit generated records before installing them:

~~~sh
python3 tools/import_user_xcompose.py \
  --input "$HOME/.XCompose" \
  --locale custom.UTF-8 \
  --home "$HOME" \
  --system-root /usr/share/X11/locale \
  --locale-compose /usr/share/X11/locale/en_US.UTF-8/Compose \
  --output /tmp/custom.UTF-8.json

python3 tools/compose_pack.py build \
  --input /tmp/custom.UTF-8.json \
  --output /tmp/custom.UTF-8.nlp
~~~

The JSON writer creates missing output directories privately (mode 0700), atomically replaces the selected output, and writes the file with mode 0600. It refuses to overwrite a file that contributed to the import or the supplied keysym header.

## Integration boundary

This is an explicit user-invoked host utility, not a runtime feature. NekoEdit does not automatically read $XCOMPOSEFILE, search for ~/.XCompose, merge it with system data at startup, or expose an importer in Settings. After running the installer, the resulting .nlp pack is discovered by the existing Settings locale dropdown. Importing does not move, delete, or modify the selected source file. The editor remains a freestanding executable with no Python/runtime-library dependency.
