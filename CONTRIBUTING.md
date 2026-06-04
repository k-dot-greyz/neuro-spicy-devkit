# Contributing to Neuro-Spicy DevKit

Thanks for your interest! This project is built for neurodivergent-friendly developer workflows, so we value **clarity, directness, predictability**, and small incremental changes.

---

## Quick Start

```sh
git clone https://github.com/k-dot-greyz/neuro-spicy-devkit.git
cd neuro-spicy-devkit
chmod +x scripts/*.sh init.sh
bash scripts/health-check-core.sh --fix    # see what's missing
bash scripts/test-integration.sh           # run the test suite (canonical)
```

---

## Before You Submit

Run these locally before opening a PR (CI runs the same checks on every PR):

1. **Syntax check**: `bash -n scripts/*.sh init.sh`
2. **Lint**: `shellcheck scripts/*.sh init.sh` (CI blocks on `--severity=error`; warnings are tracked separately)
3. **Format check**: `shfmt -d -i 4 -ci scripts/*.sh init.sh`
4. **Integration tests**: `bash scripts/test-integration.sh`
5. **JSON validation**: `jq empty portable-dev-env/profiles/templates/*.json`

Optional helper: `bash scripts/test-bash-scripts.sh` runs syntax/help checks on a subset of scripts and dry-run only for `neuro-spicy-setup-core.sh`. Prefer `test-integration.sh` for pre-PR validation.

---

## GlitchWorks Agnostic Architecture Protocol

This repository provides a portable, multi-platform development environment. All scripts and tools must follow the **GlitchWorks Agnostic Architecture Protocol** so they stay robust, portable, and safe to run anywhere.

When writing or modifying scripts (PowerShell or Bash), design with these four pillars:

### 1. Cross-Platform Portability

We support **Windows (PowerShell 5.1+ and PowerShell Core)** and **Linux/macOS (Bash 4+ target)**.

* **macOS note**: Scripts in this repo use `#!/bin/bash`, which on macOS resolves to the system Bash **3.2** at `/bin/bash`. For Bash 4+ features, install a newer Bash (`brew install bash`) and run scripts explicitly with `/opt/homebrew/bin/bash` (Apple Silicon) or `/usr/local/bin/bash` (Intel)—do not assume the default shebang already selects Bash 4+.
* **No platform assumptions**: Never assume utilities like `sed`, `awk`, or `grep` behave the same across GNU/Linux and macOS (BSD).
* **Dual implementations**: If a script performs a system-level action, provide both a `.ps1` (PowerShell) and `.sh` (Bash) equivalent with matching behavior.
* **Line endings**: Bash scripts (`.sh`) use LF. PowerShell scripts (`.ps1`) may use LF or CRLF; LF is preferred for repository consistency.

### 2. Dry-Run Safety

Any script that modifies the user's system, writes files, or changes configurations **must** support dry-run mode.

* **The flag**: Implement `--dry-run` or `-d` as a standard argument.
* **The behavior**: Print exactly what actions *would* run without executing them or modifying files.
* **Verification**: Dry-run paths must not accidentally execute state-changing commands. CI validates `neuro-spicy-setup-core.sh --dry-run` and `setup-github-token.sh --dry-run`.

### 3. Environment Variable Sandboxing

Scripts must respect the user's shell environment and avoid polluting it.

* **Local scopes**: In Bash, use `local` inside functions. In PowerShell, use local or script-scoped variables.
* **No global pollution**: Do not permanently modify global environment variables unless the user opts in or it is clearly documented core behavior.
* **Sandboxed execution**: Temporary environment variables should exist only for the script's lifetime.

#### Environment hydration (CPU architecture)

**Environment hydration** means applying this repository's portable templates and setup steps on the user's machine: copying or merging files from `portable-dev-env/` (Cursor/VSCode rules, settings, profiles), running idempotent Git/shell guidance, and surfacing optional variables such as `GITHUB_TOKEN` or `PATH` additions—without permanently polluting the global environment unless the user opts in.

Hydration is **architecture-agnostic** when it only moves text/JSON/Markdown configs or runs shell logic that does not download CPU-specific binaries. Those paths must behave the same on every supported CPU.

| Architecture | Typical identifiers | Hydration support | Notes for contributors |
| :--- | :--- | :--- | :--- |
| **ARM64** | `aarch64`, `arm64` | **Fully supported** | Linux ARM64 SBCs/servers, macOS Apple Silicon, Windows on ARM (use **PowerShell Core**). Prefer distro/package managers (`apt`, `brew`, `winget`) so the correct arch binaries are chosen automatically. |
| **ARM32** | `armv7l`, `armhf`, `armv6l` | **Supported for config hydration**; **best-effort for optional tool installs** | File-based setup (rules, settings, profiles, Git config) matches other platforms. Do **not** hardcode `x86_64`/`amd64` download URLs or assume Node/Python/Cursor builds exist for every ARM32 board—detect arch, fail with a clear manual-install message, or delegate to the OS package manager. |
| **x86_64 / amd64** | `x86_64`, `amd64` | **Fully supported** | Default CI and desktop target; same hydration rules as ARM64. |

When a script needs the host CPU for installs or health output, detect it portably:

* **Bash**: `uname -m` (see `scripts/health-check-core.sh --verbose`).
* **PowerShell**: `$env:PROCESSOR_ARCHITECTURE` on Windows; on PowerShell Core across platforms, prefer `[System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture`.

**Quality expectation**: changes that touch hydration or installs must not regress ARM64; ARM32 must at minimum keep config hydration and dry-run paths working even when binary installers are unavailable.

### 4. Idempotent Script Execution

Running a script multiple times must be safe and converge on the same final state.

* **Check before doing**: Before installing, writing, or appending, verify whether the step is already complete.
* **No duplications**: Never blindly append to `.bashrc` or `settings.json`; check for existing lines/settings or use idempotent block replacement.
* **Graceful skipping**: Log helpful skip messages (e.g., `[SKIP] Node.js is already installed`) and continue without error.

---

## Submodule Boundary Rule

Neuro-Spicy DevKit is used standalone or as a **Git submodule** in larger superprojects (such as `dev-master`).

* **Code and product docs only**: Keep this repo limited to its own code, configuration templates, and product-facing documentation.
* **No monorepo spillover**: Do not commit parent-project workflows, private guides, or monorepo-specific notes here.
* **Self-contained**: Scripts, tests, and guides must run independently of any parent project's environment.

---

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

---

## Commit Style and Workflow

We use **Conventional Commits** for PR titles and commit messages when practical:

`type(scope): message`

* **Types**: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`
* **Example**: `docs(scope): add contributing guidelines and standards`

Additional expectations:

- One logical change per commit
- Imperative mood: "Fix health check set -e exit" not "fixed stuff"
- Reference issue numbers when applicable

```bash
git checkout -b docs/your-topic
# ... make changes ...
git push -u origin docs/your-topic
# open PR against main
```

---

## Security

- Report vulnerabilities via GitHub Security Advisories (not public issues). See `SECURITY.md` when present on `main`.
- Token/credential fixes are treated as Critical priority
- All PRs touching `scripts/setup-github-token.*` or Docker files require owner review

---

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

Key entry scripts:

| Path | Description |
| :--- | :--- |
| `init.sh` / `init.ps1` | Interactive initialization entrypoints |
| `scripts/neuro-spicy-setup-core.*` | Core installation and configuration |
| `scripts/health-check-core.*` | Environment validation and diagnostics |
| `scripts/test-integration.sh` | Canonical integration test suite |
| `scripts/test-bash-scripts.sh` | Optional syntax/help checks; dry-run for setup-core only |

---

## Questions?

Open an issue or ping @k-dot-greyz. We don't bite (usually).
