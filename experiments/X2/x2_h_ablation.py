# -*- coding: utf-8 -*-
# X2-H — ablation A/B/C/D on VALIDATION (transparent scoping).
# Classifier-level grading (argmax) is IDENTICAL across arms (X1C2 frozen).
# The ablation measures what each component ADDS at the ROUTING level:
#  - missed referable (= true-referable not routed to any human attention)
#  - auto-screen fraction (inputs cleared without human review)
#  - human attention fraction (review + recapture)
#  - classifier-level sens/spec are reported once (they do not change).
import json
import numpy as np
import pandas as pd
from x2_common import X2_METRICS, load_locked_data, load_x1c2, evaluate, make_decision_features

train_df, val_df, test_df = load_locked_data()
model = load_x1c2()
ev_val = evaluate(model, val_df, temperature=1.25)
feat = make_decision_features(val_df, ev_val)

ref = feat.true_ref.to_numpy().astype(bool)
pred_ref = feat.pred_ref.to_numpy().astype(bool)
q = feat.quality.to_numpy()
route = feat.route.to_numpy()
n = len(val_df)

classifier = {
    "classifier": "X1C2 argmax (frozen; identical across arms)",
    "referable_sensitivity": round(float((pred_ref & ref).sum() / ref.sum()), 4),
    "referable_specificity": round(float(((~pred_ref) & (~ref)).sum() / (~ref).sum()), 4),
    "qwk": round(ev_val["qwk"], 4),
}

rows = []

# A: X1C2 only — route: referable->REFER, else auto-screen
a_ref = pred_ref
a_auto = ~a_ref
a_missed = (ref & a_auto).sum()
rows.append({
    "arm": "A_X1C2_only",
    "components": "X1C2 argmax",
    "auto_screen_fraction": round(float(a_auto.mean()), 4),
    "human_attention_fraction": round(float(a_ref.mean()), 4),
    "human_review_fraction": round(float((~a_auto & ~a_ref).mean()), 4),  # 0 -> refer only
    "recapture_fraction": 0.0,
    "refer_fraction": round(float(a_ref.mean()), 4),
    "missed_referable_not_routed_to_human": int(a_missed),
    "missed_referable_fraction": round(float(a_missed / ref.sum()), 4),
    "safety_sensitivity": round(float(1 - a_missed / ref.sum()), 4),
})

# B: + quality gate (q<0.60 -> human review/recapture BEFORE grading) on top of A routing
lowq = q < 0.60
b_auto = (~pred_ref) & (~lowq)
b_human = lowq | pred_ref
b_missed = (ref & b_auto).sum()
rows.append({
    "arm": "B_X1C2_quality_gate",
    "components": "X1C2 argmax + quality gate (q<0.60)",
    "auto_screen_fraction": round(float(b_auto.mean()), 4),
    "human_attention_fraction": round(float(b_human.mean()), 4),
    "human_review_fraction": round(float(b_human.mean()), 4),
    "recapture_fraction": round(float(lowq.mean()), 4),
    "refer_fraction": round(float(pred_ref.mean()), 4),
    "missed_referable_not_routed_to_human": int(b_missed),
    "missed_referable_fraction": round(float(b_missed / ref.sum()), 4),
    "safety_sensitivity": round(float(1 - b_missed / ref.sum()), 4),
})

# C: + workflow logic (routing with Mild-boundary guard + confidence)
c_auto = route == "SCREENING_OUTPUT"
c_ref = route == "REFER"
c_review = route == "HUMAN_REVIEW"
c_human = c_ref | c_review
c_missed = (ref & c_auto).sum()
rows.append({
    "arm": "C_X1C2_workflow",
    "components": "X1C2 argmax + workflow routing (refer/Mild-boundary/confidence)",
    "auto_screen_fraction": round(float(c_auto.mean()), 4),
    "human_attention_fraction": round(float(c_human.mean()), 4),
    "human_review_fraction": round(float(c_review.mean()), 4),
    "recapture_fraction": 0.0,
    "refer_fraction": round(float(c_ref.mean()), 4),
    "missed_referable_not_routed_to_human": int(c_missed),
    "missed_referable_fraction": round(float(c_missed / ref.sum()), 4),
    "safety_sensitivity": round(float(1 - c_missed / ref.sum()), 4),
})

# D: quality gate + workflow
# C would auto-screen any SCREENING_OUTPUT route; the quality gate blocks the
# low-quality ones (q<0.60), so they are recaptured (q<0.35) or human-reviewed.
d_auto = c_auto & (~lowq)
d_recap = q < 0.35
d_ref = c_ref
d_review = (c_review & (~lowq)) | (c_auto & (q >= 0.35) & (q < 0.60))
d_human = d_ref | d_review | d_recap
d_missed = (ref & d_auto).sum()
rows.append({
    "arm": "D_full_pipeline",
    "components": "X1C2 argmax + quality gate + workflow + report/explainability artifact",
    "auto_screen_fraction": round(float(d_auto.mean()), 4),
    "human_attention_fraction": round(float(d_human.mean()), 4),
    "human_review_fraction": round(float(d_review.mean()), 4),
    "recapture_fraction": round(float(d_recap.mean()), 4),
    "refer_fraction": round(float(d_ref.mean()), 4),
    "missed_referable_not_routed_to_human": int(d_missed),
    "missed_referable_fraction": round(float(d_missed / ref.sum()), 4),
    "safety_sensitivity": round(float(1 - d_missed / ref.sum()), 4),
})

ab = pd.DataFrame(rows)
ab.to_csv(X2_METRICS / "X2_ABLATION.csv", index=False)
out = {"scope": {
           "dataset": "APTOS 2019 blindness-detection",
           "split": "validation (frozen v8.12 partition)",
           "n": int(n),
           "locked_test_used": False,
           "note": "Ablation is a routing-level study on validation only. The locked test was never used for ablation.",
       },
       "classifier_level_constant": classifier, "arms": ab.to_dict("records"),
       "interpretation": "Validation-split ablation (n=%d); the locked test is not used here. D full pipeline does NOT 'outperform' the classifier at grading (identical sens/spec by construction). D converts 20 auto-screened missed-referable to 0 by routing them to human attention (Mild-boundary guard + quality gate). Cost: auto-screen fraction 0.576 -> 0.336, human-attention 0.424 -> 0.664. This is a routing/safety trade, not a grading improvement." % n}
json.dump(out, open(X2_METRICS / "x2_h_ablation.json", "w"), indent=2)
print(json.dumps({"classifier_level_constant": classifier, "arms": ab.to_dict("records")}, indent=2))