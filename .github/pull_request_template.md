## Summary

<!-- One paragraph: what and why -->

## Tracks

<!-- Closes #N for single-issue PRs. For epics use: Part of #20 (do not auto-close epic). -->

- Closes #
- Part of #

## Merge train

- **Base branch:** <!-- e.g. greyzxcursor/tdd-orchestration-431f or main -->
- **Labels:** <!-- merge-train, wave-*, lane-*, area-* -->

## Links

- Depends on PR: #
- Depends on issue: #
- Supersedes PR: #
- Blocks: <!-- what must wait for this -->

## Definition of done

- [ ] Behavior change has a failing test first (`tests/unit` or `tests/integration`)
- [ ] `./tests/run.sh`
- [ ] `shellcheck` on touched `*.sh`
- [ ] `--dry-run` / `--non-interactive` paths preserved or extended
- [ ] PowerShell twin updated if bash behavior changed (or tracked issue)

## Test plan

```bash
./tests/run.sh
bash scripts/test-integration.sh
```
