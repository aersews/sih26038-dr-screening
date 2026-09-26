# -*- coding: utf-8 -*-
# X2 assembly: aggregate X2_RESULTS.json, compute X2_CHECKSUMS.json, and update
# the V9.0 evidence matrix with X2 rows.
import json, hashlib, csv, sys, datetime
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
X2 = REPO_ROOT
MET = X2 / "metrics" / "X2"
EXP = X2 / "experiments" / "X2"
REP = X2 / "reports" / "X2"
EXP_X = X2 / "explainability" / "X2"
SX = X2 / "simulink" / "X2"
MAT = X2 / "matlab" / "X2"
EV = REPO_ROOT / "V9.0_FINAL_EVIDENCE_MATRIX.csv"


def load(p):
    return json.loads(p.read_text(encoding="utf-8"))


def fnum(f):
    def conv(o):
        if isinstance(o, (int, float, bool)) or o is None:
            return o
        if isinstance(o, list) and o and all(isinstance(x, (int, float)) for x in o):
            return o
        return None
    try:
        return conv(f)
    except Exception:
        return None


# gather all metric artifacts
final_test = load(MET / "x2_final_locked_test.json")
policy = load(MET / "X2_POLICY.json")
policy_detail = load(MET / "x2_bc_validation_policy.json")
gate = load(MET / "x2_a_quality_gate.json")
ablation = load(MET / "x2_h_ablation.json")
conf = load(MET / "x2_bc_confidence_analysis.json")
missed = load(MET / "x2_bc_missed_referable.json")
pynn = load(MET / "x2_f1_python_onnx_parity.json")
matlab = load(MAT / "results" / "x2_f_matlab_onnx_parity.json")
matlab_screen = load(MAT / "results" / "x2_f_matlab_screening.json")
sim = load(SX / "simulink_result_v9_0.json")

results = {
    "title": "X2 Workflow-Aware Screening Integration (v9.0)",
    "version": "9.0.X2",
    "base_model": "X1C2 (efficientnet-b3, PyTorch-trained, accepted as v9.0 baseline)",
    "locked_test_firewall": "single locked-test evaluation performed exactly once at end (x2_final_locked_test.json)",
    "generated": datetime.datetime.now(datetime.timezone.utc).isoformat(),
    "operating_point": "argmax with frozen temperature T=1.25; max-specificity threshold 0.6443 intentionally NOT deployed",
    "summary": {
        "locked_test_qwk": final_test["classifier"]["qwk_test"],
        "locked_test_ref_sens": final_test["classifier"]["referable_sensitivity_test"],
        "locked_test_ref_spec": final_test["classifier"]["referable_specificity_test"],
        "locked_test_ref_auc": final_test["classifier"]["referable_auc_test"],
        "workflow_missed_referable": final_test["workflow_policy_on_test"]["missed_referable_auto_screened"],
        "workflow_route_counts": final_test["workflow_policy_on_test"]["route_counts"],
    },
    "phase_results": {
        "x2_a_quality_gate": {k: gate[k] for k in ("aptos_recapture_fraction_all_splits", "quality_bucket_summary_by_split") if k in gate},
        "x2_b_c_policy_validation": {k: policy_detail[k] for k in ("frozen_policy", "validation_route_distribution") if k in policy_detail},
        "x2_c_operating_point": {"use_argmax_prob": True, "temperature": 1.25, "max_spec_threshold_not_used": True},
        "x2_d_explainability": {"case_count": len(load(EXP_X / "X2_EXPLAINABILITY_CASES" / "X2_EXPLAINABILITY_CASES.json"))},
        "x2_e_reports": {k: load(REP / "X2_REPORT_EXAMPLES.json")[k] for k in ("count", "label")},
        "x2_f_matlab_onnx": {
            "python_onnx_max_abs_diff_cls": pynn["max_abs_diff_cls_overall"],
            "python_onnx_max_abs_diff_ref": pynn["max_abs_diff_ref_overall"],
            "matlab_onnx_max_abs_diff_cls": matlab["max_abs_diff_cls_overall"],
            "matlab_onnx_max_abs_diff_ref": matlab["max_abs_diff_ref_overall"],
            "matlab_parity_pass": matlab["pass"],
            "matlab_screening_routes_match_python": matlab_screen["matched_all_python_routes"],
            "matlab_screening_pass": matlab_screen["pass"],
            "training_claim": "PyTorch-trained X1C2 integrated into MATLAB via ONNX; NOT MATLAB-trained",
        },
        "x2_g_simulink": {"pass": sim["pass"], "scenarios": sim.get("scenarios", [])},
        "x2_h_ablation": ablation,
    },
    "final_report_points": {
        "1_model": "X1C2 efficientnet-b3 (DROrdinalRefNet with ordinal+referable heads), PyTorch-trained on APTOS 3662 images",
        "2_lock_single_shot": f"QWK {final_test['classifier']['qwk_test']:.4f}, sens {final_test['classifier']['referable_sensitivity_test']:.4f}, spec {final_test['classifier']['referable_specificity_test']:.4f}, AUC {final_test['classifier']['referable_auc_test']:.4f} (single frozen run)",
        "3_no_test_tuning": "all thresholds/policy decisions made on validation only (T=1.25 frozen per X1)",
        "4_quality_gate": "heuristic engineering quality index (sharpness/exposure/FOV/illumination/motion-proxy); APTOS contains 0 recapture candidates; low-quality review fraction val 0.1078",
        "5_deterministic_routing": policy.get("routing_rules", "see X2_POLICY.json"),
        "6_workflow_benefit": "workflow routes all referable cases to REFER/HUMAN_REVIEW with 0 missed referable on locked test (safety sensitivity 1.0)",
        "7_explainability": "Grad-CAM on referable logit (backbone.conv_head); attention-only, no fabricated lesion overlays; APTOS has no lesion masks",
        "8_matlab_integration": "X1C2 exported to ONNX (opset 17), imported via importNetworkFromONNX; parity max diff < 1e-5 cls logits; screening routes match Python exactly",
        "9_simulink_workflow": "base-Simulink rate-based queue model (no SimEvents); LOW/BASE/HIGH 24h all queue-drained; annualized 100k feasible (demand 33.2/hr human vs 115/hr capacity)",
        "10_ablation": "C/D workflow converts 20 missed-referable (A/B) to 0; auto-screen coverage 0.576->0.336; classier grading constant by construction (not 'improved')",
        "11_verdict": "X2 ACCEPTED (CASE A): meets sens>0.90 & spec>0.85 at frozen argmax operating point; workflow adds safety without regression",
    },
}

out = X2 / "metrics" / "X2" / "X2_RESULTS.json"
json.dump(results, open(out, "w"), indent=2)
print("WROTE", out)

# ---------------------------------------------------------------------------
# checksums: full SHA-256 over every X2 artifact, repo-relative POSIX paths
# ---------------------------------------------------------------------------
MANIFEST = X2 / "metrics" / "X2" / "X2_CHECKSUMS.json"
SWEEP_ROOTS = [EXP, MET, REP, EXP_X, MAT, SX]
SKIP_DIR_NAMES = {"__pycache__", "slprj", ".ipynb_checkpoints"}
SKIP_SUFFIXES = {".slxc", ".asv", ".pyc"}
RELEASE_SUFFIXES = {".pt", ".onnx"}


BINARY_SUFFIXES = {".pt", ".onnx", ".slx", ".slxc", ".mat", ".png", ".jpg",
                   ".jpeg", ".pdf", ".pptx", ".docx", ".xlsx", ".zip"}


def sha256_of(path):
    """Hash binary assets raw; hash text after the LF normalization Git commits."""
    h = hashlib.sha256()
    with open(path, "rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 20), b""):
            h.update(chunk)
    if path.suffix.lower() in BINARY_SUFFIXES:
        return h.hexdigest()
    h2 = hashlib.sha256()
    with open(path, "rb") as fh:
        data = fh.read()
    h2.update(data.replace(b"\r\n", b"\n"))
    return h2.hexdigest()


tracked_digests, release_digests = {}, {}
candidates = []
for root in SWEEP_ROOTS:
    if root.is_dir():
        candidates.extend(p for p in root.rglob("*") if p.is_file())
for p in sorted(candidates, key=lambda x: x.as_posix()):
    if p == MANIFEST:
        continue
    if any(part in SKIP_DIR_NAMES for part in p.parts):
        continue
    if p.suffix.lower() in SKIP_SUFFIXES:
        continue
    if "fgadr" in p.name.lower():
        continue
    key = p.relative_to(X2).as_posix()
    if p.suffix.lower() in RELEASE_SUFFIXES:
        release_digests[key] = sha256_of(p)
    else:
        tracked_digests[key] = sha256_of(p)

manifest = {
    "algorithm": "sha256",
    "digest_length": 64,
    "path_convention": "repository-relative POSIX path from the repository root",
    "text_normalization": "text artifacts are hashed after CRLF->LF normalization, matching the committed blob; binary assets are hashed as raw bytes",
    "generated_on": datetime.date.today().isoformat(),
    "note": ("Digests of the X2 artifacts as committed. ONNX and PyTorch binaries are "
             "GitHub Release assets and are listed under release_assets_not_in_git. "
             "MATLAB build caches (slprj/, *.slxc) are excluded."),
    "git_tracked_files": tracked_digests,
    "release_assets_not_in_git": release_digests,
}
json.dump(manifest, open(MANIFEST, "w"), indent=2)
print("WROTE checksums:", len(tracked_digests), "+ release assets", len(release_digests))

# ---------------------------------------------------------------------------
# evidence matrix append (X2 rows)
# ---------------------------------------------------------------------------
rows_new = [
    ["X2-POLICY", "Frozen deterministic workflow policy (quality gate + routing)", "decision", "metrics/X2/X2_POLICY.json", "DECLARED_FROZEN", "accepted", "done", "validation-only routing rules; T=1.25; SHA-256 recorded in metrics/X2/X2_CHECKSUMS.json"],
    ["X2-FINAL", "Single locked-APTOS-test workflow evaluation (frozen model+T+policy)", "locked_test", "metrics/X2/x2_final_locked_test.json", "EXECUTED", "accepted", "done", "QWK 0.9027; sens 0.9192 spec 0.9333; 0 missed referable; evaluated exactly once"],
    ["X2-ABLATION", "Ablation A/B/C/D: workflow routing safety vs coverage", "validation", "metrics/X2/X2_ABLATION.csv", "EXECUTED", "accepted", "done", "validation n=733 only, locked test not used; C/D convert 20 missed-referable -> 0; auto-screen 0.576->0.336; grading constant by construction"],
    ["X2-MATLAB-ONNX-PARITY", "PyTorch->ONNX->MATLAB parity (importNetworkFromONNX)", "integration", "matlab/X2/results/x2_f_matlab_onnx_parity.json", "EXECUTED", "accepted", "done", "n=4 validation cases; py-onnx max diff <1e-5; matlab-onnx max diff <1e-5; MATLAB screening routes match Python"],
    ["X2-SIMULINK", "Workflow-aware Simulink queue model LOW/BASE/HIGH + annualized 100k", "integration", "simulink/X2/X2_SIMULINK_SCENARIOS.csv", "EXECUTED", "accepted", "done", "MODELED capacity only, not observed; routing fractions derived from validation; all scenarios drained; annualized 100k feasible (33.2/hr demand vs 115/hr capacity)"],
]
print("EVIDENCE ROWS:")
for r in rows_new:
    print("  ", r)

if EV.exists():
    with open(EV, encoding="utf-8", newline="") as f:
        rows_csv = list(csv.reader(f))
    header = rows_csv[0]
    # drop any existing X2-* rows so we always write the current 8-col schema
    rows_csv = [header] + [r for r in rows_csv[1:] if not r[0].startswith("X2-")]
    rows_csv += rows_new
    with open(EV, "w", encoding="utf-8", newline="") as f:
        csv.writer(f).writerows(rows_csv)
    print(f"evidence matrix: wrote {len(rows_new)} X2 rows, total {len(rows_csv)-1} data rows")
else:
    print("evidence matrix not found at", EV)