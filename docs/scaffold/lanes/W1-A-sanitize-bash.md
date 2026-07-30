# Lane W1-A — Sanitize bash IO

**Branch:** `greyzxcursor/w1a-sanitize-bash-b042`  
**Owns:** `scripts/neuro-spicy-init.sh`, OpenClaw install paths in bash, health checks (#8, #12)

## Mission

Remove `curl | bash` (or equivalent unsafe pipes). Document vendored/checksummed install or explicit user confirmation.

## RED first

Add integration or unit test that fails if install script pipes remote shell directly (grep-based contract test is acceptable).

## GREEN

Replace with hardened flow; keep `--non-interactive` fail-closed.

## Verify

```bash
./tests/run.sh
shellcheck scripts/neuro-spicy-init.sh
```

## Unblocks

Setting `NS_RESOLVER_DRY_RUN=false` for real installs in `ns_resolver_apply`.

## Out of scope

fish, epic Rust/MCP installers.
