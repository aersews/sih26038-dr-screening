# SIH26038 Requirement Matrix (v9.0)

> **FGADR evidence withheld.** FGADR-derived material (dataset, images, masks, checkpoints, results, and the `x3/step4b_fgadr/` pathway) is excluded from this repository pending authorization and redistribution review. FGADR is licensed for non-commercial research only and its images may not be redistributed. Every FGADR number, file path, and status below is a historical record only: those artifacts are not distributed here, cannot be reproduced or verified from this repository, and must not be cited as evidence contained in this repository. All non-FGADR evidence (X1, X2, fovea and classical lesion prototypes, MATLAB/Simulink integration) is unaffected.

Source of truth: official SIH 2026 statement `https://sih2026.vuce.in/ps/SIH26038` (MathWorks; MedTech/BioTech/HealthTech; deadline 30 Sep 2026). Status reflects frozen v8.12 evidence location + v9.0 gap. Matrix rows are traceable to the PS numbered description.

Status legend: **[AVAILABLE]** frozen evidence exists · **[PARTIAL]** exists but incomplete/unvalidated, needs v9.0 work · **[MISSING]** not implemented · **[NOT NEEDED]** out of scope this sprint · **[FGADR]** isolated prototype pathway now unlocked (see `FGADR_AUDIT_v9_0.md`; FGADR is pixel-level supervised training data, license: non-commercial research only).

FGADR-gated statuses above and in the rows below (e.g. **[FGADR — TRAINABLE]**, **[FGADR — SPARSE, CAUTION]**) are historical planning states recorded before execution: the FGADR pathway was planned, not published, and its artifacts are withheld from this repository (see the notice at the top of this document). The requirement rows are left unchanged and describe the plan as written, not delivered evidence.

## A. Image Quality Assessment & Enhancement
| # | PS Requirement (verbatim) | v8.12 Status | Evidence (frozen) | v9.0 Gap / Plan |
|---|---|---|---|---|
| 1a | Evaluate focus, illumination, field of view | **[PARTIAL]** | `engineering_quality_index` (cell 07: sharpness/exposure/FOV/uniformity/directional); quality cache `aptos_quality_cache.csv`; legacy `quality_mobilenetv2` (SIH_DR, test acc 0.904) | No externally-rated quality labels; v9.0: produce quality-gate demo w/ scope label QUALITY_HEURISTIC |
| 1b | Adaptive enhancement (CLAHE, illumination normalization, denoising) | **[PARTIAL]** | CLAHE + `compute_fundus_crop` preprocessing (cell 06) | Denoise / explicit illumination-normalization step missing; add or scope-out explicitly |
| 1c | Reject ungradeable + recapture feedback | **[MISSING]** | — | Build recapture-feedback pathway for demo (deterministic, ICDR-scoped) |

## B. Retinal Structure Segmentation
| # | PS Requirement | v8.12 Status | Evidence (frozen) | v9.0 Gap / Plan |
|---|---|---|---|---|
| 2a | Optic disc / fovea localization | **[PARTIAL / HONEST_NEGATIVE]** | IDRiD C heuristics: median error 1014/1073 px (train/test), 0% within 200 px; fovea → no valid outputs | Decide: real DL-localizer within sprint, else explicit HONEST_NEGATIVE with scope label + roadmap |
| 2b | Vessel segmentation | **[AVAILABLE / PARTIAL]** | DRIVE FOV-masked dev Dice 0.683 (n=4 held-out), `drive_vessel_best_v8_12.pt`, `drive_vessel_results_v8_12.*` | Toolbox-level vessel map is enough for demo; not the clinical backbone. v9.0 optional improvement |
| 2c | Microaneurysm detection (PS asks *sub-pixel*) | **[FGADR — TRAINABLE]** | v8.12: MA Dice 0.000 on IDRiD (honest negative) | FGADR MA masks: 1424/1842 imgs with pixel-level MA (55.6M+ pos px after severity-grading collapse). Build isolated MA lesion-evidence prototype (P0) w/ IDRiD A-test as external eval; keep IDRiD test single-shot |
| 2d | Exudate segmentation | **[FGADR — TRAINABLE]** | v8.12: EX Dice 0.008 on IDRiD (honest negative) | FGADR EX masks: 1279/1842 + SE masks: 627/1842 (hard + soft exudate both pixel-level). Build isolated EX/SE prototype (P0); IDRiD A-test as external single-shot eval |
| 2e | Hemorrhage classification | **[FGADR — TRAINABLE]** | v8.12: HE Dice 0.000 on IDRiD (honest negative) | FGADR HE masks: 1456/1842 imgs (lesion-mask dir is `Hemohedge`). Build isolated HE prototype (P0); IDRiD A-test as external single-shot eval |
| 2f | Neovascularization detection | **[FGADR — SPARSE, CAUTION]** | v8.12: no authorized NV dataset (FGADR dropped) | FGADR **DOES** include pixel-level NV: 49/1842 imgs (2.7%, all grade ≥2; 34/49 grade 4). **Insufficient positive volume for a strong model — report explicitly.** Optional: image-level NV flag demo on these 49 (+ zero-shot caution); otherwise scoped as prototype-only w/ honesty note |

## C. DR Severity Grading
| # | PS Requirement | v8.12 Status | Evidence (frozen) | v9.0 Gap / Plan |
|---|---|---|---|---|
| 3a | ICDR Levels 0–4 | **[AVAILABLE]** | `DROrdinalNet` (5-class + ordinal head), `dr_ordinal_best_v8_12.pt`, `final_test_report_v8_12.json` | Re-run on locked split to re-baseline; keep parity |
| 3b | Sensitivity >90% referable (Level 2+) | **[PARTIAL]** | ref sens 0.8956 | **CORE v9.0 GOAL** — exceed 0.90 (workflow awareness X2 designed to reach this) |
| 3c | Specificity >85% referable | **[AVAILABLE]** | ref spec 0.9287 | Must NOT regress below 0.85 |

## D. Explainability Module
| # | PS Requirement | v8.12 Status | Evidence (frozen) | v9.0 Gap / Plan |
|---|---|---|---|---|
| 4a | Grad-CAM attention maps | **[PARTIAL]** | `pytorch_grad_cam` wrapper in executable notebook (cell 22); **no saved demo artifacts** (gradcam_outputs empty) | Generate saved Grad-CAM demo set in v9.0 (required artifact) |
| 4b | Lesion-level evidence correlated with clinical criteria | **[FGADR — TRAINABLE]** | v8.12: lesion Dice ~0 → non-credible | FGADR provides 6 pixel-level lesion classes (MA/HE/EX/SE/IRMA/NV) + image grades on the same 1842 images. Train isolated multi-class lesion-evidence prototype → real overlays + report integration. Replace the classical-only EX/HE prototype with FGADR-trained evidence maps (isolated; X1C2/X2 untouched)
| 4c | Calibrated confidence scores | **[AVAILABLE]** | temperature scaling T=2.15, `calibration_v8_12.json`, policy threshold 0.78104581 | Re-verify on re-baseline |
| 4d | Automated annotated reports; ophthalmologist validation <30 s; human-in-the-loop | **[MISSING]** | no report generator | Build annotated-report + clinician-checklist demo w/ "AI proposes, clinician disposes" |

## E. Simulink Workflow Simulation
| # | PS Requirement | v8.12 Status | Evidence (frozen) | v9.0 Gap / Plan |
|---|---|---|---|---|
| 5a | Acquisition rates, bandwidth, throughput, review capacity | **[AVAILABLE]** | `simulink_result_v8_12.json` (1441 steps, utilization 0.900625, queue 0), `matlab_execution_v8_12.m` | Re-run in v9.0; note natively `DOCUMENTED_PORT_LIMITATION` boundary |
| 5b | Optimize resource allocation 100k+ patients/yr | **[PARTIAL]** | `district_resource_sweep_v8_12.csv`, `learned_risk_fusion_v8_12.json` | Re-issue with v9.0 numbers; SimEvents NOT available → no queue-paradigm claims |

## F. Expected-Solution / Cross-Cutting
| # | PS Requirement | v8.12 Status | Evidence (frozen) | v9.0 Gap / Plan |
|---|---|---|---|---|
| 6a | Grad-CAM "rated as clinically useful" | **[MISSING]** | none (no demo saved) | Produce demo set for clinician rating (Kappa/agreement qualified, not a clinical trial) |
| 6b | Validate vs published benchmarks; integrated pipeline > any single technique | **[PARTIAL]** | `five_fold_paper_results_v8_12.csv`, IDRiD external reports, `literature_context_status_v8_12.json` (STATIC_REFERENCE_ONLY) | Produce clean **ablation table** (A=baseline / B=+quality gate / C=+structure priors / D=full) in v9.0 |
| 6c | MATLAB-based pipeline | **[AVAILABLE / PARTIAL]** | ONNX export + MATLAB parity (diff 4.3e-6 PASS); preprocessing parity = DOCUMENTED_PORT_LIMITATION | Preprocess in Python, grade in MATLAB at ONNX boundary; keep parity evidence |
| 6d | Tools listed (IPT/CVT/DLT/MIT/Simulink/SMTL) | **[PARTIAL]** | IPT+DLT+Simulink present; CVT / MIT / SMTL NOT installed | Demo must run on installed toolboxes; do not reference absent-toolbox functions |

## Hard constraints carried into v9.0
1. Frozen v8.12 artifacts untouched; any training uses **copies** in `sih26038_v9_0\`.
2. Locked APTOS test + IDRiD test = single-shot final evaluation only (no tuning).
3. Referral threshold 0.78104581 is validation-derived — never presented as test-tuned.
4. Messidor-2 labels are third-party — any severity claim scoped THIRD_PARTY_LABELED, never official clinical validation.
5. SimEvents / CVT / MIT / SMTL unavailable — no claims requiring them.
6. "AI proposes, clinician disposes" — no clinical validation claim.