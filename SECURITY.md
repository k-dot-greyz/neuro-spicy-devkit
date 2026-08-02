# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| main (latest) | ✅ |
| Feature branches | ⚠️ Best-effort |

## Reporting a Vulnerability

**Do NOT open a public issue for security vulnerabilities.**

Instead, use [GitHub Security Advisories](https://github.com/k-dot-greyz/neuro-spicy-devkit/security/advisories/new) to report privately.

### What to include

- Description of the vulnerability
- Steps to reproduce (or proof of concept)
- Impact assessment (what can an attacker do?)
- Affected files/scripts
- Suggested fix (if you have one)

### Response timeline

- **Acknowledgment**: Within 48 hours
- **Assessment**: Within 1 week
- **Fix**: Depends on severity (Critical: ASAP, Major: 1-2 weeks, Minor: next release)

### Scope

Security-sensitive areas of this project include:

- **Token/credential handling**: `scripts/setup-github-token.*`, `scripts/neuro-spicy-init.*`
- **Shell injection**: Any script that processes user input (especially `read`, `eval`, `printf`)
- **Docker image**: `portable-dev-env/openclaw/docker/` (container escape, privilege escalation)
- **CI/CD**: `.github/workflows/` (workflow injection, secret leakage)
- **File permissions**: Anything writing to `~/.config/neuro-spicy/` or shell config files

### Out of scope

- Vulnerabilities in upstream tools (Node.js, Rust, Python, OpenClaw) — report those to the respective projects
- Issues requiring physical access to the machine
- Social engineering attacks
