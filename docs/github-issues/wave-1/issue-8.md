## Wave / lane

- **Wave:** `wave-1-sanitize-io` (Gate 1 — block resolver **real installs** until green)
- **Lane:** `lane-bash` · **Area:** `area-bash`
- **Labels:** `security`, `unsafe-io`, `task`

## Links

- Parent epic: #6 (security hardening)
- Part of: #20 (orchestrator — sanitize before feature installs)
- Depends on: Wave 0 merge (#21 orchestrator, #22 TDD) — rebase from train head
- Blocks: Phase 3 `ns-resolver` **network install** steps for OpenClaw
- Related: #12 (same health/init curl hints)
- Procedure: [LABELS_AND_LINKING.md](https://github.com/k-dot-greyz/neuro-spicy-devkit/blob/main/docs/LABELS_AND_LINKING.md)
- Suggested branch: `greyzxcursor/8-openclaw-download-2a19`

## File ownership (do not edit in parallel Wave 1 PRs)

- `scripts/neuro-spicy-init.sh` (OpenClaw install path)
- `scripts/health-check-core.sh` (curl install hints — coordinate with #12)

## Agent hydration

```text
Base: greyzxcursor/tdd-orchestration-431f (or main post Wave 0)
Iron law: test first — assert no curl|bash in repo (grep + unit test)
Run: ./tests/run.sh && shellcheck on touched *.sh
Do NOT: ns-resolver real installs, new MCP packages
PR: [Security] Closes #8, draft until DoD
```

## Definition of done

- [ ] No `curl | bash` or `curl | sh` in any `.sh` file
- [ ] OpenClaw install: download to `mktemp`, verify, then execute (match PS1 pattern)
- [ ] Health check `--fix` hints use `--proto '=https' --tlsv1.2`
- [ ] `./tests/run.sh` green; shellcheck clean on touched files

---

## Technical detail

**Epic:** #6  
**Files:** `scripts/neuro-spicy-init.sh:197`, `scripts/health-check-core.sh:241`  
**Severity:** Major

`curl ... | bash` pipes remote code directly to shell. Even with `--proto '=https' --tlsv1.2`, a compromised server or MITM can execute arbitrary code.

**Fix:** Download to `mktemp` file, then execute. The PowerShell side already does this (commit 576f5fe). Align bash to match.

**Acceptance:** No `curl | bash` or `curl | sh` patterns remain in any `.sh` file. Health check `--fix` hints use hardened flags.
