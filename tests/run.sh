#!/bin/bash
# Run all unit tests (TDD gate)

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

failures=0
shopt -s nullglob
for t in tests/unit/test_*.sh; do
    echo "→ $(basename "$t")"
    if bash "$t"; then
        :
    else
        failures=$((failures + 1))
    fi
done

for t in tests/integration/test_*.sh; do
    echo "→ $(basename "$t")"
    if bash "$t"; then
        :
    else
        failures=$((failures + 1))
    fi
done

if [[ $failures -gt 0 ]]; then
    echo ""
    echo "$failures unit test file(s) failed" >&2
    exit 1
fi

echo ""
echo "All unit tests passed."
exit 0
