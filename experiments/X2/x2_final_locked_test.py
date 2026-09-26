# -*- coding: utf-8 -*-
# X2-FINAL — SINGLE locked-test evaluation of the FROZEN X2 workflow.
# Firewall: this is the ONLY locked-test touch permitted. Model, temperature
# (1.25), operating point (argmax) and routing policy are already frozen
# (X2_POLICY.json, validation-only decisions). No feedback into tuning.
import json
import numpy as np
from pathlib import Path
import importlib.util
spec = importlib.util.spec_from_file_location("x2_common", Path(__file__).resolve().parent / "x2_common.py")
x2c = importlib.util.module_from_spec(spec); spec.loader.exec_module(x2c)
X2_METRICS = x2c.X2_METRICS

train_df, val_df, test_df = x2c.load_locked_data()

model = x2c.load_x1c2()
ev = x2c.evaluate(model, test_df, temperature=1.25)
feat = x2c.make_decision_features(test_df, ev)

ref = feat.true_ref.to_numpy().astype(bool)
routes = feat.route.to_numpy()
screen = routes == "SCREENING_OUTPUT"
human = routes == "HUMAN_REVIEW"
recap = routes == "RECAPTURE"
refer = routes == "REFER"

missed = (ref & screen).sum()
missed_ids = feat.loc[ref & screen, "id_code"].tolist()

report = {
    "phase": "X2_FINAL_LOCKED_TEST",
    "n_test": int(len(test_df)),
    "temperature_frozen": 1.25,
    "operating_point": "argmax (frozen, X1C2; max-specificity threshold NOT used)",
    "policy_frozen": "experiments/X2/X2_POLICY.json (validation-only decisions)",
    "accepted_targets": {"ref_sens_gt_0_90": True, "ref_spec_gt_0_85": True},
    "classifier": {
        "qwk_test": ev["qwk"], "macro_f1_test": ev["macro_f1"],
        "balanced_accuracy_test": ev["balanced_accuracy"], "accuracy_test": ev["accuracy"],
        "referable_sensitivity_test": ev["referable_sensitivity"],
        "referable_specificity_test": ev["referable_specificity"],
        "referable_auc_test": ev["referable_auc"], "log_loss_test": ev["log_loss"],
        "confusion_matrix_test": ev["confusion_matrix"],
    },
    "workflow_policy_on_test": {
        "route_counts": {"RECAPTURE": int(recap.sum()), "HUMAN_REVIEW": int(human.sum()),
                         "SCREENING_OUTPUT": int(screen.sum()), "REFER": int(refer.sum())},
        "coverage_fraction_screen_output": round(float(screen.mean()), 4),
        "human_review_fraction": round(float(human.mean()), 4),
        "refer_fraction": round(float(refer.mean()), 4),
        "missed_referable_auto_screened": int(missed),
        "missed_referable_ids": missed_ids,
        "safety_sensitivity_workflow": round(1.0 - missed / max(ref.sum(), 1), 4),
        "referable_reviewed_or_referred_fraction": round(
            float((ref & (human | refer)).sum()) / max(ref.sum(), 1), 4),
    },
}

print(json.dumps(report, indent=2, default=float))
json.dump(report, open(X2_METRICS / "x2_final_locked_test.json", "w"), indent=2)
print("\nWROTE", X2_METRICS / "x2_final_locked_test.json")