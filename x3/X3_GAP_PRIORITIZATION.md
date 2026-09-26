# X3 — Gap Prioritization (Step 3)

Decision made 24 Sep 2026 from the Step 1 requirement audit + Step 2 visual evidence audit.

| Gap | PS rows | Priority | Action in X3 |
|---|---|---|---|
| OD / fovea localization | 2a | **HIGH** | Buildable: official IDRiD C coordinates (413 train / 103 test) verified on disk → small supervised fovea localizer, trained on C-train only, single-shot C-test eval, labeled PROTOTYPE/EXPERIMENTAL. Isolated; no APTOS/IDRiD-B grading labels touched. |
| Lesion-level visual evidence | 4b (2c/2d/2e) | **MED** | v8.12 trained lesion model is a validated honest negative. Smallest defensible step: **classical, no-training** color/morphology candidate detector on IDRiD A official masks → honest candidate-level + pixel Dice, real overlay PNGs. No retrained DR/lesion model. Label PROTOTYPE. |
| Clinician rating (Grad-CAM "clinically useful") | 6a | **LOW** | No qualified reviewer immediately accessible in the working environment → `CLINICIAN VALIDATION = NOT EXECUTED`, demo cases provided for future rating. No fabricated scores. |
| Microaneurysm / exudate / hemorrhage (as ≥clinical capability) | 2c/2d/2e | **LOW** | Cannot claim in sprint; stay HONEST_NEGATIVE (D). Covered by Step 4 only as an honest PROTOTYPE candidate detector, never a clinical claim. |
| Neovascularization | 2f | OUT | Scoped out (no authorized dataset); documented. |
| Denoising step (1b) | 1b | OUT | Scoped out: no clinical quality-label corpus to validate a denoiser; would be unverifiable. |
| Simulink queue-paradigm / SimEvents | 5a/5b | OUT | SimEvents unavailable; rate-based model labeled MODELED CAPACITY. |

## Execution order
1. Step 5 (fovea localizer) — highest judgment visibility (converts a D row to a measurable prototype).
2. Step 4 (classical lesion candidate prototype) — produces honest visual evidence + metrics for 4b.
3. Steps 6–11: case review, clinician flag (not executed), Simulink/ablation audits, Messidor confinement, final package.

Rule kept from X3 protocol: any new component is **isolated + explicitly labeled PROTOTYPE/EXPERIMENTAL** and never mixed with the frozen DR-grading evidence.