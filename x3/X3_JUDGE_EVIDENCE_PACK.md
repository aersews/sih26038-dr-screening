# X3 — Judge Evidence Pack (Team MMC 148873 · v9.0 closure)

> Companion to `X3_FINAL_EVIDENCE_MATRIX.csv`. Every non-FGADR item below is verified present on disk with
> paths given relative to `sih26038_v9_0\`. FGADR-referenced artifacts are **excluded/withheld** from this
> repository: their paths and metrics are historical records only, so this pack covers the non-FGADR
> evidence only and must not be read as confirming that FGADR artifacts are available. Status labels are
> factual (evidence/status), never scores.

> **FGADR evidence withheld.** FGADR-derived material (dataset, images, masks, checkpoints, results, and the `x3/step4b_fgadr/` pathway) is excluded from this repository pending authorization and redistribution review. FGADR is licensed for non-commercial research only and its images may not be redistributed. Every FGADR number, file path, and status below is a historical record only: those artifacts are not distributed here, cannot be reproduced or verified from this repository, and must not be cited as evidence contained in this repository. All non-FGADR evidence (X1, X2, fovea and classical lesion prototypes, MATLAB/Simulink integration) is unaffected.

---

## 1. What this pack contains (5 deliverables)

| # | Deliverable | Path |
|---|-------------|------|
| 1 | Requirement closure audit | `x3\X3_SIH_REQUIREMENT_CLOSURE_AUDIT.md` |
| 2 | Final evidence matrix | `x3\X3_FINAL_EVIDENCE_MATRIX.csv` |
| 3 | Judge evidence pack (this file) | `x3\X3_JUDGE_EVIDENCE_PACK.md` |
| 4 | Demo cases bundle | `x3\X3_DEMO_CASES\` |
| 5 | Simulink summary | `x3\X3_SIMULINK_SUMMARY.csv` |

---

## 2. A/B/C/D closure audit — headline result

Source: `x3\X3_SIH_REQUIREMENT_CLOSURE_AUDIT.md` (all SIH26038 v9.0 PS rows 1a–6d mapped).

- **A (fully satisfied)**: 3a, 3b, 3c, 4c
- **B (functionally satisfied / prototype-level)**: 1a, 1b, 1c, 2a, 2b, 2c, 2d, 2e, 2f, 4a, 4b, 4d, 5a, 5b, 6b, 6c, 6d
- **C (missing)**: 6a — clinician validation (no qualified clinician accessible; NOT EXECUTED)
- **D (explicitly deferred/downgraded, not hidden)**: none for lesions — v8.12 classical D entries (2c/2d/2e) were replaced as the evidence path by the trained FGADR prototype (Step 4b); the classical results remain recorded as baseline.

Nothing is fabricated; every D/C row is a stated honesty gap with a recorded reason (for FGADR-gated rows that reason rests on withheld historical records, not on artifacts in this repository).

---

## 3. Headline evidence (exact numbers from disk)

### 3.1 Frozen pipeline (X1C2 + X2 policy) — NOT re-run, single-shot confirmed
- Locked APTOS test (n=732, once): **QWK 0.9027, argmax sens 0.9192, spec 0.9333**; 0 missed referable.
  `metrics\X1\x1_locked_test_report.json`, `metrics\X2\x2_final_locked_test.json`
- Calibration T=1.25; frozen max-spec cutoff sens 0.8620 < 0.90 → **honest negative, do not deploy**.
- Ablation A/B/C/D (`metrics\X2\X2_ABLATION.csv`): routing+reporting converts 20 missed-referable → 0.
- MATLAB/ONNX parity <1e-5; Simulink 100k/yr feasible (validation-only; labeled MODELED CAPACITY).

### 3.2 X3 closure work (this sprint, isolated/labeled)
- **Fovea localizer (IDRiD C, test n=103 single-shot)** — `x3\step5_fovea\`:
  - v2 (pretrained backbone, train-only): median 273 px, 32.0% within 200 px, 4.9% within 50 px.
  - Beats constant-centroid baseline (312 px / 23.3%) and v1/historical heuristic (0 valid outputs → honest negative).
  - Status: `PROTOTYPE/EXPERIMENTAL`, not clinical. — requirement **2a → B**.
- **Classical lesion detector (IDRiD A, test n=27, no training)** — `x3\step4_lesion\`:
  - EX: dice 0.125 / comp-recall 0.796 / comp-precision 0.128; HE: dice 0.076; MA/SE not attempted.
  - Status: candidate-highlight prototype only (kept as baseline).
- **FGADR-trained lesion-evidence prototype (MA/HE/EX/SE)** — `x3\step4b_fgadr\`:
  - Locked split 80/10/10 (train 1479 / val 182 / test 181, stratified, dup-pairs single-split, no leakage).
  - UNet from scratch (7.49M params), per-class Tversky loss, fp32, best epoch 92, ~3 h on RTX A2000.
  - Locked test (FOV-masked, per-image positive-GT): **MA dice 0.256 / HE 0.461 / EX 0.513 / SE 0.407** (mean 0.409; n=181). `FGADR_RESULTS.json`, `FGADR_TEST_METRICS.csv`.
  - Single-shot external check (IDRiD A test n=27, no tuning, letterbox 1280): **EX 0.370 / SE 0.195 / HE 0.164 / MA 0.059** — EX generalizes, MA weak cross-domain. `FGADR_EXTERNAL_IDRID_RESULTS.json`.
  - Overlays (4 montages + panels) `overlays\`; lesion-evidence reports `reports\lesion_report_*.txt`.
  - Status: `PROTOTYPE/EXPERIMENTAL`, not clinical. — **2c/2d/2e → B**, **4b → B** (report integration).
  - NV: FGADR NV = 49 positives (2.7%) → `INSUFFICIENT_DATA / EXPERIMENTAL-ONLY`, not trained as a detector.
- **Explainability review** — `x3\X3_CLINICAL_EXPLAINABILITY_REVIEW.md`: 4 demo cases verified coherent,
  attention-only framing. Path bug fixed (`x3\x3_step6_fix_paths.py`). **Clinician validation NOT EXECUTED.**
- **Messidor-2** — `x3\X3_MESSIDOR_PROBE_CONFINEMENT_STATEMENT.md`: data IS present at `data\messidor-2`
  (1744 imgs; prior record path typo corrected). Labels third-party → **no severity claim; NOT_EVALUATED**.

---

## 4. Demo cases bundle — `x3\X3_DEMO_CASES\`

Ready to hand to a judge/end-user without opening the project (non-FGADR cases only — see the FGADR sub-section below for withheld material):

| File | Source | What it shows |
|------|--------|---------------|
| `case1_non_referable_good_quality.png` | `explainability\X2\X2_EXPLAINABILITY_CASES\case1_…png` | Grad-CAM on a non-referable good-quality image → routed to auto-screen |
| `case2_referable_good_quality.png` | `…\case2_…png` | Referable → routed to human, attention on lesions |
| `case3_low_quality_review.png` | `…\case3_…png` | Quality-gate fail → review queue |
| `case4_uncertain_review.png` | `…\case4_…png` | High-uncertainty → review queue |
| `report_non_referable_good_quality.txt` | `reports\X2\X2_REPORT_EXAMPLES\` | Generated clinician-facing report |
| `report_referable_good_quality.txt` | 〃 | Referable report |
| `report_low_quality_review.txt` | 〃 | Review-needed report |
| `report_uncertain_review.txt` | 〃 | Review-needed report (uncertainty) |
| `fovea_v2_test_IDRiD_003/_047/_099.png` | `x3\step5_fovea\overlays\` | Fovea-localizer overlay (pred vs GT center) |
| `lesion_IDRiD_55/56/57_EX.png` + `_HE.png` | `x3\step4_lesion\overlays\` | Classical EX/HE detector overlays on test images |
| `X3_SIMULINK_SUMMARY.csv` | `x3\` | Queue-model + annualized capacity table |

### FGADR lesion-evidence demo (max Dice per class, from test split) — **WITHHELD, not distributed**
| Case | Metric | Overlay (montage) |
|------|--------|-------------------|
| MA `1832_2` | dice 0.754 | `x3\step4b_fgadr\overlays\case_MA_1832_2_montage.png` |
| HE `0627_3` | dice 0.813 | `x3\step4b_fgadr\overlays\case_HE_0627_3_montage.png` |
| EX `1091_2` | dice 0.871 | `x3\step4b_fgadr\overlays\case_EX_1091_2_montage.png` (fused all-class evidence: `overlays\evidence_EX_1091_2_fused.png`) |
| SE `0174_2` | dice 0.899 | `x3\step4b_fgadr\overlays\case_SE_0174_2_montage.png` |

All non-FGADR copies are exact file copies (no resizing/cropping) so numbers shown in any overlay match the source PNGs. The FGADR montages/panels listed above and the `fgadr_*` files in `x3\X3_DEMO_CASES\` are **withheld**: they are not distributed here and cannot be inspected or verified from this repository.

---

## 5. Honesty checklist (signed in `X3_SIH_REQUIREMENT_CLOSURE_AUDIT.md`)

- [x] No fabricated metric; every non-FGADR `EXECUTED` maps to a file in this repository. FGADR `EXECUTED` entries map to **withheld** artifacts only and are historical records.
- [x] 6a clinician validation reported as NOT EXECUTED (not silently omitted).
- [x] 2c/2d/2e upgraded from D to B via the trained FGADR prototype (Step 4b) with real locked-test + external metrics — **recorded, but the FGADR evidence is withheld from this repository and was not available to the reviewer**; the classical D results remain recorded as baseline, not deleted.
- [x] NV reported `INSUFFICIENT_DATA / EXPERIMENTAL-ONLY` (FGADR 49 positives, withheld historical record); no manufactured NV benchmark.
- [x] Messidor confined: data presence corrected, no claim made, labels flagged third-party.
- [x] Frozen X1/X2 evidence untouched (this sprint added only `x3\*` files).
- [x] Prototype status labels used (`PROTOTYPE/EXPERIMENTAL`) wherever generalization is limited.