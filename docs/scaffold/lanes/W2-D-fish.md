# Lane W2-D — Fish adapter

**Branch:** `greyzxcursor/w2d-fish-b042`  
**Owns:** `portable-dev-env/shell/aliases.fish`, fish lines in `test_shell_adapters.sh`, CI `fish -n` step

## Mission

Parity for `check`, `setup`, `doctor`, `push`, `dryrun` — each calls `bash` on engine scripts. **Never** `source aliases.sh` from fish.

## RED first

If fish available locally: function existence test via `fish -c 'source aliases.fish; functions check'`.

## GREEN

Extend `aliases.fish` only; document in `portable-dev-env/shell/README.md`.

## Verify

```bash
fish -n portable-dev-env/shell/aliases.fish
./tests/run.sh
```

## Out of scope

bash engine, PowerShell.
