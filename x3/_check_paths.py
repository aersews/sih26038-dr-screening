import os, re, json
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
for p in [
    REPO_ROOT / "metrics" / "X2" / "X2_RESULTS.json",
    REPO_ROOT / "reports" / "X2" / "X2_REPORT_EXAMPLES.json",
]:
    t = open(p, encoding="utf-8").read()
    olds = set(re.findall(r"[\w\:\\/\.]*explainability[\w\:\\/\.]*", t))
    print("=====", os.path.basename(p))
    for o in sorted(olds):
        print("  ", o, "exists=", os.path.exists(o.replace("\\\\", "\\")))