# -*- coding: utf-8 -*-
# X1 Step 2 — Train candidate X1C2 (DROrdinalRefNet with severity-emphasis CE +
# ordinal BCE + auxiliary referable BCE head). Same data contract and locked
# split as v8.12. checkpoint by validation QWK, patience early stop.
import json, time, sys
from pathlib import Path
import numpy as np
import torch
import torch.nn.functional as F
from torch.utils.data import DataLoader
import pandas as pd
from tqdm import tqdm
from x1_common import (
    ROOT, X1_CKPT_DIR, X1_METRICS, CANDIDATE, BACKBONE_NAME, IMG_SIZE, BATCH,
    NUM_WORKERS, EPOCHS, LR, WEIGHT_DECAY, ORDINAL_WEIGHT, REF_WEIGHT, PATIENCE,
    DEVICE, AMP, AMP_DEVICE, load_locked_data, fingerprint, DROrdinalRefNet,
    make_losses, ordinal_target, referable_target, evaluate, set_seed, sha256_file,
    DRDataset,
)

def main():
    t0 = time.time()
    train_df, val_df, test_df = load_locked_data()
    fp = fingerprint([train_df, val_df, test_df])
    print("Split fingerprint:", fp)

    set_seed(42)
    model = DROrdinalRefNet(pretrained=True).to(DEVICE)
    ce, bce, ref_bce, loss_cfg = make_losses(train_df)
    config = {
        "candidate": CANDIDATE,
        "backbone": BACKBONE_NAME,
        "img_size": IMG_SIZE,
        "batch": BATCH,
        "epochs": EPOCHS,
        "lr": LR, "weight_decay": WEIGHT_DECAY,
        "ordinal_weight": ORDINAL_WEIGHT, "ref_weight": REF_WEIGHT,
        "patience": PATIENCE, "seed": 42,
        "loss": loss_cfg,
        "augmentation": "HFlip0.5 + Rot10 + ColorJitter(0.08,0.08,0.05) [v8.12 contract]",
        "split_fingerprint": fp,
        "parameter_count": int(sum(p.numel() for p in model.parameters())),
    }
    opt = torch.optim.AdamW(model.parameters(), lr=LR, weight_decay=WEIGHT_DECAY)
    sched = torch.optim.lr_scheduler.CosineAnnealingLR(opt, T_max=EPOCHS)
    scaler = torch.amp.GradScaler("cuda", enabled=AMP) if AMP else None

    loader = None  # real loader built below via DRDataset
    best = -np.inf; bad = 0; history = []
    best_ckpath = X1_CKPT_DIR / f"dr_x1c2_best_{CANDIDATE}.pt"

    for ep in range(EPOCHS):
        model.train(); losses = []
        dl = DataLoader(DRDataset(train_df, train=True), batch_size=BATCH,
                        shuffle=True, num_workers=NUM_WORKERS, pin_memory=AMP)
        for x, y in tqdm(dl, desc=f"Epoch {ep+1}/{EPOCHS}"):
            x = x.to(DEVICE, non_blocking=True); y = y.to(DEVICE)
            opt.zero_grad(set_to_none=True)
            if AMP:
                with torch.autocast(device_type=AMP_DEVICE, dtype=torch.float16, enabled=True):
                    c, o, r = model(x)
                    loss = (ce(c, y) + ORDINAL_WEIGHT * bce(o, ordinal_target(y))
                            + REF_WEIGHT * ref_bce(r, referable_target(y)))
                scaler.scale(loss).backward(); scaler.step(opt); scaler.update()
            else:
                c, o, r = model(x)
                loss = (ce(c, y) + ORDINAL_WEIGHT * bce(o, ordinal_target(y))
                        + REF_WEIGHT * ref_bce(r, referable_target(y)))
                loss.backward(); opt.step()
            losses.append(float(loss.detach().cpu()))
        sched.step()

        ev = evaluate(model, val_df)
        row = {"epoch": ep + 1, "loss": float(np.mean(losses)),
               "qwk": ev["qwk"], "macro_f1": ev["macro_f1"],
               "balanced_accuracy": ev["balanced_accuracy"],
               "relu_ref_sens": ev["referable_sensitivity"],
               "relu_ref_spec": ev["referable_specificity"],
               "ref_auc": ev["referable_auc"]}
        history.append(row); print(row)

        if ev["qwk"] > best:
            best = ev["qwk"]; bad = 0
            torch.save({"model": model.state_dict(), "optimizer": opt.state_dict(),
                        "scheduler": sched.state_dict(),
                        "scaler": scaler.state_dict() if scaler is not None else None,
                        "seed": 42, "config": config, "best_qwk": float(best),
                        "epoch": ep + 1}, best_ckpath)
        else:
            bad += 1
            if bad >= PATIENCE:
                print("Early stopping."); break

    ckpath = best_ckpath
    sha = sha256_file(ckpath)
    fp_note = fingerprint([train_df, val_df, test_df])
    history_df = pd.DataFrame(history)
    history_df.to_csv(X1_METRICS / "x1_training_history.csv", index=False)
    json.dump(config | {"best_qwk": float(best), "ckpt": str(ckpath),
                        "ckpt_sha256": sha, "elapsed_s": round(time.time() - t0, 1)},
              open(X1_METRICS / "x1_model_config.json", "w"), indent=2)
    print("Best val QWK:", best)
    print("CKPT:", ckpath)
    print("SHA256:", sha)
    print("Elapsed:", round(time.time() - t0, 1), "s")

if __name__ == "__main__":
    main()