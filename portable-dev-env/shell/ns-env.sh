#!/bin/bash
# Shared paths for bash/zsh shell adapters (source from aliases.sh).

_ns_shell_adapter_dir() {
    cd "$(dirname "${BASH_SOURCE[0]}")" && pwd
}

if [[ -z "${NS_DEVKIT_ROOT:-}" ]]; then
    NS_DEVKIT_ROOT="$(_ns_shell_adapter_dir)/../.."
    NS_DEVKIT_ROOT="$(cd "$NS_DEVKIT_ROOT" && pwd)"
fi

export NS_DEVKIT_ROOT
export NS_SCRIPTS="${NS_DEVKIT_ROOT}/scripts"
export NS_CLI="${NS_SCRIPTS}/ns"

ns_engine() {
  bash "$NS_CLI" "$@"
}
