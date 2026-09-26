# X3 — SIH26038 Requirement Closure Audit

> **FGADR evidence withheld.** FGADR-derived material (dataset, images, masks, checkpoints, results, and the `x3/step4b_fgadr/` pathway) is excluded from this repository pending authorization and redistribution review. FGADR is licensed for non-commercial research only and its images may not be redistributed. Every FGADR number, file path, and status below is a historical record only: those artifacts are not distributed here, cannot be reproduced or verified from this repository, and must not be cited as evidence contained in this repository. All non-FGADR evidence (X1, X2, fovea and classical lesion prototypes, MATLAB/Simulink integration) is unaffected.

Audit date: 24 Sep 2026. Scope: every row of `SIH26038_REQUIREMENT_MATRIX_v9_0.md` mapped against ACTUAL frozen + v9.0 evidence. Freeze honored: X1C2 checkpoint, locked tests, X2 routing policy, MATLAB parity, and Simulink model are untouched.

Status legend (applied to every PS row, gaps not hidden):
- **A** = fully satisfied — frozen/executed evidence demonstrates the requirement within its scope.
- **B** = partial — implemented and demonstrable, but limited (heuristic-only, validity not clinically established, or a modeled capability).
- **C** = missing — not implemented at all.
- **D** = not demonstrated — attempted and measured as a negative result, or no evidence exists.

---

## A. Image Quality Assessment & Enhancement

| PS | Requirement | v8.12 status | X3 status | Evidence | Gap / verdict |
|---|---|---|---|---|---|
| 1a | Evaluate focus, illumination, field of view | PARTIAL | **B** | quality-gate computed and saved: `metrics/X2/x2_a_quality_gate.json`, `plots/X2/X2_QUALITY_DISTRIBUTION.png`, gate examples `plots/X2/x2_gate_example_*.png` | Implemented as a **HEURISTIC** (engineering features: sharpness/exposure/FOV/uniformity/directional). No externally-rated quality labels; labeled QUALITY_HEURISTIC. |
| 1b | Adaptive enhancement (CLAHE, illumination normalization, denoising) | PARTIAL | **B** | frozen preprocessing: CLAHE + `compute_fundus_crop` (cell 06); routed images through it in X2 | CLAHE + foreground crop present and executed. Explicit denoise / illumination-normalization step is scoped OUT with rationale (documented at bottom). |
| 1c | Reject ungradeable + recapture feedback | MISSING | **B** | `X2_POLICY.json`: deterministic rule `quality<0.35 -> RECAPTURE`; RECAPTURE route in `x2_bc_policy.py` + Simulink recap pool | Pathway implemented, deterministic, ICDR-scoped. 0 test images hit RECAPTURE (no ungradeable in APTOS-set); present as decision path, not a claim of clinical grading of ungradeable images. |

## B. Retinal Structure Segmentation

| PS | Requirement | v8.12 status | X3 status | Evidence | Gap / verdict |
|---|---|---|---|---|---|
| 2a | Optic disc / fovea localization | PARTIAL / HONEST_NEGATIVE | **B (prototype)** | Baseline honest-negative: heuristic median error 1014/1073 px, 0% within 200 px (`idrid_localization_results_v8_12.json`). **Step 5 EXECUTED**: fovea localizer (pretrained efficientnet_b3 + linear head, trained on IDRiD C train 413) → C-test single-shot median **273 px, 32% within 200 px**, beats constant-centroid baseline (313 px / 23%) and the old broken heuristic (`x3/step5_fovea/x3_fovea_prototype_v2_results.json`). | Heuristic is NOT a capability (still recorded). New fovea prototype is **EXPERIMENTAL**, isolated, single-shot; far from clinically validated — kept scoped as prototype. |
| 2b | Vessel segmentation | AVAILABLE / PARTIAL | **B** | DRIVE FOV-masked dev Dice 0.683 (n=4 held-out), `drive_vessel_best_v8_12.pt`, `drive_vessel_results_v8_12.*` | Toolbox-level vessel map demonstrable for the demo. Explicitly NOT the clinical backbone. Optional improvement not attempted this sprint (contract keeps it demo-level). |
| 2c | Microaneurysm detection (PS: sub-pixel) | MISSING / HONEST_NEGATIVE | **B (prototype, isolated)** | v8.12 honest negative: MA Dice 0.000 on IDRiD (`idrid_lesion_results_v8_12.json`). **Step 4b EXECUTED**: FGADR-trained lesion-evidence prototype (UNet 7.49M, isolated under `x3/step4b_fgadr/`, locked test n=181) → MA Dice **0.256**, recall 0.336, IoU 0.165 (`FGADR_RESULTS.json`); real overlays (`overlays/case_MA_1832_2_*`). | Trained prototype replaces the honest negative as the demonstrated evidence path, but is **PROTOTYPE only** — FGADR-trained, single dataset, not sub-pixel precise, not clinically validated. MA is the weakest class. |
| 2d | Exudate segmentation | MISSING / HONEST_NEGATIVE | **B (prototype, isolated)** | v8.12 honest negative: EX Dice 0.008. **Step 4b EXECUTED**: FGADR prototype → EX Dice **0.513**, IoU 0.366 (`FGADR_RESULTS.json`); SE Dice **0.407**; overlays (`overlays/case_EX_1091_2_*`); single-shot IDRiD A-test external check → EX Dice 0.370 (`FGADR_EXTERNAL_IDRID_RESULTS.json`). | Trained prototype with real pixel metrics on official-like masks + cross-domain check; strongest class. **PROTOTYPE only**; classical candidate detector (step4) still recorded as baseline. |
| 2e | Hemorrhage classification | MISSING / HONEST_NEGATIVE | **B (prototype, isolated)** | v8.12 honest negative: HE Dice 0.000. **Step 4b EXECUTED**: FGADR prototype → HE Dice **0.461**, IoU 0.346 (`FGADR_RESULTS.json`); overlays (`overlays/case_HE_0627_3_*`); IDRiD A-test external → HE Dice 0.164. | Trained prototype supersedes the honest negative for demonstration; **PROTOTYPE only**, weaker cross-domain. |
| 2f | Neovascularization detection | NOT NEEDED | **B (scoped out, documented)** | contract: FGADR/NV dataset acquisition abandoned; FGADR NV = 49 positives only (2.7% of Seg-set), sparse-annotation convention | Explicitly documented out of scope: no authorized NV dataset. FGADR NV present but **insufficient for a credible standalone NV detector** this sprint → kept `INSUFFICIENT_DATA / EXPERIMENTAL-ONLY`, not claimed anywhere. |

## C. DR Severity Grading

| PS | Requirement | v8.12 status | X3 status | Evidence | Gap / verdict |
|---|---|---|---|---|---|
| 3a | ICDR Levels 0–4 | AVAILABLE | **A** | `X1C2` frozen, locked test: QWK 0.9027, acc 0.8240 (`metrics/X1/x1_locked_test_report.json`) | Fully satisfied on APTOS locked test, single-shot. |
| 3b | Sensitivity >90% referable (Level 2+) | PARTIAL | **A** | Locked test argmax sens **0.9192** > 0.90 (`x1_locked_test_report.json`, `x2_final_locked_test.json`) | Met at the predeclared argmax operating point. Honest negative retained: the frozen *max-specificity* threshold point gives sens 0.8620 < 0.90 → that cutoff is flagged NOT for deployment. |
| 3c | Specificity >85% referable | AVAILABLE | **A** | Locked test argmax spec **0.9333** > 0.85 | Met; no regression below 0.85. |

## D. Explainability Module

| PS | Requirement | v8.12 status | X3 status | Evidence | Gap / verdict |
|---|---|---|---|---|---|
| 4a | Grad-CAM attention maps | PARTIAL (no saved artifacts) | **B** | `pytorch_grad_cam` ONNX wrapper; 4 saved demo cases `explainability/X2/X2_EXPLAINABILITY_CASES/case*.png` | Implemented + saved demo set on 4 diverse decisions (good/referable, good/non-referable, low-quality, uncertain). Grad-CAM is **attention guidance, not lesion evidence**. |
| 4b | Lesion-level evidence correlated with clinical criteria | MISSING | **B (prototype, partial)** | v8.12 trained lesion model = honest negative (Dice≈0). **Step 4b EXECUTED**: FGADR-trained lesion-evidence prototype (MA/HE/EX/SE) on locked FGADR test n=181 → per-image Dice MA 0.256 / HE 0.461 / EX 0.513 / SE 0.407 (`x3/step4b_fgadr/FGADR_RESULTS.json`), real overlay PNGs (`x3/step4b_fgadr/overlays/`), and lesion-evidence section integrated into the screening report (`x3/step4b_fgadr/reports/lesion_report_*.txt`). Classical no-training detector (step4, IDRiD A n=27) kept as baseline: EX 0.125 / HE 0.076. | Real, measured lesion evidence with overlays + report integration — a trained prototype on FGADR (non-commercial research set, arXiv:2008.09772). NOT a clinical segmentation capability; single dataset, moderate Dice, weakest on MA; cross-domain IDRiD check shows EX generalizes best. NV stays INSUFFICIENT_DATA. |
| 4c | Calibrated confidence scores | AVAILABLE | **A** | `X1_CALIBRATION.json` T=1.25 (validation-only), `x1_calibration.json`, policy confidence rules in `X2_POLICY.json` | Temperature-scaled probabilities used consistently from X1 through X2 routing. |
| 4d | Automated annotated reports; ophthalmologist validation <30 s; human-in-the-loop | MISSING | **B** | `reports/X2/X2_REPORT_EXAMPLES/report_*.txt` (4), report builder `x2_e_reports.py`, HUMAN_REVIEW routing in policy + Simulink human pools | Report generator built and saved. "AI proposes, clinician disposes" implemented in the workflow. **Clinician <30 s validation NOT performed** → flagged in X3 Step 7 if no reviewer is available. |

## E. Simulink Workflow Simulation

| PS | Requirement | v8.12 status | X3 status | Evidence | Gap / verdict |
|---|---|---|---|---|---|
| 5a | Acquisition rates, bandwidth, throughput, review capacity | AVAILABLE | **B** | `sih26038_screening_workflow_v9_0.slx`, `X2_SIMULINK_SCENARIOS.csv` (LOW 5/hr, BASE 10/hr, HIGH 40/hr; bandwidth 20 Mbps; image 2.5 MB; all scenarios drained; max queue 0) | Executed rate-based operational model. **MODELED CAPACITY** only — not a deployed network. SimEvents unavailable → no queue-paradigm claims (documented port limitation). |
| 5b | Optimize resource allocation 100k+ patients/yr | PARTIAL | **B** | annualized run at 100k/yr: human demand 33.22/hr vs capacity 115/hr; margin 81.78/hr; modeled max sustainable ≈346k/yr (`simulink_result_v9_0.json`) | Presented as a **modeled** capacity/optimization study, labeled MODELED CAPACITY; not a field deployment claim. |

## F. Expected-Solution / Cross-Cutting

| PS | Requirement | v8.12 status | X3 status | Evidence | Gap / verdict |
|---|---|---|---|---|---|
| 6a | Grad-CAM "rated as clinically useful" | MISSING | **C** | demo set exists (4 cases) but NO clinician rating performed | No fabricated ratings. X3 Step 7: only if a qualified reviewer is immediately accessible; otherwise marked `CLINICIAN VALIDATION = NOT EXECUTED`. |
| 6b | Validate vs published benchmarks; integrated pipeline > any single technique | PARTIAL | **B** | five-fold APTOS CSV, IDRiD external reports, `X2_ABLATION.csv` A/B/C/D | Ablation demonstrates the integrated workflow's routing safety trade vs single-threshold screening (C/D convert 20 missed-referable → 0). Grading classifier is constant by construction → no claim that routing improves grading accuracy. |
| 6c | MATLAB-based pipeline | AVAILABLE / PARTIAL | **B** | `matlab/X2/dr_x1c2.onnx`; python↔onnx↔MATLAB parity: cls max diff 6.676e-6, ref 3.815e-6 (<1e-3 tol, PASS); MATLAB screening routes match Python exactly | Inference parity established at the ONNX boundary. Preprocessing stays in Python (`DOCUMENTED_PORT_LIMITATION`); no MATLAB-only end-to-end claim. |
| 6d | Tools listed (IPT/CVT/DLT/MIT/Simulink/SMTL) | PARTIAL | **B** | IPT + DL Toolbox + Simulink installed; CVT / MIT / SMTL / SimEvents NOT installed | Demo exercises only installed toolboxes; absent-toolbox functions never referenced. |

---

## X3 Step 1 verdict summary

| Grade | Rows |
|---|---|
| **A** fully satisfied | 3a, 3b, 3c, 4c |
| **B** partial / scoped | 1a, 1b, 1c, 2a (fovea prototype), 2b, 2c (FGADR MA prototype), 2d (FGADR EX/SE prototype), 2e (FGADR HE prototype), 2f, 4a, 4b (FGADR MA/HE/EX/SE prototype + report integration), 4d, 5a, 5b, 6b, 6c, 6d |
| **C** missing | 6a (clinician rating) |
| **D** not demonstrated | (none for lesions — v8.12 honest negatives replaced by FGADR prototypes; classical step4 remains as recorded baseline) |

### No evidence is fabricated
- 2c/2d/2e classical v8.12 results remain honest negatives (Dice ≈ 0) and are still recorded; they are **superseded as the evidence path** by the trained FGADR lesion-evidence prototype (Step 4b), which is explicitly PROTOYPE/EXPERIMENTAL (FGADR-trained, single dataset, not clinically validated).
- 6a has no clinician score; nothing is invented to fill it.
- All Simulink/annualized numbers are labeled MODELED and derived from the executed base Simulink model.
- Steps 4 (classical), 4b (FGADR-trained), and 5 (fovea) executed as isolated PROTOTYPE experiments and scored honestly (FGADR per-image Dice: MA 0.256 / HE 0.461 / EX 0.513 / SE 0.407 on locked test n=181; IDRiD single-shot: EX 0.370 / HE 0.164 / MA 0.059; fovea median 273 px). Any partial or failed sub-result (NV insufficient, MA weak, cross-domain drop) is written down exactly as measured; no improvement is claimed as a clinical capability.

### Scoping note (1b denoise / 1c quality)
- Illumination normalization = implemented (CLAHE + crop). Standalone "denoising" step is scoped out: no clinical quality-label corpus exists to validate a denoiser, so it would be an unverifiable cosmetic step.
- Quality gate is an engineering heuristic (QUALITY_HEURISTIC label); it routes ungradeable/uncertain images to human review, but is NOT claimed to be a clinically validated quality grade.