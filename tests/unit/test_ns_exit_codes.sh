#!/bin/bash
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
# shellcheck source=tests/lib/assert.sh
source "$ROOT/tests/lib/assert.sh"
# shellcheck source=scripts/lib/ns-exit-codes.sh
source "$ROOT/scripts/lib/ns-exit-codes.sh"

ns_assert_eq "0" "$NS_EXIT_SUCCESS" "success"
ns_assert_eq "1" "$NS_EXIT_ERROR" "error"
ns_assert_eq "2" "$NS_EXIT_MISSING_DEP" "missing dep"
ns_assert_eq "3" "$NS_EXIT_CONFIG" "config"

ns_assert_eq "success" "$(ns_exit_name "$NS_EXIT_SUCCESS")" "name success"
ns_assert_eq "missing_dependency" "$(ns_exit_name "$NS_EXIT_MISSING_DEP")" "name missing"

if [[ $NS_ASSERT_FAIL -ne 0 ]]; then
    echo "test_ns_exit_codes.sh: FAILED" >&2
    exit 1
fi
echo "test_ns_exit_codes.sh: OK"
exit 0
