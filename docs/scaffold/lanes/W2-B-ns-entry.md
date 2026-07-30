# Lane W2-B — `ns` CLI entry

**Branch:** `greyzxcursor/w2b-ns-entry-b042`  
**Owns:** `scripts/ns`, `scripts/doctor-core.sh`, `tests/unit/test_ns_entry.sh`

## Mission

Harden dispatcher: subcommand parsing, help text, exit codes, safe flag forwarding per target script.

## RED first

Extend `test_ns_entry.sh`:

- `ns check --help` exits 0
- Global `ns --verbose check` forwards `--verbose` to health
- `ns setup --dry-run` reaches setup script

## GREEN

Minimal changes in `scripts/ns`; avoid duplicating parse logic — use `ns-cli.sh` where possible.

## Verify

```bash
./tests/run.sh
shellcheck scripts/ns scripts/doctor-core.sh
bash scripts/ns help
```

## Out of scope

Resolver install paths, `aliases.fish`.
