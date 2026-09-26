# SIH26038: Explainable Diabetic Retinopathy Screening

Research prototype for SIH 2026 problem SIH26038: an AI-assisted diabetic retinopathy screening workflow designed for resource-constrained settings.

> This project is not a medical device, diagnostic service, or substitute for ophthalmologist review. The system is intended for research and human-in-the-loop demonstration only.

## Current evidence snapshot

| Scope | Result | Evidence |
|---|---:|---|
| APTOS locked internal test, `n=732` | QWK `0.9027` | [`metrics/X2/x2_final_locked_test.json`](metrics/X2/x2_final_locked_test.json) |
| Referable sensitivity, ICDR grade 2+ | `0.9192` | [`metrics/X2/x2_final_locked_test.json`](metrics/X2/x2_final_locked_test.json) |
| Referable specificity, ICDR grade 2+ | `0.9333` | [`metrics/X2/x2_final_locked_test.json`](metrics/X2/x2_final_locked_test.json) |
| Referable ROC AUC | `0.9792` | [`metrics/X2/x2_final_locked_test.json`](metrics/X2/x2_final_locked_test.json) |
| Workflow safety sensitivity | `1.0` with zero referable cases auto-screened | [`metrics/X2/x2_final_locked_test.json`](metrics/X2/x2_final_locked_test.json) |
| Python to ONNX Runtime parity | maximum class-logit difference `8.1e-6` over `n=4` validation images | [`metrics/X2/x2_f1_python_onnx_parity.json`](metrics/X2/x2_f1_python_onnx_parity.json) |
| ONNX to MATLAB parity | maximum class-logit difference `6.67572e-6` over `n=4` validation cases | [`matlab/X2/results/x2_f_matlab_onnx_parity.json`](matlab/X2/results/x2_f_matlab_onnx_parity.json) |
| Simulink capacity model | approximately `346,000` images/year **modeled** capacity, not an observed or validated throughput result | [`simulink/X2/simulink_result_v9_0.json`](simulink/X2/simulink_result_v9_0.json) |

The APTOS result is an internal locked-split evaluation, not prospective clinical validation. No clinician rating, clinical trial, IRB study, or deployment study has been performed.

Scope limits that matter when reading the numbers:

- Both parity checks cover only `n=4` validation images. They demonstrate implementation agreement, not population-level or device-level equivalence.
- The ablation in [`metrics/X2/X2_ABLATION.csv`](metrics/X2/X2_ABLATION.csv) is a **validation-split** study (`n=733`). The locked test was never used for ablation.
- Simulink capacity is a queue model driven by validation-derived routing fractions. It is a modeling result, not measured throughput.
- The fovea and classical lesion prototypes are unsupervised or training-free research code, not clinical components.

## Workflow

1. Crop the retinal field of view and apply CLAHE preprocessing.
2. Estimate engineering image-quality features and route potentially unusable images to recapture or human review.
3. Run the `efficientnet_b3` ordinal classifier for ICDR grades 0-4 and referable disease.
4. Apply temperature scaling and deterministic confidence routing.
5. Produce classifier-attention Grad-CAM examples and an annotated draft report.
6. Route referable, uncertain, or low-quality cases to a human decision-maker.
7. Export the PyTorch model to ONNX and verify Python/MATLAB inference parity.
8. Simulate acquisition and review capacity in Simulink.

The quality gate is a heuristic. Grad-CAM shows classifier attention, not a clinician-validated lesion annotation. The routing policy improves workflow safety by reducing automatic screening coverage; it does not change the underlying grading predictions.

## Repository layout

| Path | Purpose |
|---|---|
| `experiments/X1/` | Rebaseline training, evaluation, calibration, and robustness scripts |
| `experiments/X2/` | Quality gate, routing, explainability, reports, ONNX, and evidence assembly |
| `metrics/` | Machine-readable evaluation outputs |
| `plots/` | Evaluation and quality-gate figures |
| `explainability/` | Saved Grad-CAM examples |
| `reports/` | Human-readable reports and generated report examples |
| `matlab/` | MATLAB ONNX integration, parity scripts, and results |
| `simulink/` | Simulink model, runner, scenarios, and results |
| `x3/` | Isolated lesion and localization prototypes plus evidence audits |
| `submission/` | Final presentation and QA artifacts |
| [`MODEL_CARD.md`](MODEL_CARD.md) | Intended use, metrics, limitations, and safety boundaries |
| [`KNOWN_ISSUES.md`](KNOWN_ISSUES.md) | Integrity and reproducibility issues still open |
| [`V9.0_EXPERIMENT_CONTRACT.md`](V9.0_EXPERIMENT_CONTRACT.md) | Frozen experiment rules and scope labels |

## Requirements

- Python `3.13.5`
- PyTorch `2.11.0+cu128` and torchvision `0.26.0+cu128`
- An NVIDIA GPU is recommended but not required for syntax and artifact review
- MATLAB R2026a with Deep Learning Toolbox, Image Processing Toolbox, and Simulink for MATLAB/Simulink execution
- Datasets must be obtained separately under their original terms

The audited Python environment is captured in [`environment_audit_v9_0.md`](environment_audit_v9_0.md) and pinned in [`requirements.txt`](requirements.txt).

## Setup

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
```

The scripts expect a workspace containing this repository and external frozen inputs:

```text
workspace/
  sih26038_v9_0/
  data/
  sih26038_results_v8_12/
  sih26038_checkpoints_v8_12/
  sih26038_export_v8_12/
```

Set `SIH_WORKSPACE_ROOT` when the inputs are stored elsewhere:

```powershell
$env:SIH_WORKSPACE_ROOT = "C:\path\to\workspace"
python experiments\X1\x1_step1_baseline.py
```

Do not casually rerun locked-test scripts. They are retained to reproduce the frozen evidence protocol and must not be used for iterative tuning.

## Models and datasets

Large model files are excluded from Git and published as versioned GitHub Release assets. Download the release matching the repository tag, verify its SHA-256 digest, and extract it into the workspace paths expected by the scripts.

[`experiments/X1/X1_CHECKSUMS.json`](experiments/X1/X1_CHECKSUMS.json) and [`metrics/X2/X2_CHECKSUMS.json`](metrics/X2/X2_CHECKSUMS.json) are full 64-hex SHA-256 manifests over the committed artifacts. Release binaries that are not in Git are listed separately under `release_assets_not_in_git`; the X2 manifest is regenerated by `experiments/X2/x2_assemble.py`. The historical truncated digests in earlier revisions of these files were SHA-256 prefixes, not MD5.

Datasets, credentials, generated caches, MATLAB build caches, and model binaries are intentionally excluded. Never commit API credentials such as `kaggle.json`, `.env` files, private keys, or patient-identifiable data.

FGADR-derived files are excluded pending authorization review; `git ls-files` contains no FGADR path. References to FGADR in historical reports, decks, and audits are not evidence included in this repository, and those documents carry an explicit withheld-evidence notice.

## Validation

Run a syntax check after changes:

```powershell
python -m compileall -q .
```

The project does not currently contain an automated unit-test suite. MATLAB and Simulink execution requires the licensed desktop toolchain described above. See [`KNOWN_ISSUES.md`](KNOWN_ISSUES.md) before using the scripts for a new experiment.

## License

Source code is released under the [MIT License](LICENSE). Dataset licenses and restrictions remain with their respective owners. Model weights are research artifacts and are not licensed for clinical deployment.
