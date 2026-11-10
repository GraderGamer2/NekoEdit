# NekoEdit Compose locale data

This directory contains four non-en_US Compose datasets. Each JSON file is a **complete flattened table**, built from the pinned X.Org en_US Compose baseline plus its locale's `Multi_key` and dead-key additions and overrides. They are not small overlays.

## Reproducible source pins

- Base and locale data: [mirror/libX11](https://github.com/mirror/libX11), commit \`ff8706a5eae25b8bafce300527079f68a201d27f\`.
- Base file: \`nls/en_US.UTF-8/Compose.pre\`, blob \`84888ef02bc1aa0ecaa939f59fcf4b10e5e7b3df\`.
- Brazilian Portuguese file: \`nls/pt_BR.UTF-8/Compose.pre\`, blob \`29846c63171d944c34a320376051591da2a2df3b\`. It includes the en_US table and adds/overrides locale rules.
- Keysym values: [X11Libre/mirror.fdo.xorgproto](https://github.com/X11Libre/mirror.fdo.xorgproto), commit \`6d3907b6d5dc4aa7d7ee6ee5d7d8714e7466630b\`.
- Keysym header: \`include/X11/keysymdef.h\`, blob \`96d056662e822701a591f461842ac8c0e17fb560\`.

The locale-import workflow downloads these exact commits, verifies their Git blob IDs, regenerates the JSON, and compares it byte-for-byte before building the \`.nlp\` asset.

## Included scope and filtering

- For pt_BR, fi_FI, and sr_RS, the importer follows the locale's en_US include and applies locale rules as overrides. The standalone el_GR source does not contain an include; the explicit `--locale-standalone` mode merges its rules over the same pinned en_US baseline.
- XKB Multi_key rules import two to four following keysyms when each resolves to a Unicode scalar. Recognized dead_* actions import as a chain of one to three actions followed by one Unicode scalar; each action is normalized to its combining mark and stored in a separate dead_key namespace.
- Output strings retain 1–8 Unicode scalars, including combining marks and variation selectors.
- Non-Unicode input keysyms, unsupported sequence depths, dead-key chains exceeding three actions, invalid intermediate/final dead-key events, and invalid scalar values are omitted.
- Prefix ambiguity is removed independently within each rule kind, so a Multi_key rule and dead-key rule may share the same scalar inputs.
- pt_BR contains 4,484 records: 3,448 two-scalar, 894 three-scalar, and 142 four-scalar records; 274 records have multi-scalar output.

The generated binary is not embedded in NekoEdit. \`make locale-packs\` builds it in \`build/locales/\`; the normal Actions build uploads it separately, and the locale-pack Release workflow attaches the \`.nlp\` asset and this notice when a GitHub Release is published.

See [NOTICE](pt_BR.UTF-8.NOTICE.txt) for source attribution and licensing references.


## fi_FI.UTF-8, sr_RS.UTF-8, and el_GR.UTF-8

The additional datasets use the same pinned en_US Compose baseline and xorgproto keysym definitions above. Their locale source files and Git blobs are:

| Locale | Upstream source path | Git blob | Final records | Multi_key source lines | Dead-key source lines | Multi_key overrides | Dead-key overrides |
|---|---|---|---:|---:|---:|
| `fi_FI.UTF-8` | `nls/fi_FI.UTF-8/Compose.pre` | `bebab219d279670dde30c2260f5712c9d311f1d5` | 4,488 | 6 | 346 | 5 | 338 |
| `sr_RS.UTF-8` | `nls/sr_RS.UTF-8/Compose.pre` | `68699325c905629f8fa22f94e5848fd06e6be9fe` | 4,495 | 40 | 50 | 36 | 38 |
| `el_GR.UTF-8` | `nls/el_GR.UTF-8/Compose.pre` | `4a644258ce32cd34ddcc0c47605938db5f697b7d` | 5,730 | 922 | 970 | 394 | 234 |

The refreshed common en_US baseline contributes 1,576 accepted dead-key records (348 more than the previous generated table), which are included in each flattened locale pack. Finnish contributes six accepted locale-specific Multi_key rules and 346 dead-key rules, of which 338 override shared base entries and eight add new inputs. Serbian contributes forty accepted Multi_key rules for Cyrillic accent composition and fifty locale dead-key rules, of which 38 override base entries and 12 add new inputs. The Brazilian Portuguese source contributes nine accepted locale Multi_key rules and two dead-key overrides; in particular, dead acute plus `c` and `C` produce `ç` and `Ç`. The generated tables retain source-line and unsupported-rule statistics. The Greek source contributes 922 accepted locale Multi_key rules and 970 supported dead-key rules, with 628 total overrides (394 Multi_key and 234 dead-key overrides); its standalone source is merged over en_US by the explicit importer mode.

The Build and test workflow fetches all four locale files from the pinned libX11 revision and verifies their blob IDs before regenerating the data. The importer receives each locale-specific source blob through `--locale-compose-blob`; all generated JSON files must compare byte-for-byte with the committed data before the packs are uploaded.


## el_GR.UTF-8

The Greek dataset uses the same pinned en_US baseline and xorgproto keysym definitions. Its source file is standalone (it does not include en_US); the reproducible importer therefore merges the en_US baseline explicitly and then applies the Greek locale rules. The source file is `nls/el_GR.UTF-8/Compose.pre` (Git blob `4a644258ce32cd34ddcc0c47605938db5f697b7d` in libX11 commit `ff8706a5eae25b8bafce300527079f68a201d27f`).

The standalone Greek source includes Latin-1 and Greek/ISO 8859-7 Compose material plus a Greek Extended section credited in the upstream file to Vasilis Vasaitis, based on the idea and initial implementation by Alejandros Diamandidis. The importer retains only records whose input keysyms resolve to Unicode scalars, supports two to four total inputs for dead-key rules (one to three marks followed by a base scalar), and drops shorter ambiguous prefixes. Multi-key rules and dead-key records remain typed and separate in NLP1.

The Build and test workflow verifies the exact libX11 blob before running \`tools/import_xcompose.py --locale-standalone\`; it compares the regenerated JSON byte-for-byte with the committed dataset before creating the separate \`.nlp\` pack. See [NOTICE](el_GR.UTF-8.NOTICE.txt) for source attribution and licensing references.
