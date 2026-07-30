#!/usr/bin/env bash
# Neuro-Spicy DevKit — deep diagnostic (deps + configs; connectivity hooks later).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/ns-exit-codes.sh
source "$SCRIPT_DIR/lib/ns-exit-codes.sh"
# shellcheck source=lib/ns-cli.sh
source "$SCRIPT_DIR/lib/ns-cli.sh"

ns_cli_reset
ns_cli_parse "$@"

if [[ "${NS_CLI_WANTS_HELP:-false}" == "true" ]]; then
    cat <<'EOF'
Usage: doctor-core.sh [OPTIONS]

Deep diagnostic: runs health check and aggregates exit codes.

Options (shared CLI):
  --verbose, -v
  --quiet, -q
  --non-interactive, -y
  --dry-run, -n     List extra checks without running network probes (scaffold)
  --help, -h
EOF
    exit "$NS_EXIT_SUCCESS"
fi

health_args=()
[[ "${NS_CLI_VERBOSE:-false}" == "true" ]] && health_args+=(--verbose)

final_code="$NS_EXIT_SUCCESS"

if [[ "${NS_CLI_DRY_RUN:-false}" == "true" ]]; then
    echo "DRY-RUN: would run health-check-core.sh ${health_args[*]}"
    echo "DRY-RUN: would run connectivity probes (not implemented)"
    exit "$NS_EXIT_SUCCESS"
fi

set +e
bash "$SCRIPT_DIR/health-check-core.sh" "${health_args[@]}"
health_code=$?
set -e

if [[ $health_code -ne "$NS_EXIT_SUCCESS" ]]; then
    final_code=$health_code
fi

exit "$final_code"
