# -*- coding: utf-8 -*-
# X1 — robustness only (continuation of step34; writes x1_robustness_locked_test.csv)
import json, time
import numpy as np
import pandas as pd
import torch
import torch.nn.functional as F
from torch.utils.data import DataLoader, Dataset
from torchvision import transforms
from PIL import Image
import cv2
from sklearn import metrics as skm
from x1_common import (
    ROOT, X1_CKPT_DIR, X1_METRICS, CANDIDATE, load_locked_data, DROrdinalRefNet,
    DEVICE, BATCH, NUM_WORKERS, MEAN, STD, preprocess_fundus,
)

CKPT = X1_CKPT_DIR / f"dr_x1c2_best_{CANDIDATE}.pt"
CB = X1_METRICS / "x1_robustness_locked_test.csv"


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
        self.tf = transforms.Compose([transforms.ToPILImage(), transforms.ToTensor(),
                                     transforms.Normalize(MEAN, STD)])

    def __len__(self): return len(self.df)

    def __getitem__(self, i):
        r = self.df.iloc[i]
        raw = np.asarray(Image.open(r.image_path).convert("RGB"))
        return self.tf(preprocess_fundus(deterministic_corruption(raw, self.s, self.seed))), int(r.diagnosis)


@torch.no_grad()
def robust_qwk(model, df, severity, seed):
    dl = DataLoader(RobustDS(df, severity, seed), batch_size=BATCH, shuffle=False, num_workers=NUM_WORKERS)
    y = []; p = []
    model.eval()
    for x, yy in dl:
        c, _, _ = model(x.to(DEVICE))
        p.extend(c.float().argmax(1).cpu().numpy()); y.extend(yy.numpy())
    return float(skm.cohen_kappa_score(y, p, weights="quadratic"))


def main():
    t0 = time.time()
    _, _, test_df = load_locked_data()
    model = DROrdinalRefNet(pretrained=False).to(DEVICE)
    model.load_state_dict(torch.load(CKPT, map_location="cuda")["model"]); model.eval()
    if CB.exists():
        done = pd.read_csv(CB).severity.tolist()
    else:
        done = []
    rows = []
    for severity in range(6):
        if severity in done:
            print(f"skip severity {severity} (cached)"); continue
        vals = [robust_qwk(model, test_df, severity, s) for s in (0, 1, 2, 3, 4)]
        rows.append({"severity": severity, "qwk_mean": float(np.mean(vals)),
                     "qwk_std": float(np.std(vals, ddof=1)), "qwk_values": vals})
        df = pd.read_csv(CB) if CB.exists() else pd.DataFrame(columns=["severity", "qwk_mean", "qwk_std", "qwk_values"])
        df = pd.concat([df, pd.DataFrame(rows)], ignore_index=True)
        df.to_csv(CB, index=False)
        print("severity", severity, "done", round(time.time() - t0, 1), "s")
    df = pd.read_csv(CB)
    print(df.to_string())
    print("Elapsed total:", round(time.time() - t0, 1), "s")


if __name__ == "__main__":
    main()