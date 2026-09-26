# Known Issues

This repository is a research snapshot. The following issues are intentionally documented rather than hidden.

## Resolved in this publication

- `experiments/X1/X1_CHECKSUMS.json` and `metrics/X2/X2_CHECKSUMS.json` are now full 64-hex
  SHA-256 manifests over repository-relative POSIX paths. The earlier 32-character values were
  truncated SHA-256 prefixes, not MD5; 30 of 37 entries were prefix-identical to the regenerated
  digests, and every differing entry corresponds to a file intentionally edited for path
  portability or scope correction. Release binaries are listed under `release_assets_not_in_git`.
- `experiments/X2/x2_assemble.py` no longer truncates digests and now sweeps the X2 artifact
  trees instead of a stale hard-coded file list.
- The stale `x1_fill_val.py` entry was dropped; no such file exists in this repository.
- Tracked evidence no longer contains workstation-local paths. `x3/x3_step6_fix_paths.py` is a
  read-only auditor and no longer mutates frozen evidence, and
  `x3/x3_step2_visual_evidence_audit.py` emits repository-relative paths on regeneration.
- `metrics/X2/X2_ABLATION.csv` and `metrics/X2/x2_h_ablation.json` record the routing split
  correctly and declare the validation-only scope (`n=733`); the dead assignments in the arm-D
  block of `experiments/X2/x2_h_ablation.py` were removed.
- `x3/X3_SIMULINK_SUMMARY.csv` labels its counting unit per row, so the 24-hour scenario totals
  and the hourly annualized row are no longer read as the same quantity.
- FGADR-referencing documents carry an explicit withheld-evidence notice, and the FGADR rows in
  `x3/X3_FINAL_EVIDENCE_MATRIX.csv` are marked `WITHHELD`/`excluded`.

## Evidence integrity

- `metrics/X2/x2_final_locked_test.json` records the policy at `experiments/X2/X2_POLICY.json`,
  while the tracked policy is `metrics/X2/X2_POLICY.json`. The JSON was frozen under the frozen
  protocol and is left unedited; read the policy from `metrics/X2/X2_POLICY.json`.
- `x3/X3_SIH_REQUIREMENT_CLOSURE_AUDIT.md` contains values that do not consistently match the
  canonical JSON/CSV metrics. Prefer the scoped machine-readable artifacts and resolve
  discrepancies before publication.
- Historical artifact names and directory names do not always match `V9.0_EXPERIMENT_CONTRACT.md`.
- Checkpoint digests recorded in prose (`73522dbbe7f476...`) are abbreviated. Use the manifests
  for full digests.

## Reproducibility

- Raw datasets, frozen v8.12 manifests, and frozen checkpoints are not stored in this repository
  and must be obtained or restored separately.
- There is no automated unit-test suite and no CI workflow.
- The project depends on a specific CUDA, Python, PyTorch, MATLAB, and Simulink environment.
- The project is not a turnkey inference application; the tracked scripts reproduce research
  stages rather than a validated clinical service.
- The frozen evidence in this snapshot cannot be regenerated here because the inputs are absent.
  Any rerun requires restoring the workspace layout described in `README.md`.

## Scope and authorization

- FGADR-derived files are excluded pending authorization and redistribution review. `git ls-files`
  contains no FGADR path.
- Historical reports, decks, and audits still mention FGADR results. Those numbers are historical
  records only, cannot be reproduced or verified from this repository, and must not be cited as
  evidence contained in it.
- Messidor-2 labels are third-party labels, not official clinical-grade labels.
- No ophthalmologist usability study, clinical validation, IRB review, or prospective deployment
  was performed.

## Safety and deployment

- The quality gate is a heuristic and has not been validated against clinical image-quality labels.
- The workflow's perfect safety sensitivity is a property of the executed locked-test routing
  result, not a guarantee for future data.
- MATLAB preprocessing parity remains a documented port limitation; inference parity is evaluated
  at the ONNX boundary and covers only `n=4` validation images.
- Simulink capacity is modeled from validation-derived routing fractions, not an observed
  operational result.
- The system must not be used for autonomous diagnosis.
