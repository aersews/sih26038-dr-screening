# -*- coding: utf-8 -*-
# X2 common harness — workflow-aware screening integration on top of X1C2.
# - Quality gate: reuse v8.12 engineering_quality_index components (HEURISTIC).
# - Deterministic workflow policy (no learned fusion).
# - All decisions on validation; locked test evaluated once only.
import json, hashlib
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "X1"))
import numpy as np
import pandas as pd
import cv2
from PIL import Image
import torch
from x1_common import (
    REPO_ROOT, ROOT, V812_RESULTS, X1_CKPT_DIR, evaluate, DROrdinalRefNet, load_locked_data,
    DEVICE, DR_CLASSES,
)

X2_DIR = REPO_ROOT / "experiments" / "X2"
X2_METRICS = REPO_ROOT / "metrics" / "X2"
X2_PLOTS = REPO_ROOT / "plots" / "X2"
X2_EXPLAIN = REPO_ROOT / "explainability" / "X2"
X2_REPORTS = REPO_ROOT / "reports" / "X2"
X2_MATLAB = REPO_ROOT / "matlab" / "X2"
X2_SIMULINK = REPO_ROOT / "simulink" / "X2"
for p in (X2_DIR, X2_METRICS, X2_PLOTS, X2_EXPLAIN, X2_REPORTS, X2_MATLAB, X2_SIMULINK):
    p.mkdir(parents=True, exist_ok=True)

X1C2_CKPT = X1_CKPT_DIR / "dr_x1c2_best_X1C2.pt"

# ---------------------------------------------------------------------------
# Quality gate (HEURISTIC) — matches v8.12 engineering_quality_index + buckets
# ---------------------------------------------------------------------------
def illumination_uniformity_score(gray):
    g = np.asarray(gray, dtype=np.float32) / 255.0
    if g.ndim != 2:
        g = cv2.cvtColor(g, cv2.COLOR_RGB2GRAY) / 255.0
    blur = cv2.GaussianBlur(g, (0, 0), sigmaX=max(g.shape) / 20.0)
    med = float(np.median(g)) + 1e-6
    deviation = float(np.mean(np.abs(blur - med)) / med)
    return float(np.clip(1.0 - deviation, 0.0, 1.0))


def directional_motion_blur_score(gray):
    g = np.asarray(gray, dtype=np.float32)
    gx = cv2.Sobel(g, cv2.CV_32F, 1, 0, ksize=3)
    gy = cv2.Sobel(g, cv2.CV_32F, 0, 1, ksize=3)
    ax = float(np.mean(np.abs(gx))); ay = float(np.mean(np.abs(gy)))
    imbalance = abs(ax - ay) / (ax + ay + 1e-6)
    return float(np.clip(1.0 - imbalance, 0.0, 1.0))


def engineering_quality_index(img):
    img = np.asarray(img)
    gray = cv2.cvtColor(img, cv2.COLOR_RGB2GRAY)
    sharp = float(cv2.Laplacian(gray, cv2.CV_64F).var())
    sharp_score = float(np.clip(np.log1p(sharp) / 8.0, 0.0, 1.0))
    low = (gray < 15).mean(); high = (gray > 245).mean()
    exposure = float(1.0 - np.clip(low + high, 0.0, 1.0))
    fov = float(np.mean(img.sum(axis=2) > 30))
    uniform = illumination_uniformity_score(gray)
    directional = directional_motion_blur_score(gray)
    score = (0.25 * sharp_score + 0.20 * exposure + 0.20 * fov +
             0.20 * uniform + 0.15 * directional)
    return float(np.clip(score, 0.0, 1.0)), {
        "sharpness": sharp_score, "exposure": exposure,
        "fov_coverage": float(fov), "illumination_uniformity": uniform,
        "directional_motion_blur_proxy": directional,
    }


def quality_bucket(q):
    if q < 0.35:
        return "RECAPTURE_CANDIDATE"
    if q < 0.60:
        return "LOW_QUALITY_REVIEW"
    return "USABLE_FOR_MODEL"


# predeclared gate thresholds (validation-only; heuristic label)
Q_RECAPTURE = 0.35
Q_USABLE = 0.60
CONF_HIGH = 0.90   # high-confidence auto-screen threshold (probability)
UNC_HIGH = 0.50    # uncertainty above which -> human review (normalized entropy)


def normalized_entropy(p):
    p = np.clip(np.asarray(p, float), 1e-9, 1.0)
    return float(-(p * np.log(p)).sum() / np.log(len(p)))


def quality_gate_pass(raw_image, components=False):
    score, parts = engineering_quality_index(raw_image)
    bucket = quality_bucket(score)
    if bucket == "RECAPTURE_CANDIDATE":
        decision, reason = "RECAPTURE", f"quality {score:.3f} < 0.35 (heuristic)"
    elif bucket == "LOW_QUALITY_REVIEW":
        decision, reason = "HUMAN_REVIEW", f"quality {score:.3f} in [0.35, 0.60) (heuristic)"
    else:
        decision, reason = "ACCEPT", f"quality {score:.3f} >= 0.60 (heuristic)"
    out = {"quality_score": score, "quality_bucket": bucket,
           "gate_decision": decision, "reason": reason, "quality_heuristic": True}
    if components:
        out["components"] = parts
    return out


# ---------------------------------------------------------------------------
# Deterministic workflow policy (no learned fusion) — PRE-DECLARED
# Routing:
#   RECAPTURE if quality < 0.35
#   REFER if referable (argmax >= 2)
#   HUMAN_REVIEW if quality[0.35,0.60) OR low confidence(<0.90) OR high uncertainty(>0.50)
#   SCREENING_OUTPUT otherwise (non-referable + usable + confident)
# ---------------------------------------------------------------------------
def workflow_route(row):
    q = float(row["quality"])
    ref_prob = float(row["ref_prob"])
    confidence = float(row["confidence"])
    pred_ref = int(row["pred_ref"])
    pred = int(row["pred"])

    if q < Q_RECAPTURE:
        return "RECAPTURE", f"low quality {q:.3f} < 0.35"
    if pred_ref == 1:
        return "REFER", f"referable (X1C2 argmax>=2); ref_prob {ref_prob:.3f}"
    if pred == 1:
        return "HUMAN_REVIEW", f"predicted Mild NPDR (argmax=1) on referable boundary"
    if q < Q_USABLE:
        return "HUMAN_REVIEW", f"quality {q:.3f} in [0.35, 0.60)"
    if confidence < CONF_HIGH or row["uncertainty"] > UNC_HIGH:
        return "HUMAN_REVIEW", f"low confidence {confidence:.3f} / high uncertainty {row['uncertainty']:.3f}"
    return "SCREENING_OUTPUT", f"non-referable + usable + confident (conf {confidence:.3f})"


def make_decision_features(df, ev):
    p = ev["probs"]
    out = pd.DataFrame({
        "id_code": df.id_code, "image_path": df.image_path,
        "label": df.diagnosis.to_numpy(),
        "quality": df.quality.to_numpy(),
        "ref_prob": p[:, 2:].sum(1),
        "confidence": p.max(1),
        "uncertainty": [normalized_entropy(x) for x in p],
        "pred": ev["pred"],
    })
    out["true_ref"] = (out.label >= 2).astype(int)
    out["pred_ref"] = (out.pred >= 2).astype(int)
    routes = [workflow_route(r) for _, r in out.iterrows()]
    out["route"], out["route_reason"] = zip(*routes)
    return out


def ablation_arms(df, ev):
    """A..D: A=X1C2 only; B=+quality gate; C=+workflow logic; D=+quality+workflow+output."""
    feat = make_decision_features(df, ev)

    def row(arm, acting_pred_ref, screening, recapture, human_review, ref_sens, ref_spec, coverage):
        return {
            "arm": arm, "n": len(df),
            "referable_predicted": int(acting_pred_ref.sum()),
            "screen_output": int(screening.sum()),
            "recapture": int(recapture.sum()),
            "human_review": int(human_review.sum()),
            "referable_sensitivity": round(ref_sens, 4),
            "referable_specificity": round(ref_spec, 4),
            "coverage_fraction": round(coverage, 4),
            "human_review_fraction": round(float(human_review.mean()), 4),
            "recapture_fraction": round(float(recapture.mean()), 4),
        }

    ref = feat.true_ref.to_numpy().astype(bool)
    pred_ref = feat.pred_ref.to_numpy().astype(bool)

    # A: X1C2 only (no gate, no policy): all non-referable screened out
    a_screen = ~pred_ref
    a_recap = np.zeros(len(df), bool)
    a_review = np.zeros(len(df), bool)
    a_refpred = pred_ref
    sens = (pred_ref & ref).sum() / max(ref.sum(), 1)
    spec = (~pred_ref & ~ref).sum() / max((~ref).sum(), 1)
    rows = [row("A_X1C2_only", a_refpred, a_screen, a_recap, a_review, sens, spec, a_screen.mean())]

    # B: +quality gate (recapture low quality before grading)
    lowq = feat.quality.to_numpy() < Q_RECAPTURE
    b_refpred = pred_ref & ~lowq
    b_screen = ~pred_ref & ~lowq
    sens = (b_refpred & ref).sum() / max(ref.sum(), 1)
    spec = (b_screen & ~ref).sum() / max((~ref).sum(), 1)
    rows.append(row("B_X1C2_quality_gate", b_refpred, b_screen, lowq, np.zeros(len(df), bool), sens, spec, b_screen.mean()))

    # C: +workflow logic (full routing, no quality-gate rejections -> all low-q are human review)
    c_recap = np.zeros(len(df), bool)
    c_review = feat.quality.to_numpy() >= 0  # placeholder
    c_refpred = pred_ref
    c_screen = feat.route.to_numpy() == "SCREENING_OUTPUT"
    # referable determed by argmax; recapture none in C (gate not active), low-quality goes review
    c_recap = np.zeros(len(df), bool)
    sens = (c_refpred & ref).sum() / max(ref.sum(), 1)
    spec = (c_screen & ~ref).sum() / max((~ref).sum(), 1)
    rows.append(row("C_X1C2_workflow", c_refpred, c_screen, c_recap, ~c_screen & ~c_refpred, sens, spec, c_screen.mean()))

    # D: +quality gate + workflow + output artifact
    d_recap = lowq
    d_refpred = pred_ref & ~lowq
    d_screen = feat.route.to_numpy() == "SCREENING_OUTPUT"
    d_human = (feat.route.to_numpy() == "HUMAN_REVIEW") & ~lowq
    sens = (d_refpred & ref).sum() / max(ref.sum(), 1)
    spec = (d_screen & ~ref).sum() / max((~ref).sum(), 1)
    rows.append(row("D_full_pipeline", d_refpred, d_screen, d_recap, d_human | lowq, sens, spec, d_screen.mean()))

    return pd.DataFrame(rows)


def load_x1c2():
    model = DROrdinalRefNet(pretrained=False).to(DEVICE)
    model.load_state_dict(torch.load(X1C2_CKPT, map_location="cuda")["model"])
    model.eval()
    return model


def sha256_file(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for block in iter(lambda: f.read(1 << 20), b""):
            h.update(block)
    return h.hexdigest()