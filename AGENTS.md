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

Config: `.shellcheckrc` (severity=warning, targeted inline disables only).

### Test

```sh
./tests/run.sh                                      # unit + offline integration (TDD gate)
bash scripts/test-integration.sh                    # smoke + network checks
bash -n scripts/*.sh init.sh                        # syntax validation
```

See `docs/TDD_ORCHESTRATION.md` and `tasks.md` for the epic TDD backlog.
For GitHub labels, linking, and merge-train PR hygiene: `docs/LABELS_AND_LINKING.md`.

Legacy note: `scripts/test-bash-scripts.sh` is fixed for `set -e` + increment; prefer `./tests/run.sh`.

### Run / demo

The scripts are the product. Key entry points:

- `./init.sh` — interactive launcher (**requires TTY** — skip in headless agents)
- `./scripts/health-check-core.sh [--verbose] [--fix]` — environment validation
- `./scripts/neuro-spicy-setup-core.sh [--components core|minimal|all] [--dry-run] [--skip-backup]` — setup runner
- `./scripts/git-push-retry.sh [--branch <name>] [--dry-run]` — reliable git push with exponential backoff
- `./scripts/setup-github-token.sh [--test] [--dry-run]` — GitHub token setup (secure creds storage)

### OpenClaw Docker (hardened)

```sh
cd portable-dev-env/openclaw/docker
cp .env.example .env                    # fill in your API key
docker compose build                    # multi-stage, non-root, alpine
docker compose up -d                    # gateway at http://127.0.0.1:18789
docker compose logs -f openclaw         # watch logs
docker compose run --rm openclaw openclaw doctor  # health check inside container
```

Security posture: non-root (UID 1001), read-only rootfs, `no-new-privileges`, all caps dropped except `NET_BIND_SERVICE`, 2GB mem limit, 256 PID limit, localhost-only port bind, tini init for signal handling. See `docker/Dockerfile` for full details.

### Gotchas

1. **`set -euo pipefail` + optional checks = early exit.** `health-check-core.sh` exits on first non-zero return (e.g., missing GitHub token, Cursor, VSCode). In headless VMs this is expected. Pass `GITHUB_TOKEN=<any_value>` to get past the token check if needed.

2. **No Cursor/VSCode/OpenClaw on cloud VMs.** The health check checks for all three editors. They won't be found in headless VMs — that's fine. The `.vscode/` and `portable-dev-env/openclaw/` configs are for human devs using the repo locally.

3. **Interactive scripts block.** `neuro-spicy-init.sh` uses `read` prompts throughout. Never run it non-interactively. Use `neuro-spicy-setup-core.sh --dry-run` or individual functions instead.

4. **`scripts/setup-github-token.sh` requires TTY.** It prompts for token input interactively. Use `--test` to validate an existing token non-interactively, or `--dry-run` to preview.

### File layout

```text
scripts/                 # All bash/ps1 scripts (the product)
portable-dev-env/        # Editor configs, profiles, templates
  cursor/                # Cursor AI rules + memories
  openclaw/              # OpenClaw config template + workspace (SOUL.md, AGENTS.md)
    docker/              # Hardened Dockerfile, compose, .env.example
  vscode/                # VSCode settings + extensions templates
  profiles/templates/    # Profile templates (e.g., frontend-developer.json)
docs/                    # Documentation
.vscode/                 # THIS repo's workspace settings (shellcheck, shfmt, format-on-save)
.editorconfig            # Formatting rules
.shellcheckrc            # Shellcheck config
.gitignore               # Excludes backup-*/, profiles/user/, .env
.gitattributes           # LF for .sh, CRLF for .ps1
```
