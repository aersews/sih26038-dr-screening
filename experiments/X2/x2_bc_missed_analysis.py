# -*- coding: utf-8 -*-
import json
from x2_common import X2_METRICS, load_locked_data, load_x1c2, evaluate, make_decision_features, DR_CLASSES

train_df, val_df, test_df = load_locked_data()
model = load_x1c2()
ev_val = evaluate(model, val_df, temperature=1.25)
feat = make_decision_features(val_df, ev_val)

ref = feat.true_ref.to_numpy().astype(bool)
q = feat.quality.to_numpy()
conf = feat.confidence.to_numpy()
pred = feat.pred.to_numpy()

screen = (~feat.pred_ref.to_numpy().astype(bool)) & (q >= 0.60)
miss = ref & screen
print("referable auto-screened (any confidence, good quality):", int(miss.sum()))
pred_bins = {}
for p in range(5):
    pred_bins[DR_CLASSES[p]] = int((miss & (pred == p)).sum())
print("predicted-class breakdown of missed referable:", pred_bins)

m = feat[miss]
cols = ["id_code", "label", "pred", "quality", "ref_prob", "confidence", "uncertainty"]
print(m[cols].to_string(index=False))
json.dump({"n_missed": int(miss.sum()), "by_predicted_class": pred_bins,
           "rows": m[cols].to_dict("records")},
           open(X2_METRICS / "x2_bc_missed_referable.json", "w"), indent=2)