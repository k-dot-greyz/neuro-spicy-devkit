# Contributing to Neuro-Spicy DevKit

Thanks for your interest! This project is built for neurodivergent-friendly developer workflows, so we value clarity, directness, and small incremental changes.

## Quick Start

```sh
git clone https://github.com/k-dot-greyz/neuro-spicy-devkit.git
cd neuro-spicy-devkit
chmod +x scripts/*.sh init.sh
bash scripts/health-check-core.sh --fix    # see what's missing
bash scripts/test-integration.sh           # run the test suite
```

## Before You Submit

1. **Syntax check**: `bash -n scripts/*.sh init.sh`
2. **Lint**: `shellcheck scripts/*.sh init.sh`
3. **Format check**: `shfmt -d -i 4 -ci scripts/*.sh init.sh`
4. **Integration tests**: `bash scripts/test-integration.sh`
5. **JSON validation**: `jq empty portable-dev-env/profiles/templates/*.json`

CI runs all of these automatically on every PR.

## Code Standards

### Shell scripts
- 4-space indent, LF line endings (enforced by `.editorconfig`)
- `set -euo pipefail` at the top of every script
- All tool checks wrapped in `if/else` (never bare function calls under `set -e`)
- Arithmetic: `x=$((x + 1))` not `((x++))` (the latter returns exit 1 from zero)
- Every script supports `--help` and `--dry-run` where applicable
- Use `printf %q` for writing shell variables to files (prevents injection)
- Credentials go in `~/.config/neuro-spicy/credentials` (chmod 600), never in code

### PowerShell scripts
- 4-space indent, CRLF line endings
- Use `$LASTEXITCODE` for external commands (not `try-catch`)
- Use `PtrToStringBSTR` + `ZeroFreeBSTR` for SecureString handling
- No `Invoke-Expression` — download to temp file then execute

### Docker
- Multi-stage builds, `node:22-alpine` base
- Non-root user (UID 1001), read-only rootfs, all caps dropped
- `tini` for init, localhost-only port binding
- Use `cp -r` not `cp -rn` (BusyBox Alpine doesn't support `-n`)

### Version references
- Never hardcode tool versions — use `latest`, `lts`, or caret ranges
- Version detection regexes must be future-proof (no ceiling caps)
- Install hints: provide multiple methods (nvm + apt + brew)

## Commit Style

- One logical change per commit
- Descriptive message, imperative mood: "Fix health check set -e exit" not "fixed stuff"
- Reference issue numbers when applicable

## Security

- Report vulnerabilities via GitHub Security Advisories (not public issues)
- Token/credential fixes are treated as Critical priority
- All PRs touching `scripts/setup-github-token.*` or Docker files require owner review

## File Layout

```text
scripts/                  # Bash/PowerShell scripts (the product)
portable-dev-env/         # Editor configs, profiles, templates
  cursor/                 # Cursor AI rules + memories
  openclaw/               # OpenClaw config + Docker deployment
  vscode/                 # VSCode settings + extensions
  profiles/templates/     # Profile templates (JSON)
  shell/                  # Shell aliases and shortcuts
docs/                     # Documentation
.github/                  # CI workflows, CODEOWNERS
.vscode/                  # This repo's workspace settings
tests/                    # Test framework (unit + integration)
```

## Questions?

Open an issue or ping @k-dot-greyz. We don't bite (usually).
