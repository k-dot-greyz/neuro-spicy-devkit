## Wave / lane

- **Wave:** `wave-1-sanitize-io`
- **Lane:** `lane-powershell` · **Area:** `area-profiles`
- **Labels:** `security`, `credentials`, `task`

## Links

- Parent epic: #6
- Part of: #20
- Depends on: Wave 0 (#21, #22)
- Related: #17 (SEC-001 bash profile/rc — coordinate credential model)
- Blocks: PS1 profile hydration until PAT is env-name only
- Procedure: [LABELS_AND_LINKING.md](https://github.com/k-dot-greyz/neuro-spicy-devkit/blob/main/docs/LABELS_AND_LINKING.md)
- Suggested branch: `greyzxcursor/9-ps1-token-creds-2a19`

## File ownership

- `scripts/neuro-spicy-init.ps1` (registry + profile JSON writes)
- Do **not** touch bash `neuro-spicy-init.sh` in this PR (#17 lane)

## Agent hydration

```text
Lane B — PowerShell only
Run: shellcheck not applicable; validate with -DryRun / --dry-run paths
PR: [Security] Closes #9
```

## Definition of done

- [ ] No `SetEnvironmentVariable` for token secrets in user registry
- [ ] Profile JSON stores `github_token_env` (name), not raw PAT
- [ ] Matches `setup-github-token.ps1` ACL creds file pattern
- [ ] `--dry-run` shows would-write paths without writing

---

## Technical detail

**Epic:** #6  
**Files:** `scripts/neuro-spicy-init.ps1:272`, `scripts/neuro-spicy-init.ps1:381`  
**Severity:** Critical

Two issues:

1. `neuro-spicy-init.ps1:272` still writes `GITHUB_TOKEN` to Windows registry via `SetEnvironmentVariable('User')`
2. `neuro-spicy-init.ps1:381` writes raw PAT value to profile JSON on disk (`github_token = $script:GITHUB_TOKEN`)

**Fix:**

1. Replace registry write with ACL-restricted creds file (match `setup-github-token.ps1` pattern)
2. Change `github_token` → `github_token_env = 'GITHUB_TOKEN'` (match bash init schema)

**Acceptance:** No `SetEnvironmentVariable` for tokens. No raw PAT in profile JSON. Single source of truth per platform.
