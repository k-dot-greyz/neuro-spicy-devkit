# TDD orchestration — Neuro-Spicy DevKit (CLI / shell)

This repo treats the **shell CLI** as the product: bash libraries + scripts as the **engine**, with **bash / zsh / fish** interactive adapters. TDD means: **behavior tests first**, then the smallest `scripts/lib/*.sh` (or adapter) change to go green.

## Iron law

No new behavior in `scripts/*.sh`, `scripts/lib/*.sh`, or shell adapters without a failing test in `tests/unit/` or `tests/integration/` first.

## CLI architecture

```text
Interactive shells                    Engine (always bash)
─────────────────                     ────────────────────
bash:  source aliases.sh       ──┐
zsh:   source aliases.sh       ──┼──► scripts/*.sh  +  scripts/lib/ns-*.sh
fish:  source aliases.fish     ──┘         │
       (completions per shell)             ▼
                                    exit 0/1/2/3 + structured flags
```

Rules:

1. **Engine = bash.** Shebangs are `#!/usr/bin/env bash`. CI runs scripts under bash. Prefer POSIX-friendly code; bash ≥ 4 features OK when documented.
2. **Fish never sources bash.** Fish gets its own `aliases.fish` / functions that *invoke* the bash engine (`bash "$NS_ROOT/scripts/..."`).
3. **zsh prefers the bash adapter** for aliases that are zsh-compatible; add `completions.zsh` separately when needed.
4. **PowerShell is deferred parity** (Phase 6 in `tasks.md`), not part of the CLI MVP critical path.
5. **No real remote installs in unit tests.** Resolver tests use `--dry-run` until sanitize issues (#8+) are green.

## Layout

```text
tests/
  run.sh                 # orchestrator (exit 0 = all green)
  lib/assert.sh          # tiny assertions (no external test framework)
  unit/                  # fast, offline (bash)
  integration/           # script + CLI contracts
scripts/
  lib/
    ns-exit-codes.sh     # 0/1/2/3 contract
    ns-version.sh        # semver satisfy checks for profiles
    ns-cli.sh            # --verbose, --quiet, --non-interactive
    ns-profile.sh        # profile requirements
    ns-resolver.sh       # detect → plan → install (--dry-run first)
  ns                     # (Phase 3b) optional dispatcher: check|setup|doctor
portable-dev-env/shell/
  aliases.sh             # bash + zsh interactive shortcuts
  aliases.fish           # fish interactive shortcuts (Phase 4)
  completions.*          # optional per-shell completions
```

## Red → green → refactor loop

1. **RED** — Add one case to the relevant `tests/unit/test_*.sh` (or integration). Run `./tests/run.sh` and confirm failure for the *right* reason.
2. **GREEN** — Implement the minimum in `scripts/lib/` or the shell adapter. Re-run until that file’s tests pass.
3. **REFACTOR** — Deduplicate; keep tests green. Run `shellcheck` on touched bash; `fish -n` on fish files.

## Standardized CLI flags

All user-facing bash entrypoints should accept (via `ns_cli_parse` or equivalent):

| Flag | Meaning |
|------|---------|
| `--verbose` / `-v` | Extra diagnostics on stderr |
| `--quiet` / `-q` | Suppress non-essential stdout |
| `--non-interactive` / `-y` | No prompts; fail closed if input required |
| `--dry-run` | Plan only (setup/resolver) |
| `--help` / `-h` | Usage; exit 0 |

## Exit code contract (epic)

| Code | Meaning |
|------|---------|
| `0` | Success |
| `1` | General error |
| `2` | Missing dependency |
| `3` | Configuration error |

Scripts should `source` `scripts/lib/ns-exit-codes.sh` and use `NS_EXIT_*` constants instead of magic numbers.

## CI alignment

`.github/workflows/ci.yml` runs:

- shellcheck + shfmt (bash engine)
- `./tests/run.sh`
- `./scripts/test-integration.sh` (skips network-heavy cases when offline where possible)
- After Phase 4: `fish -n` on fish adapters when `fish` is available in the runner

## Next slices (CLI order)

1. `ns-resolver.sh` — `detect → plan → install → verify` with `--dry-run` only in tests until installers are hardened.
2. Thin `scripts/ns` (or `bin/ns`) dispatcher: `ns check|setup|doctor` → existing scripts; keep aliases as sugar.
3. Fish + zsh adapter parity for the MVP command set; alias contract tests.
4. Sanitize bash install IO (#8, #12) before any non-dry-run resolver path.

Track checklist status in [tasks.md](../tasks.md). Swarm parallelization: [SWARM_ORCHESTRATION.md](SWARM_ORCHESTRATION.md).
