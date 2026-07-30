#!/bin/bash
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
# shellcheck source=tests/lib/assert.sh
source "$ROOT/tests/lib/assert.sh"
# shellcheck source=scripts/lib/ns-resolver.sh
source "$ROOT/scripts/lib/ns-resolver.sh"

PROFILE="$ROOT/portable-dev-env/profiles/templates/frontend-developer.json"

plan="$(ns_resolver_plan "$PROFILE")"
ns_assert_match "$plan" git "profile requires git"

export NS_RESOLVER_DRY_RUN=true
apply_out="$(ns_resolver_apply "$PROFILE")"
if echo "$plan" | grep -q '^install:'; then
    ns_assert_match "$apply_out" DRY-RUN "apply dry-run for missing tools"
else
    ns_assert_match "$apply_out" "OK: verify:" "apply verifies present tools"
fi

if [[ $NS_ASSERT_FAIL -ne 0 ]]; then
    echo "test_ns_resolver.sh: FAILED" >&2
    exit 1
fi
echo "test_ns_resolver.sh: OK"
exit 0
