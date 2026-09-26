# -*- coding: utf-8 -*-
# X2-A — QUALITY GATE: verify heuristic gate on the full APTOS manifest
# (validation-based engineering; heuristic label; no clinical claim).
import json
import numpy as np
import pandas as pd
from pathlib import Path
from PIL import Image
import cv2
from x2_common import (
    ROOT, V812_RESULTS, X2_METRICS, X2_PLOTS, load_locked_data,
    engineering_quality_index, quality_bucket, quality_gate_pass, Q_RECAPTURE, Q_USABLE,
)
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

man = pd.read_csv(V812_RESULTS / "aptos_manifest_v8_12.csv")
qc = pd.read_csv(V812_RESULTS / "aptos_quality_cache.csv")
man = man.merge(qc, on="image_path", how="left")

# Recompute quality for a sample to confirm cache consistency
sample = man.image_path.iloc[0]
img = np.asarray(Image.open(sample).convert("RGB"))
q_re, _ = engineering_quality_index(img)
cache_consistency = {"image": sample, "cache_quality": float(man.quality.iloc[0]), "recomputed_quality": q_re}

train_df, val_df, test_df = load_locked_data()

def gate_summary(df):
    q = df.quality.to_numpy()
    recapture = (q < Q_RECAPTURE).mean()
    lowq_review = ((q >= Q_RECAPTURE) & (q < Q_USABLE)).mean()
    usable = (q >= Q_USABLE).mean()
    n_ref = (df.diagnosis >= 2).sum()
    n_ref_recapture = int(((df.diagnosis >= 2).to_numpy() & (q < Q_RECAPTURE)).sum())
    return {
        "n": len(df), "quality_mean": round(float(q.mean()), 4), "quality_std": round(float(q.std()), 4),
        "recapture_fraction": round(float(recapture), 4),
        "low_quality_review_fraction": round(float(lowq_review), 4),
        "usable_fraction": round(float(usable), 4),
        "referable_count": int(n_ref),
        "referable_in_recapture_candidate": int(n_ref_recapture),
        "referable_in_recapture_fraction": round(float(n_ref_recapture / max(n_ref, 1)), 4),
    }

summary = {"cache_consistency_check": cache_consistency,
           "train": gate_summary(train_df), "validation": gate_summary(val_df),
           "test": gate_summary(test_df)}

# gate evidence examples from VALIDATION (not test)
def pick(df, bucket_pred):
    m = df.quality.map(quality_bucket).map(bucket_pred) if callable(bucket_pred) else bucket_pred
    idx = m.to_numpy().nonzero()
    return df.iloc[idx[0][0]] if len(idx[0]) else None

def gate_example(r):
    img = np.asarray(Image.open(r.image_path).convert("RGB"))
    score, parts = engineering_quality_index(img)
    gate = quality_gate_pass(img, components=True)
    fig, ax = plt.subplots(1, 1, figsize=(4.6, 4.6))
    ax.imshow(img); ax.axis("off")
    ax.set_title(f"id {r.id_code}\nquality {score:.3f} — {gate['quality_bucket']}\n{gate['gate_decision']}")
    fig.tight_layout()
    p = X2_PLOTS / f"x2_gate_example_{r.id_code}.png"
    fig.savefig(p, dpi=140); plt.close(fig)
    return {"id_code": r.id_code, "quality_score": round(score, 4), "components": {k: round(v, 4) for k, v in parts.items()},
            "gate_decision": gate["gate_decision"], "bucket": gate["quality_bucket"],
            "true_grade": int(r.diagnosis), "image_saved": str(p)}

# 1 good quality, 2 poor/recapture
ann_good = pick(val_df, lambda b: b == "USABLE_FOR_MODEL")
ann_poor = pick(val_df, lambda b: b == "RECAPTURE_CANDIDATE")
if ann_poor is None:
    q = val_df.quality.to_numpy()
    ann_poor = val_df.iloc[int(np.argmin(q))]
ann_low = pick(val_df, lambda b: b == "LOW_QUALITY_REVIEW")
if ann_low is None:
    ann_low = ann_poor
if ann_low is None:
    q = val_df.quality.to_numpy()
    ann_low = val_df.iloc[int(np.argmin(q))]

summary["examples_good_quality"] = gate_example(ann_good)
summary["examples_poor_quality"] = gate_example(ann_poor)
if ann_low is not None:
    summary["examples_lowreview_quality"] = gate_example(ann_low)

# quality distribution histogram (validation)
q = val_df.quality.to_numpy()
fig, ax = plt.subplots(1, 1, figsize=(6.4, 4))
ax.hist(q, bins=40, color="steelblue", edgecolor="white")
ax.axvline(Q_RECAPTURE, color="red", ls="--", label=f"recapture < {Q_RECAPTURE}")
ax.axvline(Q_USABLE, color="green", ls="--", label=f"usable >= {Q_USABLE}")
ax.set_xlabel("engineering quality index (heuristic)"); ax.set_ylabel("validation images")
ax.set_title("X2 validation quality distribution (n=733)")
ax.legend()
fig.tight_layout(); fig.savefig(X2_PLOTS / "X2_QUALITY_DISTRIBUTION.png", dpi=140); plt.close(fig)

json.dump(summary, open(X2_METRICS / "x2_a_quality_gate.json", "w"), indent=2)
print(json.dumps(summary, indent=2))