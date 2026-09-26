# Model Card: SIH26038 DR Screening X1C2

## Model summary

X1C2 is a PyTorch `efficientnet_b3` classifier with three outputs:

- Five-class ICDR diabetic retinopathy logits for grades 0-4
- Four ordinal logits
- One binary referable-disease logit for grades 2-4

The model uses a 300x300 cropped and CLAHE-enhanced fundus image. The frozen v9.0 evaluation uses temperature scaling with `T=1.25` and a deterministic workflow policy.

## Intended use

Research and engineering demonstration of an AI-assisted screening workflow in resource-constrained settings. Outputs may support triage, quality review, model debugging, and human-review demonstrations.

## Out-of-scope use

Do not use this model for autonomous diagnosis, treatment selection, emergency triage, population screening without qualified oversight, or any decision where the output has not been reviewed by a trained clinician.

## Training context

- Primary dataset: APTOS 2019 blindness-detection fundus images
- Split: frozen internal train/validation/locked-test partition
- Locked test size: `n=732`
- Validation decisions: model selection, temperature calibration, and routing policy
- Locked test: one-shot final evaluation under the documented protocol
- Input: color retinal fundus photograph
- Output classes: ICDR grades 0-4 and referable disease at grade 2 or higher

## Evaluation results

| Metric | APTOS locked test |
|---|---:|
| Quadratic weighted kappa | `0.9027` |
| Accuracy | `0.8115` |
| Macro F1 | `0.6460` |
| Referable sensitivity | `0.9192` |
| Referable specificity | `0.9333` |
| Referable ROC AUC | `0.9792` |

At the workflow layer, 302 cases were referred, 161 routed to human review, 269 released as screening outputs, and none were recaptured. No referable case was automatically screened. This is a routing-safety result, not evidence that the classifier's grading accuracy improved.

## Integration evidence

Both parity checks were executed on the same `n=4` validation images. They show that the
three implementations agree on those cases; they are not a population-level or
device-qualification equivalence test.

- Python PyTorch to ONNX Runtime maximum absolute difference: approximately `8.1e-6` (`n=4`)
- ONNX to MATLAB maximum class-logit difference: `6.67572e-6` (`n=4`)
- ONNX to MATLAB maximum referable-logit difference: `3.81469727e-6` (`n=4`)
- MATLAB screening routes matched Python on the executed cases

## Limitations

- No prospective, multicenter, clinical, or clinician-validated evaluation was performed
- APTOS images do not represent every camera, clinic, population, or disease prevalence
- Parity evidence covers only `n=4` validation images
- The image-quality score is an engineering heuristic without externally rated quality labels
- Grad-CAM is classifier attention guidance, not validated lesion evidence
- Calibration and operating-point transfer require validation for each deployment population
- The historical IDRiD evaluation documented substantial domain-shift limitations
- MATLAB preprocessing is not numerically identical to the Python OpenCV preprocessing; parity is established at the ONNX inference boundary
- Simulink capacity is a queue model driven by validation-derived routing fractions. It is modeled, not an observed or validated throughput result
- The routing ablation is a validation-split study (`n=733`); the locked test was not used for it
- FGADR-derived prototypes are excluded pending authorization review, and FGADR numbers retained in historical documents are unverifiable from this repository

## Human oversight

The workflow is designed around human disposition. Referable, uncertain, and low-quality cases must remain in a clinician-controlled pathway. Generated reports are drafts and include a non-diagnostic disclaimer.

## Release artifacts

Large artifacts are distributed through GitHub Releases rather than Git history:

- `dr_x1c2_best_X1C2.pt`
- `dr_x1c2.onnx`
- Experimental fovea-localization checkpoints, when authorized for release

Verify release-asset checksums before use. [`experiments/X1/X1_CHECKSUMS.json`](experiments/X1/X1_CHECKSUMS.json) and [`metrics/X2/X2_CHECKSUMS.json`](metrics/X2/X2_CHECKSUMS.json) record full 64-hex SHA-256 digests; the excluded binaries are listed under `release_assets_not_in_git` in each manifest.

## Ethical and safety considerations

Dataset shift, camera variation, image-quality failures, prevalence changes, and automation bias can make performance worse than the reported internal evaluation. A deployment would require governance, monitoring, bias analysis, incident response, privacy controls, and independent clinical validation.
