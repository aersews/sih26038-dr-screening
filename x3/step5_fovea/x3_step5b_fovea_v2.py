"""X3 Step 5b: IDRiD C fovea localizer v2 (PROTOTYPE/EXPERIMENTAL).
Pretrained timm backbone (efficientnet_b3, same family as X1C2 backbone but a NEW
localization head) trained ONLY on IDRiD C training (413). Single-shot C-test eval.
Compared against (a) constant-centroid baseline and (b) the naive 5-conv net.
No tuning on test. Outputs result JSON + overlay for top/mid/worst.
"""
import os, cv2, json, math, time
import numpy as np, torch, torch.nn as nn, torch.nn.functional as F
import csv, timm
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
WORKSPACE_ROOT = Path(os.environ.get("SIH_WORKSPACE_ROOT", str(REPO_ROOT.parent))).expanduser().resolve()
DATA = WORKSPACE_ROOT / "data" / "idrid" / "C. Localization"
OUT_D = REPO_ROOT / "x3" / "step5_fovea"
os.makedirs(OUT_D, exist_ok=True)
IMG = 300
NATIVE = {"w": 4288, "h": 2848}

def load_coords(csvp):
    rows = []
    for r in csv.reader(open(csvp)):
        if len(r) >= 3 and r[1].strip() and r[2].strip():
            try:
                rows.append((r[0].strip(), float(r[1]), float(r[2])))
            except Exception:
                pass
    return rows

fov_tr = load_coords(DATA / "2. Groundtruths" / "2. Fovea Center Location" / "IDRiD_Fovea_Center_Training Set_Markups.csv")
fov_te = load_coords(DATA / "2. Groundtruths" / "2. Fovea Center Location" / "IDRiD_Fovea_Center_Testing Set_Markups.csv")
assert len(fov_tr) == 413 and len(fov_te) == 103

def load_image(idc, split):
    root = DATA / ("1. Original Images" / ("a. Training Set" if split == "train" else "b. Testing Set"))
    im = cv2.imread(os.path.join(root, idc + ".jpg"))
    im = cv2.resize(im, (IMG, IMG), interpolation=cv2.INTER_AREA)
    im = cv2.cvtColor(im, cv2.COLOR_BGR2RGB).astype(np.float32) / 255.0
    im = (im - im.mean()) / (im.std() + 1e-6)
    return torch.tensor(im.transpose(2, 0, 1), dtype=torch.float32)

def build(split):
    src = fov_tr if split == "train" else fov_te
    d = {f[0]: (f[1] / NATIVE["w"], f[2] / NATIVE["h"]) for f in src}
    ids = [f[0] for f in src]
    ims = [load_image(i, split) for i in ids]
    ys = torch.tensor([d[i] for i in ids], dtype=torch.float32)
    return ims, ys, ids

Xtr, ytr, idtr = build("train")
Xte, yte, idte = build("test")

# constant-centroid baseline
cx = ytr[:, 0].mean().item()
cy = ytr[:, 1].mean().item()
base_errs = np.array([
    math.hypot((cx - yte[k, 0].item()) * NATIVE["w"], (cy - yte[k, 1].item()) * NATIVE["h"])
    for k in range(len(idte))])
print("CONSTANT-CENTROID baseline: median %.1f px, within200 %.3f" % (
    np.median(base_errs), (base_errs <= 200).mean()))

class Reg(nn.Module):
    def __init__(self):
        super().__init__()
        self.b = timm.create_model("efficientnet_b3", pretrained=True, num_classes=0)
        self.head = nn.Linear(self.b.num_features, 2)

    def forward(self, x):
        return self.head(self.b(x))

torch.manual_seed(11)
model = Reg().cuda()
opt = torch.optim.AdamW(model.head.parameters(), lr=5e-3)
opt_full = torch.optim.Adam(model.parameters(), lr=1e-4)
step = 0
B = 16
EPOCHS = 12
tr_im = torch.stack([im.cuda() for im in Xtr])
ytr_c = ytr.cuda()
n = len(tr_im)
t0 = time.time()
for ep in range(1, EPOCHS + 1):
    model.train()
    perm = torch.randperm(n).cuda()
    ls = 0.0; nb = 0
    for i in range(0, n, B):
        idx = perm[i:i + B]
        out = model(tr_im[idx])
        loss = F.mse_loss(out, ytr_c[idx]) * 100
        opt.zero_grad(); loss.backward(); opt.step()
        ls += loss.item(); nb += 1
    # fine-tune prehead a bit later
    if ep >= 5:
        for i in range(0, n, B):
            idx = perm[i:i + B]
            out = model(tr_im[idx])
            loss = F.mse_loss(out, ytr_c[idx]) * 100
            opt_full.zero_grad(); loss.backward(); opt_full.step()
    print("epoch %2d mse*100 %.4f  elapsed %.0fs" % (ep, ls / nb, time.time() - t0))

model.eval()
with torch.no_grad():
    te_im = torch.stack([im.cuda() for im in Xte])
    out = model(te_im).cpu().numpy()

errs = np.array([
    math.hypot((out[k, 0] - yte[k, 0].item()) * NATIVE["w"],
               (out[k, 1] - yte[k, 1].item()) * NATIVE["h"])
    for k in range(len(idte))])
within = {str(t): float((errs <= t).mean()) for t in (50, 100, 200)}

res = {
    "phase": "x3_step5b_idrid_c_fovea_prototype_v2",
    "version": "v9_0",
    "execution_status": "EXECUTED_PROTOTYPE_EXPERIMENTAL",
    "trained_on": "IDRiD C training n=413 official fovea centers",
    "evaluated_on": "IDRiD C test n=103 single-shot no tuning",
    "method": "pretrained efficientnet_b3 (timm) + linear head, input 300x300; isolated prototype",
    "baselines": {
        "constant_centroid_median_px": float(np.median(base_errs)),
        "constant_centroid_within200": float((base_errs <= 200).mean()),
        "naive_5conv_median_px": 1808.3
    },
    "results_native_px": {
        "n": int(len(errs)), "mean": float(errs.mean()), "sd": float(errs.std()),
        "median": float(np.median(errs)),
        "q25": float(np.percentile(errs, 25)), "q75": float(np.percentile(errs, 75)),
        "min": float(errs.min()), "max": float(errs.max()),
        "ci95": [float(np.percentile(errs, 2.5)), float(np.percentile(errs, 97.5))],
    },
    "frac_within_px": within,
    "scope": "PROTOTYPE experimental localizer; NOT a clinical claim; does not update DR grading evidence",
    "model": os.path.join(OUT_D, "fovea_prototype_v2_v9_0.pt"),
    "executed_at": time.strftime("%d-%b-%Y %H:%M:%S"),
}
torch.save({"model": model.state_dict(), "backbone": "efficientnet_b3", "head": "linear2", "img_size": IMG}, res["model"])
json.dump(res, open(os.path.join(OUT_D, "x3_fovea_prototype_v2_results.json"), "w"), indent=1)

os.makedirs(os.path.join(OUT_D, "overlays"), exist_ok=True)
idx = sorted(range(len(idte)), key=lambda k: errs[k])
for k in [idx[0], idx[len(idx) // 2], idx[-1]]:
    im = cv2.imread(os.path.join(DATA, "1. Original Images", "b. Testing Set", idte[k] + ".jpg"))
    im = cv2.resize(im, (1024, 680))
    gx, gy = yte[k, 0].item() * 1024, yte[k, 1].item() * 680
    px, py = out[k, 0] * 1024, out[k, 1] * 680
    cv2.circle(im, (int(gx), int(gy)), 14, (0, 255, 0), 3)
    cv2.circle(im, (int(px), int(py)), 10, (0, 0, 255), 3)
    cv2.putText(im, "gt green / pred red err=%.0fpx" % errs[k], (10, 40),
                cv2.FONT_HERSHEY_SIMPLEX, 0.9, (255, 255, 255), 2)
    cv2.imwrite(os.path.join(OUT_D, "overlays", f"fovea_v2_test_{idte[k]}.png"), im)

print("v2 results: median %.1f mean %.1f within200 %.3f min %.1f max %.1f" % (
    res["results_native_px"]["median"], res["results_native_px"]["mean"],
    res["frac_within_px"]["200"], res["results_native_px"]["min"], res["results_native_px"]["max"]))
print("within_50", within["50"])