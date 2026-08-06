#!/usr/bin/env bash
# Apply GitHub issue labels and bodies from a manifest (requires gh auth with issue write).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO="${GITHUB_REPOSITORY:-k-dot-greyz/neuro-spicy-devkit}"
DRY_RUN=0
SYNC_LABELS=0
MANIFEST=""

usage() {
    cat <<EOF
Usage: $0 [--sync-labels] [--manifest PATH] [--dry-run] [--repo OWNER/NAME]

  --sync-labels   Create/update labels from .github/labels.yml (gh label create --force)
  --manifest      YAML manifest with issues[].number, labels[], body_file
  --dry-run       Print actions without calling GitHub
  --repo          Default: k-dot-greyz/neuro-spicy-devkit
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --sync-labels) SYNC_LABELS=1 ;;
        --manifest) MANIFEST="${2:-}"; shift ;;
        --dry-run) DRY_RUN=1 ;;
        --repo) REPO="${2:-}"; shift ;;
        -h | --help) usage; exit 0 ;;
        *) echo "Unknown option: $1" >&2; usage; exit 1 ;;
    esac
    shift
done

if ! command -v gh >/dev/null 2>&1; then
    echo "gh CLI is required" >&2
    exit 1
fi

sync_labels_from_yaml() {
    local labels_file="${ROOT}/.github/labels.yml"
    if [[ ! -f "$labels_file" ]]; then
        echo "Missing $labels_file" >&2
        exit 1
    fi
    python3 - "$labels_file" "$REPO" "$DRY_RUN" <<'PY'
import re, subprocess, sys
labels_file, repo, dry = sys.argv[1], sys.argv[2], int(sys.argv[3])
text = open(labels_file).read()
blocks = re.split(r"\n- name:", text)
for b in blocks[1:]:
    m_name = re.match(r"\s*(\S+)", b)
    m_color = re.search(r"color:\s*(\S+)", b)
    m_desc = re.search(r"description:\s*(.+)", b)
    if not m_name or not m_color:
        continue
    name, color = m_name.group(1), m_color.group(1)
    desc = m_desc.group(1).strip() if m_desc else ""
    cmd = [
        "gh", "label", "create", name,
        "--repo", repo, "--color", color, "--description", desc, "--force",
    ]
    if dry:
        print("[dry-run]", " ".join(cmd))
    else:
        subprocess.run(cmd, check=True)
print("Labels synced from", labels_file)
PY
}

apply_manifest() {
    local manifest_path="$1"
    if [[ ! -f "$manifest_path" ]]; then
        echo "Missing manifest: $manifest_path" >&2
        exit 1
    fi
    python3 - "$ROOT" "$manifest_path" "$REPO" "$DRY_RUN" <<'PY'
import re, subprocess, sys, os

root, manifest, repo, dry = sys.argv[1], sys.argv[2], sys.argv[3], int(sys.argv[4])
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

def run(cmd):
    if dry:
        print("[dry-run]", " ".join(cmd))
        return
    subprocess.run(cmd, check=True)

for item in issues:
    num = item["number"]
    body_rel = item.get("body_file", "")
    body_path = os.path.join(root, body_rel) if not os.path.isabs(body_rel) else body_rel
    if not os.path.isfile(body_path):
        raise SystemExit(f"Missing body file for #{num}: {body_path}")
    labels = item.get("labels", [])
    print(f"Updating issue #{num} ({len(labels)} labels)")
    run(["gh", "issue", "edit", str(num), "--repo", repo, "--body-file", body_path])
    if labels:
        run(["gh", "issue", "edit", str(num), "--repo", repo, "--add-label", ",".join(labels)])
PY
}

if [[ "$SYNC_LABELS" -eq 1 ]]; then
    sync_labels_from_yaml
fi

if [[ -n "$MANIFEST" ]]; then
    if [[ ! "$MANIFEST" = /* ]]; then
        MANIFEST="${ROOT}/${MANIFEST}"
    fi
    apply_manifest "$MANIFEST"
fi

if [[ "$SYNC_LABELS" -eq 0 && -z "$MANIFEST" ]]; then
    usage
    exit 1
fi

echo "Done."
