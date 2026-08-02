# Cursor Skills — Implementation Plan

## Goal

Create a set of reusable, transferable Cursor skills for the Neuro-Spicy DevKit that:
- Work as SOPs for both human devs and AI agents
- Transfer to other repos/CLIs with minimal adaptation (parameterized, not hardcoded)
- Are reference-hydrated (point to actual files, commands, configs — not hypothetical scripts)
- Follow the skill file format that Cursor Cloud agents read at task time

## Architecture

```text
.cursor/
  skills/
    dev-environment-bootstrap.md    # Skill 1
    shell-script-development.md     # Skill 2
    secure-credential-management.md # Skill 3
    docker-hardened-deployment.md   # Skill 4
    health-check-diagnostics.md     # Skill 5
    git-workflow-ci.md              # Skill 6
```

Each skill is a standalone markdown file with:
- **When to use** — trigger conditions
- **Prerequisites** — what must exist before starting
- **Steps** — ordered procedure with actual commands
- **Validation** — how to verify success
- **Troubleshooting** — common failures and fixes
- **Transferability notes** — what to change for other repos

## Skill Inventory

### Skill 1: Dev Environment Bootstrap

**When:** First clone, new machine, cloud agent cold boot, or `health-check-core.sh` reports failures.

**Covers:**
- System deps detection (git, node, python, rust)
- Tool installation (shellcheck, shfmt, jq, tree)
- Secret hydration (GITHUB_TOKEN, AI provider keys, SSH)
- Editor setup (Cursor, VSCode, OpenClaw)
- Shell aliases sourcing
- Validation via `test-integration.sh`

**Key references:**
- `scripts/health-check-core.sh --fix` (detect + suggest)
- `scripts/setup-github-token.sh` (credential setup)
- `portable-dev-env/shell/aliases.sh` (shell shortcuts)
- `CONTRIBUTING.md` (code standards)

**Transferability:** Parameterize the tool list and install commands. The pattern (detect → install → verify) transfers to any stack — only the tool names change.

---

### Skill 2: Shell Script Development

**When:** Writing, modifying, or reviewing any `.sh` or `.ps1` file in the repo.

**Covers:**
- Script template (shebang, `set -euo pipefail`, colors, arg parsing, `--help`, `--dry-run`)
- Lint workflow (`shellcheck` → `shfmt` → `bash -n`)
- Testing strategy (integration tests, --help/--dry-run smoke tests)
- Common pitfalls (`set -e` + arithmetic, `eval` injection, `try-catch` in PowerShell)
- Cross-platform parity checklist (bash ↔ PowerShell)

**Key references:**
- `.shellcheckrc` (lint config)
- `.editorconfig` (formatting rules)
- `scripts/git-push-retry.sh` (reference implementation — arg parsing, arrays, retry loop)
- `scripts/test-integration.sh` (how to add test cases)
- `CONTRIBUTING.md` → Shell scripts section

**Transferability:** The template and lint workflow transfer to any bash-heavy repo. Swap `.shellcheckrc` settings and `shfmt` flags as needed.

---

### Skill 3: Secure Credential Management

**When:** Any task involving tokens, API keys, passwords, or secret material.

**Covers:**
- Storage: `~/.config/neuro-spicy/credentials` (chmod 600, umask 077)
- Shell wiring: conditional source from `~/.bashrc` / `~/.zshrc`
- PowerShell: ACL-restricted profile creds file, `ZeroFreeBSTR` for SecureString
- Detection: `health-check-core.sh` → `test_secrets()` function
- Anti-patterns: never `eval` user input, never write tokens to `.bashrc` directly, never embed in JSON
- `.gitignore` patterns for secret files

**Key references:**
- `scripts/setup-github-token.sh` (bash reference implementation)
- `scripts/setup-github-token.ps1` (PowerShell reference implementation)
- `scripts/neuro-spicy-init.sh` lines 250-265 (creds file write pattern)
- `.gitignore` → `.env.*` patterns
- `SECURITY.md` (vuln reporting)

**Transferability:** The `umask 077` + dedicated creds file pattern works for any CLI tool that needs persistent secrets. The PowerShell ACL pattern is Windows-universal.

---

### Skill 4: Docker Hardened Deployment

**When:** Building, deploying, or modifying the OpenClaw Docker image or any containerized service.

**Covers:**
- Multi-stage builds (builder → production)
- Non-root user (UID 1001, `adduser -S`)
- Read-only rootfs + tmpfs for writable dirs
- Capability dropping (`cap_drop: ALL`, `cap_add: NET_BIND_SERVICE`)
- Init system (tini, not dumb-init, not bare node)
- Resource limits (memory, CPU, PIDs)
- Localhost-only port binding
- Health checks (`HEALTHCHECK` directive + compose)
- Entrypoint pattern (config init, env detection, `exec "$@"`)
- BusyBox Alpine gotchas (`cp -n` doesn't exist, use `apk` not `apt`)

**Key references:**
- `portable-dev-env/openclaw/docker/Dockerfile` (reference implementation)
- `portable-dev-env/openclaw/docker/docker-compose.yml` (security posture)
- `portable-dev-env/openclaw/docker/docker-entrypoint.sh` (init pattern)
- `portable-dev-env/openclaw/docker/.env.example` (secret template)

**Transferability:** The security posture table and Dockerfile patterns are container-universal. Swap the base image and installed packages for any Node/Python/Rust service.

---

### Skill 5: Health Check & Diagnostics

**When:** Environment validation fails, CI breaks, or a new tool/check needs to be added.

**Covers:**
- Adding a new check to `health-check-core.sh` (function template, `--fix` hints, `set -e` safety)
- Adding a new test to `test-integration.sh` (assertion pattern)
- Reading health check output (pass/fail/skip semantics)
- The `set -e` + `(())` arithmetic trap (use `$((x + 1))` always)
- Wrapping function calls in `if/else` for `set -e` compatibility

**Key references:**
- `scripts/health-check-core.sh` → `test_rust()` as template for new checks
- `scripts/test-integration.sh` → `log_test` / `log_pass` / `log_fail` pattern
- `AGENTS.md` → Gotchas section

**Transferability:** The detect → report → suggest-fix pattern and the `set -e`-safe function wrapper transfer to any health check script in any repo.

---

### Skill 6: Git Workflow & CI

**When:** Pushing code, creating PRs, managing branches, or modifying CI pipelines.

**Covers:**
- Push with retry (`git-push-retry.sh` — exponential backoff, `--force-with-lease`)
- PR conventions (use PR template checklist, reference issues)
- Branch naming (`greyzxcursor/<descriptive-name>-<suffix>`)
- CI pipeline structure (syntax → lint → format → smoke tests → integration tests)
- Blocking vs non-blocking checks (errors block, warnings annotate)
- Dependabot for GitHub Actions version management

**Key references:**
- `scripts/git-push-retry.sh` (push implementation)
- `.github/workflows/ci.yml` (pipeline)
- `.github/PULL_REQUEST_TEMPLATE.md` (PR checklist)
- `.github/dependabot.yml` (auto-updates)
- `CONTRIBUTING.md` → Commit Style section

**Transferability:** The CI structure (syntax → lint → format → test, with blocking/non-blocking tiers) transfers to any shell-heavy or polyglot repo. Swap the tool names.

---

## Implementation Order

| Phase | Skills | Rationale |
|-------|--------|-----------|
| 1 | Skills 2, 5 | Core dev loop — most used by agents working on this repo |
| 2 | Skills 1, 3 | Environment setup — used on cold boot and secret rotation |
| 3 | Skills 4, 6 | Deployment + workflow — used less frequently but high impact |

## Transferability Design Principles

1. **Parameterize tool names** — Reference `${LINTER}` patterns, not hardcoded `shellcheck`
2. **Document the pattern, not just the command** — "detect → install → verify" is the pattern; the specific commands are examples
3. **Include a "For other repos" section** — What to change when porting
4. **Keep skills self-contained** — Each skill must work without reading other skills
5. **Reference, don't duplicate** — Point to `CONTRIBUTING.md` / `AGENTS.md` for standards, don't copy them into skills

## File Format

Each skill file follows this structure:

```markdown
# Skill: <Name>

## When to use
<trigger conditions>

## Prerequisites
<what must exist>

## Procedure
### Step 1: <action>
<commands + explanation>
...

## Validation
<how to verify success>

## Troubleshooting
| Symptom | Cause | Fix |
|---------|-------|-----|
...

## For other repos
<what to change when porting this skill>
```

## Dependencies

- PR #5 merged (baseline dev environment)
- PR #21 merged (health check hydration, CI, integration tests, docs)
- `.cursor/` directory created at repo root (not `portable-dev-env/cursor/` which is the template)

## Open Questions

1. Should skills live in `.cursor/skills/` (repo-specific, read by Cursor) or `portable-dev-env/cursor/skills/` (portable template, copied to user machines)?
   - **Recommendation**: Both. `.cursor/skills/` for this repo's agents. `portable-dev-env/cursor/skills/` as transferable templates.

2. Should skills reference the `portable-dev-env/cursor/rules/ai-behavior-rules.md` or replace it?
   - **Recommendation**: Skills complement rules. Rules define personality/style. Skills define procedures.

3. Should we include a skill index/registry file?
   - **Recommendation**: Yes. A `.cursor/skills/index.md` that lists all skills with their trigger conditions for quick lookup.
