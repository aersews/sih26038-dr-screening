# X3 — Visual Evidence Audit (Step 2)

Audited 24 Sep 2026. Script: `x3/x3_step2_visual_evidence_audit.py` → `x3/X3_VISUAL_EVIDENCE_AUDIT.json`. Result: **34/34 items present and content-verified**. No fabricated content; every check is on-disk existence + parseability + content-richness (std/coverage for images).

| # | Artifact category | Present | Detail |
|---|---|---|---|
| 1 | Original fundus image | 5/5 | APTOS `train_images` (png set present); the 4 demo source images `0083ee8054ee/0304bedad8fe/9b4fc15df3c8/054b1b305160.png` present |
| 2 | Quality gate decision | 2/2 | `metrics/X2/x2_a_quality_gate.json` (parsed, populated) + `plots/X2/X2_QUALITY_DISTRIBUTION.png` |
| 3 | DR prediction + confidence | 2/2 | `x1_locked_test_report.json`, `x2_final_locked_test.json` |
| 4 | Grad-CAM attention map | 4/4 | 4 case PNGs (845×3120, std 88–102, >90% pixels populated — content-rich, not blank) |
| 5 | Overlay / case metadata | 1/1 | `X2_EXPLAINABILITY_CASES.json` (4 cases, routes/mods/probs consistent) |
| 6 | Automated annotated report | 4/4 | `reports/X2/X2_REPORT_EXAMPLES/report_*.txt` (4 files) |
| 7 | MATLAB ONNX inference | 2/2 | `x2_f_matlab_onnx_parity.json` (PASS), `x2_f_matlab_screening.json` (routes match Python) |
| 8 | Simulink workflow model | 1/1 | `sih26038_screening_workflow_v9_0.slx` |
| 9 | Capacity simulation output | 1/1 | `X2_SIMULINK_SCENARIOS.csv` (3 scenario rows) |
| 10 | IDRiD C fovea/OD ground truth | 2/2 | Fovea center CSVs (413 train + 103 test) — basis for X3 Step 5 |
| 11 | IDRiD A lesion masks | 10/10 | MA/HE/EX/SE/OD masks present for train (54) + test (27); SE is the sparse set (26 train / 14 test) |

## Notes / honesty
- Category 4 Grad-CAM = attention-only evidence; explicitly **not** lesion evidence (PS 2c–2e remain honest negatives, Dice ≈ 0 — see requirement audit rows 2c/2d/2e).
- Categories 8/9 are **modeled** (rate-based Simulink, no SimEvents); labeled MODELED CAPACITY in X2 evidence and reprised here.
- IDRiD lesion masks exist on disk (used for the X3 Step 4 gap determination only; **no fabricated lesion overlays** are planned).
- Fovea ground truth verified row-valid (413/413, 103/103) and matches local image renumbering — no coordinate-to-image mismatch found.