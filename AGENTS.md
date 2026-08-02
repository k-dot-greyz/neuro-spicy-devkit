# AGENTS.md

## Cursor Cloud specific instructions

**Neuro-Spicy DevKit** — a shell-script CLI toolkit for bootstrapping dev environments. No runtime services, no package managers, no build step. The product IS the scripts.

### What's already ready after update script runs

| Tool | Location | Purpose |
|------|----------|---------|
| shellcheck | `/usr/bin/shellcheck` | Bash linter (primary lint tool) |
| shfmt | `/usr/local/bin/shfmt` | Bash formatter |
| jq | `/usr/bin/jq` | JSON processor |
| tree | `/usr/bin/tree` | Directory visualization |
| git | system | Already configured |
| node | system (nvm) | Validated by health check |
| python3 | system | Validated by health check |

Scripts are pre-chmod'd executable. No `npm install` or `pip install` needed — ever.

### Lint

```sh
shellcheck scripts/*.sh init.sh        # static analysis (primary)
shfmt -d -i 4 -ci scripts/*.sh init.sh # formatting check (no write)
shfmt -w -i 4 -ci scripts/*.sh         # auto-format in place
```

Config: `.shellcheckrc` (severity=warning, disables SC2034/SC1091).

### Test

```sh
bash -n scripts/*.sh init.sh                          # syntax validation
bash scripts/health-check-core.sh --help              # verify help flag
bash scripts/neuro-spicy-setup-core.sh --help         # verify help flag
bash scripts/neuro-spicy-setup-core.sh --dry-run      # verify dry-run
```

The built-in `scripts/test-bash-scripts.sh` has a bug: `set -euo pipefail` + `((total_tests++))` from 0 = instant exit. Don't use it — run the commands above instead.

### Run / demo

The scripts are the product. Key entry points:

- `./init.sh` — interactive launcher (**requires TTY** — skip in headless agents)
- `./scripts/health-check-core.sh [--verbose] [--fix]` — environment validation
- `./scripts/neuro-spicy-setup-core.sh [--components core|minimal|all] [--dry-run] [--skip-backup]` — setup runner

### Gotchas

1. **`set -euo pipefail` + optional checks = early exit.** `health-check-core.sh` exits on first non-zero return (e.g., missing GitHub token, Cursor, VSCode). In headless VMs this is expected. Pass `GITHUB_TOKEN=<any_value>` to get past the token check if needed.

2. **No Cursor/VSCode on cloud VMs.** The health check and setup scripts check for these editors. They won't be found — that's fine. The `.vscode/` workspace configs are for human devs using the repo locally.

3. **Interactive scripts block.** `neuro-spicy-init.sh` uses `read` prompts throughout. Never run it non-interactively. Use `neuro-spicy-setup-core.sh --dry-run` or individual functions instead.

4. **`git-push-retry.sh` doesn't exist.** Referenced in `test-bash-scripts.sh` but never created. The test script logs `ERROR: Script not found: git-push-retry.sh` and moves on.

### File layout

```text
scripts/                 # All bash/ps1 scripts (the product)
portable-dev-env/        # Editor configs, profiles, templates
  cursor/                # Cursor AI rules + memories
  vscode/                # VSCode settings + extensions templates
  profiles/templates/    # Profile templates (e.g., frontend-developer.json)
docs/                    # Documentation
.vscode/                 # THIS repo's workspace settings (shellcheck, shfmt, format-on-save)
.editorconfig            # Formatting rules
.shellcheckrc            # Shellcheck config
.gitignore               # Excludes backup-*/, profiles/user/, .env
.gitattributes           # LF for .sh, CRLF for .ps1
```
