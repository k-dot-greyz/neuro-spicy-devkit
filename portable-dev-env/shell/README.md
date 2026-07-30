# Neuro-Spicy shell adapters (bash / zsh / fish)

Fish **must not** source bash files. Use `aliases.fish` only.

## Bash / Zsh

Add to `~/.bashrc` or `~/.zshrc`:

```bash
NS_DEVKIT_ROOT="/path/to/neuro-spicy-devkit"
[ -f "$NS_DEVKIT_ROOT/portable-dev-env/shell/aliases.sh" ] && \
  source "$NS_DEVKIT_ROOT/portable-dev-env/shell/aliases.sh"
```

Or let `aliases.sh` auto-detect root from its own path (default).

## Fish

```fish
set -gx NS_DEVKIT_ROOT /path/to/neuro-spicy-devkit
source $NS_DEVKIT_ROOT/portable-dev-env/shell/aliases.fish
```

## Engine CLI (all shells)

```bash
bash /path/to/neuro-spicy-devkit/scripts/ns help
```

Adapters call the bash engine via `bash "$NS_SCRIPTS/..."` or `ns_engine`.

## Verify

```bash
./tests/run.sh
fish -n portable-dev-env/shell/aliases.fish   # when fish is installed
```

See [docs/CLI_IMPLEMENTATION_SCAFFOLD.md](../../docs/CLI_IMPLEMENTATION_SCAFFOLD.md).
