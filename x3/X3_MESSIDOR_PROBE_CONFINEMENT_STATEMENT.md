# X3 — Messidor-2 Probe Confinement Statement (Step 10)

## 1. What the confinement requires
Messidor-2 is permitted only as a **robustness/probe dataset**, never as a source of an official clinical validation claim. Any reported number must carry `THIRD_PARTY_MESSIDOR2`; no severity claim from Messidor becomes part of the APTOS locked-test or frozen X1/X2 evidence.

## 2. Material finding: data is present (correction of the v8.12 record)
- v8.12 `messidor2_external_status_v8_12.json` / `phase7_messidor2_v8_12.json` recorded `data_present: false` because they checked `data/messidor2`.
- On 24 Sep 2026 this audit found the actual directory is **`../data/messidor-2`** relative to the repository root (hyphenated) and it **exists**:
  - 1 744 image rows in `messidor_data.csv` (columns `id_code`, `diagnosis` 0–4, `adjudicated_dme`, `adjudicated_gradable`); all rows `adjudicated_gradable = 1`.
  - 1 744 image files present (`preprocess\*.PP.png` + `IM*.JPG`); filename set == CSV id set (no orphans verified).
- Correction recorded in `X3_STEP10_MESSIDOR_CONFINEMENT.json`. The earlier "no data on disk" statement was a **path typo**, not a claim that the dataset is absent.

## 3. What is NOT claimed (unchanged honesty rules)
- **No Messidor-derived severity metric is added to the evidence matrix.** The X2/X1 evidence rows do not contain any Messidor number.
- The `diagnosis` column (0–4) is **third-party provenance** (this `messidor_data.csv` is not the official ADCIS label spreadsheet; official Messidor-2 does not ship DR ground truth for all exams in a single file). A 0–4 → ICDR 5-level equivalence was **not** verified against an official source in this audit, so **no severity-equivalence claim is made**.
- Consistent with PS row 4 ("Messidor-2 labels are third-party — any severity claim scoped THIRD_PARTY_LABELED, never official clinical validation"): if any future probe were run, it would be labeled `THIRD_PARTY_MESSIDOR2` and explicitly excluded from the locked-test/validation evidence.

## 4. Decision for X3
- Record the presence correction (above) and keep Messidor OUT of the evidence package as a scored claim.
- If time permits, a **probe** (varied external-input robustness sanity check, no severity claim) could be run and labeled `THIRD_PARTY_MESSIDOR2 / PROBE_ONLY`; it would live under `x3/probes/`, never in `metrics/X1|X2/`. Not executed in this pass to avoid any implication that Messidor is part of the validated envelope.

### Evidence references
- `metrics/…/messidor2_external_status_v8_12.json` (prior, path-typo negative)
- `X3_STEP10_MESSIDOR_CONFINEMENT.json` (this correction)