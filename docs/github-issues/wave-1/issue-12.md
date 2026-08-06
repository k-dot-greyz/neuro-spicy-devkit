## Wave / lane

- **Wave:** `wave-1-sanitize-io`
- **Lane:** `lane-bash` · **Area:** `area-bash`
- **Labels:** `security`, `task`

## Links

- Parent epic: #6
- Part of: #20
- Depends on: Wave 0
- Related: #8 (curl hints — merge #8 first or same lane agent coordinates)
- Procedure: [LABELS_AND_LINKING.md](https://github.com/k-dot-greyz/neuro-spicy-devkit/blob/main/docs/LABELS_AND_LINKING.md)
- Suggested branch: `greyzxcursor/12-openclaw-health-sete-2a19`

## File ownership

- `scripts/health-check-core.sh` (OpenClaw probe + curl hints)
- Coordinate with #8 if both touch curl hint strings

## Agent hydration

```text
Integration: tests/integration/test_health_exit.sh may need expectation update
Run: ./tests/run.sh
PR: [Security] Closes #12
```

## Definition of done

- [ ] Broken `openclaw` binary does not abort health check under `set -e`
- [ ] All curl install hints include TLS hardening flags
- [ ] `./tests/run.sh` green

---

## Technical detail

**Epic:** #6  
**Files:** `scripts/health-check-core.sh:222-241`  
**Severity:** Major (version probe) + Major (curl hints)

1. `openclaw --version` probe inside function can fail under `set -e` if binary is broken
2. `curl` install hint missing `--proto '=https' --tlsv1.2` flags (inconsistent with init script)

**Fix:**

1. Wrap version probe in `if/else`
2. Add TLS hardening flags to curl hint

**Acceptance:** Health check doesn't crash on broken openclaw binary. All curl hints use hardened flags.
