#!/bin/bash
# Semver-style requirement checks for profile JSON (major.minor.patch).

ns_version_normalize() {
    local v="${1#v}"
    echo "${v%%-*}"
}

ns_version_parts() {
    local v
    v=$(ns_version_normalize "$1")
    local major minor patch
    IFS='.' read -r major minor patch <<<"$v"
    major=${major:-0}
    minor=${minor:-0}
    patch=${patch:-0}
    echo "$major $minor $patch"
}

ns_version_compare() {
    local a="$1"
    local b="$2"
    read -r am aj ap <<<"$(ns_version_parts "$a")"
    read -r bm bj bp <<<"$(ns_version_parts "$b")"
    if ((am > bm)); then echo 1; return; fi
    if ((am < bm)); then echo -1; return; fi
    if ((aj > bj)); then echo 1; return; fi
    if ((aj < bj)); then echo -1; return; fi
    if ((ap > bp)); then echo 1; return; fi
    if ((ap < bp)); then echo -1; return; fi
    echo 0
}

# ns_version_satisfies <installed> <constraint>
# Supports >=x.y.z and ^x.y.z (npm caret on same major).
ns_version_satisfies() {
    local installed="$1"
    local constraint="$2"
    local op="${constraint%%[0-9]*}"
    local want="${constraint#"$op"}"

    if [[ -z "$op" ]]; then
        op=">="
        want="$constraint"
    fi

    case "$op" in
        ">=")
            local cmp
            cmp=$(ns_version_compare "$installed" "$want")
            if [[ "$cmp" -ge 0 ]]; then return 0; fi
            return 1
            ;;
        "^")
            read -r wm wj wp <<<"$(ns_version_parts "$want")"
            read -r im ij ip <<<"$(ns_version_parts "$installed")"
            if ((im != wm)); then return 1; fi
            local floor_cmp next_major ceiling_cmp
            floor_cmp=$(ns_version_compare "$installed" "$want")
            if [[ "$floor_cmp" -lt 0 ]]; then return 1; fi
            next_major="$((wm + 1)).0.0"
            ceiling_cmp=$(ns_version_compare "$installed" "$next_major")
            if [[ "$ceiling_cmp" -lt 0 ]]; then return 0; fi
            return 1
            ;;
        *)
            return 1
            ;;
    esac
}
