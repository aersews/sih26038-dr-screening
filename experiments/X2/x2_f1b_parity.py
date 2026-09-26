# -*- coding: utf-8 -*-
# X2-F1b — Python torch -> onnxruntime parity on validation images (CPU onnxruntime).
import json, sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "X1"))
import torch, numpy as np
from x1_common import preprocess_fundus, MEAN, STD
from torchvision import transforms
import onnxruntime as ort
import importlib.util
spec = importlib.util.spec_from_file_location("x2_common", Path(__file__).resolve().parent / "x2_common.py")
x2c = importlib.util.module_from_spec(spec); spec.loader.exec_module(x2c)

model = x2c.load_x1c2().cpu(); model.eval()
class ClsRefWrapper(torch.nn.Module):
    def __init__(self, m):
        super().__init__(); self.backbone=m.backbone; self.drop=m.drop; self.cls=m.cls; self.ref=m.ref
    def forward(self, x):
        z=self.drop(self.backbone(x)); return self.cls(z), self.ref(z).squeeze(-1)
wrapper = ClsRefWrapper(model).eval()

tf = transforms.Compose([transforms.ToTensor(), transforms.Normalize(MEAN, STD)])
train_df, val_df, test_df = x2c.load_locked_data()
ref_ids = ["0083ee8054ee", "0304bedad8fe", "9b4fc15df3c8", "054b1b305160"]
onnx_path = x2c.X2_MATLAB / "dr_x1c2.onnx"
sess = ort.InferenceSession(str(onnx_path), providers=["CPUExecutionProvider"])

rows = []
for imid in ref_ids:
    row = val_df[val_df.id_code == imid].iloc[0]
    x = tf(preprocess_fundus(row.image_path)).unsqueeze(0)
    with torch.no_grad():
        cls_logits, ref_logit = wrapper(x)
    cls_logits = cls_logits.float().cpu().numpy(); ref_logit = ref_logit.float().cpu().numpy()
    onnx_out = sess.run(None, {"fundus_image": x.numpy()})
    o_cls = np.asarray(onnx_out[0]); o_ref = np.asarray(onnx_out[1])
    torch_pred = int(cls_logits.argmax(1)[0]); onnx_pred = int(o_cls.argmax(1)[0])
    rows.append({
        "id_code": imid, "true_label": int(row.diagnosis),
        "torch_cls_logits": [round(float(v), 6) for v in cls_logits.ravel()],
        "onnx_cls_logits": [round(float(v), 6) for v in o_cls.ravel()],
        "torch_ref_logit": round(float(ref_logit.ravel()[0]), 6),
        "onnx_ref_logit": round(float(o_ref.ravel()[0]), 6),
        "max_abs_diff_cls": float(np.abs(o_cls - cls_logits).max()),
        "max_abs_diff_ref": float(np.abs(o_ref - ref_logit).max()),
        "torch_pred_severity": torch_pred, "onnx_pred_severity": onnx_pred,
        "semantic_agreement": torch_pred == onnx_pred,
    })

parity_py = {
    "scope": "X1C2 torch(python,float32) vs onnxruntime(CPU), 4 validation images, opset 17",
    "onnx_path": str(onnx_path),
    "cases": rows,
    "max_abs_diff_cls_overall": max(r["max_abs_diff_cls"] for r in rows),
    "max_abs_diff_ref_overall": max(r["max_abs_diff_ref"] for r in rows),
    "all_semantic_agreement": all(r["semantic_agreement"] for r in rows),
}
json.dump(parity_py, open(x2c.X2_METRICS / "x2_f1_python_onnx_parity.json", "w"), indent=2)
print(json.dumps(parity_py, indent=2))