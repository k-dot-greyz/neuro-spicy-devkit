#!/bin/bash
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
# shellcheck source=tests/lib/assert.sh
source "$ROOT/tests/lib/assert.sh"

NS="$ROOT/scripts/ns"

help_out="$(bash "$NS" help 2>&1)"
ns_assert_match "$help_out" check "help lists check"
ns_assert_match "$help_out" doctor "help lists doctor"

set +e
bash "$NS" doctor --dry-run >/dev/null 2>&1
doc_code=$?
set -e
ns_assert_eq "0" "$doc_code" "doctor --dry-run exits 0"

set +e
bash "$NS" not-a-command >/dev/null 2>&1
bad_code=$?
set -e
ns_assert_eq "1" "$bad_code" "unknown command exits 1"

if [[ $NS_ASSERT_FAIL -ne 0 ]]; then
    echo "test_ns_entry.sh: FAILED" >&2
    exit 1
fi
echo "test_ns_entry.sh: OK"
exit 0
