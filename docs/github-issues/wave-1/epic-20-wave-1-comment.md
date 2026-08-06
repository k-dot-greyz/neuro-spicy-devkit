### Wave 1 — sanitize IO (ready for swarm)

Children hydrated in repo ([`docs/github-issues/wave-1/`](https://github.com/k-dot-greyz/neuro-spicy-devkit/tree/main/docs/github-issues/wave-1)):

| Issue | Lane | Merge hint |
|-------|------|------------|
| #11 Docker BusyBox `cp` | `lane-docker` | **First** |
| #8 curl\|bash OpenClaw | `lane-bash` | After #11 |
| #12 OpenClaw health `set -e` | `lane-bash` | Coordinate with #8 |
| #9 PS1 PAT in JSON/registry | `lane-powershell` | After #11 |
| #10 PS1 token escaping | `lane-powershell` | With or after #9 |
| #17 SEC-001 keychain / no PAT in JSON | bash + PS1 | Split by shell |

Apply labels + bodies (maintainer):

```bash
./scripts/github-apply-issue-metadata.sh --sync-labels
./scripts/github-apply-issue-metadata.sh --manifest docs/github-issues/wave-1/manifest.yml
```

**Gate:** Do not merge Wave 2 resolver **real installs** until Wave 1 is green.

See [WAVE_1_SANITIZE.md](https://github.com/k-dot-greyz/neuro-spicy-devkit/blob/main/docs/WAVE_1_SANITIZE.md).
