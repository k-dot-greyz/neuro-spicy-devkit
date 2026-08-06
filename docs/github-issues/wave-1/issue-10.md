## Wave / lane

- **Wave:** `wave-1-sanitize-io`
- **Lane:** `lane-powershell` · **Area:** `area-powershell`
- **Labels:** `security`, `task`

## Links

- Parent epic: #6
- Part of: #20
- Depends on: #9 (shared token/creds story) — can stack after #9 or same PR if small
- Procedure: [LABELS_AND_LINKING.md](https://github.com/k-dot-greyz/neuro-spicy-devkit/blob/main/docs/LABELS_AND_LINKING.md)
- Suggested branch: `greyzxcursor/10-ps1-token-escape-2a19`

## File ownership

- `scripts/setup-github-token.ps1`

## Agent hydration

```text
Add Pester stub or bash parity test if repo adds PS1 test harness (Phase 5)
PR: [Security] Closes #10
```

## Definition of done

- [ ] Null `Response` → connectivity error, not "invalid token"
- [ ] Single-quote in token or path escaped in generated PS1 source
- [ ] Round-trip test with special characters in dry-run or fixture

---

## Technical detail

**Epic:** #6  
**Files:** `scripts/setup-github-token.ps1:25-28,126,138`  
**Severity:** Major

1. **Catch block mislabels errors:** `Response.StatusCode.Value__` throws when `Response` is null (network/TLS/proxy failures). All errors get labeled 'token invalid'.
2. **Single quote injection:** Token or creds file path containing `'` breaks the generated PowerShell source file.

**Fix:**

1. Check if `Response` is null → distinct connectivity error message
2. Escape `'` to `''` in both `$tokenInput` and `$credsFile` before writing

**Acceptance:** Network errors say 'connectivity' not 'invalid token'. Token with special chars survives round-trip.
