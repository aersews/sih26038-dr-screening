# -*- coding: utf-8 -*-
# X2-D — EXPLAINABILITY for X1C2 (Grad-CAM on referable head).
# Representative cases drawn from VALIDATION (test untouched).
# Cases: 1 non-referable/good quality | 2 referable/good quality
#        3 low-quality -> recapture/review | 4 uncertain -> human review
import json
import numpy as np
import pandas as pd
import torch
import torch.nn.functional as F
import cv2
from pathlib import Path
from PIL import Image
from x2_common import (
    X2_EXPLAIN, X2_METRICS, load_locked_data, load_x1c2, evaluate, make_decision_features,
    engineering_quality_index, quality_gate_pass, normalized_entropy,
)
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from x1_common import preprocess_fundus, MEAN, STD, DR_CLASSES
from torchvision import transforms

train_df, val_df, test_df = load_locked_data()
model = load_x1c2()
ev_val = evaluate(model, val_df, temperature=1.25)
feat = make_decision_features(val_df, ev_val)

# === Grad-CAM: hook the last conv feature map before global pooling ===
device = next(model.parameters()).device
target_layer = None
bb = model.backbone
# efficientnet_b3: conv_head is the last conv layer; features = conv_head(blocks output)
if hasattr(bb, "conv_head"):
    target_layer = bb.conv_head
    target_name = "backbone.conv_head"
else:
    for n, m in model.named_modules():
        if isinstance(m, torch.nn.Conv2d):
            target_layer = m
            target_name = n
print("Grad-CAM target:", target_name)

activations = {}
gradients = {}

def fwd_hook(module, inp, out):
    activations["a"] = out.detach()

def bwd_hook(module, ginp, gout):
    gradients["g"] = gout[0].detach()

h1 = target_layer.register_forward_hook(fwd_hook)
h2 = target_layer.register_full_backward_hook(bwd_hook)

tf = transforms.Compose([transforms.ToTensor(), transforms.Normalize(MEAN, STD)])


def gradcam(image_path):
    raw = np.asarray(Image.open(image_path).convert("RGB"))
    pp = preprocess_fundus(raw)
    x = tf(pp).unsqueeze(0).to(device)
    x.requires_grad_(True)
    model.zero_grad()
    cls_logits, ord_logits, ref_logit = model(x)
    # gradient of referable logit
    ref_logit.backward(gradient=torch.ones_like(ref_logit))
    a = activations["a"]
    g = gradients["g"]
    w = g.mean(dim=(2, 3), keepdim=True)          # GAP of gradients
    cam = F.relu((w * a).sum(dim=1, keepdim=True))[0, 0].detach().cpu().numpy()
    cam = cv2.resize(cam, (pp.shape[1], pp.shape[0]), interpolation=cv2.INTER_LINEAR)
    cam = (cam - cam.min()) / (cam.max() - cam.min() + 1e-8)
    cam_rgb = cv2.applyColorMap((cam * 255).astype(np.uint8), cv2.COLORMAP_JET)
    cam_rgb = cv2.cvtColor(cam_rgb, cv2.COLOR_BGR2RGB)
    overlay = (0.55 * pp + 0.45 * cam_rgb).astype(np.uint8)
    return raw, pp, cam, cam_rgb, overlay, float(F.softmax(cls_logits, 1).max().item())


def select_case(df, fe, mask, label):
    m = df[mask]
    if len(m) == 0:
        return None
    return m.iloc[0], fe[mask].iloc[0]


cases = []
# 1. non-referable / good quality / high confidence -> SCREENING_OUTPUT
sel1 = select_case(val_df, feat, (feat.true_ref == 0) & (feat.route == "SCREENING_OUTPUT"), "non-ref good")
# 2. referable / good quality -> REFER
sel2 = select_case(val_df, feat, (feat.true_ref == 1) & (feat.route == "REFER"), "referable good")
# 3. low-quality -> HUMAN_REVIEW (quality 0.35-0.60) — use min quality
qmin_idx = int(np.argmin(val_df.quality.to_numpy()))
sel3 = (val_df.iloc[qmin_idx], feat.iloc[qmin_idx])
# 4. uncertain -> HUMAN_REVIEW (high entropy non-ref)
sel4 = select_case(val_df, feat, (feat.route == "HUMAN_REVIEW") & (feat.true_ref == 0) & (feat.uncertainty > 0.55), "uncertain review")

records = []
for k, (case, name) in enumerate(
        [(sel1, "non_referable_good_quality"), (sel2, "referable_good_quality"),
         (sel3, "low_quality_review"), (sel4, "uncertain_review")], start=1):
    if case is None:
        print("MISSING case", name); continue
    row, fr = case
    raw, pp, cam, cam_rgb, overlay, conf = gradcam(row.image_path)
    qscore, parts = engineering_quality_index(raw)
    gate = quality_gate_pass(raw, components=True)
    probs = ev_val["probs"][fr.name]
    pdisp = probs / probs.sum()

    fig, axes = plt.subplots(1, 4, figsize=(24, 6.5))
    axes[0].imshow(raw); axes[0].set_title(f"Original\nid {row.id_code}\nquality {qscore:.3f}"); axes[0].axis("off")
    axes[1].imshow(pp); axes[1].set_title("Preprocessed (crop+CLAHE+300)"); axes[1].axis("off")
    axes[2].imshow(overlay); axes[2].set_title("Grad-CAM referable evidence"); axes[2].axis("off")
    axes[3].barh(DR_CLASSES, pdisp[::-1]); axes[3].set_title(f"Class probs (T=1.25)\nroute: {fr.route}"); axes[3].set_xlim(0, 1)
    fig.suptitle(f"Case {k}: {name} | true {DR_CLASSES[row.diagnosis]} | route {fr.route}")
    fig.tight_layout()
    fig.savefig(X2_EXPLAIN / f"case{k}_{name}.png", dpi=130)
    plt.close(fig)

    records.append({
        "case": k, "name": name, "id_code": row.id_code,
        "true_grade": int(row.diagnosis), "true_grade_name": DR_CLASSES[row.diagnosis],
        "predicted_grade": int(fr.pred), "predicted_grade_name": DR_CLASSES[int(fr.pred)],
        "route": fr.route, "route_reason": fr.route_reason,
        "quality_score": round(qscore, 4),
        "quality_components": {kk: round(vv, 4) for kk, vv in parts.items()},
        "gate_decision": gate["gate_decision"],
        "class_probs": {DR_CLASSES[i]: round(float(probs[i]), 4) for i in range(5)},
        "referable_probability": round(float(fr.ref_prob), 4),
        "confidence": round(float(fr.confidence), 4),
        "normalized_uncertainty": round(float(fr.uncertainty), 4),
        "gradcam_method": "Grad-CAM on referable logit (backbone.conv_head), relu-weighted GAP",
        "gradcam_target_layer": target_name,
        "image": str(X2_EXPLAIN / f"case{k}_{name}.png"),
        "lesion_overlay": "NOT available: APTOS has no lesion masks; Grad-CAM shows classifier attention only (not lesion annotation). No fabricated lesion overlays.",
    })

h1.remove(); h2.remove()
json.dump(records, open(X2_EXPLAIN / "X2_EXPLAINABILITY_CASES.json", "w"), indent=2)
print(json.dumps(records, indent=2))