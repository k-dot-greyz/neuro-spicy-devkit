# Epic #20 — CLI-first TDD backlog (bash / zsh / fish)

## Product focus

The DevKit product surface for the next waves is a **shell CLI**, not a language-runtime installer farm.

| Layer | Role | Shells |
|-------|------|--------|
| **Engine** | Scripts + `scripts/lib/*.sh` — detect, plan, setup, doctor, exit codes | **bash** (CI + shebang runtime; shellcheck + shfmt) |
| **Interactive UX** | Aliases, functions, completions, `PATH` wrappers | **bash**, **zsh**, **fish** (adapters; fish never sources bash) |
| **Parity (deferred)** | PowerShell twins | `*.ps1` — after CLI shell triad is green |

Prefer **POSIX-friendly** constructs in new lib code when they do not fight clarity. Bash arrays / `[[ ]]` are allowed in the engine; document bash **≥ 4** as the supported runtime. Do not claim “pure POSIX sh” for libs that already use bash arrays (`ns-cli.sh`).

## Guiding user story (MVP)

**As a** neuro-spicy developer on a fresh machine (bash, zsh, or fish),  
**I want** a small CLI (`check` → `setup` → `doctor`) with predictable flags and exit codes,  
**So that** agents and humans can automate bring-up from the terminal without guessing from log prose.

### MVP UX flow

1. `bash scripts/health-check-core.sh [--verbose|--quiet|--json]` — detect stack + secrets; summary always prints; exit `2` / `3` per contract.
2. `bash scripts/neuro-spicy-setup-core.sh --profile frontend-developer --dry-run --non-interactive` — print planned installs from profile JSON.
3. Interactive shells load matching adapters:
   - bash/zsh: `portable-dev-env/shell/aliases.sh` (+ completions)
   - fish: `portable-dev-env/shell/aliases.fish` (or `conf.d/neuro-spicy.fish`)
4. `./tests/run.sh` — unit + offline integration gates before merge.

Primary commands (aliases / thin wrappers → bash engine):

| Command | Meaning |
|---------|---------|
| `check` | health detect + summary |
| `setup` | profile-driven setup (honor `--dry-run`) |
| `doctor` | deep diagnostic (deps + configs + connectivity) |
| `lint` / `fmt` | polyglot formatters via shell entrypoints |
| `push` | `git-push-retry.sh` |
| `nuke` | clean build artifacts/caches |

## TDD phases (red → green → refactor)

| Phase | Focus | Test target | Production target |
|-------|--------|-------------|-------------------|
| **0** | Harness | `tests/run.sh`, `tests/lib/assert.sh` | CI job `unit-tests` |
| **1** | Contracts | `tests/unit/test_ns_exit_codes.sh` | `scripts/lib/ns-exit-codes.sh` |
| **1** | Semver | `tests/unit/test_ns_version.sh` | `scripts/lib/ns-version.sh` |
| **1** | CLI flags | `tests/unit/test_ns_cli.sh` | `scripts/lib/ns-cli.sh` |
| **2** | Profile deps | `tests/unit/test_ns_profile.sh` | `scripts/lib/ns-profile.sh` |
| **2** | Health exit codes | `tests/integration/test_health_exit.sh` | `health-check-core.sh` sources libs |
| **3** | Install resolver (dry-run) | `tests/unit/test_ns_resolver.sh` | `scripts/lib/ns-resolver.sh` |
| **3b** | CLI entry + help | `tests/unit/test_ns_entry.sh`, help smoke | `scripts/ns` or `bin/ns` dispatcher → bash libs |
| **4** | Shell adapters | bash/zsh source smoke; fish syntax check | `aliases.sh`, `aliases.fish`, completions |
| **4b** | Alias contract | `tests/integration/test_cli_aliases.sh` | `check`/`setup`/`doctor` map to scripts |
| **5** | Sanitize unsafe IO | issue-linked tests (#8–#12) | bash init/install paths (no `curl\|bash`) |
| **6** | PowerShell parity | Pester or matrix (deferred) | `*.ps1` twins — **not** blocking CLI MVP |

Phases **0–2** are largely landed on the TDD branch. Next implementation slices: **3 → 3b → 4 → 4b → 5**, then epic installers.

## Swarm mapping (see also `docs/SWARM_ORCHESTRATION.md`)

| Wave | Parallel lanes | Blocked on |
|------|----------------|------------|
| **0** | Merge #21 + #22 | — |
| **1** | Sanitize bash IO (#8/#12) parallel with Docker (#11); PS1 (#9/#10/#17) optional side lane | Wave 0 |
| **2** | Resolver dry-run parallel with `ns` CLI entry + flag help parallel with shell adapters (bash/zsh/fish) | Wave 0; real installs wait for #8 |
| **3** | Alias/integration contracts parallel with `doctor` CLI | Wave 2 dry-run + adapters |
| **4** | Epic language installers (profile columns) | Wave 1 sanitize + Wave 2 resolver |

## Epic checklist mapping (CLI-shaped)

- **Exit code standardization** → Phase 1 + Phase 2 health wiring.
- **`--verbose` / `--quiet` / `--non-interactive` / `--dry-run`** → Phase 1 `ns-cli` + Phase 3 resolver + Phase 3b entry.
- **Profile-driven config** → Phase 2 `ns-profile.sh`.
- **Shell aliases & shortcuts** → Phase 4 / 4b (bash + zsh + fish).
- **CI hygiene** → Phase 0 + shellcheck/shfmt; add fish `fish -n` when adapters land.
- **Hardened installs / MCP / Rust…** → after Phase 5 sanitize; planner-only until then.
- **PowerShell** → Phase 6 deferred; do not parallel-edit PS1 on the CLI critical path unless Wave 1 security lane.

## Run locally

```bash
./tests/run.sh                    # unit + offline integration (fast)
./scripts/test-integration.sh     # network + script smoke
shellcheck scripts/*.sh scripts/lib/*.sh
```

Fish adapter smoke (when Phase 4 lands):

```fish
fish -n portable-dev-env/shell/aliases.fish
```

See [docs/TDD_ORCHESTRATION.md](docs/TDD_ORCHESTRATION.md), [docs/SWARM_ORCHESTRATION.md](docs/SWARM_ORCHESTRATION.md), and **[docs/CLI_IMPLEMENTATION_SCAFFOLD.md](docs/CLI_IMPLEMENTATION_SCAFFOLD.md)** (rehydrated plan + execution + file map).
