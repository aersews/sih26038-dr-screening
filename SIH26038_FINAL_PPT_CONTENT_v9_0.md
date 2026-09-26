# FINAL DECK CONTENT — SIH 2026

SIH26038 — Explainable AI for Diabetic Retinopathy Screening in Rural India
Team MMC (ID 148873) · Motihari College of Engineering · MedTech/BioTech/HealthTech · PS Category: Software
Deck format: SIH 2026 official 6-slide template → final portal artifact = PDF.
Prepared from v9.0 accepted evidence only. Every number below is traced to a file on disk (see FINAL METRIC MASTER TABLE).

> Note on the template: no official SIH PPT template file is present in the workspace. This document uses
> the six official section names supplied with the assignment (TITLE / IDEA TITLE / TECHNICAL APPROACH /
> FEASIBILITY AND VIABILITY / IMPACT AND BENEFITS / RESEARCH AND REFERENCES). Do not add a seventh slide.

> **FGADR evidence withheld.** FGADR-derived material (dataset, images, masks, checkpoints, results, and the `x3/step4b_fgadr/` pathway) is excluded from this repository pending authorization and redistribution review. FGADR is licensed for non-commercial research only and its images may not be redistributed. Every FGADR number, file path, and status below is a historical record only: those artifacts are not distributed here, cannot be reproduced or verified from this repository, and must not be cited as evidence contained in this repository. All non-FGADR evidence (X1, X2, fovea and classical lesion prototypes, MATLAB/Simulink integration) is unaffected.

---

# Slide 1 — TITLE

## Exact text
- **SMART INDIA HACKATHON 2026**
- Problem Statement ID: **SIH26038**
- Problem Statement Title: **Explainable AI for Diabetic Retinopathy Screening in Rural India**
- Theme: MedTech / BioTech / HealthTech
- PS Category: Software
- Team ID: **148873**
- Team Name: **MMC**
- Institute: **Motihari College of Engineering**

## Visual
- Background: official SIH 2026 title styling only. One real fundus image strip as a subtle accent band
  (optional): `sih26038_v9_0\explainability\X2\X2_EXPLAINABILITY_CASES\case2_referable_good_quality.png`
  (845×3120 wide strip) — do NOT enlarge beyond a band; it is a 3-panel explainability strip, keep as-is or use only panel 1 crop of the original fundus.

## Layout notes
- Single centered block. Title, PS ID, PS title, theme/category on top; team block below.
- Font: template defaults. No extra slogan, no tagline that competes with the official title.
- Leave the fundus band to the far right or bottom, no text over it.

## Claim notes
- No numbers on this slide. Nothing to defend. Do not add team member names, mentors, AISHE codes, or advisor names (not in source files).

---

# Slide 2 — IDEA TITLE

Goal: answer in seconds — (1) the rural problem, (2) what we built, (3) why it is distinctive.

## Exact text

**A. PROBLEM (3 bullets, ≤7 words each)**
- Retina specialists are scarce in rural India
- Fundus image quality varies widely at PHCs/camps
- Screening must be explainable, not a black box

**B. SOLUTION (one sentence)**
> An explainable, quality-aware AI workflow that grades DR (ICDR 0–4), surfaces retinal evidence, generates an AI-assisted screening report, and routes every case for human review.

**C. UNIQUE VALUE PROPOSITION (exactly 3 items)**
1. Quality-aware screening — accepts / recaptures / routes by image quality
2. Evidence-aware explainability — Grad-CAM attention + lesion evidence maps + annotated report
3. MATLAB + Simulink rural workflow integration — ONNX-verified, district-capacity modeled

## Hero visual
- File: `sih26038_v9_0\explainability\X2\X2_EXPLAINABILITY_CASES\case2_referable_good_quality.png`
  (also present as `sih26038_v9_0\x3\X3_DEMO_CASES\case2_referable_good_quality.png`)
- What it shows: 3-panel strip for one real validation case — (left) preprocessed fundus; (middle) Grad-CAM attention overlay on the referable logit; (right/panel) grade + quality + route summary. Case 0083ee8054ee, true grade 4 (Proliferative DR), predicted grade 4, routed REFER, quality 0.678 ACCEPT.
- Why it belongs: single image proves the whole story — an actual image, real attention, real routing decision. This is the strongest explainability case (referable + correctly graded + high-signal attention).
- Verified on disk (845×3120, populated).

## Supporting visual
- File: `sih26038_v9_0\reports\X2\X2_REPORT_EXAMPLES\report_referable_good_quality.txt`
  (same file in `x3\X3_DEMO_CASES\report_referable_good_quality.txt`)
- What it shows: the machine-generated **AI-assisted screening report** for that case — image ID, quality index, DR grade, referable flag, confidence/uncertainty, referable probability, referral reason, human-review recommendation, and the explicit **"NOT a diagnostic report"** disclaimer.
- Why it belongs: shows the human-in-the-loop output artifact and honesty framing in one glance. Rendered as a small text card (first ~10 lines), not a screenshot of a file.

## Caption
- Hero: "Real fundus → Grad-CAM attention → routed to human review (case 0083ee8054ee, grade 4)".
- Report card: "AI-assisted screening report — machine-generated, never a diagnostic report".

## Claim notes
- "AI-assisted screening report", NOT "diagnostic report" / "clinical diagnosis".
- Attention is Grad-CAM on the referable logit — classifier attention only; APTOS has no lesion masks, so no lesion overlay is fabricated on this slide.
- No invented rural statistics; the three problem bullets are generic, sourced from the PS framing, not fabricated data.

---

# Slide 3 — TECHNICAL APPROACH

This is the strongest technical slide — a clean horizontal 6-stage pipeline + a compact metric strip.

## Exact text — pipeline (6 boxes, ≤2 short lines each)

| # | Box | Lines |
|---|-----|-------|
| 1 | IMAGE QUALITY | Focus • illumination • FOV — Accept / Recapture |
| 2 | RETINAL STRUCTURES | Optic disc (Dice 0.897) — Fovea (prototype) — Vessels (DRIVE dev) |
| 3 | LESION EVIDENCE | MA • HE • EX • SE — FGADR-trained prototype |
| 4 | DR GRADING | ICDR 0–4 (X1C2) — Referable sens 91.92% |
| 5 | EXPLAINABILITY | Grad-CAM • Confidence • Annotated report |
| 6 | MATLAB / SIMULINK | ONNX → MATLAB — Workflow simulation |

## Metrics strip (4 cells — compact, top of slide or under pipeline)
- **QWK 0.9027**
- **Sensitivity 91.92%** (referable, ≥2)
- **Specificity 93.33%** (referable)
- **AUC 0.9792** (referable)

All four = single locked APTOS test (n=732), one-shot, frozen model + calibration + argmax.

## Evidence band (small, below metrics)
- MATLAB parity: **6.7e-6** max difference (ONNX → MATLAB; Python→ONNX 8.1e-6)
- Lesion prototype: **mean Dice 0.409** (FGADR test, MA/HE/EX/SE)
- Validation label the strip: "VALIDATED" for the grading metrics; "PROTOTYPE" for lesion/fovea rows.

## Visuals
1. Pipeline diagram — draw as 6 boxes + arrows using the template shapes (no code screenshots).
2. Representative lesion overlay:
   - Primary: `sih26038_v9_0\x3\step4b_fgadr\overlays\case_EX_1091_2_montage.png` (1290×1290) — real FGADR test case, EX dice 0.871; original / ground-truth / prediction / overlay quadrants.
   - Alternative (all-class fused evidence): `sih26038_v9_0\x3\step4b_fgadr\overlays\evidence_EX_1091_2_fused.png` (1280×1280) — EX case with MA/HE/EX/SE color-coded evidence overlay.
   - Caption: "FGADR-trained lesion-evidence prototype — real overlay (EX case, Dice 0.871)". Label: PROTOTYPE.
3. Optionally `plots\X2\X2_QUALITY_DISTRIBUTION.png` (560×896) in the quality box.

## Claim notes
- Split VALIDATED vs PROTOTYPE clearly:
  - VALIDATED = APTOS locked-test grading metrics (0.9027 / 91.92% / 93.33% / 0.9792).
  - PROTOTYPE = fovea localizer (median 273 px), FGADR lesion evidence (Dice 0.256–0.513), vessels (DRIVE development split).
- "Optic disc Dice 0.897" = **structural segmentation**, never call it lesion segmentation.
- "Vessels" = DRIVE FOV-masked **dev** Dice 0.683 on the official training split (n=4 held-out); do not label it an official DRIVE challenge result.
- 91.92% is the v9.0 headline; do not use 89.56% here.
- Do not claim the test set was tuned; add a one-line footer: "Single locked-test evaluation; operating point frozen on validation."
- 7.49M-parameter UNet / Tversky loss details go in judge Q&A, not on the slide (keep concise).

---

# Slide 4 — FEASIBILITY AND VIABILITY

Answer: "Does the prototype actually work?"

## Exact text — SECTION 1 · VALIDATED NOW (5–6 concise items)
- ✅ APTOS locked-test target achieved — sens 91.92% > 90%, spec 93.33% > 85%
- ✅ MATLAB / ONNX parity verified (max Δ 6.7e-6; all 4 routes reproduced)
- ✅ X2 routing evaluated on locked test (RECAPTURE 0 · review 161 · auto 269 · refer 302)
- ✅ 0 missed referable in workflow routing (safety sensitivity 1.0)
- ✅ 4 annotated AI-assisted screening reports generated
- ✅ Simulink workflow executed (LOW / BASE / HIGH, queues drained)

## Exact text — SECTION 2 · PROTOTYPE EVIDENCE
- Optic disc Dice `0.897` (structural; IDRiD held-out)
- Fovea prototype: `273 px` median error; `32%` within 200 px (n=103, single-shot)
- FGADR lesion prototype: Dice `0.256–0.513` (MA→EX; mean 0.409)
- Real lesion overlays generated (FGADR test cases)

## Exact text — SECTION 3 · REMAINING VALIDATION
- ⏳ Clinician reviewer study pending (not executed this sprint)
- ⏳ NV detection limited by sparse positives (49 / 1842 ≈ 2.7%)
- ⏳ Broader prospective clinical validation pending

## Evidence blocks
- Grading: `metrics\X2\x2_final_locked_test.json`
- Routing: `simulink\X2\X2_SIMULINK_SCENARIOS.csv`
- Prototype: `x3\step5_fovea\x3_fovea_prototype_v2_results.json`, `x3\step4b_fgadr\FGADR_RESULTS.json`

## Visual (one strong visual + optional second)
- Primary (recommended — verified on disk): FGADR lesion montage
  `sih26038_v9_0\x3\step4b_fgadr\overlays\case_SE_0174_2_montage.png` (SE, dice 0.899, 1290×1290)
  OR fovea overlay `sih26038_v9_0\x3\X3_DEMO_CASES\fovea_v2_test_IDRiD_003.png` (680×1024, predicted vs GT center).
- Strongest single "it works" visual: `sih26038_v9_0\plots\X2\X2_QUALITY_DISTRIBUTION.png` (560×896) — the quality-gate distribution shows the quality-aware design working.
- MATLAB / Simulink: **no screenshot asset currently exists on disk as a PNG**. If the deck builder has MATLAB available, capture one screenshot of `matlab\X2\sih26038_screening_workflow_v9_0.slx` (real model, not fabricated) or of `run_x2_matlab_onnx_parity.m` output. Otherwise use the quality-distribution plot as the visual and keep Simulink numbers as text (see claim notes).
- Pick ONE of: FGADR montage OR fovea overlay OR quality distribution — do not overcrowd.

## Claim notes
- "346k/yr" belongs here ONLY with the word MODELED (see Slide 5).
- Prototype metrics carry the `PROTOTYPE / EXPERIMENTAL` label; they are dataset-and-split-specific.
- "Clinician validation pending" must be visible — it is a statement of next step, not a failure.
- Do not say "clinically validated system", "ophthalmologist validated", or "<30 s validated review".
- Simulink = rate-based operational model (no SimEvents; do not claim queue-paradigm beyond what ran).

---

# Slide 5 — IMPACT AND BENEFITS

Frame around a rural workflow, not more metrics.

## Exact text — workflow visual (4 stacked boxes with arrows)
```
PHC / EYE CAMP
      ↓   (fundus capture at patient level)
LOCAL AI (quality gate → grade → evidence → report)
      ↓
CLINICIAN (AI-assisted review; AI remains decision support)
      ↓
DISTRICT REFERRAL (prioritized, capacity-planned)
```

## Exact text — beneficiaries (3 small blocks)
- **PHC / camp technician** — instant quality feedback; structured screening
- **Clinician** — lesion/evidence maps; prioritized referral review; AI is decision support
- **District program** — workload simulation; review-capacity planning

## Metrics (quantified, with the last one explicitly modeled)
| Metric | Value | Label |
|---|---|---|
| Referable sensitivity | 91.92% | APTOS locked test |
| Referable specificity | 93.33% | APTOS locked test |
| Human-review routes | 161 | locked test |
| Refer routes | 302 | locked test |
| Modeled capacity | ~346k/yr | **MODELED CAPACITY** |

## Visual
- Rural workflow diagram: draw with template shapes (boxes + arrows) per above. This is a schematic, not artificial medical imagery.
- No more than one secondary visual (e.g., a small quality-gate or refer-vs-review bar), and none is required.

## Claim notes
- Every occurrence of 346k/yr and 100k/yr must be "**modeled** capacity" (Simulink model with pools: demand 33.2/hr vs capacity 115/hr, margin 81.8/hr). Not deployed, not validated throughput.
- Do not repeat the pixel-level metric strip from Slide 3.
- Emphasize workflow safety instead of "replacing doctors": "human-in-the-loop screening workflow".
- Explicit sentence: "Clinical reviewer validation remains the next validation step." (small, credible).

---

# Slide 6 — RESEARCH AND REFERENCES

Compact indexed table. No literature-review paragraphs.

## Exact text
Caption line: "Prototype evidence is dataset- and split-specific; clinical validation remains pending."

| # | Source | Role / key evidence |
|---|---|---|
| 1 | APTOS 2019 (Klebs/ASNR) | Primary DR grading; locked test n=732 — QWK 0.9027, sens 91.92%, spec 93.33% |
| 2 | IDRiD | Segmentation/localization; OD Dice 0.897; fovea prototype (median 273 px); external lesion check |
| 3 | DRIVE | Vessel structure map (FOV-masked dev Dice 0.683, development split) |
| 4 | FGADR (arXiv:2008.09772) | Pixel lesion evidence prototype (MA/HE/EX/SE); non-commercial research license |
| 5 | ICDR / DR severity grading | Clinical grading standard used for the 0–4 referable target definition |
| 6 | Grad-CAM (arXiv:1610.02391) | Attention maps on the referable logit (attention-only, not lesion evidence) |
| 7 | ONNX | PyTorch → ONNX export; Python/ONNX parity max Δ 8.1e-6; MATLAB/ONNX 6.7e-6 |
| 8 | MATLAB R2026a | `importNetworkFromONNX` integration; PyTorch-trained model integrated via ONNX (NOT MATLAB-trained) |
| 9 | Simulink | Screening workflow model; LOW/BASE/HIGH drained; ~346k/yr modeled capacity |

## Claim notes
- Keep citations minimal (name + role). No DOI/NSc details beyond the arXiv IDs already used.
- DRIVE: dev split only (do not imply challenge-held official test was scored locally).
- No clinician/mentor/team-member references (none in source files).
- FGADR licensing: "non-commercial research use" noted in the caption line to stay claim-safe.

---

# JUDGE TAKEAWAYS

Exactly five points a judge should remember:

1. **We met the SIH operating target** — referable sensitivity **91.92%** and specificity **93.33%** (both beyond >90% / >85%), plus QWK **0.9027** on a single frozen locked-APTOS test (n=732); no test-set tuning.
2. **It is a complete human-in-the-loop workflow, not a single CNN** — quality gate → ICDR 0–4 grading → evidence + Grad-CAM → AI-assisted report → routing (0 missed referable; safety sensitivity 1.0).
3. **Explainability is real and honest** — Grad-CAM attention + FGADR-trained lesion-evidence overlays (test Dice 0.256–0.513) + annotated reports that explicitly say they are not diagnostic.
4. **MATLAB + Simulink integration is parity-verified** — PyTorch→ONNX→MATLAB max diff 6.7e-6, routes identical in MATLAB, district throughput modeled at ~346k/yr (explicitly modeled).
5. **We are explicit about limitations** — clinician validation pending; NV under-labeled (2.7%); MA weakest; everything outside the APTOS grading metrics is labeled PROTOTYPE / EXPERIMENTAL.

---

# LIKELY JUDGE QUESTIONS (with safest answer from the evidence)

1. **How did you achieve >90% referable sensitivity?**
   We retrained the v8.12 architecture as X1C2 with severity-weighted + ordinal + referable targets, then used the frozen **argmax** calibrated operating point (T=1.25) on the single locked test. This raised sensitivity from 0.8956 (v8.12, same convention) to **0.9192** while specificity rose to 0.9333. No locked-test tuning: every threshold was fixed on validation.

2. **What exactly is novel vs. published work?**
   We claim no research novelty in the classifier itself. The contribution is the integrated, evidence-labeled workflow: quality gate + explainability + AI-assisted report + MATLAB/ONNX + Simulink capacity model, with every metric scoped. That integration is the submission artifact.

3. **What happens with poor-quality images?**
   A heuristic quality index (sharpness, illumination, FOV, motion-blur proxy) routes them: q<0.35 → RECAPTURE; 0.35≤q<0.60 → HUMAN_REVIEW; else usable. On locked test: RECAPTURE 0, and the low-quality image (q=0.429) demonstrates the review route. Labeled QUALITY_HEURISTIC — not a clinical quality grade.

4. **What does Grad-CAM actually show?**
   Classifier **attention** on the referable logit (layer `backbone.conv_head`) — it localizes what the model looked at; it is NOT a lesion annotation. APTOS ships no lesion masks, so we never fabricate lesion overlays from Grad-CAM.

5. **Are the lesion results clinically validated?**
   No. The FGADR MA/HE/EX/SE results are a **trained lesion-evidence prototype** (mean Dice 0.409 on a locked FGADR test) — dataset-specific, not a clinical segmentation capability. No clinician validation has been done.

6. **Why is MA (microaneurysm) weaker?**
   MA Dice is lowest (0.256 on FGADR test; IoU 0.161; median 0.257) — microaneurysms are tiny, low-contrast lesions and MA carries the sub-pixel "PS" ask. On the external IDRiD single-shot check MA drops further (0.059), so we report it honestly as the weakest class.

7. **What about NV (neovascularization)?**
   FGADR has only 49 NV-positive images (≈2.7%), so NV status is **INSUFFICIENT_DATA / EXPERIMENTAL-ONLY**. No production NV detector was trained or validated. IRMA is excluded from the primary model.

8. **How does MATLAB fit into the system?**
   The PyTorch-trained X1C2 is exported to ONNX and imported into MATLAB (`importNetworkFromONNX`, R2026a). Max diff vs Python 6.7e-6; MATLAB reproduced all four Python screening routes exactly. Preprocessing stays in Python (documented port limitation). We do not claim the model was trained in MATLAB.

9. **Is the ~346k/year capacity real?**
   It is a **modeled capacity** estimate from the executed Simulink workflow model (demand 33.2 images/hr into human review vs modeled capacity 115/hr; margin 81.8/hr). It is not deployed throughput or clinical capacity validation.

10. **Why is human review still needed?**
   The design is a **human-in-the-loop screening workflow**: AI proposes, clinician disposes. Workflow routing sends all referable and boundary/uncertain cases to human attention (0 missed referable; safety sensitivity 1.0). AI never replaces the ophthalmologist.

11. **How does IDRiD performance compare?**
   Grading transfer to IDRiD-B is substantially weaker (single-shot QWK ~0.49, n=103 — domain shift, recorded honestly, not tuned). The FGADR lesion prototype on IDRiD-A test (n=27): EX 0.370 / SE 0.195 / HE 0.164 / MA 0.059 — shows EX generalizes best and MA is the cross-domain bottleneck.

12. **What remains unvalidated?**
   (a) clinician validation (NOT EXECUTED — no qualified reviewer available this sprint); (b) NV; (c) prospective clinical validation; (d) quality gate is heuristic; (e) lesion evidence is dataset/spit-specific; (f) vessels are dev-split only.

13. **Was the locked test used for any decisions?**
   No. Firewall: single evaluation at the end. Temperature (T=1.25), operating point (argmax), and routing rules were frozen on validation; we explicitly document a max-specificity threshold that fails on transfer (sens 0.862) and is NOT recommended for deployment.

14. **Why specificity 93.33% and not higher?**
   The predeclared selection rule maximizes specificity at validation given sens ≥90 / spec ≥85. The locked-test spec (0.9333) already exceeds the >85% target at the argmax point; the alternative max-spec cutoff would trade sensitivity below 90.

15. **Is this deployable in a rural PHC today?**
   As a prototype evidence system, the workflow is complete and the capacity model indicates feasibility (modeled), but clinical validation and field deployment planning remain outstanding. We present it as a validated-prototype framework, not a certified product.

16. **What datasets did you actually use, and what licenses?**
   APTOS (official SIH-attached), IDRiD, DRIVE (all research use), plus FGADR (non-commercial research license, cited arXiv:2008.09772; not redistributed). Messidor-2 on disk is third-party-labeled and unused for severity claims.

17. **Overall accuracy on the locked test?**
   0.8115 (n=732); balanced accuracy 0.6466; macro-F1 0.6460 (from `x2_final_locked_test.json`). We headline QWK/sens/spec/AUC because the PS targets are referable-level, but we report these too.

18. **How reproducible is your pipeline / can you rerun it?**
   Seed-42, locked split fingerprint `d6934df52f526795`, deterministic routing policy, and sha-256 CHECKSUMS for X1/X2/FGADR artifacts make the results reproducible from `sih26038_v9_0\`.

19. **Would the workflow hurt specificity by over-referring?**
   Routing is a safety trade: auto-screen coverage drops (0.336) so nothing referable is missed; the classifier's specificity stays at 0.9333 (grading is unchanged by routing by construction — ablation C/D).

20. **What would you do next given 3 more months?**
   Clinician reviewer study for the <30-s checklist and Grad-CAM utility rating; NV augmentation or scoped-out statement; prospective district-pilot data; Japanese/dataset expansion for lesion prototype; on-device (edge) deployment sizing for PHC cameras.

---

# DO-NOT-SAY LIST

Forbidden claims — never say these in the presentation:

1. "Clinically validated / clinically proven / hospital-ready"
2. "Diagnostic report" / "clinical diagnosis" (always "AI-assisted screening report")
3. "Replaces ophthalmologists" / "clinical review is unnecessary"
4. "The system safely replaces doctors"
5. "NV detection validated" / any NV claim beyond INSUFFICIENT_DATA / EXPERIMENTAL-ONLY
6. "Clinical-grade lesion segmentation" (use "FGADR-trained lesion-evidence prototype")
7. "346k validated patients" / "100k deployed patients" (use "~346k/yr MODELED CAPACITY")
8. "Validated <30-second review" (review target exists; clinician validation NOT executed)
9. "Trained in MATLAB" (use "PyTorch-trained model integrated into MATLAB via ONNX")
10. "We tuned on the test set" / "the test set was re-used"
11. "SimEvents used" / queue-paradigm claims beyond the rate-based Simulink model
12. "Optical disc is a lesion result" (it is STRUCTURAL segmentation)
13. "DRIVE official challenge result" (it is the development split; official test is challenge-held)
14. "89.56% sensitivity is our headline" (that is the v8.12 comparison value only)
15. "Messidor-2 validated us" (labels are third-party; no severity claim)
16. "Grad-CAM marks actual lesions" (attention only)
17. "Sub-pixel MA detection achieved" (MA prototype is weakest)
18. "Ophthalmologist validated Grad-CAM" (6a = NOT EXECUTED)
19. "Integrated pipeline outperforms the classifier" (ablation shows a safety/routing trade, grading is constant by construction)
20. Any MOE stats, AISHE codes, mentor/advisor/clinician names, or team-member bios not present in the source files.
21. "FGADR mask pixels are counts of lesions" (they are graded intensity maps; we binarize >0 as the standard mapping).
22. "Our UNet equals a clinically reliable detector" (report it as PROTOTYPE/EXPERIMENTAL).

---

# FINAL METRIC MASTER TABLE

Every numerical value intended for the PPT — metric, value, dataset, split, status, permitted wording.

| Metric | Value | Dataset | Split | Status | Permitted wording |
|---|---|---|---|---|---|
| Quadratic weighted κ (QWK) | 0.9027 | APTOS 2019 | Locked test n=732, single-shot | VALIDATED | "QWK 0.9027 (locked APTOS test, one-shot)" |
| Referable sensitivity (≥2) | 0.9192 = 91.92% | APTOS | Locked test n=732 | VALIDATED | "Referable sensitivity 91.92% (>90% target)" |
| Referable specificity (≥2) | 0.9333 = 93.33% | APTOS | Locked test n=732 | VALIDATED | "Referable specificity 93.33% (>85% target)" |
| Referable AUC | 0.9792 | APTOS | Locked test n=732 | VALIDATED | "Referable AUC 0.9792" |
| v8.12 comparison sensitivity | 0.8956 = 89.56% | APTOS | v8.12 locked test | VALIDATED (old baseline) | comparison only: "up from 89.56% in v8.12" |
| Overall accuracy | 0.8115 | APTOS | Locked test | VALIDATED | report in Q&A only |
| Safety sensitivity (workflow) | 1.0 (0 missed referable) | APTOS | Locked test, routing | VALIDATED (routing) | "workflow routed 0 missed referable" |
| Route counts | RECAPTURE 0 · HUMAN_REVIEW 161 · SCREENING_OUTPUT 269 · REFER 302 | APTOS | Locked test | VALIDATED | per route number, e.g. "161 to human review" |
| Regrade raw probability? | route coverage 0.3675 auto | APTOS | Locked test | VALIDATED | "auto-screen coverage 0.34–0.37" |
| Optic disc (structural) Dice | 0.897 | IDRiD | Held-out (n=8 validation) | VALIDATED (structural) | "Optic disc segmentation Dice 0.897 (STRUCTURAL)" |
| Fovea median error | 273 px | IDRiD C | Test n=103 single-shot | PROTOTYPE/EXPERIMENTAL | "Fovea prototype: median 273 px" |
| Fovea within 200 px | 32.0% | IDRiD C | Test n=103 | PROTOTYPE/EXPERIMENTAL | "32% within 200 px (prototype)" |
| Vessel Dice | 0.683 (FOV-masked) | DRIVE | Development split (n=4 held-out) | AVAILABLE / PROTOTYPE | "Vessel map (DRIVE development split)" — never "official challenge" |
| FGADR MA Dice | 0.256 | FGADR | Locked test n=140 pos | PROTOTYPE/EXPERIMENTAL | "MA Dice 0.256 (trained prototype; weakest class)" |
| FGADR HE Dice | 0.461 | FGADR | Locked test n=140 pos | PROTOTYPE/EXPERIMENTAL | "HE Dice 0.461" |
| FGADR EX Dice | 0.513 | FGADR | Locked test n=125 pos | PROTOTYPE/EXPERIMENTAL | "EX Dice 0.513 (best class)" |
| FGADR SE Dice | 0.407 | FGADR | Locked test n=63 pos | PROTOTYPE/EXPERIMENTAL | "SE Dice 0.407" |
| FGADR mean Dice | 0.409 | FGADR | Locked test n=181 | PROTOTYPE/EXPERIMENTAL | "mean Dice 0.409 (prototype)" |
| FGADR UNet size | ~7.49M params | — | — | FACT (config) | "UNet from scratch, 7.49M params" |
| FGADR split | train 1479 / val 182 / test 181 | FGADR | Self-created stratified 80/10/10, dup-safe | EXECUTED | "stratified 80/10/10, no leakage" |
| IDRiD external (FGADR model) EX | 0.370 | IDRiD A test | n=27 single-shot, no tuning | PROTOTYPE/EXTERNAL | "EX 0.370 on IDRiD (single-shot)" |
| IDRiD external SE | 0.195 | IDRiD A test | n=27 | PROTOTYPE/EXTERNAL | "SE 0.195" |
| IDRiD external HE | 0.164 | IDRiD A test | n=27 | PROTOTYPE/EXTERNAL | "HE 0.164" |
| IDRiD external MA | 0.059 | IDRiD A test | n=27 | PROTOTYPE/EXTERNAL | "MA 0.059 — weakest, reported honestly" |
| Classical (no-training) EX baseline | Dice 0.125 | IDRiD A test | n=27 | PROTOTYPE baseline | "classical baseline EX 0.125 (recorded)" |
| Classical HE baseline | Dice 0.076 | IDRiD A test | n=27 | PROTOTYPE baseline | "(classical HE 0.076)" |
| MATLAB/ONNX parity | max Δ cls 6.7e-6 | X1C2 → MATLAB | 4 validation images | VALIDATED | "MATLAB parity 6.7e-6 (ONNX)" |
| Python/ONNX parity | max Δ cls 8.1e-6 | PyTorch → ONNX | 4 validation images | VALIDATED | "Python→ONNX 8.1e-6" |
| ML route reproduction (MATLAB) | 4/4 exact | X1C2 | 4 validation images | VALIDATED | "MATLAB reproduced all 4 routes" |
| Simulink scenarios | LOW/BASE/HIGH drained, max queue 0 | Simulink model | 24 h each (1441 steps) | EXECUTED (modeled) | "all scenarios queue-drained" |
| Human-review demand | 33.2/hr | Simulink | annualized 100k | MODELED | "33.2 images/hr into human review (modeled)" |
| Human capacity | 115/hr | Simulink | pools config | MODELED | "modeled capacity 115/hr" |
| Sustainable annual | ~346k/yr | Simulink | annualized from current pools | MODELED CAPACITY | "~346k/yr MODELED CAPACITY" |
| NV positives | 49 / 1842 ≈ 2.7% | FGADR | all | FACT / INSUFFICIENT_DATA | "NV: 2.7% positive images — insufficient for a detector" |
| Grad-CAM | attention on referable logit | APTOS | 4 cases | EXPLANATION ONLY | "classifier attention, not lesion annotation" |

---

# ASSET PACKING LIST (for the deck builder)

| Use | File (relative to `sih26038_v9_0\`) | Shows | Caption |
|---|---|---|---|
| S2 hero | `explainability\X2\X2_EXPLAINABILITY_CASES\case2_referable_good_quality.png` | fundus → Grad-CAM → route (grade 4, REFER) | "Real fundus → attention → human review" |
| S2 report card | `reports\X2\X2_REPORT_EXAMPLES\report_referable_good_quality.txt` | annotated AI-assisted screening report | "AI-assisted screening report (not diagnostic)" |
| S3 pipeline | draw with template shapes | quality → structures → lesions → grading → explainability → MATLAB/Simulink | — |
| S3 lesion overlay | `x3\step4b_fgadr\overlays\case_EX_1091_2_montage.png` | orig/GT/pred/overlay for EX (dice 0.871) | "Lesion-evidence prototype — EX, Dice 0.871" |
| S3 quality dist | `plots\X2\X2_QUALITY_DISTRIBUTION.png` | quality histogram | "Quality-gate heuristic" |
| S4 evidence visual (choose 1) | `x3\step4b_fgadr\overlays\case_SE_0174_2_montage.png` OR `x3\X3_DEMO_CASES\fovea_v2_test_IDRiD_003.png` OR `plots\X2\X2_QUALITY_DISTRIBUTION.png` | lesion evidence / fovea localization / quality distribution | per asset |
| S4 (optional, MATLAB-available only) | capture from `matlab\X2\sih26038_screening_workflow_v9_0.slx` or parity runner | real Simulink/parity screenshot | "Simulink workflow model (rate-based)" |
| S5 workflow | draw with template shapes | PHC/camp → local AI → clinician → district referral | — |
| S6 | none (table only) | references | — |

Verified on disk: X2 explainability strips (845×3120), FGADR montages (1290×1290) + fused evidence (1280×1280), fovea overlays (680×1024), quality distribution (560×896), quality-gate examples (644×644), classical lesion strips (680×3072), X1 ROC (728×700). NOTE: no MATLAB/Simulink PNG screenshot exists yet; capture from the .slx only if MATLAB is available (it is a real project artifact, not fabricated), otherwise use the quality-distribution plot.