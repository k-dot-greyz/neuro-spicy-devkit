# OpenClaw Agent Instructions — Neuro-Spicy DevKit

## Project context

This is a shell-script CLI toolkit for bootstrapping developer environments. No runtime services, no package managers, no build step.

## Key commands

- `shellcheck scripts/*.sh` — lint all bash scripts
- `shfmt -d -i 4 -ci scripts/*.sh` — check formatting
- `bash scripts/health-check-core.sh --verbose` — validate environment
- `bash scripts/neuro-spicy-setup-core.sh --dry-run` — preview setup

## Rules

- Never hardcode tool versions — use latest/LTS pointers
- All scripts must pass `shellcheck` and `bash -n` before commit
- Interactive scripts must support `--dry-run` and `--help`
- Tokens go in `~/.config/neuro-spicy/credentials` (chmod 600), never in code
- Shell scripts use 4-space indent, LF line endings
- PowerShell scripts use 4-space indent, CRLF line endings
