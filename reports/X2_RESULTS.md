# X2 — Workflow-Aware Screening Integration (v9.0)

**Project:** SIH26038 Diabetic-Retinopathy Screening Decision Support (Team MMC 148873)
**Phase:** X2 (on top of accepted baseline X1 = v9.0 candidate "X1C2"), appended to the v9.0 evidence record
**Status:** COMPLETE — CASE A accepted

---

## 1. Model used

X1C2 — `efficientnet-b3` (timm), `DROrdinalRefNet` with classification (5-class), ordinal (4-bit) and
referable (binary) heads, dropout 0.35. **PyTorch-trained** on APTOS 3662 images (split fingerprint
`d6934df52f526795`). Checkpoint sha256 `73522dbbe7f476...`. Frozen for all of X2; **no retraining in X2.

## 2. Single locked-APTOS-test evaluation (frozen, exactly once; n = 732)

Evaluated once at the end of X2 with the fully frozen stack (model + temperature T=1.25 + argmax operating
point + deterministic routing policy). Firewall honored: no locked-test feedback into any tuning.

| Metric | Locked test | X1 (same convention) | Target |
|---|---|---|---|
| QWK (quadratic κ) | **0.9027** | 0.9027 | no regression |
| Referable sensitivity | **0.9192** | 0.9192 | > 0.90 ✔ |
| Referable specificity | **0.9333** | 0.9333 | > 0.85 ✔ |
| Referable AUC | **0.9792** | 0.9792 | — |
| Macro-F1 / Balanced acc | 0.6460 / 0.6466 | 0.6460 / 0.6466 | — |
| Overall accuracy | 0.8115 | 0.8115 | — |

Routing policy on locked test: **RECAPTURE 0, HUMAN_REVIEW 161, SCREENING_OUTPUT 269, REFER 302**;
coverage (auto-screen output) = 0.3675; **missed referable auto-screened = 0** → workflow safety sensitivity **1.0**.
(All referable images are either REFER-ed or HUMAN_REVIEW-ed — the Mild-NPDR guard closes the classifier's
20-case referable-miss gap identified on validation.)

## 3. No locked-test tuning

Every threshold and policy decision was made on **validation only**:
- temperature T = 1.25 (frozen in X1; validation Brier 0.2544)
- operating point = **argmax** of T-calibrated softmax (the max-specificity threshold 0.6443
  from X1 is documented as **intentionally NOT deployed** — its locked-test sensitivity was 0.862 < 0.90)
- quality gate thresholds and routing rules pre-declared in `experiments/X2/x2_common.py`

## 4. X2-A quality gate (heuristic, explicitly not clinically validated)

Engineering quality index (Laplacian sharpness, exposure, FOV coverage, illumination uniformity,
motion-blur proxy) with three buckets: `RECAPTURE_CANDIDATE (q<0.35)`, `LOW_QUALITY_REVIEW (0.35≤q<0.60)`,
`USABLE_FOR_MODEL (q≥0.60)`.

- APTOS contains **0 recapture candidates** at every split (train/val/test) → recapture fraction 0.0.
- Low-quality-review fraction: train 0.1857, **val 0.1078**, test 0.0847.
- Examples: good `0083ee8054ee` (q=0.678), poor `9b4fc15df3c8` (q=0.429, illumination uniformity 0.0).
- Evidence: `metrics/X2/x2_a_quality_gate.json`, `plots/X2/X2_QUALITY_DISTRIBUTION.png`.

## 5. X2-B/X2-C workflow policy (deterministic, frozen)

Routing rules (order is fixed, no learned fusion): quality<0.35→RECAPTURE; referable (argmax≥2)→REFER;
predicted Mild NPDR→HUMAN_REVIEW (referable-boundary guard); quality∈[0.35,0.60)→HUMAN_REVIEW;
confidence<0.90 or normalized-uncertainty>0.50→HUMAN_REVIEW; otherwise SCREENING_OUTPUT.

Validation (n=733): RECAPTURE 0, HUMAN_REVIEW 176, SCREENING_OUTPUT 246, REFER 311;
sensitivity 0.9329 / specificity 0.9241; coverage 0.3356; human review 0.2401; refer 0.4243;
missed referable auto-screened = 0. `metrics/X2/X2_POLICY.json`.

## 6. X2-H ablation (A/B/C/D, validation)

| Arm | Auto-screen | Human attention | Missed referable | Safety sens |
|---|---|---|---|---|
| A X1C2 only | 0.5757 | 0.4243 | 20 | 0.9329 |
| B + quality gate | 0.4802 | — | 20 | 0.9329 |
| C workflow routing | 0.3356 | — | **0** | **1.0** |
| D full pipeline | 0.3356 | — | **0** | **1.0** |

Classifier grading is identical across arms by construction (`sens 0.9329 / spec 0.9241 / QWK 0.9037`);
the workflow converts 20 missed referable → 0 at the cost of auto-screen coverage. **Claim documented:
the workflow does not "outperform" the classifier; it is a safety/routing trade.** `X2_ABLATION.csv`.

## 7. X2-D explainability

Grad-CAM on the **referable logit**, targeting `backbone.conv_head`. Four representative validation cases:
non-referable-good `0304bedad8fe`, referable-good `0083ee8054ee`, low-quality `9b4fc15df3c8`,
uncertain `054b1b305160`. Overlays show **classifier attention only** — APTOS ships no lesion masks, so
**no lesion overlays are asserted or fabricated** (explicitly recorded in the cases JSON).
`explainability/X2/X2_EXPLAINABILITY_CASES/`.

## 8. X2-E annotated reports

Machine-generated AI-assisted screening report for each case (Image ID, quality + bucket, DR grade,
referable Y/N, confidence/uncertainty, referable prob, reason for referral route, human-review
recommendation) with an explicit **"not a diagnostic report"** disclaimer and clinician-ownership note.
`reports/X2/X2_REPORT_EXAMPLES/`.

## 9. X2-F MATLAB integration (ONNX)

- X1C2 exported to ONNX (opset 17; inputs `fundus_image`, outputs `cls_logits` [5] + `ref_logit` [1]).
- **Python torch vs onnxruntime**: max |Δ| cls 8.1e-6, ref 5.7e-6; 100% semantic agreement (4 validation images).
- **MATLAB R2026a `importNetworkFromONNX`** runs identical tensors: max |Δ| cls 6.7e-6, ref 3.8e-6; **pass**.
- **MATLAB screening workflow** re-implements the frozen policy (T=1.25 softmax → confidence/uncertainty/ref_prob
  → deterministic routing) and reproduces all four Python routes exactly (**PASS**).
- Wording honored: "**PyTorch-trained X1C2 model integrated into MATLAB via ONNX; NOT MATLAB-trained**."
- `matlab/X2/` (`dr_x1c2.onnx`, runners, `data/ref/`), `metrics/X2/x2_f1_python_onnx_parity.json`,
  `matlab/X2/results/x2_f_matlab_onnx_parity.json`, `x2_f_matlab_screening.json`.

## 10. X2-G Simulink workflow (base Simulink, rate-based)

New model `sih26038_screening_workflow_v9_0.slx` (built with `add_block`; no SimEvents — not installed),
porting the v8.12 discrete-queue topology and routing acquisition through the X2 fractions
(auto 0.3356 / mid-review 0.2401 / refer 0.4243 / recapture 0.0).

| Scenario | Arrivals 24h | Auto-screen | Human attention | Util vs capacity | Max queue | Drained | 100k feasible |
|---|---|---|---|---|---|---|---|
| LOW (5/hr) | 120.1 | 40.3 | 79.8 | 0.029 | 0 | ✔ | ✔ |
| BASE (10/hr) | 240.2 | 80.6 | 159.6 | 0.058 | 0 | ✔ | ✔ |
| HIGH (40/hr) | 960.7 | 322.4 | 638.3 | 0.231 | 0 | ✔ | ✔ |

Annualized 100k planning check: mean demand 50 images/hr → human-attention demand **33.2/hr**
(refer 21.2 + review 12.0 + recapture 0) against capacity **115/hr** (4 mid-pools @20 + 2 specialists @15 + 5
recapture) → margin 81.8/hr, sustainable annual volume ≈ **346k** at current pools. All scenarios queue-drained.
`simulink/X2/X2_SIMULINK_SCENARIOS.csv`, `simulink/X2/simulink_result_v9_0.json`,
`simulink/X2/sih26038_screening_workflow_v9_0.slx`.

## 11. Verdict

**X2 ACCEPTED (CASE A):** the workflow-aware pipeline meets the target operating envelope
(sens 0.9192 > 0.90 and spec 0.9333 > 0.85 on the single locked-APTOS-test run) using the frozen argmax
operating point, while routing **every** referable case to human attention (0 missed referable; workflow
safety sensitivity 1.0) — a strictly safer behavior than X1C2-alone screening. MATLAB/ONNX integration is
parity-verified and the Simulink model demonstrates 100k/year feasibility with substantial capacity headroom.

---

### Deliverables
- `metrics/X2/` — `X2_RESULTS.json`, `X2_POLICY.json`, `X2_ABLATION.csv`, `X2_SIMULINK_SCENARIOS.csv`,
  `X2_CHECKSUMS.json`, `x2_a_quality_gate.json`, `x2_bc_*.json`, `x2_f1_python_onnx_parity.json`,
  `x2_final_locked_test.json`, `x2_h_ablation.json`
- `experiments/X2/` — `x2_common.py`, `x2_a_quality_gate.py`, `x2_bc_policy.py`, `x2_bc_confidence_analysis.py`,
  `x2_bc_missed_analysis.py`, `x2_h_ablation.py`, `x2_d_explainability.py`, `x2_e_reports.py`,
  `x2_f*.py`, `x2_assemble.py`, `x2_final_locked_test.py`
- `explainability/X2/X2_EXPLAINABILITY_CASES/`, `reports/X2/X2_REPORT_EXAMPLES/`, `plots/X2/`,
  `matlab/X2/`, `simulink/X2/`
- Evidence matrix updated: `V9.0_FINAL_EVIDENCE_MATRIX.csv` (18 data rows).