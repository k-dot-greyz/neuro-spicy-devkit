#!/bin/bash
# Read requirement fields from profile JSON templates.

ns_profile_requirements_json() {
    local profile_path="$1"
    if ! command -v jq >/dev/null 2>&1; then
        echo "{}" >&2
        return 1
    fi
    jq -c '.requirements // {}' "$profile_path"
}

ns_profile_requirement() {
    local profile_path="$1"
    local tool="$2"
    if ! command -v jq >/dev/null 2>&1; then
        return 1
    fi
    jq -r --arg t "$tool" '.requirements[$t] // empty' "$profile_path"
}
