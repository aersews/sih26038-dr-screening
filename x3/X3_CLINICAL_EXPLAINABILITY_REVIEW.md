# X3 — Clinical Explainability Review (Step 6) + Clinician Micro-Pilot Status (Step 7)

Date: 24 Sep 2026.

## Step 6 — Explainability review of the 4 X2 demo cases

Review is an **automated artifact-integrity + content review** (no clinician was available; see Step 7).

| Case | id_code | True grade | AI grade | Route | Grad-CAM saved | Report saved | Verdict |
|---|---|---|---|---|---|---|---|
| non_referable_good_quality | 0304bedad8fe | No DR | No DR | SCREENING_OUTPUT | case1 PNG (845×3120, content-rich) | report_non_referable_good_quality.txt | coherent |
| referable_good_quality | 0083ee8054ee | PDR | PDR | REFER | case2 PNG | report_referable_good_quality.txt | coherent |
| low_quality_review | 9b4fc15df3c8 | No DR | No DR | HUMAN_REVIEW (quality 0.429) | case3 PNG | report_low_quality_review.txt | coherent |
| uncertain_review | 054b1b305160 | No DR | No DR | HUMAN_REVIEW (conf 0.412) | case4 PNG | report_uncertain_review.txt | coherent |

Checks performed (pass/fail):
- Grad-CAM PNG exists, 845×3120, std 88–102, >90% pixels populated → **PASS** (not blank/decorative).
- Case JSON (probs, ref_prob, confidence, uncertainty, route) internally consistent with report text and policy rules → **PASS**.
- Every report "Evidence image:" path resolves to the actual PNG on disk (stale-path bug found and fixed in this step) → **PASS**.
- Report text is scoped: "NOT a diagnostic report", "Grad-CAM shows classifier attention only; APTOS has no lesion masks; no lesion overlays fabricated" → **PASS**.
- No clinician-rated "clinically useful" score exists → **NOT EXECUTED** (see Step 7); demo materials are provided for a future rating pass.

## Step 7 — Clinician micro-pilot availability

- No qualified ophthalmologist/reviewer is accessible from this working environment (automated workspace; no scheduled external reviewer).
- Per X3 protocol: **CLINICIAN VALIDATION = NOT EXECUTED**.
- Nothing is fabricated to fill the gap: no fake agreement stats, no invented Kappa. The requirements that depend on clinician rating (PS 6a "rated as clinically useful", 4d "<30 s validation") remain flagged C / partial, consistent with the X3 requirement audit.