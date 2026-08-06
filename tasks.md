# Epic #20 — TDD implementation backlog

Issue/PR labels, merge train, and linking: [docs/LABELS_AND_LINKING.md](docs/LABELS_AND_LINKING.md).

## Guiding user story (MVP)

**As a** neuro-spicy developer on a fresh machine,  
**I want** `check` → `setup` → `doctor` to detect my stack, install only what my profile needs, and exit with predictable codes,  
**So that** agents and CI can automate environment bring-up without guessing from log prose.

### MVP UX flow

1. `bash scripts/health-check-core.sh [--fix]` — detect stack + secrets; summary always prints; exit `2` if required deps missing.
2. `bash scripts/neuro-spicy-setup-core.sh --profile frontend-developer --dry-run` — show planned installs from profile JSON.
3. `bash tests/run.sh` — unit + integration gates before merge.

## TDD phases (red → green → refactor)

| Phase | Focus | Test target | Production target |
|-------|--------|-------------|-------------------|
| **0** | Harness | `tests/run.sh`, `tests/lib/assert.sh` | CI job `unit-tests` |
| **1** | Contracts | `tests/unit/test_ns_exit_codes.sh` | `scripts/lib/ns-exit-codes.sh` |
| **1** | Semver | `tests/unit/test_ns_version.sh` | `scripts/lib/ns-version.sh` |
| **1** | CLI flags | `tests/unit/test_ns_cli.sh` | `scripts/lib/ns-cli.sh` |
| **2** | Profile deps | `tests/unit/test_ns_profile.sh` | `scripts/lib/ns-profile.sh` |
| **2** | Health exit codes | `tests/integration/test_health_exit.sh` | `health-check-core.sh` sources libs |
| **3** | Install resolver | `tests/unit/test_ns_resolver.sh` | `scripts/lib/ns-resolver.sh` (`--dry-run`) |
| **4** | MCP + aliases | extend integration | profiles + `aliases.sh` |
| **5** | PowerShell parity | Pester or bash parity matrix | `*.ps1` twins |

## Epic checklist mapping

- **Exit code standardization** → Phase 1 (`ns-exit-codes.sh`) + Phase 2 health wiring.
- **`--dry-run` / `--non-interactive`** → Phase 1 CLI lib + setup resolver Phase 3.
- **Profile-driven config** → Phase 2 `ns-profile.sh`.
- **CI hygiene** → Phase 0 CI + existing shellcheck/shfmt.
- **Shell aliases** → shipped in `portable-dev-env/shell/aliases.sh`; add alias contract tests in Phase 4.

## Run locally

```bash
./tests/run.sh              # unit tests (fast)
./scripts/test-integration.sh   # network + script smoke
```

See [docs/TDD_ORCHESTRATION.md](docs/TDD_ORCHESTRATION.md) for the full red-green-refactor loop.
