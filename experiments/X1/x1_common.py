# -*- coding: utf-8 -*-
# X1 common harness — v9.0 DR rebaseline
# Reads ONLY the frozen v8.12 artifacts (manifest, locked split, quality cache, frozen ckpt).
# Writes ALL new artifacts under sih26038_v9_0/{experiments,checkpoints,metrics,plots}/X1.
import os, json, random, hashlib, time, warnings
from pathlib import Path
import numpy as np
import pandas as pd
from PIL import Image
import cv2
import torch
import torch.nn as nn
import torch.nn.functional as F
from torch.utils.data import Dataset, DataLoader
from torchvision import transforms
from sklearn.metrics import (
    cohen_kappa_score, f1_score, balanced_accuracy_score, accuracy_score,
    confusion_matrix, roc_auc_score, log_loss,
    roc_curve, precision_recall_curve, auc as sk_auc,
)
import timm

REPO_ROOT = Path(__file__).resolve().parents[2]
WORKSPACE_ROOT = Path(os.environ.get("SIH_WORKSPACE_ROOT", str(REPO_ROOT.parent))).expanduser().resolve()
ROOT = WORKSPACE_ROOT
V812_RESULTS = ROOT / "sih26038_results_v8_12"
V812_CKPT_DIR = ROOT / "sih26038_checkpoints_v8_12"
V812_FROZEN_CKPT = V812_CKPT_DIR / "dr_ordinal_best_v8_12.pt"

X1_DIR = REPO_ROOT / "experiments" / "X1"
X1_CKPT_DIR = REPO_ROOT / "checkpoints" / "X1"
X1_METRICS = REPO_ROOT / "metrics" / "X1"
X1_PLOTS = REPO_ROOT / "plots" / "X1"
for p in (X1_DIR, X1_CKPT_DIR, X1_METRICS, X1_PLOTS):
    p.mkdir(parents=True, exist_ok=True)

VERSION = "v9_0"
CANDIDATE = "X1C2"
SEED = 42
DEVICE = torch.device("cuda" if torch.cuda.is_available() else "cpu")
AMP = DEVICE.type == "cuda"
AMP_DEVICE = DEVICE.type

BACKBONE_NAME = "efficientnet_b3"
IMG_SIZE = 300
BATCH = 8
NUM_WORKERS = 0
EPOCHS = 20
LR = 2e-4
WEIGHT_DECAY = 1e-4
ORDINAL_WEIGHT = 0.5
REF_WEIGHT = 0.6
PATIENCE = 5
TARGET_REF_SENS = 0.90
TARGET_REF_SPEC = 0.85

MEAN = (0.485, 0.456, 0.406)
STD = (0.229, 0.224, 0.225)
DR_CLASSES = ["No DR", "Mild NPDR", "Moderate NPDR", "Severe NPDR", "Proliferative DR"]


def set_seed(seed=SEED, deterministic=True):
    random.seed(seed); np.random.seed(seed); torch.manual_seed(seed)
    if torch.cuda.is_available(): torch.cuda.manual_seed_all(seed)
    torch.backends.cudnn.deterministic = deterministic
    torch.backends.cudnn.benchmark = not deterministic


set_seed(SEED)


def sha256_file(path, chunk=1 << 20):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for block in iter(lambda: f.read(chunk), b""):
            h.update(block)
    return h.hexdigest()


# ---------------------------------------------------------------------------
# Data loading — frozen v8.12 manifest + locked split, READ ONLY
# ---------------------------------------------------------------------------
def load_locked_data():
    man = pd.read_csv(V812_RESULTS / "aptos_manifest_v8_12.csv")
    lock = json.load(open(V812_RESULTS / "locked_split_ids_v8_12.json"))
    qc = pd.read_csv(V812_RESULTS / "aptos_quality_cache.csv")
    man = man.merge(qc, on="image_path", how="left")
    parts = {}
    for name in ("train", "val", "test"):
        ids = set(lock[name])
        df = man[man.id_code.isin(ids)].reset_index(drop=True)
        assert len(df) == len(ids), f"{name}: manifest vs locked split mismatch"
        parts[name] = df
    # no-leak audit
    for a, b in [("train", "val"), ("train", "test"), ("val", "test")]:
        assert not (set(parts[a].sha256) & set(parts[b].sha256)), f"sha leak {a}/{b}"
        assert not (set(parts[a].group_id) & set(parts[b].group_id)), f"group leak {a}/{b}"
    return parts["train"], parts["val"], parts["test"]


def fingerprint(dfs):
    cols = "|".join(d.id_code.astype(str).str.cat(sep=",") for d in dfs)
    return hashlib.sha256(cols.encode()).hexdigest()[:16]


# ---------------------------------------------------------------------------
# Preprocessing — exact v8.12 data contract
# ---------------------------------------------------------------------------
def compute_fundus_crop(image_rgb):
    gray = cv2.cvtColor(image_rgb, cv2.COLOR_RGB2GRAY)
    fg = gray > 7
    if not fg.any():
        return 0, 0, image_rgb.shape[1], image_rgb.shape[0]
    ys, xs = np.where(fg)
    x0, y0, x1, y1 = xs.min(), ys.min(), xs.max() + 1, ys.max() + 1
    roi = image_rgb[y0:y1, x0:x1]
    g2 = cv2.cvtColor(roi, cv2.COLOR_RGB2GRAY)
    _, th = cv2.threshold(g2, 10, 255, cv2.THRESH_BINARY)
    cnts, _ = cv2.findContours(th, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    if cnts:
        x, y, w, h = cv2.boundingRect(max(cnts, key=cv2.contourArea))
        if w >= 10 and h >= 10:
            return x0 + x, y0 + y, x0 + x + w, y0 + y + h
    return x0, y0, x1, y1


def apply_geometry(image_rgb, size=300, enhance=True):
    x0, y0, x1, y1 = compute_fundus_crop(image_rgb)
    rgb = image_rgb[y0:y1, x0:x1]
    if enhance:
        lab = cv2.cvtColor(rgb, cv2.COLOR_RGB2LAB)
        l, a, b = cv2.split(lab)
        l = cv2.createCLAHE(2.0, (8, 8)).apply(l)
        rgb = cv2.cvtColor(cv2.merge((l, a, b)), cv2.COLOR_LAB2RGB)
    return cv2.resize(rgb, (size, size), interpolation=cv2.INTER_AREA)


def preprocess_fundus(image_or_path, size=IMG_SIZE):
    if isinstance(image_or_path, (str, Path)):
        image_or_path = np.asarray(Image.open(image_or_path).convert("RGB"))
    return apply_geometry(image_or_path, size=size, enhance=True)


def dr_tf(train=False):
    ops = [transforms.ToPILImage()]
    if train:
        ops += [transforms.RandomHorizontalFlip(0.5),
                transforms.RandomRotation(10),
                transforms.ColorJitter(brightness=0.08, contrast=0.08, saturation=0.05)]
    ops += [transforms.ToTensor(), transforms.Normalize(MEAN, STD)]
    return transforms.Compose(ops)


class DRDataset(Dataset):
    def __init__(self, df, train=False):
        self.df = df.reset_index(drop=True)
        self.tf = dr_tf(train)

    def __len__(self):
        return len(self.df)

    def __getitem__(self, i):
        r = self.df.iloc[i]
        return self.tf(preprocess_fundus(r.image_path)), int(r.diagnosis)


# ---------------------------------------------------------------------------
# Model — X1C2 candidate: v8.12 backbone + auxiliary referable head
# ---------------------------------------------------------------------------
class DROrdinalRefNet(nn.Module):
    def __init__(self, pretrained=True):
        super().__init__()
        self.backbone = timm.create_model(BACKBONE_NAME, pretrained=pretrained,
                                          num_classes=0, global_pool="avg")
        f = self.backbone.num_features
        self.drop = nn.Dropout(0.35)
        self.cls = nn.Linear(f, 5)
        self.ord = nn.Linear(f, 4)
        self.ref = nn.Linear(f, 1)

    def forward(self, x):
        z = self.drop(self.backbone(x))
        return self.cls(z), self.ord(z), self.ref(z)


def ordinal_target(y):
    return torch.stack([(y > k).float() for k in range(4)], dim=1)


def referable_target(y):
    return (y >= 2).float().unsqueeze(1)


def make_losses(df):
    counts = df.diagnosis.value_counts().reindex(range(5), fill_value=1).to_numpy(float)
    # X1C2: severity-emphasis class weights (sqrt-scaled inverse-frequency, capped)
    w = np.clip(np.sqrt(len(df) / (5 * counts)), 0.5, 4.0)
    sev = np.asarray([1.0, 1.0, 1.0, 1.2, 1.3])  # emphasise severe NPDR / PDR
    w = np.clip(w * sev, 0.5, 5.0)
    ce = nn.CrossEntropyLoss(weight=torch.tensor(w, dtype=torch.float32, device=DEVICE))
    pos = []
    for k in range(4):
        n = max(int((df.diagnosis.to_numpy() > k).sum()), 1)
        pos.append(min((len(df) - n) / n, 10.0))
    bce = nn.BCEWithLogitsLoss(pos_weight=torch.tensor(pos, dtype=torch.float32, device=DEVICE))
    n_ref = max(int((df.diagnosis.to_numpy() >= 2).sum()), 1)
    ref_pos = min((len(df) - n_ref) / n_ref, 10.0)
    ref_bce = nn.BCEWithLogitsLoss(pos_weight=torch.tensor([ref_pos], dtype=torch.float32, device=DEVICE))
    return ce, bce, ref_bce, {"class_weights": w.tolist(), "ordinal_pos": pos, "ref_pos": [ref_pos]}


@torch.no_grad()
def evaluate(model, df, temperature=1.0, want_ref=True):
    dl = DataLoader(DRDataset(df), batch_size=BATCH, shuffle=False, num_workers=NUM_WORKERS)
    y_all, p_all, z_all, ref_logit_all = [], [], [], []
    model.eval()
    for x, y in dl:
        c, o, r = model(x.to(DEVICE, non_blocking=True))
        z = c.float()
        p = F.softmax(z / temperature, dim=1).cpu().numpy()
        z_all.extend(z.cpu().numpy()); p_all.extend(p)
        y_all.extend(y.numpy()); ref_logit_all.extend(r.float().cpu().numpy().ravel())
    y = np.asarray(y_all); p = np.asarray(p_all); z = np.asarray(z_all)
    ref_logit = np.asarray(ref_logit_all)
    pred = p.argmax(1)
    ref = (y >= 2).astype(int)
    ref_pred = (pred >= 2).astype(int)
    ref_score = p[:, 2:].sum(1)
    out = {
        "qwk": float(cohen_kappa_score(y, pred, weights="quadratic")),
        "macro_f1": float(f1_score(y, pred, average="macro", zero_division=0)),
        "balanced_accuracy": float(balanced_accuracy_score(y, pred)),
        "accuracy": float(accuracy_score(y, pred)),
        "referable_sensitivity": float(((ref_pred == 1) & (ref == 1)).sum() / max(ref.sum(), 1)),
        "referable_specificity": float(((ref_pred == 0) & (ref == 0)).sum() / max((ref == 0).sum(), 1)),
        "referable_auc": float(roc_auc_score(ref, ref_score)) if len(np.unique(ref)) == 2 else None,
        "log_loss": float(log_loss(y, np.clip(p, 1e-7, 1 - 1e-7), labels=list(range(5)))),
        "confusion_matrix": confusion_matrix(y, pred, labels=list(range(5))).tolist(),
        "y": y, "pred": pred, "probs": p, "logits": z, "ref_logit": ref_logit,
        "ref_score": ref_score, "ref": ref,
    }
    return out


def multiclass_brier(y, p):
    oh = np.eye(p.shape[1])[y]
    return float(np.mean(np.sum((p - oh) ** 2, axis=1)))


def fit_temperature(logits, y):
    z = torch.tensor(logits, dtype=torch.float32)
    yy = torch.tensor(y, dtype=torch.long)
    best = (float("inf"), 1.0)
    for T in np.linspace(0.5, 3.0, 101):
        loss = F.cross_entropy(z / float(T), yy).item()
        if loss < best[0]:
            best = (loss, float(T))
    return best[1]


# ---------------------------------------------------------------------------
# Operating-point search on REFERABLE probability (distinct from v8.12
# referral-policy risk threshold T=0.78104581, which is documented separately).
# Predeclared rule: among validation thresholds with sens>=0.90 AND spec>=0.85,
# select the threshold with MAXIMUM specificity; tie-break = smaller threshold.
# ---------------------------------------------------------------------------
def search_referable_operating_point(y_true, ref_score, min_sens=0.90, min_spec=0.85):
    y = (np.asarray(y_true) >= 2).astype(int)
    s = np.asarray(ref_score, dtype=float)
    ths = np.unique(np.round(np.r_[0.0, s, 1.0], 10))[::-1]
    rows = []
    for t in ths:
        pr = (s >= t).astype(int)
        tp = int(((pr == 1) & (y == 1)).sum()); fn = int(((pr == 0) & (y == 1)).sum())
        tn = int(((pr == 0) & (y == 0)).sum()); fp = int(((pr == 1) & (y == 0)).sum())
        sens = tp / max(tp + fn, 1)
        spec = tn / max(tn + fp, 1)
        rows.append({"threshold": float(t), "sens": float(sens), "spec": float(spec),
                     "tp": tp, "fn": fn, "tn": tn, "fp": fp})
    feasible = [r for r in rows if r["sens"] + 1e-12 >= min_sens and r["spec"] + 1e-12 >= min_spec]
    chosen = None
    if feasible:
        # predeclared rule: maximize specificity; tie-break smaller threshold
        chosen = max(feasible, key=lambda r: (r["spec"], -r["threshold"]))
    return rows, chosen