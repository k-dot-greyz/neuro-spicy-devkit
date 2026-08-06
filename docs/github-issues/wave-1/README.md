# Wave 1 — sanitize IO (GitHub issue hydration)

Pre-filled bodies and labels for issues **#8, #9, #10, #11, #12, #17**. Apply after merge train **Wave 0** (#21, #22) or from train head if stacking sanitize work.

Procedure: [LABELS_AND_LINKING.md](../LABELS_AND_LINKING.md) · Swarm lanes: [WAVE_1_SANITIZE.md](../WAVE_1_SANITIZE.md)

## Apply (human or local `gh` with write access)

```bash
# 1) Sync labels from canonical list (needs maintainer token)
./scripts/github-apply-issue-metadata.sh --sync-labels

# 2) Apply Wave 1 bodies + labels
./scripts/github-apply-issue-metadata.sh --manifest docs/github-issues/wave-1/manifest.yml

# Dry-run
./scripts/github-apply-issue-metadata.sh --manifest docs/github-issues/wave-1/manifest.yml --dry-run
```

## Files

| Issue | Body file | Primary lane |
|-------|-----------|--------------|
| #8 | [issue-8.md](issue-8.md) | lane-bash |
| #9 | [issue-9.md](issue-9.md) | lane-powershell |
| #10 | [issue-10.md](issue-10.md) | lane-powershell |
| #11 | [issue-11.md](issue-11.md) | lane-docker |
| #12 | [issue-12.md](issue-12.md) | lane-bash |
| #17 | [issue-17.md](issue-17.md) | bash + powershell (coordinate with #9) |

Labels are listed in [manifest.yml](manifest.yml).

## Paste on Epic #20 (optional)

After applying, add a comment on #20 linking Wave 1 children — see [epic-20-wave-1-comment.md](epic-20-wave-1-comment.md).
