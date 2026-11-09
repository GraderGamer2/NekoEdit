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

With the pack installed at `~/.nekoedit/locales/pt_BR.UTF-8.nlp`, choose **Settings → COMPOSE LOCALE → pt_BR**. The selection is stored in `~/.nekoedit/preferences`. A stored choice takes precedence over `NEKOEDIT_LOCALE`; if there is no saved preference, the environment variable remains available as a first-run override. Selecting `en_US` stores the built-in choice and suppresses an environment override. A missing/invalid selected pack leaves built-in en_US active and Settings displays `MISSING`.

Settings selection does not install or download locale data. Install a release asset or copy a locally built pack into the locale directory first.
