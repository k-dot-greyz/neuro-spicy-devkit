#!/bin/bash
# detect → plan → apply → verify (install paths gated until IO sanitize #8).

# shellcheck source=ns-profile.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/ns-profile.sh"

NS_RESOLVER_DRY_RUN="${NS_RESOLVER_DRY_RUN:-true}"

ns_resolver_detect_tool() {
    local tool="$1"
    case "$tool" in
        git) command -v git ;;
        nodejs | node) command -v node ;;
        npm) command -v npm ;;
        python | python3) command -v python3 ;;
        rust | cargo) command -v cargo ;;
        *) command -v "$tool" 2>/dev/null || true ;;
    esac
}

# Emit one plan line per requirement: plan:<action>:<tool>=<constraint>
ns_resolver_plan() {
    local profile_path="$1"
    if [[ ! -f "$profile_path" ]]; then
        echo "ns_resolver_plan: missing profile: $profile_path" >&2
        return 1
    fi
    if ! command -v jq >/dev/null 2>&1; then
        echo "ns_resolver_plan: jq required" >&2
        return 2
    fi
    local tool constraint
    while IFS=$'\t' read -r tool constraint; do
        [[ -z "$tool" ]] && continue
        if ns_resolver_detect_tool "$tool" >/dev/null; then
            echo "verify:${tool}=${constraint}"
        else
            echo "install:${tool}=${constraint}"
        fi
    done < <(jq -r '.requirements // {} | to_entries[] | [.key, .value] | @tsv' "$profile_path")
}

ns_resolver_apply() {
    local profile_path="$1"
    local line
    local dry="${NS_RESOLVER_DRY_RUN}"
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        case "$line" in
            install:*)
                if [[ "$dry" == "true" || "$dry" == "1" ]]; then
                    echo "DRY-RUN: would satisfy $line"
                else
                    echo "ns_resolver_apply: real install blocked (sanitize #8); line=$line" >&2
                    return 3
                fi
                ;;
            verify:*)
                echo "OK: $line"
                ;;
            *)
                echo "ns_resolver_apply: unknown plan line: $line" >&2
                return 1
                ;;
        esac
    done < <(ns_resolver_plan "$profile_path")
}
