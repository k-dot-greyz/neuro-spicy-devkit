# Changelog

All notable changes to the Neuro-Spicy DevKit will be documented in this file.

Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added
- Full-stack health check with 13 checks: Git, Node, Python, Secrets, Rust, TypeScript, Astro/Vite, Playwright, dev tools, AI CLI, OpenClaw, Cursor, VSCode
- Runtime secret hydration: GITHUB_TOKEN, AI provider keys (Anthropic/OpenAI/Google/OpenRouter), SSH key detection with `--fix` prompts
- Shell aliases (`portable-dev-env/shell/aliases.sh`) — 40+ shortcuts for polyglot dev workflow
- GitHub Actions CI pipeline (`bash -n`, shellcheck, shfmt, JSON validation, integration tests)
- Integration test suite (`scripts/test-integration.sh`) — 18 tests covering access, scripts, secrets, JSON
- `CODEOWNERS`, `CONTRIBUTING.md`, `SECURITY.md`, `CODE_OF_CONDUCT.md`
- GitHub issue/PR templates with structured forms
- Dependabot config for GitHub Actions auto-updates
- OpenClaw integration: health check detection, init script install, config templates, hardened Docker image
- `scripts/git-push-retry.sh/.ps1` — reliable git push with exponential backoff
- `scripts/setup-github-token.sh/.ps1` — secure token setup wizard with `--test` and `--dry-run`
- `.editorconfig`, `.shellcheckrc`, `.gitignore`, `.gitattributes` — dev environment configs
- `.vscode/settings.json` + `extensions.json` — workspace settings with shellcheck/shfmt integration

### Fixed
- `set -euo pipefail` health check killer — all tool checks wrapped in conditionals, arithmetic counters fixed
- `eval` command injection in `neuro-spicy-init.sh` → `printf -v`
- Token storage: plaintext in `~/.bashrc` → dedicated creds file (umask 077, chmod 600)
- PowerShell BSTR memory leak → `ZeroFreeBSTR` cleanup
- `iwr|iex` remote code execution → download-to-temp-then-execute
- Version detection regexes future-proofed (Node caps at v29 → unlimited, Python caps at 3.19 → unlimited)
- `brew install python3` → `brew install python` (correct Homebrew formula)
- Duplicate log function definitions in health check
- Missing `BLUE` color variable
- Docker entrypoint `cp -rn` (BusyBox incompatible) — tracked in #11

### Changed
- All hardcoded tool versions replaced with latest/LTS tracking
- NodeSource install URLs: `setup_18.x` → `setup_lts.x`
- Node install hints: single method → three options (nvm + NodeSource + brew)
- Template package.json deps: `"latest"` → caret ranges (`^19.0.0` etc.)
- Frontend profile: added OpenClaw as editor, nvm install fallback chain
- Profile JSON: `github_token` (raw value) → `github_token_env` (env var name reference)

### Security
- Token race condition: `umask 077` subshell before writing credentials file
- PowerShell: registry persistence removed, ACL-restricted profile creds file instead
- `.gitignore`: `.env.*` wildcard with `.env.example` whitelist
- `.shellcheckrc`: removed unjustified global disables
- Docker: non-root (UID 1001), read-only rootfs, all caps dropped, tini init, localhost-only
