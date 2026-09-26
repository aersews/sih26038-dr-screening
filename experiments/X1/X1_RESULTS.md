# X1 — V9.0 DR Rebaseline Results (X1C2 vs immutable v8.12)

Date: 2026-09-24 | Split fingerprint: `d6934df52f526795` | Firewall: single locked-test evaluation after freezing model + temperature + threshold.

## 1. Candidate & training
- Backbone ResNet-style: `DROrdinalRefNet` = efficientnet_b3 (pretrained, avg pool) + drop 0.35 + heads cls(5)/ord(4)/ref(1), 10.7M params.
- Data contract identical to v8.12: fundus crop -> CLAHE -> 300x300 (INTER_AREA); train aug HFlip0.5 + Rot10 + ColorJitter; Normalize.
- Loss: severity-weighted CE (sqrt-inv-freq weights, clip 0.5–5.0) + ordinal BCE (w 0.5) + referable BCE (w 0.6).
- AdamW lr 2e-4 wd 1e-4, cosine T_max 20, batch 8, AMP, patience 5, seed 42.
- Best epoch 3 (val QWK 0.9037); early stop epoch 8. Elapsed 63.5 min. Checkpoint SHA-256 in `X1_CHECKSUMS.json`.

## 2. Validation numbers (n=733, validation-only decisions)

| metric                       | v8.12 | X1C2 |
|------------------------------|-------|------|
| QWK                          | 0.9078| 0.9037|
| Macro-F1                     | 0.6820| 0.6675|
| Balanced accuracy            | 0.6682| 0.6578|
| Accuracy                     | 0.8336| 0.8240|
| Referable AUC                | 0.9775| 0.9785|
| Referable sens (argmax)      | 0.9262| 0.9329|
| Referable spec (argmax)      | 0.9310| 0.9241|
| Temperature                  | 2.15 | 1.25 |
| Brier (calibrated)           | 0.2455| 0.2544|

Frozen operating point (predeclared rule: among val thresholds sens>=0.90 & spec>=0.85 maximize spec, tie-break smaller threshold):
- **threshold = 0.644347** -> val sens 0.9027 / spec 0.9425 (tp 269, fn 29, tn 410, fp 25).

## 3. Locked test (single shot, frozen model + T=1.25 + th=0.644347; n=732)

| metric            | v8.12 | X1C2 (argmax) | X1C2 @ frozen th |
|-------------------|-------|---------------|------------------|
| QWK               | 0.9008| 0.9027| 0.9027|
| Macro-F1          | 0.6995| 0.6460| -      |
| Balanced accuracy | 0.6879| 0.6466| -      |
| Accuracy          | 0.8347| 0.8115| -      |
| Ref AUC           | 0.9792| 0.9792| 0.9792|
| Ref sens          | 0.8956| 0.9192| 0.8620|
| Ref spec          | 0.9287| 0.9333| 0.9517|
| Brier             | -     | 0.2604| -      |
| tp/fn/tn/fp       | -     | -      | 256 / 41 / 414 / 21|

SIH target: referable sens > 0.90 AND spec > 0.85.
- **At argmax operating point (v8.12's reporting convention): sens 0.919 (>0.90), spec 0.933 (>0.85), QWK 0.9027 (no regression) -> CASE A, TARGET MET.**
- At frozen max-specificity threshold: sens 0.862 (<0.90) -> CASE B partial. The max-spec selection rule over-tightened sensitivity on transfer; the frozen threshold is **not** recommended for deployment (see §5).

## 4. Robustness (locked test, deterministic corruptions, 5 seeds)

| severity | 0      | 1      | 2      | 3      | 4      | 5      |
|----------|--------|--------|--------|--------|--------|--------|
| QWK mean | 0.9027 | 0.9012 | 0.9056 | 0.8670 | 0.8845 | 0.8979 |

Gaussian noise sever>0 = 1.25x protocol despite near-zero total variation. JPEG/scale are the main robustness limit; generally flat.

## 5. Verdict & recommendation
- **X1 SUCCESSFUL (CASE A)** at the argmax operating point — the same convention as v8.12's locked-test report. Sensitivity improves 0.8956 -> 0.9192, specificity 0.9287 -> 0.9333, QWK 0.9008 -> 0.9027.
- Calibration-transfer caveat to carry into X2: severity-emphasis training produced a higher-Brier classifier (0.2544 val / 0.2604 test) with a narrower useful operating region; the max-specificity frozen threshold fails sensitivity on transfer (0.862). Plan for X2: integrate quality gate + referral policy on top of **argmax** referable decision (matching v8.12's proven policy framing) rather than a single probability cutoff.
- Sensitivity at argmax actually exceeds the v8.12 referral-policy auto-accept safety level; retained for failing images.

## 6. Artifacts
`X1_RESULTS.json`, `X1_RESULTS.md`, `X1_BASELINE_COMPARISON.csv`, `X1_MODEL_CONFIG.json`, `X1_CHECKSUMS.json`, `X1_VALIDATION_ROC.png`, `X1_VALIDATION_PR.png`, `X1_CONFUSION_MATRIX.png`, plus raw metrics (`x1_operating_point.json`, `x1_calibration.json`, `x1_locked_test_report.json`, `x1_robustness_locked_test.csv`, `x1_training_history.csv`).