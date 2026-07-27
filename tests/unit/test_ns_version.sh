#!/bin/bash
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
# shellcheck source=tests/lib/assert.sh
source "$ROOT/tests/lib/assert.sh"
# shellcheck source=scripts/lib/ns-version.sh
source "$ROOT/scripts/lib/ns-version.sh"

ns_version_satisfies "18.17.0" ">=18.0.0"
ns_assert_true "18.17 >= 18.0" "$?"

ns_version_satisfies "17.9.0" ">=18.0.0"
ns_assert_false "17.9 < 18.0" "$?"

ns_version_satisfies "3.12.1" ">=3.11.0"
ns_assert_true "python style" "$?"

ns_version_satisfies "2.30.0" ">=2.30.0"
ns_assert_true "exact floor" "$?"

ns_version_satisfies "2.29.9" ">=2.30.0"
ns_assert_false "below floor" "$?"

ns_version_satisfies "1.0.0" "^1.2.0"
ns_assert_false "caret major match minor low" "$?"

ns_version_satisfies "1.3.0" "^1.2.0"
ns_assert_true "caret compatible" "$?"

if [[ $NS_ASSERT_FAIL -ne 0 ]]; then
    echo "test_ns_version.sh: FAILED" >&2
    exit 1
fi
echo "test_ns_version.sh: OK"
exit 0
