# -*- coding: utf-8 -*-
# X2-B/C — deterministic workflow policy + operating point reference on VALIDATION.
# - Operating point: X1C2 argmax (X1-accepted, no test tuning).
# - Policy is deterministic (no learned fusion), pre-declared in x2_common.py.
# - Freezes X2_POLICY.json; policy object carries the routing rules.
import json
import numpy as np
import pandas as pd
from x2_common import (
    X2_METRICS, load_locked_data, load_x1c2, evaluate, make_decision_features,
    workflow_route, Q_RECAPTURE, Q_USABLE, CONF_HIGH, UNC_HIGH,
)

train_df, val_df, test_df = load_locked_data()
model = load_x1c2()

# Validation-only decisions under validation temperature T=1.25 (X1 frozen).
T = 1.25
ev_val = evaluate(model, val_df, temperature=T)
feat = make_decision_features(val_df, ev_val)

routes = feat.route.to_numpy()
dist = {r: int((routes == r).sum()) for r in ("RECAPTURE", "HUMAN_REVIEW", "SCREENING_OUTPUT", "REFER")}

ref = feat.true_ref.to_numpy().astype(bool)
detected = feat.ref_prob.to_numpy() >= 0.5
sens_argmax = float((feat.pred_ref & ref).sum() / ref.sum())
spec_argmax = float(((~feat.pred_ref) & (~ref)).sum() / (~ref).sum())

# residual safety: true-referable images that would be auto-screened out
missed_routes = routes == "SCREENING_OUTPUT"
missed_ref = int((ref & missed_routes).sum())

policy_eval = {
    "operating_point": "X1C2 argmax (reference; X1-accepted; NOT test-tuned)",
    "temperature": T,
    "validation": {
        "n": len(val_df),
        "route_distribution": dist,
        "referable_argmax_sensitivity": round(sens_argmax, 4),
        "referable_argmax_specificity": round(spec_argmax, 4),
        "screen_output_fraction": round(float((routes == "SCREENING_OUTPUT").mean()), 4),
        "human_review_fraction": round(float((routes == "HUMAN_REVIEW").mean()), 4),
        "recapture_fraction": round(float((routes == "RECAPTURE").mean()), 4),
        "refer_fraction": round(float((routes == "REFER").mean()), 4),
        "coverage_fraction": round(float((routes == "SCREENING_OUTPUT").mean()), 4),
        "true_ref_in_refer_path": int((ref & (feat.pred_ref)).sum()),
        "true_ref_auto_screened_out_missed": int(missed_ref),
        "true_ref_auto_screened_out_fraction": round(float(missed_ref / ref.sum()), 6),
        "screening_output_safety_sensitivity": round(float(1 - missed_ref / ref.sum()), 6),
        "self_report": "coverage = screening_output images / n; screening outputs are non-referable+usable+confident",
    },
    "policy_definition": {
        "type": "DETERMINISTIC_RULE_BASED (no learned fusion)",
        "rules_predeclared_before_test": True,
        "Q_RECAPTURE": Q_RECAPTURE,
        "Q_USABLE": Q_USABLE,
        "CONF_HIGH": CONF_HIGH,
        "UNC_HIGH": UNC_HIGH,
        "routing": [
            "if quality < 0.35 -> RECAPTURE",
            "elif referable probability (X1C2 argmax >= 2) -> REFER (human review / referral)",
            "elif predicted class == Mild NPDR (argmax = 1) -> HUMAN_REVIEW (referable-boundary safety guard)",
            "elif quality < 0.60 -> HUMAN_REVIEW",
            "elif confidence < 0.90 or normalized_entropy > 0.50 -> HUMAN_REVIEW",
            "else -> SCREENING_OUTPUT (non-referable + usable + confident)",
        ],
    },
    "quality_gate_status": "HEURISTIC engineering index (focus/illumination/FOV/uniformity/motion proxy); not clinically validated",
}

json.dump(policy_eval, open(X2_METRICS / "x2_bc_validation_policy.json", "w"), indent=2)

# Save a policy record (the frozen policy)
policy = {
    "candidate": "X1C2",
    "operating_point": "argmax",
    "temperature": T,
    "rules": policy_eval["policy_definition"]["routing"],
    "constants": {"Q_RECAPTURE": Q_RECAPTURE, "Q_USABLE": Q_USABLE, "CONF_HIGH": CONF_HIGH, "UNC_HIGH": UNC_HIGH},
    "fit_split": "validation_only",
    "test_locked": True,
}
json.dump(policy, open(X2_METRICS / "X2_POLICY.json", "w"), indent=2)

print(json.dumps(policy_eval, indent=2))