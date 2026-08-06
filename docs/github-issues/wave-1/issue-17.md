## Wave / lane

- **Wave:** `wave-1-sanitize-io`
- **Lanes:** `lane-bash` + `lane-powershell` (coordinate — split PRs OK)
- **Area:** `area-profiles`
- **Labels:** `security`, `credentials`, `task`

## Links

- Parent epic: #6 · Audit: #3 (SEC-001)
- Part of: #20
- Depends on: Wave 0; overlaps **PR #5** / **#21** creds file direction — **supersede #5** narrative, don't duplicate
- Related: #9 (PS1 profile/registry)
- Blocks: Epic feature installs that assume token in profile JSON
- Procedure: [LABELS_AND_LINKING.md](https://github.com/k-dot-greyz/neuro-spicy-devkit/blob/main/docs/LABELS_AND_LINKING.md)
- Suggested branch: `greyzxcursor/17-sec001-keychain-2a19`

## File ownership

- Bash: `scripts/neuro-spicy-init.sh`, `scripts/setup-github-token.sh`
- Profile templates / user profile paths
- **Split:** bash PR vs PS1 PR (#9) to avoid lane conflict

## Agent hydration

```text
Do NOT reintroduce plaintext PAT in JSON or shell rc
Update AUDIT_IMPLEMENTATION.md when on branch
PR: [Security] Closes #17 (may be multi-PR — use Part of #17 in body)
```

## Definition of done

- [ ] PAT via platform secret store OR documented creds file (`~/.config/neuro-spicy/`) — not rc export of raw token
- [ ] No PAT in `user-profile.json` or templates — env name / retrieval only
- [ ] Migration note for existing plaintext rc lines
- [ ] `AUDIT_IMPLEMENTATION.md` checklist updated when that file exists on branch

---

## Technical detail

## Context

Tracks **SEC-001** from audit (Issue #3). Compared to `main` / branch `audit/security-fixes-2026-02-05`:

- `scripts/neuro-spicy-init.sh` still appends **raw** `export GITHUB_TOKEN='...'` to `~/.bashrc` / `~/.zshrc` and writes `"github_token": "$GITHUB_TOKEN"` into `portable-dev-env/profiles/user/user-profile.json` (plaintext in repo-adjacent files).

## Open PR overlap

- **PR #5** (`cursor/development-environment-setup-7103`) improves this partially: writes **quoted** token to `~/.config/neuro-spicy/credentials` (umask 077) and changes profile field to `githubToken` — **still not OS keychain** and **token still embedded in JSON** if users generate profiles.

## Acceptance criteria

- [ ] Store/retrieve PAT via **macOS Keychain**, **Linux Secret Service** (`secret-tool` / libsecret), and document **Windows** path (Credential Manager / setup script), per `AUDIT_IMPLEMENTATION.md` / Issue #3.
- [ ] **Never** persist the PAT inside `user-profile.json` or templates; use env var name / retrieval instructions only.
- [ ] Migrate or deprecate plaintext lines in shell rc files; document one supported flow (`setup-github-token.sh` from PR #5 is a building block).
- [ ] Update `AUDIT_IMPLEMENTATION.md` checklist when done.

Refs: #3, PR #4, PR #5
