"""X3 Step 5: IDRiD C fovea localizer (PROTOTYPE/EXPERIMENTAL).
- Trained ONLY on IDRiD C training set (413 images, official fovea centers).
- Single-shot evaluation on IDRiD C test set (103 images) — no tuning on test.
- Small randomly-initialized CNN regressing normalized (x,y); no pretrained weights.
- Isolated experiment; does not touch APTOS locked test or IDRiD B grading labels.
Outputs: model .pt, result JSON, overlay PNGs for 4 test images.
"""
import os, cv2, json, math, time
import numpy as np, torch, torch.nn as nn, torch.nn.functional as F
import csv
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
WORKSPACE_ROOT = Path(os.environ.get("SIH_WORKSPACE_ROOT", str(REPO_ROOT.parent))).expanduser().resolve()
DATA = WORKSPACE_ROOT / "data" / "idrid" / "C. Localization"
OUT_D = REPO_ROOT / "x3" / "step5_fovea"
os.makedirs(OUT_D, exist_ok=True)

IMG_W, IMG_H = 320, 213  # keep 1.505 aspect of 4288x2848

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
assert len(fov_tr) == 413 and len(fov_te) == 103, (len(fov_tr), len(fov_te))

def load_image(idc, split):
    root = DATA / ("1. Original Images" / ("a. Training Set" if split == "train" else "b. Testing Set"))
    im = cv2.imread(os.path.join(root, idc + ".jpg"))
    h, w = im.shape[:2]
    im = cv2.resize(im, (IMG_W, IMG_H), interpolation=cv2.INTER_AREA)
    im = cv2.cvtColor(im, cv2.COLOR_BGR2RGB).astype(np.float32) / 255.0
    im = (im - im.mean()) / (im.std() + 1e-6)
    return torch.tensor(im.transpose(2, 0, 1), dtype=torch.float32), w, h

def build(split):
    src = fov_tr if split == "train" else fov_te
    dir_map = {f[0]: (f[1], f[2]) for f in src}
    ids = [f[0] for f in src]
    xs, ys, ims = [], [], []
    for i in ids:
        x, y = dir_map[i]
        im, w, h = load_image(i, split)
        xs.append(x / w); ys.append(y / h)
        ims.append(im)
    return ims, torch.tensor(xs), torch.tensor(ys), ids

Xtr, yxtr, yytr, idtr = build("train")
Xte, yxte, yyte, idte = build("test")

class FoveaNet(nn.Module):
    def __init__(self):
        super().__init__()
        self.conv = nn.Sequential(
            nn.Conv2d(3, 32, 5, stride=2, padding=2), nn.BatchNorm2d(32), nn.ReLU(),
            nn.Conv2d(32, 64, 3, stride=2, padding=1), nn.BatchNorm2d(64), nn.ReLU(),
            nn.Conv2d(64, 128, 3, stride=2, padding=1), nn.BatchNorm2d(128), nn.ReLU(),
            nn.Conv2d(128, 128, 3, stride=2, padding=1), nn.BatchNorm2d(128), nn.ReLU(),
            nn.Conv2d(128, 256, 3, stride=2, padding=1), nn.BatchNorm2d(256), nn.ReLU(),
        )
        self.head = nn.Sequential(nn.Linear(17920, 128), nn.ReLU(), nn.Linear(128, 2))

    def forward(self, x):
        f = self.conv(x)          # (B,256,7,10)
        f = f.flatten(1)
        return self.head(f)

model = FoveaNet().cuda()
opt = torch.optim.Adam(model.parameters(), lr=1e-3)
sched = torch.optim.lr_scheduler.CosineAnnealingLR(opt, T_max=30)

import torch.utils.data as D
B = 16
tr_im = torch.stack([im.cuda() for im in Xtr])
ytr = torch.stack([yxtr, yytr], dim=1).cuda()
n = len(tr_im)

torch.manual_seed(7)
start = time.time()
EPOCHS = 30
hist = []
for ep in range(1, EPOCHS + 1):
    model.train()
    perm = torch.randperm(n).cuda()
    loss_sum, nb = 0.0, 0
    for i in range(0, n, B):
        idx = perm[i:i + B]
        out = model(tr_im[idx])
        loss = F.mse_loss(out, ytr[idx])
        opt.zero_grad(); loss.backward(); opt.step()
        loss_sum += loss.item(); nb += 1
    sched.step()
    hist.append(round(loss_sum / nb, 5))
    if ep % 5 == 0 or ep == EPOCHS:
        print(f"epoch {ep:2d} loss {loss_sum/nb:.5f} elapsed {time.time()-start:.0f}s")

model.eval()
native = {"w": 4288, "h": 2848}
with torch.no_grad():
    te_im = torch.stack([im.cuda() for im in Xte])
    out = model(te_im).cpu().numpy()

errs = []
for k in range(len(idte)):
    px = out[k][0] * native["w"]
    py = out[k][1] * native["h"]
    gx = yxte[k].item() * native["w"]
    gy = yyte[k].item() * native["h"]
    errs.append(math.hypot(px - gx, py - gy))

errs = np.array(errs)
within = {str(t): float((errs <= t).mean()) for t in (50, 100, 200)}
res = {
    "phase": "x3_step5_idrid_c_fovea_prototype",
    "version": "v9_0",
    "execution_status": "EXECUTED_PROTOTYPE_EXPERIMENTAL",
    "trained_on": "IDRiD C training set n=413 (official fovea centers)",
    "evaluated_on": "IDRiD C test set n=103 single-shot (no tuning)",
    "labels": "official IDRiD fovea center coordinates",
    "method": "random-init small CNN 5-conv regressor at 320x213; no pretrained weights; isolated prototype",
    "model": os.path.join(OUT_D, "fovea_prototype_v9_0.pt"),
    "native_pixels": native,
    "results_native_px": {
        "n": int(len(errs)),
        "mean": float(errs.mean()), "sd": float(errs.std()),
        "median": float(np.median(errs)),
        "q25": float(np.percentile(errs, 25)), "q75": float(np.percentile(errs, 75)),
        "min": float(errs.min()), "max": float(errs.max()),
        "ci95": [float(np.percentile(errs, 2.5)), float(np.percentile(errs, 97.5))],
    },
    "frac_within_px": within,
    "training_loss_hist": hist,
    "scope": "PROTOTYPE; experimental localizer, NOT a clinical claim; does not update DR grading evidence",
    "executed_at": time.strftime("%d-%b-%Y %H:%M:%S"),
}
torch.save({"model": model.state_dict(), "config": "FoveaNet320x213"}, res["model"])
json.dump(res, open(os.path.join(OUT_D, "x3_fovea_prototype_results.json"), "w"), indent=1)

# overlay 4 test images (2 best / 2 typical) with GT (green) + pred (red)
import random
random.seed(3)
idx = sorted(range(len(idte)), key=lambda k: errs[k])
plot_ids = [idx[0], idx[1], idx[len(idx)//2], idx[-1]]
os.makedirs(os.path.join(OUT_D, "overlays"), exist_ok=True)
for k in plot_ids:
    im = cv2.imread(os.path.join(DATA, "1. Original Images", "b. Testing Set", idte[k] + ".jpg"))
    im = cv2.resize(im, (1024, int(1024 * 2848 / 4288)))
    sx, sy = 1024 / 4288, (1024 * 2848 / 4288) / 2848
    gx, gy = yxte[k].item() * 4288 * sx, yyte[k].item() * 2848 * sy
    px, py = out[k][0] * 4288 * sx, out[k][1] * 2848 * sy
    cv2.circle(im, (int(gx), int(gy)), 14, (0, 255, 0), 3)
    cv2.circle(im, (int(px), int(py)), 10, (0, 0, 255), 3)
    cv2.putText(im, "GT green / pred red  err=%.0f px" % errs[k], (10, 40),
                cv2.FONT_HERSHEY_SIMPLEX, 0.9, (255, 255, 255), 2)
    cv2.imwrite(os.path.join(OUT_D, "overlays", f"fovea_test_{idte[k]}.png"), im)

print("\nresults (native px): median %.1f  mean %.1f  within200 %.3f  min %.1f max %.1f"
      % (res["results_native_px"]["median"], res["results_native_px"]["mean"],
         res["frac_within_px"]["200"], res["results_native_px"]["min"], res["results_native_px"]["max"]))
print("wrote", os.path.join(OUT_D, "x3_fovea_prototype_results.json"))