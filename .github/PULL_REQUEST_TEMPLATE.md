## What does this PR do?

<!-- One-liner. What changed and why? -->

## Changes

<!-- Bullet list of what you changed. Keep it brief. -->

-

## Checklist

- [ ] `bash -n scripts/*.sh init.sh` — syntax passes
- [ ] `shellcheck scripts/*.sh init.sh` — no new errors
- [ ] `shfmt -d -i 4 -ci scripts/*.sh init.sh` — formatting clean (or intentional)
- [ ] `bash scripts/test-integration.sh` — 18/18 pass
- [ ] `jq empty` on any changed JSON files
- [ ] New scripts support `--help` and `--dry-run`
- [ ] No hardcoded versions (use latest/LTS/caret ranges)
- [ ] No credentials in code (use `~/.config/neuro-spicy/credentials`)
- [ ] Updated `CHANGELOG.md` if user-facing

## Related issues

<!-- Closes #XX, Fixes #XX, Part of #XX -->

## Screenshots / logs

<!-- Optional. Paste health check output, test results, or screenshots. -->
