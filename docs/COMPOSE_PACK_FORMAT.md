# Optional Compose locale-pack format (NLP1)

NekoEdit keeps the default **en_US.UTF-8** Compose tables in the core executable. An optional locale pack can be installed at:

`$HOME/.nekoedit/locales/<locale-tag>.nlp`

Select it explicitly with `NEKOEDIT_LOCALE=<locale-tag>`. With no setting, the built-in en_US locale remains active. Explicit built-in names (`en_US`, `en_US.UTF-8`, `C`, and `POSIX`) also select the embedded default. Missing, incompatible, or malformed packs fall back atomically to en_US.

A selected pack is the complete Compose table for its locale. It does not overlay or merge with en_US. This keeps precedence deterministic. Records are typed as either `Multi_key` sequences or dead-key sequences; the two namespaces remain independent.

## Binary layout

All integers are unsigned little-endian. The header is exactly 72 bytes:

| Offset | Type | Meaning |
|---:|---|---|
| 0 | 8 bytes | ASCII magic `NEKOLOC1` |
| 8 | u32 | Format version, currently 1 |
| 12 | u32 | Header size, exactly 72 |
| 16 | u32 | Record size, exactly 52 |
| 20 | u32 | Record count, 1–32,768 |
| 24 | u32 | Payload byte length, exactly count × 52 |
| 28 | u32 | IEEE CRC-32 of the payload |
| 32 | u32 | Flags, zero in version 1 |
| 36 | 32 bytes | NUL-terminated ASCII locale tag, zero-padded |
| 68 | u32 | Reserved, zero |

Each 52-byte record contains a one-byte input count, one-byte output count, a 16-bit rule kind, four input scalars, and eight output scalars. Kind `0` is a `Multi_key` rule; kind `1` is a dead-key rule. The low byte stores the kind and the high byte must remain zero. Old version-1 packs used zero in both bytes, so they remain valid and are interpreted as `Multi_key`-only packs. Input count is 2–4; output count is 1–8. Unused scalar slots must be zero. A dead-key input is stored as `[combining-mark scalar, following base scalar]`.

Scalars must be nonzero Unicode scalar values no greater than U+10FFFF and outside the surrogate range. Multi-scalar results can represent combining marks and variation selectors.

Records are strictly sorted by `(rule kind, input sequence)`. Duplicate inputs and prefix ambiguity are rejected within each kind, but the same scalar tuple may exist once as `Multi_key` and once as a dead-key rule. This allows immediate resolution without timers or delayed insertion.

The runtime validates version, header and record sizes, locale-tag match, flags/reserved fields, file and record-count bounds, payload length, CRC-32, sequence ordering, prefix ambiguity, output lengths, and all used/unused scalar slots. Files larger than 2 MiB are rejected. The pack is mapped read-only only after structural validation; invalid files are unmapped and ignored.

## Build a pack

The standard-library-only generator accepts JSON:

```json
{
  "locale": "fr_FR.UTF-8",
  "sequences": [
    {"kind": "multi_key", "input": ["U+006F", "U+0069"], "output": ["U+2603", "U+FE0F"]},
    {"kind": "multi_key", "input": ["U+0079", "U+0075", "U+0069"], "output": ["U+2605"]},
    {"kind": "multi_key", "input": ["U+0077", "U+0065", "U+0072", "U+0074"], "output": ["U+1F642"]},
    {"kind": "dead_key", "input": ["U+0301", "U+0063"], "output": ["U+00E7"]}
  ]
}
```

Build and install:

```sh
python3 tools/compose_pack.py build --input fr_FR.json --output fr_FR.UTF-8.nlp
install -Dm600 fr_FR.UTF-8.nlp "$HOME/.nekoedit/locales/fr_FR.UTF-8.nlp"
NEKOEDIT_LOCALE=fr_FR.UTF-8 ./nekoedit
```

Packs are data, not shared libraries or executable plugins. Python is used only by the release/build-time generator and tests; it is not required by the editor at runtime.

## Implementation boundary

The loader and input path support two-, three-, and four-scalar records and output strings of up to eight scalars. Kind 0 is used by `Multi_key` lookup and buffering; kind 1 is queried immediately after a dead-key action and its following scalar. Old packs with a zero kind field continue to load as kind 0. The embedded en_US tables remain unchanged and active whenever no compatible optional pack is selected.


## First external locale dataset: pt_BR.UTF-8

The repository includes reproducible Brazilian Portuguese, Finnish, and Serbian datasets derived from the pinned X.Org libX11 en_US Compose baseline and locale overrides, with keysym-to-Unicode values resolved using the pinned xorgproto `keysymdef.h`. The importer flattens the en_US include, imports `Multi_key` rules with two to four Unicode scalar inputs, and imports recognized dead-key actions followed by one Unicode scalar. A dead-key action is normalized to its combining mark and stored as a kind-1 `[mark, base]` pair. Non-Unicode input symbols and dead-key sequences requiring multiple following symbols remain outside the supported subset. Shorter prefixes are dropped independently within each rule kind.

The committed source databases are [`data/locales/pt_BR.UTF-8.json`](../data/locales/pt_BR.UTF-8.json), [`fi_FI.UTF-8.json`](../data/locales/fi_FI.UTF-8.json), and [`sr_RS.UTF-8.json`](../data/locales/sr_RS.UTF-8.json), with source pins, filter statistics, and attribution in [`data/locales/README.md`](../data/locales/README.md) and [`pt_BR.UTF-8.NOTICE.txt`](../data/locales/pt_BR.UTF-8.NOTICE.txt). Rebuild from the committed JSON with:

```sh
make locale-packs
```

The standard build workflow verifies the pinned upstream inputs, regenerates the JSON, and uploads the generated `.nlp` pack as a separate artifact. The locale-pack Release workflow repeats that verification and attaches both the pack and notice when a GitHub Release is published.


## Settings selection

With valid packs installed at `~/.nekoedit/locales/<tag>.nlp`, open **Settings → Locale** to display a dropdown containing built-in en_US and every installed pack. The list is read from the private locale directory whenever Settings opens and is refreshed after Add or Remove, so selecting an already-installed pack does not open a file picker. Choose an entry with the mouse or Up/Down followed by Enter; Escape dismisses the dropdown. The selected filename determines the locale tag, and the loader validates the file header and embedded tag before activation. Selecting built-in en_US explicitly suppresses environment overrides.

**Settings → Add** opens a local `.nlp` source-file picker. Its path row is explicitly labeled **SOURCE**, while the destination is shown beside it as **TARGET: `~/.nekoedit/locales/`**. The application validates the selected file before atomically copying it to `~/.nekoedit/locales/<locale-tag>.nlp`; the original source file is left untouched. The private `.nekoedit` and `locales` directories are created with mode 0700, and installed packs use mode 0600. **Settings → Remove** requests confirmation, validates the currently selected installed file, and removes only that pack. Removing the active or persisted pack returns the selection to en_US and refreshes the dropdown. Add/Remove do not perform network downloads.


## Automatic character-locale selection

When no non-empty saved Settings preference is present, the runtime checks locale variables in this order:

1. NEKOEDIT_LOCALE (NekoEdit-specific explicit override)
2. LC_ALL
3. LC_CTYPE
4. LANG

The first non-empty value is used as the locale tag. Empty values are ignored. For the current pt_BR dataset, `pt_BR`, `pt_BR.utf8`, and `pt_BR.UTF8` resolve to the canonical pack tag `pt_BR.UTF-8`. C/POSIX spellings select built-in en_US. An unsupported non-empty higher-priority locale does not fall through to a lower-priority variable; it leaves the built-in fallback active. LC_MESSAGES and LANGUAGE are intentionally ignored because they control message translation rather than character input locale. A saved Settings selection always takes precedence over these variables. C, C.UTF-8, C.utf8, and POSIX select the embedded en_US fallback. If the selected optional locale pack is absent or invalid, the loader also leaves en_US active.


## Additional locale datasets

Three reproducible tables are included: pt_BR.UTF-8, fi_FI.UTF-8, and sr_RS.UTF-8. Their pinned source inputs, per-locale Git blob IDs, filtering statistics, and attribution are recorded in data/locales/README.md.

The importer flattens the en_US include and applies locale overrides separately for Multi_key and dead-key rules. It keeps input keysyms only when they map to Unicode scalars. Multi_key sequences support two to four scalars. A dead-key rule supports a recognized dead_* action followed by one scalar; the action is normalized to its combining mark. Longer dead-key chains, non-Unicode input symbols, and unsupported sequence depths remain outside the supported subset. Shorter-prefix removal is scoped to the same rule kind.

NLP1 uses the former 16-bit reserved record field for the rule kind. Kind zero is Multi_key; kind one is dead-key. Older version-1 packs have a zero value in that field, remain compatible, and are treated as Multi_key-only packs. The standard build verifies all pinned source blobs, regenerates the three JSON inputs byte-for-byte, and uploads generated locale packs separately from the editor executable. The Release workflow attaches every generated .nlp file and matching notice.
