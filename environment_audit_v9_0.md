# Environment Audit — v9.0

Audit date: 24 Sep 2026. Baseline v8.12 frozen — environment only inspected, no changes made.

## Compute / GPU
| Item | Value | Status |
|---|---|---|
| GPU | NVIDIA RTX A2000 12 GB (12282 MiB) | AVAILABLE |
| Driver | 573.53 | AVAILABLE |
| PyTorch CUDA | torch 2.11.0+cu128, `torch.cuda.is_available()` = True | AVAILABLE |

## Python
| Package | Version |
|---|---|
| Python | 3.13.5 |
| torch | 2.11.0+cu128 |
| torchvision | 0.26.0 |
| timm | 1.0.29 |
| segmentation-models-pytorch | 0.5.0 |
| scikit-learn | 1.9.0 |
| pandas | 3.0.5 |
| numpy | 2.5.3 |
| opencv-python | 5.0.0.93 |
| onnx | 1.22.0 |
| onnxruntime | 1.30.0 |
| gradio / gradio_client | 6.28.0 / 2.7.1 |
| ImageHash | 4.3.2 |
| pytorch_grad_cam | OK (import verified) |
| jupyter / ipython | 9.17.1 ipython, jupyter_client 8.10.0 |

## MATLAB / Simulink
| Item | Value | Status |
|---|---|---|
| MATLAB | R2026a Update 5 (26.1.0.3346908) at `C:\Program Files\MATLAB\R2026a` | AVAILABLE |
| Deep Learning Toolbox | 26.1 | AVAILABLE |
| Image Processing Toolbox | 26.1 | AVAILABLE |
| Simulink | 26.1 | AVAILABLE |
| Computer Vision Toolbox | — | MISSING |
| Medical Imaging Toolbox | — | MISSING |
| Statistics and Machine Learning Toolbox | — | MISSING |
| SimEvents | — | MISSING |
| License mode | Trial license ("evaluate for possible purchase") | constraint — confirm viability before shipping demos |

## MATLAB ↔ PyTorch parity (v8.12 frozen evidence)
- `verify_matlab_parity_v8_12.m` + `parity_result_v8_12.json`: max abs logit diff 4.2915e-6 (PASS, tol 1e-3).
- MATLAB *semantic* inference consistency: PASS (severity 4/4 matches Python 0/2/0/4).
- MATLAB *preprocessing* numeric parity: **DOCUMENTED_PORT_LIMITATION** — `adapthisteq`/boxfilter/CC-crop are not numerically identical to OpenCV CLAHE/INTER_AREA/contour. Preprocessing is done in Python; ONNX inference import is the parity boundary.

## Workspace
| Item | Value |
|---|---|
| Root | workspace root = parent directory of this repository (override with `SIH_WORKSPACE_ROOT`) |
| Data | `../data/aptos`, `../data/idrid`, `../data/DRIVE`, `../data/messidor-2` |
| Frozen checkpoints | `sih26038_checkpoints_v8_12\dr_ordinal_best_v8_12.pt` (129 MB, sha256 27BF28C5…), `drive_vessel_best_v8_12.pt` (57 MB, 5CE5536A…), `idrid_lesion_best_v8_12.pt` (57 MB, 2E51BC58…) |
| Frozen ONNX | `sih26038_export_v8_12\dr_classifier_v8_12.onnx` (42 MB, sha256 86B04F40…) |
| Results | `sih26038_results_v8_12\` (final report, calibration, policy, folds, robustness, evidence matrix, external IDRiD/lesion/localization, DRIVE vessel) |
| MATLAB package | `matlab_sih26038_v8_12\` (README, Simulink + parity m-files, `simulink_result_v8_12.json`, `parity_result_v8_12.json`) |
| Executable notebook | `SIH26038_DR_Screening_v8_12_executed.ipynb` (53 cells); code dumps in a local scratch directory as per-cell `cell_*.py` files (scratch path intentionally not recorded; regenerate from the notebook) |
| Legacy prototype | `SIH_DR\` (old modelA/modelB + quality_mobilenetv2; `gradcam_outputs/`, `logs/`, `export/` empty) |

## Known environment gaps affecting v9.0 claims
1. No SimEvents → queue/resource claims limited to the Simulink operational model executed in v8.12.
2. No CV / Stats / Medical Imaging toolboxes → MATLAB demos must only exercise DL + IP toolboxes.
3. Trial license → confirm MATLAB demo is runnable at submission time.
4. 12 GB A2000 → keep v9.0 training batch sizes / resolution that fit single-GPU memory (v8.12 small-model precedent).