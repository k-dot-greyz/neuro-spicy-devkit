# Lane W2-A — Resolver dry-run

**Branch:** `greyzxcursor/w2a-resolver-b042`  
**Owns:** `scripts/lib/ns-resolver.sh`, `tests/unit/test_ns_resolver.sh`, setup integration (coordinate with W2-B)

## Mission

Expand `detect → plan → apply` for profile `requirements` and tool plugins. **Real install must remain blocked** until #8 is merged (`NS_RESOLVER_DRY_RUN` default `true`).

## RED first

Add failing cases to `tests/unit/test_ns_resolver.sh` for:

- Missing tool → `install:` line + `DRY-RUN:` on apply
- Present tool → `verify:` line + `OK:` on apply
- Invalid profile path → non-zero exit

## GREEN

Implement in `ns-resolver.sh` only; use `ns-profile.sh` + `ns-version.sh`.

## Verify

```bash
./tests/run.sh
shellcheck scripts/lib/ns-resolver.sh
```

## Out of scope

`scripts/ns`, fish adapters, OpenClaw install changes.
