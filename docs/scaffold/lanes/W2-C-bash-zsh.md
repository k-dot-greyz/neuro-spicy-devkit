# Lane W2-C — Bash / Zsh adapters

**Branch:** `greyzxcursor/w2c-bash-zsh-b042`  
**Owns:** `portable-dev-env/shell/aliases.sh`, `ns-env.sh`, `tests/integration/test_shell_adapters.sh`, `test_cli_aliases.sh`

## Mission

Keep bash/zsh adapters thin: functions call bash engine via `NS_SCRIPTS`. Optional `completions.bash` / `_ns` zsh completion.

## RED first

Add integration cases for `setup`, `push`, and `NS_DEVKIT_ROOT` override in tests.

## GREEN

No business logic in adapters — only wiring.

## Verify

```bash
./tests/run.sh
bash -c 'source portable-dev-env/shell/aliases.sh && type setup'
command -v zsh && zsh -c 'source portable-dev-env/shell/aliases.sh && echo $NS_SCRIPTS'
```

## Out of scope

fish, resolver, init.sh security.
