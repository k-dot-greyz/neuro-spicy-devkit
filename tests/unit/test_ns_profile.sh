#!/bin/bash
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
# shellcheck source=tests/lib/assert.sh
source "$ROOT/tests/lib/assert.sh"
# shellcheck source=scripts/lib/ns-profile.sh
source "$ROOT/scripts/lib/ns-profile.sh"

PROFILE="$ROOT/portable-dev-env/profiles/templates/frontend-developer.json"
ns_assert_file_exists "$PROFILE" "frontend profile"

reqs=$(ns_profile_requirements_json "$PROFILE")
ns_assert_match "$reqs" '"nodejs"' "nodejs requirement"
ns_assert_match "$reqs" '"git"' "git requirement"

node_req=$(ns_profile_requirement "$PROFILE" "nodejs")
ns_assert_eq ">=18" "$node_req" "nodejs version constraint"

if [[ $NS_ASSERT_FAIL -ne 0 ]]; then
    echo "test_ns_profile.sh: FAILED" >&2
    exit 1
fi
echo "test_ns_profile.sh: OK"
exit 0
