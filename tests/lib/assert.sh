#!/bin/bash
# Minimal assertions for bash unit tests (no bats dependency).

NS_ASSERT_FAIL=0

ns_assert_eq() {
    local expected="$1"
    local actual="$2"
    local message="${3:-}"
    if [[ "$expected" != "$actual" ]]; then
        echo "ASSERT_EQ failed${message:+ ($message)}: expected '$expected', got '$actual'" >&2
        NS_ASSERT_FAIL=1
    fi
}

ns_assert_ne() {
    local a="$1"
    local b="$2"
    local message="${3:-}"
    if [[ "$a" == "$b" ]]; then
        echo "ASSERT_NE failed${message:+ ($message)}: both were '$a'" >&2
        NS_ASSERT_FAIL=1
    fi
}

ns_assert_true() {
    local message="${1:-}"
    local result="${2:-}"
    if [[ "$result" != "0" ]]; then
        echo "ASSERT_TRUE failed${message:+ ($message)}: exit $result" >&2
        NS_ASSERT_FAIL=1
    fi
}

ns_assert_false() {
    local message="${1:-}"
    local result="${2:-}"
    if [[ "$result" != "1" ]]; then
        echo "ASSERT_FALSE failed${message:+ ($message)}: exit $result" >&2
        NS_ASSERT_FAIL=1
    fi
}

ns_assert_match() {
    local haystack="$1"
    local pattern="$2"
    local message="${3:-}"
    if ! [[ "$haystack" =~ $pattern ]]; then
        echo "ASSERT_MATCH failed${message:+ ($message)}: '$haystack' !~ $pattern" >&2
        NS_ASSERT_FAIL=1
    fi
}

ns_assert_file_exists() {
    local path="$1"
    local message="${2:-}"
    if [[ ! -f "$path" ]]; then
        echo "ASSERT_FILE_EXISTS failed${message:+ ($message)}: $path" >&2
        NS_ASSERT_FAIL=1
    fi
}
