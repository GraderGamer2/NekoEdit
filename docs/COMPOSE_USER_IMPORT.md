# Offline user XCompose import

NekoEdit now has a **manual, offline converter** for a bounded subset of user-authored XCompose files. It converts a selected text file and its explicitly permitted includes into JSON records that the existing NLP1 pack builder can validate and encode. It does not alter the running editor or discover user files at startup.

The converter is separate from the pinned X.Org Compose.pre dataset importer. It does not download source data, run shell commands, evaluate environment variables, load executable plugins, or add a runtime library.

## Supported rules

Examples of accepted rule shapes:

    <Multi_key> <e> <e> : "Ə" U018F
    <dead_acute> <c> : "ç" ccedilla

- The first event must be Multi_key or a recognized dead_* action.
- A Multi_key rule accepts two to four following keysyms. A dead-key rule accepts exactly one following keysym; the importer normalizes the action to its combining mark and emits a kind-1 NLP1 record.
- Input keysyms are retained only when they resolve to Unicode scalar values. ASCII characters, standard printable ASCII keysym names (such as `space`, `quotedbl`, and `asciitilde`), and Uxxxx–Uxxxxxx values work without an additional file. A Unicode-annotated X.Org keysymdef.h can be supplied for other named character keysyms.
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

## Installed system Compose compatibility test

`make test` also runs `tests/system_xcompose_import_test.py`. When the standard files are present, it imports the installed `/usr/share/X11/locale/en_US.UTF-8/Compose` database through a temporary user `.XCompose` that includes it with `%L`. The test checks known Multi_key and dead-key results, a user override applied after the include, the imported record volume, and successful NLP1 validation.

On Ubuntu CI, `libx11-data` supplies the real system Compose file and `x11proto-dev` supplies `keysymdef.h`. These are test-environment packages only; neither is linked to NekoEdit or required at runtime. On a development machine without those files the integration test reports a skip, while the deterministic synthetic parser tests still run. Override the locations with `NEKOEDIT_SYSTEM_COMPOSE_FILE`, `NEKOEDIT_SYSTEM_COMPOSE_ROOT`, and `NEKOEDIT_KEYSYMDEF` when testing a different installed X.Org corpus.

The integration test constructs the imported pack in memory inside a temporary directory. It does not install a locale, write beneath the real home directory, modify the system Compose database, or add locale tables to the application executable.

## Integration boundary

The host-side converter and installer remain explicit user-invoked utilities. The editor does not automatically read $XCOMPOSEFILE, search for ~/.XCompose, or merge user/system Compose data at startup. The Settings Import action uses a separate bounded native parser and does not launch Python or any helper process. Both paths create data-only NLP1 files; neither adds locale tables or executable plugins to the editor.

## Direct import from Settings

The editor provides a native Settings -> Locale -> Import action. Select a UTF-8 .XCompose rule file in the file picker; NekoEdit derives a locale tag from the filename (for example, nekoedit-test.XCompose becomes nekoedit-test.UTF-8), validates the generated NLP1 pack, and installs it directly under ~/.nekoedit/locales/. The source file is left untouched. Existing packs are never overwritten. Rename the source file to choose a different pack name, or remove the previous pack before importing again.

The in-app importer supports bounded UTF-8 rule files containing unqualified Multi_key rules with two to four following keysyms, or one recognized dead-key action followed by one keysym. Results may be quoted UTF-8 strings with simple, octal, hexadecimal-byte, or Unicode-scalar escapes, or a Unicode-resolvable keysym. It recognizes printable ASCII names and a curated set of common Latin-1 names. Later duplicate rules override earlier rules; ambiguous shorter prefixes are dropped within the same rule kind. Modifier-qualified rules and unsupported symbols are skipped.

Quoted relative include directives are supported only for sibling files in the same directory as the selected root file. Includes expand depth-first at the point where they occur; a repeated include is allowed after its previous expansion returns, while an active inode cycle is rejected. Each target must be a simple basename: absolute paths, directory separators, "."/"..", symlinks, percent substitutions such as %L, and other path syntax are rejected. Every included object must be a regular file opened with O_NOFOLLOW. The native import limits are 512 KiB aggregate expanded input, 512 KiB per file, 32 unique files, 64 total include expansions, 16 active levels, 64 KiB per line, and 32,768 output records. Exceeding a limit or encountering an unsafe/malformed include fails the entire import; it never installs a partial pack.

Use the optional host-side converter when a file needs %H, %S, or %L includes, cross-directory/system locale resolution, non-UTF-8 source encodings, broader X.Org keysym definitions, or syntax outside the in-app subset. The host converter applies its own canonical-root and symlink policy; its detailed limits are documented above.

This conversion runs inside the freestanding editor using bounded buffers, temporary mappings, and Linux syscalls. It does not launch Python or a helper process. The generated locale remains a separate data-only pack: importing does not add locale tables to the editor executable or modify the built-in en_US dataset.
