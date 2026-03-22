# AGENTS.md

## Cursor Cloud specific instructions

This is a **shell-script CLI toolkit** (Neuro-Spicy DevKit) — there are no runtime services, no package managers, no build steps, and no installable dependencies. The entire product is Bash/PowerShell scripts + JSON/Markdown configs.

### Running scripts

- All scripts are in `scripts/` and the launcher is `init.sh` at the root.
- Scripts must be executable: `chmod +x scripts/*.sh init.sh`
- The interactive init (`scripts/neuro-spicy-init.sh`) requires TTY input — do **not** run it in a non-interactive cloud agent session.

### Lint / static analysis

- **shellcheck** — primary linter for all `.sh` files. Config in `.shellcheckrc`.
  - `shellcheck scripts/*.sh init.sh` — full lint pass
  - VSCode extension `timonwong.shellcheck` provides inline warnings
- **shfmt** — shell formatter (installed via `go install mvdan.cc/sh/v3/cmd/shfmt@latest`, binary at `~/go/bin/shfmt`).
  - `shfmt -d -i 4 -ci scripts/*.sh` — check formatting without modifying
  - `shfmt -w -i 4 -ci scripts/*.sh` — auto-format in-place
  - VSCode extension `foxundermoon.shell-format` provides format-on-save
- **bash -n** — basic syntax check (subset of what shellcheck does)
- The built-in `scripts/test-bash-scripts.sh` has a known bug: `set -euo pipefail` + `((total_tests++))` from 0 causes early exit. Run shellcheck/shfmt instead.

### Testing

- `shellcheck scripts/*.sh init.sh` — static analysis (preferred)
- `bash -n scripts/*.sh` — syntax validation
- `bash scripts/health-check-core.sh --help` and `bash scripts/neuro-spicy-setup-core.sh --help` — verify help flags
- `bash scripts/neuro-spicy-setup-core.sh --dry-run` — verify dry-run mode
- `shfmt -d -i 4 -ci scripts/*.sh` — formatting check

### Known health-check gotcha

`scripts/health-check-core.sh` uses `set -euo pipefail` and runs tool checks sequentially. If any check returns non-zero (e.g., GitHub token not set, Cursor not installed), the script exits immediately before reaching the summary. In headless cloud VMs, Cursor and VSCode will naturally be absent — this is expected. Pass `GITHUB_TOKEN=<value>` as an env var if you need to get past the token check.

### Dev tools summary

| Tool | Purpose | Install |
|------|---------|---------|
| shellcheck | Bash static analysis/linter | `apt install shellcheck` |
| shfmt | Shell script formatter | `go install mvdan.cc/sh/v3/cmd/shfmt@latest` |
| jq | JSON processor (for config files) | `apt install jq` |
| tree | Directory visualization | `apt install tree` |

### Editor setup

- `.vscode/settings.json` — workspace settings with shellcheck + shfmt integration, format-on-save
- `.vscode/extensions.json` — recommended extensions (shellcheck, shell-format, bash-ide, editorconfig, markdownlint, spell-checker)
- `.editorconfig` — consistent formatting across editors (4-space indent for `.sh`, 2-space for `.json`)
- `.shellcheckrc` — shellcheck config (severity=warning, disables SC2034/SC1091)

### Key commands reference

See `README.md` for full documentation. The main entry points are:
- `./init.sh` — interactive launcher (requires TTY)
- `./scripts/health-check-core.sh [--verbose] [--fix]` — environment validation
- `./scripts/neuro-spicy-setup-core.sh [--components core|minimal|all] [--dry-run] [--skip-backup]` — setup runner

### Security notes

- `.gitignore` excludes `backup-*/` dirs and `portable-dev-env/profiles/user/` (may contain tokens/personal data)
- `.gitattributes` enforces LF line endings for shell scripts (prevents cross-platform CRLF issues)
- The interactive init writes GitHub tokens to `~/.bashrc` — be aware of this on shared systems
