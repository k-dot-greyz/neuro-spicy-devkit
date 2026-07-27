#!/bin/bash
# Shared CLI flag parsing for DevKit scripts.

NS_CLI_VERBOSE=false
NS_CLI_QUIET=false
NS_CLI_NON_INTERACTIVE=false
NS_CLI_WANTS_HELP=false

ns_cli_reset() {
    NS_CLI_VERBOSE=false
    NS_CLI_QUIET=false
    NS_CLI_NON_INTERACTIVE=false
    NS_CLI_WANTS_HELP=false
}

# Parses global flags from "$@". Sets NS_CLI_REMAINING (array). Do not run in a command substitution if you need flag side effects.
ns_cli_parse() {
    NS_CLI_REMAINING=()
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --verbose | -v)
                NS_CLI_VERBOSE=true
                shift
                ;;
            --quiet | -q)
                NS_CLI_QUIET=true
                shift
                ;;
            --non-interactive | -y)
                NS_CLI_NON_INTERACTIVE=true
                shift
                ;;
            --help | -h)
                NS_CLI_WANTS_HELP=true
                shift
                ;;
            --)
                shift
                NS_CLI_REMAINING=("$@")
                return 0
                ;;
            *)
                NS_CLI_REMAINING+=("$1")
                shift
                ;;
        esac
    done
}
