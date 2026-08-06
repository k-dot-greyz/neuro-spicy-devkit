#!/usr/bin/env bash
# Offline check: Wave 1 manifest body files exist and list expected issues.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
MANIFEST="${ROOT}/docs/github-issues/wave-1/manifest.yml"

python3 - "$MANIFEST" "$ROOT" <<'PY'
import re, sys, os
manifest, root = sys.argv[1], sys.argv[2]
issues = []
current = None
in_labels = False
for line in open(manifest):
    m_num = re.match(r"\s*- number:\s*(\d+)", line)
    if m_num:
        current = {"number": int(m_num.group(1)), "labels": [], "body_file": ""}
        issues.append(current)
        in_labels = False
        continue
    if re.match(r"\s*labels:\s*$", line):
        in_labels = True
        continue
    m_body = re.match(r"\s*body_file:\s*(.+)", line)
    if m_body and current:
        current["body_file"] = m_body.group(1).strip()
        in_labels = False
        continue
    m_label = re.match(r"\s*-\s+([a-z0-9-]+)\s*$", line)
    if m_label and in_labels and current:
        current["labels"].append(m_label.group(1))

expected = {8, 9, 10, 11, 12, 17}
found = {i["number"] for i in issues}
if found != expected:
    raise SystemExit(f"manifest issue set mismatch: {found} vs {expected}")

for item in issues:
    path = os.path.join(root, item["body_file"])
    if not os.path.isfile(path):
        raise SystemExit(f"missing body: {path}")
    if len(item["labels"]) < 4:
        raise SystemExit(f"#{item['number']}: expected several labels, got {item['labels']}")

print("wave-1 manifest: OK (%d issues)" % len(issues))
PY
