# Optional Compose locale-pack format (NLP1)

NekoEdit keeps the default **en_US.UTF-8** Compose tables in the core executable. An optional locale pack can be installed at:

`$HOME/.nekoedit/locales/<locale-tag>.nlp`

Select it explicitly with `NEKOEDIT_LOCALE=<locale-tag>`. With no setting, the built-in en_US locale remains active. Explicit built-in names (`en_US`, `en_US.UTF-8`, `C`, and `POSIX`) also select the embedded default. Missing, incompatible, or malformed packs fall back atomically to en_US.

A selected pack is the complete Compose table for its locale. It does not overlay or merge with en_US. This keeps precedence deterministic. Locale-specific dead-key actions remain on NekoEdit's existing six-action path and are not overridden by NLP1 version 1.

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

Each 52-byte record contains a one-byte input count, one-byte output count, two zero reserved bytes, four input scalars, and eight output scalars. Input count is 2–4; output count is 1–8. Unused scalar slots must be zero.

Scalars must be nonzero Unicode scalar values no greater than U+10FFFF and outside the surrogate range. Multi-scalar results can represent combining marks and variation selectors.

Records are strictly lexicographically sorted by input sequence. Version 1 rejects duplicate sequences and prefix ambiguity (a complete sequence that is also the prefix of a longer sequence). This allows immediate resolution without timers or delayed insertion.

The runtime validates version, header and record sizes, locale-tag match, flags/reserved fields, file and record-count bounds, payload length, CRC-32, sequence ordering, prefix ambiguity, output lengths, and all used/unused scalar slots. Files larger than 2 MiB are rejected. The pack is mapped read-only only after structural validation; invalid files are unmapped and ignored.

## Build a pack

The standard-library-only generator accepts JSON:

```json
{
  "locale": "fr_FR.UTF-8",
  "sequences": [
    {"input": ["U+006F", "U+0069"], "output": ["U+2603", "U+FE0F"]},
    {"input": ["U+0079", "U+0075", "U+0069"], "output": ["U+2605"]},
    {"input": ["U+0077", "U+0065", "U+0072", "U+0074"], "output": ["U+1F642"]}
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

The loader and input path support two-, three-, and four-scalar sequences and output strings of up to eight scalars. The embedded en_US tables remain unchanged and active whenever no compatible optional pack is selected. Actual non-en_US release assets, a Settings locale selector, and an installer remain future work.


## First external locale dataset: pt_BR.UTF-8

The repository includes a reproducible Brazilian Portuguese dataset derived from the pinned X.Org libX11 en_US Compose baseline and pt_BR overrides, with keysym-to-Unicode values resolved using the pinned xorgproto `keysymdef.h`. The importer flattens the en_US include, applies locale overrides, imports only Multi_key rules whose input keysyms resolve to Unicode scalars, and removes shorter rules that prefix longer ones. Dead-key-led rules and non-Unicode input symbols are not represented by NLP1 version 1.

The committed source database is [`data/locales/pt_BR.UTF-8.json`](../data/locales/pt_BR.UTF-8.json), with source pins, filter statistics, and attribution in [`data/locales/README.md`](../data/locales/README.md) and [`pt_BR.UTF-8.NOTICE.txt`](../data/locales/pt_BR.UTF-8.NOTICE.txt). Rebuild from the committed JSON with:

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

Two additional reproducible tables are included beside pt_BR:

- **fi_FI.UTF-8** — six valid locale-specific `Multi_key` rules, five overriding an en_US result. The table has 2,904 final rules (2,217 pairs, 581 triples, 106 four-input sequences) and 100 multi-scalar outputs inherited from the base. Examples include the `fi` and `fl` ligatures and `ij` / `IJ` ligatures.
- **sr_RS.UTF-8** — 40 valid locale-specific `Multi_key` rules, 36 overriding the base table. The table has 2,907 final rules (2,221 pairs, 580 triples, 106 four-input sequences) and 106 multi-scalar results. Serbian additions compose grave, acute, circumflex, and double-grave accents with Cyrillic letters using base-plus-combining-mark output.

All three datasets share the pinned libX11 and xorgproto revisions; each locale Compose file has its own verified Git blob ID in its JSON source metadata. The importer accepts `--locale-compose-blob` so non-pt_BR locales cannot inherit the Portuguese source identifier. The standard build verifies every source blob, regenerates all three JSON files byte-for-byte, and uploads packs separately from the executable. The Release workflow attaches every generated `.nlp` file and matching notice.

NLP1 v1 imports only scalar-key `Multi_key` sequences. Finnish and Serbian source files also contain dead-key-specific rules; those are intentionally skipped and must not be mistaken for supported locale-specific dead-key behavior.
