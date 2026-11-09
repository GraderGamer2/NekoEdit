# pt_BR.UTF-8 Compose locale data

This directory contains NekoEdit's first non-en_US Compose dataset. The JSON is a **complete flattened table**, built from the pinned X.Org en_US Compose baseline with the Brazilian Portuguese locale's supported Multi_key additions and overrides. It is not a small overlay.

## Reproducible source pins

- Base and locale data: [mirror/libX11](https://github.com/mirror/libX11), commit \`ff8706a5eae25b8bafce300527079f68a201d27f\`.
- Base file: \`nls/en_US.UTF-8/Compose.pre\`, blob \`84888ef02bc1aa0ecaa939f59fcf4b10e5e7b3df\`.
- Brazilian Portuguese file: \`nls/pt_BR.UTF-8/Compose.pre\`, blob \`29846c63171d944c34a320376051591da2a2df3b\`. It includes the en_US table and adds/overrides locale rules.
- Keysym values: [X11Libre/mirror.fdo.xorgproto](https://github.com/X11Libre/mirror.fdo.xorgproto), commit \`6d3907b6d5dc4aa7d7ee6ee5d7d8714e7466630b\`.
- Keysym header: \`include/X11/keysymdef.h\`, blob \`96d056662e822701a591f461842ac8c0e17fb560\`.

The locale-import workflow downloads these exact commits, verifies their Git blob IDs, regenerates the JSON, and compares it byte-for-byte before building the \`.nlp\` asset.

## Included scope and filtering

- The importer follows the single en_US include, then applies pt_BR rules as overrides.
- Only sequences beginning with XKB \`Multi_key\` are imported. The leading action is removed; the remaining 2–4 input keysyms must resolve to Unicode scalars.
- Output strings retain 1–8 Unicode scalars, including combining marks and variation selectors.
- Dead-key-led sequences, non-Unicode input keysyms, unsupported sequence depths, and invalid scalar values are omitted. Locale-specific dead-key behavior is outside NLP1 version 1.
- If a shorter sequence prefixes a longer sequence, the shorter rule is dropped. This matches the runtime's immediate pair-resolution model and avoids timeout-based composition.
- The resulting pack has 2,908 rules: 2,220 two-input, 582 three-input, and 106 four-input rules. One hundred rules have multi-scalar output.

The generated binary is not embedded in NekoEdit. \`make locale-packs\` builds it in \`build/locales/\`; the normal Actions build uploads it separately, and the locale-pack Release workflow attaches the \`.nlp\` asset and this notice when a GitHub Release is published.

See [NOTICE](pt_BR.UTF-8.NOTICE.txt) for source attribution and licensing references.


## fi_FI.UTF-8 and sr_RS.UTF-8

The additional datasets use the same pinned en_US Compose baseline and xorgproto keysym definitions above. Their locale source files and Git blobs are:

| Locale | Upstream source path | Git blob | Final rules | Locale overrides |
|---|---|---|---:|---:|
| `fi_FI.UTF-8` | `nls/fi_FI.UTF-8/Compose.pre` | `bebab219d279670dde30c2260f5712c9d311f1d5` | 2,904 | 5 |
| `sr_RS.UTF-8` | `nls/sr_RS.UTF-8/Compose.pre` | `68699325c905629f8fa22f94e5848fd06e6be9fe` | 2,907 | 36 |

Finnish contributes six accepted locale-specific Multi_key rules: fi/fl/ij/IJ ligatures, long s, and the apostrophe-space-n sequence. Serbian contributes forty accepted Multi_key sequences for Cyrillic accent composition. The source files also contain dead-key sequences; these are excluded from NLP1 v1 because it represents Unicode scalar inputs only. The generated tables retain source-line and unsupported-rule statistics.

The Build and test workflow fetches all three locale files from the pinned libX11 revision and verifies their blob IDs before regenerating the data. The importer receives each locale-specific source blob through `--locale-compose-blob`; all generated JSON files must compare byte-for-byte with the committed data before the packs are uploaded.
