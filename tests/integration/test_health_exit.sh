#!/bin/bash
# Health check exit code contract (integration, offline)

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
# shellcheck source=tests/lib/assert.sh
source "$ROOT/tests/lib/assert.sh"
# shellcheck source=scripts/lib/ns-exit-codes.sh
source "$ROOT/scripts/lib/ns-exit-codes.sh"

HC="$ROOT/scripts/health-check-core.sh"

log=$(GITHUB_TOKEN="ghp_test" ANTHROPIC_API_KEY="sk-ant-test" bash "$HC" 2>&1) || code=$?
code=${code:-0}

if echo "$log" | grep -q "Total Checks:"; then
    ns_assert_true "summary printed" 0
else
    ns_assert_true "summary printed" 1
fi

# Successful core toolchain should not report missing-dep exit (2).
if [[ "$code" -eq "$NS_EXIT_MISSING_DEP" ]]; then
    ns_assert_true "core deps present on CI runner" 1
else
    ns_assert_true "not missing-dep exit" 0
fi

if [[ $NS_ASSERT_FAIL -ne 0 ]]; then
    echo "test_health_exit.sh: FAILED (exit code was $code)" >&2
    exit 1
fi
echo "test_health_exit.sh: OK (exit $code)"
exit 0
