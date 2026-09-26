# -*- coding: utf-8 -*-
# X2-E — annotated AI-assisted screening report generator (validation cases only).
# Machine-produced report; explicitly NOT a diagnostic report.
import json, datetime
import numpy as np
from pathlib import Path
from PIL import Image
from x2_common import (
    X2_EXPLAIN, X2_REPORTS, load_locked_data, load_x1c2, evaluate, make_decision_features,
    engineering_quality_index, quality_gate_pass,
)
from x1_common import DR_CLASSES

train_df, val_df, test_df = load_locked_data()
model = load_x1c2()
ev_val = evaluate(model, val_df, temperature=1.25)
feat = make_decision_features(val_df, ev_val)

cases = json.load(open(X2_EXPLAIN / "X2_EXPLAINABILITY_CASES.json"))
cases_by_name = {c["name"]: c for c in cases}

refer_mask = {
    "non_referable_good_quality": (feat.true_ref == 0) & (feat.route == "SCREENING_OUTPUT"),
    "referable_good_quality": (feat.true_ref == 1) & (feat.route == "REFER"),
}
id2feat = dict(zip(feat.id_code, feat.itertuples(index=False)))


def grade_name(g):
    return DR_CLASSES[int(g)]


def reason_for_referral(r):
    if r.route == "REFER":
        return f"Referable DR (prob {r.ref_prob:.3f}): routed for human review / ophthalmology referral."
    if r.route == "HUMAN_REVIEW" and r.pred == 1:
        return "Predicted Mild NPDR (referable boundary): routed for human review."
    if r.route == "HUMAN_REVIEW" and r.quality < 0.60:
        return f"Image quality below usable threshold ({r.quality:.3f} < 0.60): routed for review / recapture feedback."
    if r.route == "HUMAN_REVIEW":
        return f"Low confidence ({r.confidence:.3f} < 0.90) / high uncertainty ({r.uncertainty:.3f} > 0.50): routed for human review."
    return "Non-referable with usable quality and high confidence: screening output (no referral)."


def build_report(case_meta, fr, evidence_png):
    q = round(float(fr.quality), 3)
    grade = int(fr.pred)
    ref_yesno = "YES" if fr.route == "REFER" or fr.ref_prob >= 0.5 else (
        "REVIEW" if fr.route == "HUMAN_REVIEW" else "NO")

    lines = []
    lines.append("=" * 72)
    lines.append("AI-ASSISTED DR SCREENING REPORT  (engine-generated; NOT a diagnostic report)")
    lines.append("=" * 72)
    lines.append(f"Generated (UTC):   {datetime.datetime.now(datetime.timezone.utc).strftime('%Y-%m-%d %H:%M:%S')}")
    lines.append(f"Image ID:          {case_meta['id_code']}")
    lines.append(f"Image quality:     {q:.3f}  [{case_meta['gate_decision']}]  (heuristic engineering index)")
    lines.append(f"DR grade (AI):     {grade_name(grade)}  (X1C2, efficientnet-b3, PyTorch-trained)")
    lines.append(f"Referable:         {ref_yesno}")
    lines.append(f"Confidence:        {fr.confidence:.3f}  (uncertainty {fr.uncertainty:.3f})")
    lines.append(f"Referable prob:    {fr.ref_prob:.3f}")
    lines.append("Evidence image:    " + evidence_png)
    lines.append("")
    lines.append("Evidence / Grad-CAM:")
    lines.append("   Referable-logit Grad-CAM overlaid on the preprocessed fundus. APTOS has no lesion")
    lines.append("   ground-truth masks, so overlays show CLASSIFIER ATTENTION only; no lesion annotation")
    lines.append("   is asserted and no lesion overlays are fabricated.")
    lines.append("")
    lines.append(f"Reason for referral route: {reason_for_referral(fr)}")
    lines.append("Human-review recommendation:")
    if fr.route == "SCREENING_OUTPUT":
        lines.append("   No human review required by the current workflow policy (non-referable, usable,")
        lines.append("   confident). Programmatic note: quality reference = " + str(round(q, 3)) + ".")
    elif fr.route == "REFER":
        lines.append("   YES - route to ophthalmologist / review queue per workflow policy.")
    else:
        lines.append("   YES - route to human review before any screening output per workflow policy.")
    lines.append("")
    lines.append("Scope: research-grade screening decision-support. The model is NOT clinically validated;")
    lines.append("final disposition is the clinician's responsibility. This is an AI-assisted screening")
    lines.append("report, not a diagnostic report.")
    lines.append("=" * 72)
    return "\n".join(lines)


meta = {}
for rec in cases:
    meta[rec["name"]] = rec

reports_written = []
for name, m in cases_by_name.items():
    fr = id2feat[m["id_code"]]
    txt = build_report(m, fr, m["image"])
    out = X2_REPORTS / f"report_{name}.txt"
    out.write_text(txt, encoding="utf-8")
    reports_written.append(str(out))
    print(txt)
    print()
    print("WROTE:", out)
    print()

json.dump({"count": len(reports_written), "files": reports_written,
           "label": "AI-assisted screening report (not a diagnostic report)"},
          open(X2_REPORTS / "X2_REPORT_EXAMPLES.json", "w"), indent=2)