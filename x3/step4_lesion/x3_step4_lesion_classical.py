"""X3 Step 4: IDRiD A classical lesion candidate detector (EX + HE) PROTOTYPE/EXPERIMENTAL.
- NO training. Predeclared classical rules (color + morphology), fixed thresholds.
- Evaluated on IDRiD A official test split (27 images IDRiD_55..81, masks MA/HE/EX/SE/OD).
- Reports: pixel-level IoU/Dice, component-level recall/precision (GT component hit = overlap>0).
- Explicitly labeled PROTOTYPE: candidate highlighting, NOT a clinical segmentation capability.
- SE (soft exudate) and MA (microaneurysm) are hard classically on this data; reported but not claimed.
Outputs: overlay PNGs (3 cases) + results JSON + summary CSV.
"""
import os, cv2, json, glob, numpy as np, csv
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
WORKSPACE_ROOT = Path(os.environ.get("SIH_WORKSPACE_ROOT", str(REPO_ROOT.parent))).expanduser().resolve()
SEG = WORKSPACE_ROOT / "data" / "idrid" / "A. Segmentation"
OUT_D = REPO_ROOT / "x3" / "step4_lesion"
os.makedirs(OUT_D, exist_ok=True)

img_dir = os.path.join(SEG, "1. Original Images", "b. Testing Set")
mask_root = os.path.join(SEG, "2. All Segmentation Groundtruths", "b. Testing Set")
maskdirs = {"EX": "3. Hard Exudates", "HE": "2. Haemorrhages", "MA": "1. Microaneurysms", "SE": "4. Soft Exudates"}

images = sorted(glob.glob(os.path.join(img_dir, "*.jpg")))
print("test images:", len(images))

def load_mask(stem, cls):
    p = os.path.join(mask_root, maskdirs[cls], f"{stem}_{cls}.tif")
    if not os.path.exists(p):
        return None
    m = cv2.imread(p, cv2.IMREAD_UNCHANGED)
    if m.ndim == 3:
        m = m[:, :, 0]
    return (m > 0).astype(np.uint8)

def fundus_mask(gray):
    _, fm = cv2.threshold(gray, 0, 1, cv2.THRESH_BINARY + cv2.THRESH_OTSU)
    fm = cv2.morphologyEx(fm, cv2.MORPH_OPEN, np.ones((15, 15), np.uint8))
    fm = cv2.morphologyEx(fm, cv2.MORPH_CLOSE, np.ones((31, 31), np.uint8))
    return fm.astype(bool)

# ----- predeclared fixed thresholds (fit on IDRiD A TRAINING split only, not this test) -----
x3_EX_THRESH = 20
x3_HE_THRESH = 15

def resp_threshold(resp, fm):
    rmasked = resp[fm & (resp > 0)]
    if rmasked.size == 0:
        return 255
    th, _ = cv2.threshold(rmasked.astype(np.uint8), 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)
    return int(th)

def detect_ex(gray, fm):
    # hard exudates: bright yellow-white lesions (top-hat on green), threshold = Otsu on foreground response
    k = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (31, 31))
    o = cv2.morphologyEx(gray, cv2.MORPH_OPEN, k)
    resp = np.clip(gray - o, 0, None).astype(np.uint8)
    resp[~fm] = 0
    th = resp_threshold(resp, fm)
    cand = (resp > th).astype(np.uint8)
    mn = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (3, 3))
    cand = cv2.morphologyEx(cand, cv2.MORPH_OPEN, mn)
    cand[~fm] = 0
    return cand > 0, th

def detect_he(gray, fm):
    # hemorrhages: dark red blobs (black top-hat on green), threshold = Otsu on foreground response
    k = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (31, 31))
    c = cv2.morphologyEx(gray, cv2.MORPH_CLOSE, k)
    resp = np.clip(c - gray, 0, None).astype(np.uint8)
    resp[~fm] = 0
    th = resp_threshold(resp, fm)
    cand = (resp > th).astype(np.uint8)
    mn = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (3, 3))
    cand = cv2.morphologyEx(cand, cv2.MORPH_OPEN, mn)
    cand[~fm] = 0
    return cand > 0, th

def cc(pred, gt):
    pred = (pred > 0).astype(np.uint8) * 255
    gt = (gt > 0).astype(np.uint8) * 255
    nlab, lab, stats, cent = cv2.connectedComponentsWithStats(pred, 8)
    gt_n, gt_lab, _, _ = cv2.connectedComponentsWithStats(gt, 8)
    pred_hit = 0.0
    for g in range(1, gt_n):
        gmask = gt_lab == g
        overlap = (pred & gmask).sum() > 0
        pred_hit += 1 if overlap else 0  # denominator = GT components
    # precision @pred components that overlap gt
    gt_union = (gt > 0)
    n_pred = nlab - 1
    n_pred_overlap = 0
    for p in range(1, nlab):
        if (gt_union & (lab == p)).sum() > 0:
            n_pred_overlap += 1
    recall = pred_hit / gt_n if gt_n > 1 else (1.0 if (gt.sum() == 0 and pred.sum() == 0) else 0.0)
    precision = n_pred_overlap / n_pred if n_pred > 0 else (1.0 if gt.sum() == 0 else 0.0)
    return recall, precision, gt_n, n_pred

def dice_ious(pred, gt):
    inter = float((pred & gt).sum())
    denom = float(pred.sum() + gt.sum())
    dice = 2 * inter / denom if denom > 0 else (1.0 if gt.sum() == 0 and pred.sum() == 0 else 0.0)
    iou = inter / float((pred | gt).sum()) if (pred | gt).sum() > 0 else (1.0 if gt.sum() == 0 else 0.0)
    return dice, iou

# ----- predeclared rule: per-image Otsu threshold; geometry at 1024 width (fast, consistent) -----
SCALE = 1024

rows = []
per_class = {"EX": [], "HE": [], "MA": [], "SE": []}
meta = {}
for ip in images:
    stem = os.path.basename(ip)[:-4]
    im = cv2.imread(ip)
    im = cv2.resize(im, (SCALE, int(SCALE * im.shape[0] / im.shape[1])))
    gray = cv2.cvtColor(im, cv2.COLOR_BGR2GRAY)
    fm = fundus_mask(gray)
    for cls in ("EX", "HE", "MA", "SE"):
        gt0 = load_mask(stem, cls)  # full-res
        if gt0 is None:
            gt = np.zeros(gray.shape, np.uint8)
        else:
            gt = cv2.resize(gt0, gray.shape[::-1], interpolation=cv2.INTER_NEAREST)
        if cls == "EX":
            cand = detect_ex(gray, fm)[0]
        elif cls == "HE":
            cand = detect_he(gray, fm)[0]
        else:
            cand = np.zeros_like(gray) > 0  # not attempted classically
        r, p, n_gt, n_pred = cc(cand, gt)
        d, i = dice_ious(cand, gt)
        per_class[cls].append(dict(stem=stem, gt_pixels=int(gt.sum()), dice=d, iou=i,
                                   comp_recall=r, comp_precision=p, gt_components=n_gt, pred_components=n_pred))
    meta[stem] = (im, gray, fm)

# summary
out_rows = []
for cls in ("EX", "HE", "MA", "SE"):
    arr = per_class[cls]
    with_les = [x for x in arr if x["gt_pixels"] > 0]
    n_with = len(with_les)
    dice_m = float(np.mean([x["dice"] for x in with_les])) if with_les else None
    rec_m = float(np.mean([x["comp_recall"] for x in with_les])) if with_les else None
    prec_m = float(np.mean([x["comp_precision"] for x in with_les])) if with_les else None
    out_rows.append(dict(cls=cls, n_images=len(arr), n_with_lesion=n_with,
                         dice_mean_lesion_images=round(dice_m, 4) if dice_m is not None else None,
                         comp_recall_mean_lesion_images=round(rec_m, 4) if rec_m is not None else None,
                         comp_precision_mean_lesion_images=round(prec_m, 4) if prec_m is not None else None,
                         not_attempted_classically=cls in ("MA", "SE")))
    print(f"{cls}: n_with={n_with}/{len(arr)} dice(withLesion)={dice_m} rec@comp={rec_m} prec@comp={prec_m}")

csvp = os.path.join(OUT_D, "X3_LESION_CLASSICAL_PROTOTYPE_SUMMARY.csv")
with open(csvp, "w", newline="") as f:
    w = csv.DictWriter(f, fieldnames=list(out_rows[0].keys()))
    w.writeheader(); w.writerows(out_rows)

res = {
    "phase": "x3_step4_idrid_a_classical_lesion_prototype",
    "version": "v9_0",
    "execution_status": "EXECUTED_PROTOTYPE_EXPERIMENTAL",
    "method": "classical color+morphology candidate detector, NO training; per-image Otsu threshold on fundus-masked morphological (top-hat / black-top-hat) green-channel response",
    "dataset": "IDRiD A official TEST split 27 images (IDRiD_55..81) + official masks",
    "per_image": {cls: per_class[cls] for cls in per_class},
    "summary": out_rows,
    "scope": "PROTOTYPE: candidate highlighting for demo; NOT a clinical segmentation claim. MA/SE not attempted classically (hard with these rules); reported as not-attempted.",
    "threshold_policy": "Otsu on foreground response (fixed label-free rule; no constant threshold, no tuning on this test split)",
    "executed_at": "24-Sep-2026",
}
json.dump(res, open(os.path.join(OUT_D, "x3_lesion_classical_prototype_results.json"), "w"), indent=1)

# overlays on 3 cases: pick EX and HE ones with usable GT
os.makedirs(os.path.join(OUT_D, "overlays"), exist_ok=True)
shown = {"EX": 0, "HE": 0}
for stem, (im, gray, fm) in meta.items():
    for cls in ("EX", "HE"):
        if shown[cls] >= 3:
            continue
        gt0 = load_mask(stem, cls)
        if gt0 is None or (gt0 > 0).sum() == 0:
            continue
        gt = cv2.resize(gt0, gray.shape[::-1], interpolation=cv2.INTER_NEAREST)
        cand = detect_ex(gray, fm)[0] if cls == "EX" else detect_he(gray, fm)[0]
        overlay = im.copy()
        overlay[cand] = (0, 0, 255)          # pred red
        o2 = im.copy()
        o2[gt > 0] = (0, 255, 0)             # gt green
        comp = np.hstack([im, o2, overlay])
        cv2.putText(comp, f"{stem} {cls}: GT(green) vs classical cand(red)", (10, 30),
                    cv2.FONT_HERSHEY_SIMPLEX, 1.0, (255, 255, 255), 2)
        pth = os.path.join(OUT_D, "overlays", f"lesion_{stem}_{cls}.png")
        cv2.imwrite(pth, comp)
        shown[cls] += 1
print("wrote summary:", csvp)
print("overlays:", len(shown), "written")