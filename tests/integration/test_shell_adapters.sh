#!/bin/bash
# Bash/zsh adapter smoke (offline)

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
# shellcheck source=tests/lib/assert.sh
source "$ROOT/tests/lib/assert.sh"

ALIASES="$ROOT/portable-dev-env/shell/aliases.sh"
FISH="$ROOT/portable-dev-env/shell/aliases.fish"

ns_assert_file_exists "$ALIASES"
ns_assert_file_exists "$FISH"

bash -c "source '$ALIASES' && [[ -n \"\$NS_SCRIPTS\" ]] && [[ -x \"\$NS_SCRIPTS/ns\" ]]" || NS_ASSERT_FAIL=1

if command -v zsh >/dev/null 2>&1; then
    zsh -c "source '$ALIASES' && [[ -n \"\$NS_SCRIPTS\" ]]" || NS_ASSERT_FAIL=1
fi

if command -v fish >/dev/null 2>&1; then
    fish -n "$FISH" || NS_ASSERT_FAIL=1
else
    echo "skip: fish not installed (fish -n aliases.fish)"
fi

if [[ $NS_ASSERT_FAIL -ne 0 ]]; then
    echo "test_shell_adapters.sh: FAILED" >&2
    exit 1
fi
echo "test_shell_adapters.sh: OK"
exit 0
