#!/bin/bash
# Resolve Neuro-Spicy DevKit repository root (bash engine).

# Optional override for tests and monorepos.
# shellcheck disable=SC2034
NS_DEVKIT_ROOT="${NS_DEVKIT_ROOT:-}"

ns_devkit_root() {
    if [[ -n "$NS_DEVKIT_ROOT" ]]; then
        echo "$NS_DEVKIT_ROOT"
        return 0
    fi
    local lib_dir
    lib_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    echo "$(cd "$lib_dir/../.." && pwd)"
}

ns_devkit_scripts_dir() {
    echo "$(ns_devkit_root)/scripts"
}
