# -*- coding: utf-8 -*-
# X1 Step 1 — Baseline control: evaluate FROZEN v8.12 ckpt on locked VALIDATION split.
# Read-only wrt v8.12; used to establish the baseline validation operating point and
# to confirm harness parity. Locked test is NOT touched here.
import json, time
from pathlib import Path
import numpy as np
import torch
from x1_common import (
    ROOT, X1_METRICS, V812_FROZEN_CKPT, load_locked_data, fingerprint,
    DROrdinalRefNet, evaluate, fit_temperature, multiclass_brier,
    search_referable_operating_point, sha256_file,
)

def build_v812_state():
    # load frozen v8.12 DROrdinalNet ckpt into the ref-aware shell with ref head zeros
    d = torch.load(V812_FROZEN_CKPT, map_location="cuda")
    shell = DROrdinalRefNet(pretrained=False).to("cuda")
    sd = d["model"]
    shell.load_state_dict(sd, strict=False)
    print("load_state_dict(strict=False) OK; ckpt seed =", d.get("seed"))
    return shell

def main():
    t0 = time.time()
    train_df, val_df, test_df = load_locked_data()
    fp = fingerprint([train_df, val_df, test_df])
    print("Manifest rows:", len(train_df), len(val_df), len(test_df), "fp:", fp)

    ckptsha = sha256_file(V812_FROZEN_CKPT)
    print("Frozen ckpt sha256:", ckptsha[:16], "… (full in report)")

    model = build_v812_state()
    ev = evaluate(model, val_df, temperature=1.0)  # raw logits for temp fit
    T = fit_temperature(ev["logits"], ev["y"])
    ev_cal = evaluate(model, val_df, temperature=T)
    brier = multiclass_brier(ev["y"], ev_cal["probs"])

    rows, chosen = search_referable_operating_point(ev["y"], ev["ref_score"],
                                                     min_sens=0.90, min_spec=0.85)

    report = {
        "split": "APTOS locked validation (v8.12 freeze)",
        "fingerprint": fp,
        "ckpt": str(V812_FROZEN_CKPT),
        "ckpt_sha256": ckptsha,
        "n": int(len(val_df)),
        "class_counts": val_df.diagnosis.value_counts().reindex(range(5), fill_value=0).astype(int).to_dict(),
        "temperature": T,
        "metrics_raw": {k: v for k, v in ev.items() if k not in ("y", "pred", "probs", "logits", "ref_logit", "ref_score", "ref")},
        "brier_calibrated": brier,
        "referable_operating_point_feasible": chosen is not None,
        "referable_operating_point": chosen,
        "reported_scope": "BASELINE_VALIDATION_ONLY; baseline locked-test numbers taken from frozen final_test_report_v8_12.json",
        "elapsed_s": round(time.time() - t0, 1),
    }
    json.dump(report, open(X1_METRICS / "x1_baseline_validation_v8_12.json", "w"), indent=2)
    print(json.dumps({k: v for k, v in report.items() if k != "metrics_raw"}, indent=2))
    print("Raw baseline metrics:", json.dumps(report["metrics_raw"], indent=2))
    print("Frozen v8.12 locked-test reference (NOT recomputed): QWK 0.9008 / ref sens 0.8956 / ref spec 0.9287")

if __name__ == "__main__":
    main()