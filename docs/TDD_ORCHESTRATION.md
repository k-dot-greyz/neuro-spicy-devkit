# TDD orchestration — Neuro-Spicy DevKit

This repo treats **bash libraries + scripts** as the product. TDD here means: **behavior tests first**, then the smallest `scripts/lib/*.sh` change to go green.

## Iron law

No new behavior in `scripts/*.sh` without a failing test in `tests/unit/` or `tests/integration/` first.

## Layout

```text
tests/
  run.sh                 # orchestrator (exit 0 = all green)
  lib/assert.sh          # tiny assertions (no external test framework)
  unit/                  # fast, offline
  integration/           # script + env contracts
scripts/lib/
  ns-exit-codes.sh       # 0/1/2/3 contract
  ns-version.sh          # semver satisfy checks for profiles
  ns-cli.sh              # --verbose, --quiet, --non-interactive
scripts/test-integration.sh  # existing smoke (network optional)
```

## Red → green → refactor loop

1. **RED** — Add one case to the relevant `tests/unit/test_*.sh`. Run `./tests/run.sh` and confirm the new case fails for the *right* reason.
2. **GREEN** — Implement the minimum in `scripts/lib/`. Re-run until that file’s tests pass.
3. **REFACTOR** — Deduplicate; keep tests green. Run `shellcheck` on touched scripts.

## CI alignment

`.github/workflows/ci.yml` runs:

- shellcheck + shfmt
- `./tests/run.sh`
- `./scripts/test-integration.sh` (skips network-heavy cases when offline where possible)

## Exit code contract (epic)

| Code | Meaning |
|------|---------|
| `0` | Success |
| `1` | General error |
| `2` | Missing dependency |
| `3` | Configuration error |

Scripts should `source` `scripts/lib/ns-exit-codes.sh` and use `NS_EXIT_*` constants instead of magic numbers.

## Next slices (after Phase 1)

1. Source libs from `health-check-core.sh`; map failed **required** checks to `NS_EXIT_MISSING_DEP`.
2. `ns-profile.sh` — read `portable-dev-env/profiles/templates/*.json` requirements.
3. `ns-resolver.sh` — `detect → plan → install → verify` with `--dry-run` only in tests until installers are hardened.

Track checklist status in [tasks.md](../tasks.md).
