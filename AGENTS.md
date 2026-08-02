# AGENTS.md

## Cursor Cloud specific instructions

This is a **shell-script CLI toolkit** (Neuro-Spicy DevKit) — there are no runtime services, no package managers, no build steps, and no installable dependencies. The entire product is Bash/PowerShell scripts + JSON/Markdown configs.

### Running scripts

- All scripts are in `scripts/` and the launcher is `init.sh` at the root.
- Scripts must be executable: `chmod +x scripts/*.sh init.sh`
- The interactive init (`scripts/neuro-spicy-init.sh`) requires TTY input — do **not** run it in a non-interactive cloud agent session.

### Lint / syntax validation

There is no formal linter. Run `bash -n <script>` on each `.sh` file for syntax checking. The built-in test runner `scripts/test-bash-scripts.sh` exists but has a known issue: `set -euo pipefail` combined with `((total_tests++))` starting from 0 causes an early exit (arithmetic expression evaluates to 0 → exit code 1 → `set -e` kills the script). Run syntax checks manually instead.

### Testing

- `bash -n scripts/*.sh` — syntax validation for all scripts
- `bash scripts/health-check-core.sh --help` and `bash scripts/neuro-spicy-setup-core.sh --help` — verify help flags
- `bash scripts/neuro-spicy-setup-core.sh --dry-run` — verify dry-run mode

### Known health-check gotcha

`scripts/health-check-core.sh` uses `set -euo pipefail` and runs tool checks sequentially. If any check returns non-zero (e.g., GitHub token not set, Cursor not installed), the script exits immediately before reaching the summary. In headless cloud VMs, Cursor and VSCode will naturally be absent — this is expected. Pass `GITHUB_TOKEN=<value>` as an env var if you need to get past the token check.

### Key commands reference

See `README.md` for full documentation. The main entry points are:
- `./init.sh` — interactive launcher (requires TTY)
- `./scripts/health-check-core.sh [--verbose] [--fix]` — environment validation
- `./scripts/neuro-spicy-setup-core.sh [--components core|minimal|all] [--dry-run] [--skip-backup]` — setup runner
