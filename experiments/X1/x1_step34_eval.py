# -*- coding: utf-8 -*-
# X1 Step 3+4 — Calibrate on validation, search + freeze operating point
# (predeclared rule), then SINGLE locked-test evaluation + robustness.
import json, time
from pathlib import Path
import numpy as np
import pandas as pd
import torch
from sklearn.metrics import roc_curve, precision_recall_curve, auc as sk_auc, confusion_matrix as sk_cm
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from PIL import Image
import cv2
from x1_common import (
    ROOT, X1_DIR, X1_CKPT_DIR, X1_METRICS, X1_PLOTS, CANDIDATE,
    load_locked_data, DROrdinalRefNet, evaluate, fit_temperature,
    multiclass_brier, search_referable_operating_point, sha256_file,
    DR_CLASSES, DEVICE, BATCH, NUM_WORKERS, MEAN, STD, preprocess_fundus,
)

try:
    from torch.utils.data import DataLoader, Dataset
    import torch.nn.functional as F
    from torchvision import transforms
except Exception:
    pass

CKPT = X1_CKPT_DIR / f"dr_x1c2_best_{CANDIDATE}.pt"


def roc_pr_plot(y, score, path_roc, path_pr, title_prefix="X1-C2 validation"):
    y = (np.asarray(y) >= 2).astype(int)
    s = np.asarray(score, float)
    fpr, tpr, _ = roc_curve(y, s)
    prec, rec, _ = precision_recall_curve(y, s)
    roc_auc = sk_auc(fpr, tpr)
    pr_auc = sk_auc(rec, prec)

    fig, ax = plt.subplots(1, 1, figsize=(5.2, 5))
    ax.plot(fpr, tpr, lw=2, label=f"AUC = {roc_auc:.4f}")
    ax.plot([0, 1], [0, 1], "k--", lw=1)
    ax.set_xlabel("False positive rate"); ax.set_ylabel("True positive rate")
    ax.set_title(f"{title_prefix} · Referable ROC"); ax.legend(loc="lower right")
    fig.tight_layout(); fig.savefig(path_roc, dpi=140); plt.close(fig)

    fig, ax = plt.subplots(1, 1, figsize=(5.2, 5))
    ax.plot(rec, prec, lw=2, label=f"AP = {pr_auc:.4f}")
    ax.set_xlabel("Recall (sensitivity)"); ax.set_ylabel("Precision")
    ax.set_title(f"{title_prefix} · Referable PR"); ax.legend(loc="upper right")
    fig.tight_layout(); fig.savefig(path_pr, dpi=140); plt.close(fig)
    return {"roc_auc": float(roc_auc), "pr_auc": float(pr_auc)}


def conf_matrix_plot(cm, path, title="X1-C2 validation confusion matrix"):
    fig, ax = plt.subplots(1, 1, figsize=(6.4, 5.6))
    im = ax.imshow(np.asarray(cm), cmap="Blues")
    for i in range(cm.shape[0]):
        for j in range(cm.shape[1]):
            ax.text(j, i, int(cm[i, j]), ha="center", va="center",
                    color="white" if cm[i, j] > cm.max() / 2 else "black")
    ax.set_xticks(range(5), DR_CLASSES, rotation=45, ha="right")
    ax.set_yticks(range(5), DR_CLASSES)
    ax.set_xlabel("Predicted"); ax.set_ylabel("True")
    ax.set_title(title)
    fig.colorbar(im); fig.tight_layout(); fig.savefig(path, dpi=140); plt.close(fig)


# deterministic corruption protocol — identical to v8.12
def deterministic_corruption(x, severity, seed=0):
    if severity == 0: return x.copy()
    if severity == 1: return cv2.GaussianBlur(x, (3, 3), 0)
    if severity == 2: return cv2.convertScaleAbs(cv2.GaussianBlur(x, (5, 5), 0), alpha=0.85, beta=8)
    if severity == 3:
        rng = np.random.default_rng(seed)
        return np.clip(x.astype(np.float32) + rng.normal(0, 10, x.shape), 0, 255).astype(np.uint8)
    if severity == 4:
        bgr = cv2.cvtColor(x, cv2.COLOR_RGB2BGR)
        ok, enc = cv2.imencode(".jpg", bgr, [cv2.IMWRITE_JPEG_QUALITY, 35])
        if ok:
            return cv2.cvtColor(cv2.imdecode(enc, cv2.IMREAD_COLOR), cv2.COLOR_BGR2RGB)
        return x.copy()
    if severity == 5:
        h, w = x.shape[:2]
        small = cv2.resize(x, (max(1, w // 2), max(1, h // 2)), interpolation=cv2.INTER_AREA)
        return cv2.resize(small, (w, h), interpolation=cv2.INTER_LINEAR)
    raise ValueError


class RobustDS(Dataset):
    def __init__(self, df, severity, seed):
        self.df = df.reset_index(drop=True); self.s = severity; self.seed = seed
        ops = [transforms.ToPILImage(), transforms.ToTensor(),
               transforms.Normalize(MEAN, STD)]
        self.tf = transforms.Compose(ops)

    def __len__(self): return len(self.df)

    def __getitem__(self, i):
        r = self.df.iloc[i]
        raw = np.asarray(Image.open(r.image_path).convert("RGB"))
        pp = preprocess_fundus(deterministic_corruption(raw, self.s, self.seed))
        return self.tf(pp), int(r.diagnosis)


@torch.no_grad()
def robust_qwk(model, df, severity, seed):
    dl = DataLoader(RobustDS(df, severity, seed), batch_size=BATCH, shuffle=False,
                    num_workers=NUM_WORKERS)
    y = []; p = []
    model.eval()
    for x, yy in dl:
        c, _, _ = model(x.to(DEVICE))
        p.extend(c.float().argmax(1).cpu().numpy()); y.extend(yy.numpy())
    return float(__import__("sklearn").metrics.cohen_kappa_score(y, p, weights="quadratic"))


def main():
    t0 = time.time()
    train_df, val_df, test_df = load_locked_data()

    model = DROrdinalRefNet(pretrained=False).to(DEVICE)
    sd = torch.load(CKPT, map_location="cuda")["model"]
    model.load_state_dict(sd)
    model.eval()

    # ---- validation: calibrate + operating point (validation only) ----
    ev = evaluate(model, val_df, temperature=1.0)
    T = fit_temperature(ev["logits"], ev["y"])
    ev_cal = evaluate(model, val_df, temperature=T)
    brier_val = multiclass_brier(ev["y"], ev_cal["probs"])

    rows, chosen = search_referable_operating_point(ev["y"], ev_cal["ref_score"],
                                                     min_sens=0.90, min_spec=0.85)
    if chosen is None:
        print("VALIDATION TARGET INFEASIBLE under this candidate. No locked-test run.")
        json.dump({"feasible": False, "sweep": rows}, open(X1_METRICS / "x1_operating_point_sweep.json", "w"), indent=2)
        return

    th = chosen["threshold"]
    op = {
        "fit_split": "validation_only",
        "candidate": CANDIDATE,
        "rule": "among validation thresholds with sens>=0.90 and spec>=0.85, maximize specificity; tie-break smaller threshold",
        "threshold": th,
        "validation_metrics": {k: float(chosen[k]) for k in ("sens", "spec", "tp", "fn", "tn", "fp")},
        "temperature": T,
        "distinct_from_v812_referral_policy": "v8.12 referral-policy T=0.78104581 is a 0.55*ref_prob+0.20*entropy+0.25*(1-quality) risk score and is NOT this classifier probability threshold",
    }
    json.dump(op, open(X1_METRICS / "x1_operating_point.json", "w"), indent=2)
    json.dump({"fit_split": "validation_only", "temperature": T,
               "val_brier": brier_val}, open(X1_METRICS / "x1_calibration.json", "w"), indent=2)

    # plots (validation)
    cur = roc_pr_plot(ev["y"], ev_cal["ref_score"], X1_PLOTS / "X1_VALIDATION_ROC.png",
                      X1_PLOTS / "X1_VALIDATION_PR.png", title_prefix="X1-C2 validation")
    cm_val = sk_cm(ev["y"], (ev_cal["ref_score"] >= th).astype(int) * 0 + (ev["pred"]), labels=list(range(5)))
    # classification confusion (argmax)
    cm_val = sk_cm(ev["y"], ev["pred"], labels=list(range(5)))
    conf_matrix_plot(cm_val, X1_PLOTS / "X1_CONFUSION_MATRIX.png",
                     title="X1-C2 validation confusion matrix")

    # ---- single locked-test evaluation (frozen model + temp + threshold) ----
    tev = evaluate(model, test_df, temperature=T)
    brier_test = multiclass_brier(tev["y"], tev["probs"])
    rp = (tev["ref_score"] >= th).astype(int)
    yref = (tev["y"] >= 2).astype(int)
    tp = int(((rp == 1) & (yref == 1)).sum()); fn = int(((rp == 0) & (yref == 1)).sum())
    tn = int(((rp == 0) & (yref == 0)).sum()); fp = int(((rp == 1) & (yref == 0)).sum())
    locked_report = {
        "scope": "APTOS_LOCKED_TEST single-shot; frozen model + temp + threshold",
        "threshold": th, "temperature": T,
        "n": int(len(test_df)),
        "qwk": tev["qwk"], "macro_f1": tev["macro_f1"],
        "balanced_accuracy": tev["balanced_accuracy"], "accuracy": tev["accuracy"],
        "referable_auc": tev["referable_auc"],
        "log_loss_raw_argmax": tev["log_loss"],
        "brier": brier_test,
        "at_frozen_threshold": {
            "sens": float(tp / max(tp + fn, 1)), "spec": float(tn / max(tn + fp, 1)),
            "tp": tp, "fn": fn, "tn": tn, "fp": fp},
        "at_argmax": {"sens": tev["referable_sensitivity"],
                      "spec": tev["referable_specificity"]},
        "confusion_matrix_argmax": sk_cm(tev["y"], tev["pred"], labels=list(range(5))).tolist(),
        "class_counts": test_df.diagnosis.value_counts().reindex(range(5), fill_value=0).astype(int).to_dict(),
        "elapsed_s": round(time.time() - t0, 1),
    }
    json.dump(locked_report, open(X1_METRICS / "x1_locked_test_report.json", "w"), indent=2)

    # robustness on locked test (single protocol, like v8.12)
    rob_rows = []
    for severity in range(6):
        vals = [robust_qwk(model, test_df, severity, s) for s in (0, 1, 2, 3, 4)]
        rob_rows.append({"severity": severity, "qwk_mean": float(np.mean(vals)),
                         "qwk_std": float(np.std(vals, ddof=1)), "qwk_values": vals})
    pd.DataFrame(rob_rows).to_csv(X1_METRICS / "x1_robustness_locked_test.csv", index=False)

    print(json.dumps(locked_report, indent=2))
    print("Robustness:\n", pd.DataFrame(rob_rows).to_string())


if __name__ == "__main__":
    main()