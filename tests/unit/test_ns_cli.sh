#!/bin/bash
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
# shellcheck source=tests/lib/assert.sh
source "$ROOT/tests/lib/assert.sh"
# shellcheck source=scripts/lib/ns-cli.sh
source "$ROOT/scripts/lib/ns-cli.sh"

ns_cli_reset
ns_cli_parse --dry-run
ns_assert_eq "true" "${NS_CLI_DRY_RUN:-false}" "dry-run"

ns_cli_reset
ns_cli_parse --verbose --quiet
ns_assert_eq "true" "${NS_CLI_VERBOSE:-false}" "verbose"
ns_assert_eq "true" "${NS_CLI_QUIET:-false}" "quiet"

ns_cli_reset
ns_cli_parse --non-interactive -- foo bar
ns_assert_eq "true" "${NS_CLI_NON_INTERACTIVE:-false}" "non-interactive"
ns_assert_eq "foo bar" "${NS_CLI_REMAINING[*]}" "remaining args"

ns_cli_reset
ns_cli_parse --help
ns_assert_eq "true" "${NS_CLI_WANTS_HELP:-false}" "help"

if [[ $NS_ASSERT_FAIL -ne 0 ]]; then
    echo "test_ns_cli.sh: FAILED" >&2
    exit 1
fi
echo "test_ns_cli.sh: OK"
exit 0
