# -*- coding: utf-8 -*-
# X2-F1 — Export X1C2 to ONNX + Python-side torch<->onnxruntime parity on validation images.
import json
import numpy as np
import torch
import sys
from pathlib import Path
from PIL import Image
sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "X1"))
from x1_common import preprocess_fundus, MEAN, STD
from torchvision import transforms
from x2_common import X1C2_CKPT, X2_METRICS, X2_MATLAB, load_locked_data, load_x1c2

try:
    import onnxruntime as ort
    ONNX_RT_OK = True
except Exception as e:
    ONNX_RT_OK = False
    print("onnxruntime not available:", e)

DEVICE = "cuda"
model = load_x1c2()
model.eval()

class ClsRefWrapper(torch.nn.Module):
    """exports cls(5) + ref(1) logits; ord head omitted from deployment graph"""
    def __init__(self, m):
        super().__init__()
        self.backbone = m.backbone
        self.drop = m.drop
        self.cls = m.cls
        self.ref = m.ref

    def forward(self, x):
        z = self.drop(self.backbone(x))
        return self.cls(z), self.ref(z).squeeze(-1)

wrapper = ClsRefWrapper(model)

dummy = torch.randn(1, 3, 300, 300, device=DEVICE)
onnx_path = X2_MATLAB / "dr_x1c2.onnx"
torch.onnx.export(
    wrapper, dummy, str(onnx_path),
    input_names=["fundus_image"], output_names=["cls_logits", "ref_logit"],
    dynamic_axes={"fundus_image": {0: "batch"}, "cls_logits": {0: "batch"}, "ref_logit": {0: "batch"}},
    opset_version=17,
)

# --- semantic parity reference: validation images run through both torch and ONNX ---
train_df, val_df, test_df = load_locked_data()
ref_ids = ["0083ee8054ee", "0304bedad8fe", "9b4fc15df3c8", "054b1b305160"]
tf = transforms.Compose([transforms.ToTensor(), transforms.Normalize(MEAN, STD)])
rows = []
for imid in ref_ids:
    row = val_df[val_df.id_code == imid].iloc[0]
    pp = preprocess_fundus(row.image_path)
    x = tf(pp).unsqueeze(0).to(DEVICE)
    with torch.no_grad():
        cls_logits, ref_logit = wrapper(x)
    cls_logits = cls_logits.float().cpu().numpy()
    ref_logit = ref_logit.float().cpu().numpy()

    if ONNX_RT_OK:
        sess = ort.InferenceSession(str(onnx_path), providers=["CPUExecutionProvider"])
        onnx_out = sess.run(None, {"fundus_image": x.float().cpu().numpy()})
        o_cls = np.asarray(onnx_out[0])
        o_ref = np.asarray(onnx_out[1])
        max_diff_cls = float(np.abs(o_cls - cls_logits).max())
        max_diff_ref = float(np.abs(o_ref - ref_logit).max())
        torch_pred = int(cls_logits.argmax(1)[0])
        onnx_pred = int(o_cls.argmax(1)[0])
        rows.append({
            "id_code": imid, "true_label": int(row.diagnosis),
            "torch_cls": cls_logits.ravel().tolist(), "onnx_cls": o_cls.ravel().tolist(),
            "torch_ref_logit": ref_logit.ravel().tolist(), "onnx_ref_logit": o_ref.ravel().tolist(),
            "max_abs_diff_cls": max_diff_cls, "max_abs_diff_ref": max_diff_ref,
            "torch_pred": torch_pred, "onnx_pred": onnx_pred,
            "semantic_agreement": True if torch_pred == onnx_pred else False,
        })

parity_py = {
    "scope": "X1C2 torch vs onnxruntime (Python), validation images, CPU onnxruntime",
    "models": {"torch": "X1C2 DROrdinalRefNet (best ckpt)", "onnx": str(onnx_path)},
    "opset": 17,
    "onnxruntime_available": ONNX_RT_OK,
    "cases": rows,
    "max_abs_diff_cls_overall": max((r["max_abs_diff_cls"] for r in rows), default=None),
    "max_abs_diff_ref_overall": max((r["max_abs_diff_ref"] for r in rows), default=None),
    "all_semantic_agreement": all(r["semantic_agreement"] for r in rows) if rows else None,
}
json.dump(parity_py, open(X2_METRICS / "x2_f1_python_onnx_parity.json", "w"), indent=2)
print(json.dumps(parity_py, indent=2))