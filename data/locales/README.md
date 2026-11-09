# pt_BR.UTF-8 Compose locale data

This directory contains three non-en_US Compose datasets. Each JSON file is a **complete flattened table**, built from the pinned X.Org en_US Compose baseline plus its locale's `Multi_key` and dead-key additions and overrides. They are not small overlays.

## Reproducible source pins

- Base and locale data: [mirror/libX11](https://github.com/mirror/libX11), commit \`ff8706a5eae25b8bafce300527079f68a201d27f\`.
- Base file: \`nls/en_US.UTF-8/Compose.pre\`, blob \`84888ef02bc1aa0ecaa939f59fcf4b10e5e7b3df\`.
- Brazilian Portuguese file: \`nls/pt_BR.UTF-8/Compose.pre\`, blob \`29846c63171d944c34a320376051591da2a2df3b\`. It includes the en_US table and adds/overrides locale rules.
- Keysym values: [X11Libre/mirror.fdo.xorgproto](https://github.com/X11Libre/mirror.fdo.xorgproto), commit \`6d3907b6d5dc4aa7d7ee6ee5d7d8714e7466630b\`.
- Keysym header: \`include/X11/keysymdef.h\`, blob \`96d056662e822701a591f461842ac8c0e17fb560\`.

The locale-import workflow downloads these exact commits, verifies their Git blob IDs, regenerates the JSON, and compares it byte-for-byte before building the \`.nlp\` asset.

## Included scope and filtering

- The importer follows the single en_US include, then applies pt_BR rules as overrides.
- XKB Multi_key rules import two to four following keysyms when each resolves to a Unicode scalar. Recognized dead_* actions import when followed by exactly one Unicode scalar; the action is normalized to its combining mark and stored in a separate dead_key namespace.
- Output strings retain 1–8 Unicode scalars, including combining marks and variation selectors.
- Non-Unicode input keysyms, unsupported sequence depths, dead-key rules requiring multiple following keysyms, and invalid scalar values are omitted.
- Prefix ambiguity is removed independently within each rule kind, so a Multi_key rule and dead-key rule may share the same scalar inputs.
- pt_BR contains 4,136 records: 3,448 two-scalar, 582 three-scalar, and 106 four-scalar records; 246 records have multi-scalar output.

The generated binary is not embedded in NekoEdit. \`make locale-packs\` builds it in \`build/locales/\`; the normal Actions build uploads it separately, and the locale-pack Release workflow attaches the \`.nlp\` asset and this notice when a GitHub Release is published.

See [NOTICE](pt_BR.UTF-8.NOTICE.txt) for source attribution and licensing references.


## fi_FI.UTF-8 and sr_RS.UTF-8

The additional datasets use the same pinned en_US Compose baseline and xorgproto keysym definitions above. Their locale source files and Git blobs are:

| Locale | Upstream source path | Git blob | Final records | Multi_key source lines | Dead-key source lines | Multi_key overrides | Dead-key overrides |
|---|---|---|---:|---:|---:|
| `fi_FI.UTF-8` | `nls/fi_FI.UTF-8/Compose.pre` | `bebab219d279670dde30c2260f5712c9d311f1d5` | 4,132 | 6 | 278 | 5 | 278 |
| `sr_RS.UTF-8` | `nls/sr_RS.UTF-8/Compose.pre` | `68699325c905629f8fa22f94e5848fd06e6be9fe` | 4,147 | 40 | 50 | 36 | 38 |

Finnish contributes six accepted locale-specific Multi_key rules and 278 dead-key rules (all overriding shared base entries). Serbian contributes forty accepted Multi_key rules for Cyrillic accent composition and fifty locale dead-key rules, of which 38 override base entries and 12 add new inputs. The Brazilian Portuguese source contributes nine accepted locale Multi_key rules and two dead-key overrides; in particular, dead acute plus `c` and `C` produce `ç` and `Ç`. The generated tables retain source-line and unsupported-rule statistics.

The Build and test workflow fetches all three locale files from the pinned libX11 revision and verifies their blob IDs before regenerating the data. The importer receives each locale-specific source blob through `--locale-compose-blob`; all generated JSON files must compare byte-for-byte with the committed data before the packs are uploaded.
