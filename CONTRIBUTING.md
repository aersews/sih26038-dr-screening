# Contributing

## Ground rules

- Keep every metric labeled with its dataset, split, operating point, and evidence status.
- Never tune on the APTOS locked test or use item-level locked-test feedback for iteration.
- Preserve human review for referable, uncertain, and low-quality cases.
- Do not add datasets, credentials, patient-identifiable data, model binaries, MATLAB caches, or FGADR-derived material to Git.
- Publish large authorized model artifacts through a versioned GitHub Release with a SHA-256 digest.
- Do not describe modeled, heuristic, third-party-labeled, or prototype results as clinical validation.

## Development

1. Create a focused branch.
2. Keep paths relative to `__file__` or `SIH_WORKSPACE_ROOT`.
3. Add or update the relevant machine-readable evidence artifact.
4. Update the matching human-readable report and experiment contract when scope changes.
5. Run `python -m compileall -q .`.
6. Review `git diff` and `git status` for accidental data, credentials, or generated files.
7. Open a pull request with the exact command outputs and limitations.

## Locked evaluations

Do not rerun `x2_final_locked_test.py` for ordinary development. A new locked evaluation requires a newly defined protocol, a new output namespace, and explicit authorization to create a new evidence version.
