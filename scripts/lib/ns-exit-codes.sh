#!/bin/bash
# Standard exit codes for Neuro-Spicy DevKit scripts (epic contract).

NS_EXIT_SUCCESS=0
NS_EXIT_ERROR=1
NS_EXIT_MISSING_DEP=2
NS_EXIT_CONFIG=3

ns_exit_name() {
    local code="$1"
    case "$code" in
        "$NS_EXIT_SUCCESS") echo "success" ;;
        "$NS_EXIT_ERROR") echo "error" ;;
        "$NS_EXIT_MISSING_DEP") echo "missing_dependency" ;;
        "$NS_EXIT_CONFIG") echo "config_error" ;;
        *) echo "unknown" ;;
    esac
}
