"""X3 Step 6: read-only auditor for repository-relative evidence paths.

Scans tracked text evidence for machine-local path leakage (drive-letter roots,
user profile directories, temp/scratch directories) and verifies that every
path recorded in the frozen X2/X3 evidence resolves from a repository-relative
POSIX reference. This script is strictly read-only: it never creates, writes,
truncates, renames, or deletes any evidence artifact. Exit code 0 = clean,
1 = leakage or unresolved reference detected.
"""
import json
import os
import re
import subprocess
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]

TEXT_SUFFIXES = {".md", ".json", ".csv", ".txt", ".py", ".m", ".yml", ".yaml"}
TEXT_NAMES = {".gitignore", ".gitattributes", "LICENSE", "requirements.txt"}
SKIP_DIRS = {".git", "__pycache__", ".venv", "venv", "env", "ENV", "node_modules"}

LEAK_PATTERNS = (
    ("LEAK", "windows_user_profile", re.compile(r"[A-Za-z]:[\\/]Users[\\/][^\\/\s\"'`]+")),
    ("LEAK", "posix_user_profile", re.compile(r"/(?:Users|home)/[^/\s\"'`]+")),
    ("LEAK", "windows_temp_scratch", re.compile(r"[A-Za-z]:[\\/][^\s\"']*?AppData[\\/]")),
    ("LEAK", "windows_tmp", re.compile(r"[A-Za-z]:[\\/]tmp[\\/]")),
    ("LEAK", "posix_tmp", re.compile(r"/(?:tmp|var/tmp|private/tmp)/[^\s\"']+")),
    ("NOTE", "drive_letter_root", re.compile(r"(?:^|[\s\"'`=(,])[A-Za-z]:[\\/](?![\\/])")),
)

PATH_KEYS = frozenset(
    {"abspath", "ckpt", "correct_path", "image", "image_saved", "model", "onnx_path"}
)

EXCLUDED_NAME_TOKENS = ("fgadr",)

CASES_JSON = REPO_ROOT / "explainability" / "X2" / "X2_EXPLAINABILITY_CASES" / "X2_EXPLAINABILITY_CASES.json"
VISUAL_AUDIT_JSON = REPO_ROOT / "x3" / "X3_VISUAL_EVIDENCE_AUDIT.json"
REPORT_DIRS = (
    REPO_ROOT / "reports" / "X2" / "X2_REPORT_EXAMPLES",
    REPO_ROOT / "x3" / "X3_DEMO_CASES",
)
CASE_IMAGES_DIR = "explainability/X2/X2_EXPLAINABILITY_CASES"
EVIDENCE_LINE = re.compile(r"^Evidence image:\s+(\S.*)$")


def rel(path):
    return Path(path).relative_to(REPO_ROOT).as_posix()


def read_text(path):
    return Path(path).read_text(encoding="utf-8", errors="replace")


def is_excluded(path):
    parts = Path(path).as_posix().lower()
    return any(token in parts for token in EXCLUDED_NAME_TOKENS)


def iter_text_files():
    try:
        out = subprocess.run(
            ["git", "-C", str(REPO_ROOT), "ls-files", "-z"],
            capture_output=True, text=True, check=True,
        ).stdout
    except (OSError, subprocess.CalledProcessError):
        out = ""
    if out:
        names = [n for n in out.split("\0") if n]
    else:
        names = [
            p.relative_to(REPO_ROOT).as_posix()
            for p in REPO_ROOT.rglob("*")
            if p.is_file()
            and not is_excluded(p)
            and not any(part in SKIP_DIRS for part in p.relative_to(REPO_ROOT).parts)
        ]
    for name in sorted(names):
        candidate = REPO_ROOT / name
        if is_excluded(candidate) or not candidate.is_file():
            continue
        if candidate.suffix.lower() in TEXT_SUFFIXES or candidate.name in TEXT_NAMES:
            yield candidate


def scan_leakage():
    findings = []
    for path in iter_text_files():
        if Path(path).resolve() == Path(__file__).resolve():
            continue
        for lineno, line in enumerate(read_text(path).splitlines(), 1):
            for severity, label, pattern in LEAK_PATTERNS:
                if pattern.search(line):
                    findings.append((rel(path), lineno, severity, label, line.strip()[:140]))
    return findings


def is_repo_relative(ref):
    if not ref or not isinstance(ref, str):
        return False
    if ref.startswith(("/", "\\")) or re.match(r"^[A-Za-z]:", ref):
        return False
    return "\\" not in ref


def resolves(ref):
    return (REPO_ROOT / ref).exists()


def collect_path_values(node, out):
    if isinstance(node, dict):
        for key, value in node.items():
            if key in PATH_KEYS and isinstance(value, str):
                out.append(value)
            else:
                collect_path_values(value, out)
    elif isinstance(node, list):
        for value in node:
            collect_path_values(value, out)


def audit_json_paths():
    rows = []
    for source in (CASES_JSON, VISUAL_AUDIT_JSON):
        if not source.is_file():
            rows.append((rel(source), "", (False,), "source file missing"))
            continue
        document = json.loads(read_text(source))
        values = []
        collect_path_values(document, values)
        for ref in values:
            ok = is_repo_relative(ref)
            rows.append(
                (
                    rel(source),
                    ref,
                    (ok, resolves(ref)),
                    "" if ok else "not repository-relative POSIX",
                )
            )
    return rows


def audit_evidence_images():
    rows = []
    for directory in REPORT_DIRS:
        if not directory.is_dir():
            rows.append((rel(directory), "", (False,), "report directory missing"))
            continue
        for path in sorted(directory.glob("*.txt")):
            if is_excluded(path):
                continue
            for lineno, line in enumerate(read_text(path).splitlines(), 1):
                match = EVIDENCE_LINE.match(line.strip())
                if not match:
                    continue
                ref = match.group(1).strip()
                ok = is_repo_relative(ref)
                rows.append(
                    (
                        f"{rel(path)}:{lineno}",
                        ref,
                        (ok, resolves(ref)),
                        "" if ok else "not repository-relative POSIX",
                    )
                )
    return rows


def audit_case_asset_names():
    document = json.loads(read_text(CASES_JSON))
    expected = {f"{CASE_IMAGES_DIR}/case{case['case']}_{case['name']}.png" for case in document}
    rows = []
    for case in document:
        ref = case.get("image", "")
        named = ref in expected
        rows.append(
            (
                f"{rel(CASES_JSON)}:case{case.get('case')}",
                ref,
                (named, is_repo_relative(ref), resolves(ref)),
                "" if named else f"name mismatch; expected one of {sorted(expected)}",
            )
        )
    return rows


def report_rows(title, rows):
    print(f"\n{title}")
    if not rows:
        print("  (no path fields found)")
        return 0
    bad = 0
    for where, ref, checks, message in rows:
        ok = all(checks)
        if not ok:
            bad += 1
        print(f"  [{'OK ' if ok else 'BAD'}] {where} -> {ref} {message}".rstrip())
    print(f"  checked={len(rows)} bad={bad}")
    return bad


def main():
    print(f"REPO_ROOT (from __file__): {REPO_ROOT}")
    print("read-only audit: this script opens files for reading only and writes nothing")
    print(f"excluded by name: {', '.join(EXCLUDED_NAME_TOKENS)}")

    findings = scan_leakage()
    leaks = [f for f in findings if f[2] == "LEAK"]
    notes = [f for f in findings if f[2] != "LEAK"]
    print(f"\n1. machine-local path leakage scan: {len(leaks)} leak(s), {len(notes)} advisory")
    for path, lineno, _, label, line in leaks:
        print(f"  LEAK {path}:{lineno} [{label}] {line}")
    for path, lineno, _, label, line in notes:
        print(f"  NOTE {path}:{lineno} [{label}] {line}")
    if not findings:
        print("  none")

    bad = 0
    bad += report_rows("2. JSON path fields (repository-relative + resolvable)", audit_json_paths())
    bad += report_rows("3. report 'Evidence image:' references", audit_evidence_images())
    bad += report_rows("4. explainability case image references", audit_case_asset_names())

    total = len(leaks) + bad
    print(
        f"\nRESULT: {'CLEAN' if total == 0 else f'{total} issue(s)'}"
        f" (leakage={len(leaks)}, bad_refs={bad}, advisory={len(notes)})"
    )
    return 0 if total == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
