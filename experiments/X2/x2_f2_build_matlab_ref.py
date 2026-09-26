# -*- coding: utf-8 -*-
# X2-F2 — build MATLAB parity reference: python-preprocessed tensors + python logits.
import json, sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "X1"))
import torch, numpy as np, scipy.io
from x1_common import preprocess_fundus, MEAN, STD
from torchvision import transforms
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

inputs = []
for imid in ref_ids:
    row = val_df[val_df.id_code == imid].iloc[0]
    x = tf(preprocess_fundus(row.image_path)).unsqueeze(0)
    with torch.no_grad():
        cls_logits, ref_logit = wrapper(x)
    inputs.append({
        "id": imid, "true_label": int(row.diagnosis),
        "tensor_nchw_float32": x.float().numpy(), "cls_logits": cls_logits.float().numpy(),
        "ref_logit": ref_logit.float().numpy().reshape(1),
    })

ref_dir = x2c.X2_MATLAB / "data" / "ref"
ref_dir.mkdir(parents=True, exist_ok=True)

# multiple reference entries: matlab_names -> var names
for i, inp in enumerate(inputs):
    name = f"python_input_{i}"          # 1x3x300x300 NCHW float32
    cls = f"python_cls_logits_{i}"      # 1x5
    ref = f"python_ref_logit_{i}"       # 1x1
    out_mat = ref_dir / f"parity_reference_case{i}.mat"
    scipy.io.savemat(str(out_mat), {name: inp["tensor_nchw_float32"], cls: inp["cls_logits"], ref: inp["ref_logit"]})
    print("Wrote", out_mat)

meta = {
    "ref": [
        {"mat": f"parity_reference_case{i}.mat",
         "input_var": f"python_input_{i}", "cls_var": f"python_cls_logits_{i}",
         "ref_var": f"python_ref_logit_{i}", "id": inp["id"],
         "true_label": inp["true_label"]}
        for i, inp in enumerate(inputs)
    ],
    "preprocessing": {"foreground_threshold": 7, "clahe_clip_limit": 2.0, "clahe_tile_grid": [8, 8],
                      "resize": [300, 300], "mean": [0.485, 0.456, 0.406], "std": [0.229, 0.224, 0.225]},
    "model": "dr_x1c2.onnx (opset 17, outputs cls_logits[5], ref_logit[1])",
    "training_claim": "PyTorch-trained X1C2 integrated into MATLAB via ONNX; NOT MATLAB-trained.",
}
json.dump(meta, open(ref_dir / "matlab_parity_reference_v9_x2.json", "w"), indent=2)
print(json.dumps(meta, indent=2))