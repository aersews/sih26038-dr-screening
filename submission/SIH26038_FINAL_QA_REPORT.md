# SIH26038 – FINAL PRESENTATION QA REPORT (v9.0)

> **FGADR evidence withheld.** FGADR-derived material (dataset, images, masks, checkpoints, results, and the `x3/step4b_fgadr/` pathway) is excluded from this repository pending authorization and redistribution review. FGADR is licensed for non-commercial research only and its images may not be redistributed. Every FGADR number, file path, and status below is a historical record only: those artifacts are not distributed here, cannot be reproduced or verified from this repository, and must not be cited as evidence contained in this repository. All non-FGADR evidence (X1, X2, fovea and classical lesion prototypes, MATLAB/Simulink integration) is unaffected.

Project: Explainable AI for Diabetic Retinopathy Screening in Rural India
Team: MMC (148873) · Motihari College of Engineering
Artifacts built from official template: `SIH2026-IDEA-Presentation-Format.pptx`
Output directory: `sih26038_v9_0\submission\`

| Artifact | Path | Status |
|---|---|---|
| Deck (PPTX) | `submission\SIH26038_MMC_FINAL_DECK.pptx` | OK |
| Deck (PDF) | `submission\SIH26038_MMC_FINAL_DECK.pdf` | OK |
| Slide previews | `submission\preview\slide_01..06.png` | OK |

---

## 1. STRUCTURAL QC

- Slide count (PPTX): **6** — instructions slide 7 removed from template; no 7th content slide added.
- Slide count (PDF): **6** (pdf page count = 6).
- Official template preserved on every slide: title placeholder / footer "@SIH Idea submission- Template" / slide-number placeholders (2–6) / top-right SIH header graphic / team-name oval.
- Slide layout order: 1 Title · 2 IDEA TITLE · 3 TECHNICAL APPROACH · 4 FEASIBILITY AND VIABILITY · 5 IMPACT AND BENEFITS · 6 RESEARCH AND REFERENCES.
- Geometry audit: 0 shapes out-of-bounds on the 13.33×7.5 in canvas; 1 flagged tight text box (slide 5 benefit card, 9.5 pt / 2-line wrap — acceptable).
- Embedded images verified byte-identical to source artifacts (SHA-256 match, no repackaging): hero `case2_referable_good_quality.png`, montage `case_EX_1091_2_montage.png`; aspect ratios preserved (no distortion).

## 2. MAJOR NUMERICAL CLAIMS → SOURCE TRACE

| Claim (as printed) | Value in deck | Source artifact | Split / qualifier |
|---|---|---|---|
| QWK | 0.9027 | `metrics\X2\x2_final_locked_test.json` (QWK in platform run report 0.9027) | Locked APTOS test n=732, one-shot. |
| Referable sensitivity | 91.92% | `metrics\X2\x2_final_locked_test.json` | Locked test n=732. |
| Specificity | 93.33% | `metrics\X2\x2_final_locked_test.json` | Locked test n=732. |
| ROC AUC | 0.9792 | `metrics\X2\x2_final_locked_test.json` | Locked test n=732. |
| n = 732 | 732 | `x2_final_locked_test.json` `n_test` | Locked test. |
| Routing counts 161 / 269 / 302 / 0 (recapture) | 161, 302 shown | `w.policy_on_test.route_counts` | Evaluated workflow on locked test. |
| 0 missed referable | 0 | `workflow_policy_on_test.missed_referable_auto_screened=0` | Evaluated workflow only. |
| MATLAB/ONNX parity | ≈6.7e-6 (max diff) | `matlab\X2\results\*_matlab_onnx_parity*.json` | ONNX→MATLAB; Python→ONNX ≈8.1e-6 captioned separately. |
| FGADR mean Dice | 0.409 | `x3\step4b_fgadr\FGADR_RESULTS.json` / `FGADR_TEST_METRICS.csv` | FGADR test split; labelled PROTOTYPE. |
| Per-class (MA/HE/EX/SE) | 0.256/0.461/0.513/0.407 | `FGADR_RESULTS.json` | Labelled PROTOTYPE everywhere. |
| EX case Dice | 0.871 (1091_2) | `FGADR_TEST_METRICS.csv` | Demonstration case only. |
| OD structural Dice | 0.897 | `idrid_lesion_results_v8_12.json` (optic-disc segmentation) | Labelled STRUCTURAL EVIDENCE (not lesion). |
| Fovea median | 273 px; 32% within 200 px | `x3\step5_fovea\x3_fovea_prototype_v2_results.json` | Labelled PROTOTYPE. |
| Modeled capacity | ≈346,000 / year | `matlab\X2\results\simulink_result_v9_0.json` | Labelled "MODELED CAPACITY — Simulink simulation, not deployed". |

## 3. TECHNICAL-LANGUAGE RULES AUDIT

- T=1.25 written as **"temp. scaling + argmax"** — never "operating point"/"threshold". ✔
- MATLAB wording: "ONNX export + parity 6.7e-6 · PyTorch model exported via ONNX" — never "trained in MATLAB". ✔
- Simulink wording: "queue / workflow simulation" — never "SimEvents". ✔
- FGADR explicitly "PROTOTYPE"; NV absent from headline, "insufficient data / experimental-only" in limitations. ✔
- Clinician review shown as **pending / next validation** with explicit "not yet executed". ✔
- "AI-assisted screening ≠ autonomous diagnosis" emphasized on slides 2 and 5. ✔
- Grad-CAM described as "classifier attention evidence". ✔
- ~~346k~~ always suffixed "MODELED"; no deployment/validation claim. ✔
- No clinical-validation, diagnostic, replacement, or DRIVE-official-test claims. ✔ (forbidden-word scan clean)

## 4. EVIDENCE FILES USED (visuals / sources)

- `explainability\X2\X2_EXPLAINABILITY_CASES\case2_referable_good_quality.png` (slide 2 hero)
- `x3\step4b_fgadr\overlays\case_EX_1091_2_montage.png` (slide 3 lesion demo)
- `metrics\X2\x2_final_locked_test.json` (metrics strip, routing)
- `FGADR_RESULTS.json` / `FGADR_TEST_METRICS.csv` / `FGADR_MODEL_CONFIG.json` (lesion prototype)
- `matlab\X2\results\*parity*.json`, `simulink_result_v9_0.json` (parity + modeled capacity)
- `idrid_lesion_results_v8_12.json`, `fovea_prototype_v2_results.json` (structural/prototype evidence)

## 5. UNRESOLVED ISSUES / NOTES

- A real MATLAB/Simulink screenshot does **not** exist in the project files (only `.slx`). The deck therefore shows the MATLAB/ONNX parity result and queue-simulation summary instead of a fabricated screenshot. Slide 4 note covers this honestly.
- Template default body font (Arial) used for all added text; slide-1 title text (Garamond) untouched.
- Team metadata on slide 1 filled from the approved brief (SIH26038 / MedTech-BioTech-HealthTech / Software / 148873 / MMC / Motihari College of Engineering). No other names or claims invented.

**Result: 6 slides · zero unsupported claims · maximum judge clarity.**