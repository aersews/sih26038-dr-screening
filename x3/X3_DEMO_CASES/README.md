# X3_DEMO_CASES — demo bundle for judge review

All files are exact copies of v9.0 project artifacts (no resizing or cropping).
Full context: `..\X3_JUDGE_EVIDENCE_PACK.md` and `..\X3_FINAL_EVIDENCE_MATRIX.csv`.

## Contents

| File | Shows |
|------|-------|
| `case1_non_referable_good_quality.png` | Grad-CAM attention on non-referable good-quality image → auto-screen route |
| `case2_referable_good_quality.png` | Referable → human review; attention on lesions |
| `case3_low_quality_review.png` | Quality-gate fail → review |
| `case4_uncertain_review.png` | High-uncertainty → review |
| `report_*.txt` | Generated clinician-facing reports (4 routes) |
| `fovea_v2_test_IDRiD_003/_047/_099.png` | Fovea-localizer overlay: predicted vs GT fovea center (IDRiD C test) |
| `lesion_IDRiD_55/56/57_EX.png` (+ `_HE.png`) | Classical EX/HE detector overlays (IDRiD A. test) |
| `X3_SIMULINK_SUMMARY.csv` | Queue-model + annualized capacity (MODELED CAPACITY) |

FGADR lesion-evidence prototype (step4b) — **WITHHELD, not in this bundle**:
`fgadr_case_MA_1832_2_montage.png`, `fgadr_case_HE_0627_3_montage.png`,
`fgadr_case_EX_1091_2_montage.png`, `fgadr_case_SE_0174_2_montage.png`,
`fgadr_evidence_EX_1091_2_fused.png`, `fgadr_lesion_report_1091_2.txt`.
These files exist only in the local working copy. FGADR is non-commercial-research
licensed, its images may not be redistributed, and the derived artifacts are excluded
from this repository pending authorization review. Any FGADR numbers quoted in this
project's historical documents are unverifiable from this repository.

## Status labels (do not over-read)
- Fovea overlays: PROTOTYPE/EXPERIMENTAL (median 273 px / 32% within 200 px on test n=103).
- Classical lesion overlays (step4): candidate highlighting, no training (EX dice 0.125, HE 0.076).
- Grad-CAM maps are attention-only, not a clinical diagnosis.