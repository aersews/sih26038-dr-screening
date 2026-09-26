# X3 — Simulink Evidence Review (Step 8) + Ablation Audit (Step 9)

## Step 8 — Simulink workflow evidence review

Model: `sih26038_screening_workflow_v9_0.slx` (sha256 `5eeac02a71ba`), rate-based base Simulink (no SimEvents — port limitation honored).

Scenario evidence (`matlab/X2/results/X2_SIMULINK_SCENARIOS.csv` + `simulink_result_v9_0.json`, verified consistent with `x3/X3_SIMULINK_SUMMARY.csv`):

| Scenario | Acq/hr | Auto-screened (24h) | Human attention (24h) | Max queue | Drained | Utilization vs capacity |
|---|---|---|---|---|---|---|
| LOW | 5 | 40.3 | 79.8 | 0 | yes | 0.0289 |
| BASE | 10 | 80.6 | 159.6 | 0 | yes | 0.0578 |
| HIGH | 40 | 322.4 | 638.3 | 0 | yes | 0.2313 |
| ANNUALIZED 100k | 50 (eff) | 16.8/hr | 33.2/hr | — | modeled | 0.2889 |

- Annualized model: human demand 33.22/hr vs capacity **115/hr** (4 mid × 20 + 2 ophth × 15 + recap 5×1), margin 81.78/hr, modeled max sustainable **346,177/yr**, 100k/yr feasible = **true**.
- **Every capacity figure is labeled MODELED CAPACITY** — derived from the executed rate-based Simulink model, not a deployed-network claim, and no queue-paradigm claims are made (SimEvents absent). Confirmed consistent across the CSV, result JSON, X2 evidence matrix row, and this X3 summary CSV.

## Step 9 — Ablation audit (routing-only claims)

Ablation source: `metrics/X2/X2_ABLATION.csv` + `x2_h_ablation.json` (accepted X2 evidence).

| Arm | Components | Auto-screen frac | Human-review frac | Recapture frac | Missed referable not routed | Safety sens |
|---|---|---|---|---|---|---|
| A X1C2 only | argmax | 0.5757 | 0.0 | 0.0 | 20 | 0.9329 |
| B + quality gate | q<0.60 | 0.4802 | 0.5198 | 0.1078 | 20 | 0.9329 |
| C + workflow | refer/Mild/conf routing | 0.3356 | 0.2401 | 0.0 | 0 | 1.0 |
| D full | C + report/explain artifact | 0.3356 | 0.6644 | 0.0 | 0 | 1.0 |

Audit verdict — the evidence supports exactly these claims and no more:
1. **Claim scope is correct**: classifier (X1C2 argmax) is identical across arms by construction — `x2_h_ablation.json` states `classifier_level_constant: {sens 0.9329, spec 0.9241, qwk 0.9037}`. The ablation measures **routing safety vs coverage trade**, NOT an improvement to grading accuracy.
2. **Chain valid**: adding the workflow routing (arm C) converts the 20 missed-referable (that single-threshold argmax screening would not route) into routed cases → safety sensitivity 0.9329 → 1.0, at the cost of fewer auto-screen outputs (0.576 → 0.336) and more human attention (0.424 → 0.664).
3. **Honest negatives preserved**: abdominal rows are validation-only (`EXECUTED` under the frozen X1C2 validation policy), not a new locked-test claim; the single locked-test number remains `x2_final_locked_test.json` (unchanged).
4. **No over-claim**: arm D's human_review_fraction (0.6644) counts the report/explain artifact delivery as review attention; the ablation text does not claim D beats C clinically.
5. **Documented limitation**: ablation is on the APTOS validation set, so it demonstrates routing behavior under the frozen operating point; it is not a detection-of-unseen-clinical-settings claim.