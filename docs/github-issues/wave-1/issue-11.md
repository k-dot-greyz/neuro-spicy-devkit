## Wave / lane

- **Wave:** `wave-1-sanitize-io`
- **Lane:** `lane-docker` · **Area:** `area-docker`
- **Labels:** `bug`, `task`

## Links

- Parent epic: #6
- Part of: #20
- Depends on: Wave 0
- **Merge order:** Wave 1 **first** (smallest blast radius) — merge before #8 / #9
- Procedure: [LABELS_AND_LINKING.md](https://github.com/k-dot-greyz/neuro-spicy-devkit/blob/main/docs/LABELS_AND_LINKING.md)
- Suggested branch: `greyzxcursor/11-docker-busybox-cp-2a19`

## File ownership

- `portable-dev-env/openclaw/docker/docker-entrypoint.sh`
- `portable-dev-env/openclaw/docker/Dockerfile`

## Agent hydration

```text
Lane C — docker only
CI: skip full docker build if unavailable; document local verify
PR: [Task] Closes #11
```

## Definition of done

- [ ] `cp` in entrypoint works on BusyBox Alpine (no GNU-only `-n`)
- [ ] No silent `2>/dev/null || true` masking copy failures
- [ ] Remove unused `dumb-init` from image
- [ ] `docker compose build` succeeds locally (or documented skip in CI)

---

## Technical detail

**Epic:** #6  
**Files:** `portable-dev-env/openclaw/docker/docker-entrypoint.sh:15`, `Dockerfile:27`  
**Severity:** Critical (entrypoint silently fails) + Minor (unused package)

1. `cp -rn` uses GNU coreutils `-n` flag not available in BusyBox. Errors suppressed by `2>/dev/null || true`. Workspace defaults never copied.
2. Both `tini` and `dumb-init` installed, only `tini` used.

**Fix:**

1. Remove `-n` flag (outer `if` already guards) and error suppression
2. Remove `dumb-init` from `apk add`

**Acceptance:** `docker-entrypoint.sh` works on BusyBox Alpine. Image has no unused packages.
