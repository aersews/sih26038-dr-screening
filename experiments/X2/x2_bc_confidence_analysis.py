# -*- coding: utf-8 -*-
# Validation-only sensitivity analysis: CONF_HIGH threshold vs missed referable.
import json
import numpy as np
import pandas as pd
from x2_common import X2_METRICS, load_locked_data, load_x1c2, evaluate, make_decision_features

train_df, val_df, test_df = load_locked_data()
model = load_x1c2()
T = 1.25
ev_val = evaluate(model, val_df, temperature=T)
feat = make_decision_features(val_df, ev_val)

ref = feat.true_ref.to_numpy().astype(bool)
q = feat.quality.to_numpy()
conf = feat.confidence.to_numpy()
unc = feat.uncertainty.to_numpy()
pred_ref = feat.pred_ref.to_numpy().astype(bool)

rows = []
for conf_hi in [0.60, 0.65, 0.70, 0.75, 0.80, 0.85, 0.90, 0.95, 0.97]:
    for unc_hi in [0.99, 0.70, 0.60, 0.50, 0.40, 0.30]:
        screen = (~pred_ref) & (q >= 0.60) & (conf >= conf_hi) & (unc <= unc_hi)
        miss = int((ref & screen).sum())
        cover = float(screen.mean())
        screen_out = float((~ref & screen).sum())
        rows.append({
            "CONF_HIGH": conf_hi, "UNC_HIGH": unc_hi,
            "missed_referable_auto_accepted": miss,
            "coverage_fraction": round(cover, 4),
            "screen_output": int(screen.sum()),
            "false_positive_auto_screen": int(screen_out),
        })

df = pd.DataFrame(rows)
df = df.sort_values(["missed_referable_auto_accepted", "coverage_fraction", "CONF_HIGH"], ascending=[True, False, True])
print("== TOP table: zero-missed preferred, then max coverage ==")
print(df[df.missed_referable_auto_accepted == 0].to_string(index=False))

candidates_no_miss = df[df.missed_referable_auto_accepted == 0]
if len(candidates_no_miss):
    best = candidates_no_miss.sort_values("coverage_fraction", ascending=False).iloc[0]
else:
    best = df.sort_values(["missed_referable_auto_accepted", "coverage_fraction"]).iloc[0]
print("\nSELECTED (validation-only):", best.to_dict())
json.dump({
    "sweep": rows,
    "selection": best.to_dict(),
    "note": "validation-only decision; intended to replace CONF_HIGH/UNC_HIGH in frozen policy if zero-miss exists",
}, open(X2_METRICS / "x2_bc_confidence_analysis.json", "w"), indent=2)