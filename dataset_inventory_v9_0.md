# Dataset Inventory — v9.0

Identifiers: IDs, paths, roles, label provenance, split policy, and v8.12 metrics per dataset. Frozen baseline v8.12 artifacts are audit references only.

| ID | Path | Role | Status | Images / Labels | Split policy & notes |
|---|---|---|---|---|---|
| **APTOS** | `data\aptos` | Primary DR grading | AVAILABLE | 3662 train, 1928 test · `train.csv` (id_code, diagnosis 0–4) · `test.csv` (id_code only) | locked internal train/val (`locked_split_ids_v8_12.json`); locked APTOS test = final single-shot only |
| **IDRiD** | `data\idrid` | Segmentation / grading / localization / external shift | AVAILABLE | A: 81 originals (54/27) + MA,HE,EX,SE,OD masks · B: 516 graded (413/103) DR 0–4 + DME · C: 516 (OD & fovea centers) | official splits; v8.12: OD Dice 0.897, lesion MA/EX/HE/SE ~0 (**HONEST_NEGATIVE**), localization median error ~1014–1073 px |
| **DRIVE** | `data\DRIVE` | Vessel segmentation | AVAILABLE | 40 official images (20 test channels / 20 training) + gold masks | FOV-masked dev Dice 0.683 (n=4); official test challenge-held, not locally scored |
| **MESSIDOR2** | `data\messidor-2` | Robustness / external sanity (**third-party labels**) | AVAILABLE — CAUTION | `messidor_data.csv` 1744 rows → 1744 files (1057 PNG + 687 JPG, all 512×512 RGB) · diagnosis 0=1017,1=270,2=347,3=75,4=35 · DME 1=151 · gradable all=1 | __Not official ADCIS release.__ CSV matches public third-party MESSIDOR-2 DR-grades collation; NOT usable as primary clinical validation |
| **FGADR** | — | — | NOT NEEDED | n/a | dropped for this sprint; no authorized access |

## Messidor-2 defensibility note
The on-disk labels (`diagnosis`, `adjudicated_dme`, `adjudicated_gradable`; all 1744 gradable, diagnosis mapped to DR grade columns) exactly match the widely mirrored third-party MESSIDOR-2 collation (google-brain / xyaustin mirror). The official MESSIDOR-2 dataset is distributed as **images + pairing spreadsheet only** — it does not ship images paired with official severity labels. **Any DR-severity claim built on these labels must be scoped THIRD-PARTY_LABELED and cannot substitute for clinical validation.**