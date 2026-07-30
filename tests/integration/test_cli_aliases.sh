#!/bin/bash
# Contract: interactive adapters invoke bash engine scripts

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
# shellcheck source=tests/lib/assert.sh
source "$ROOT/tests/lib/assert.sh"

ALIASES="$ROOT/portable-dev-env/shell/aliases.sh"

type_out="$(bash -c "source '$ALIASES' && type check")"
ns_assert_match "$type_out" health-check-core.sh "check maps to health engine"

type_doc="$(bash -c "source '$ALIASES' && type doctor")"
ns_assert_match "$type_doc" doctor-core.sh "doctor maps to doctor engine"

if [[ $NS_ASSERT_FAIL -ne 0 ]]; then
    echo "test_cli_aliases.sh: FAILED" >&2
    exit 1
fi
echo "test_cli_aliases.sh: OK"
exit 0
