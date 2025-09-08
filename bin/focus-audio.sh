#!/usr/bin/env bash

set -euo pipefail

# Open URL in a cross-platform way; fall back to echo
open_url() {
	local url="$1"
	if command -v xdg-open >/dev/null 2>&1; then
		xdg-open "$url" >/dev/null 2>&1 || echo "$url"
	elif command -v open >/dev/null 2>&1; then
		open "$url" >/dev/null 2>&1 || echo "$url"
	else
		echo "$url"
	fi
}

show_help() {
	cat <<EOF
Usage: $(basename "$0") [mode]

Modes:
  activation   Play the Primary Anthem to prime focus and intent
  deep         Start the Operational Playlist for deep work
  debug        Playlist at lower intensity for debugging/triage
  design       Playlist for ideation with room for synthesis
  playlist     Open the Operational Playlist explicitly
  anthem       Open the Primary Anthem explicitly
  --help, -h   Show this help

Examples:
  $(basename "$0") activation
  $(basename "$0") deep
  $(basename "$0") playlist
EOF
}

PRIMARY_ANTHEM_URL="https://music.youtube.com/watch?v=QTFOkMXrq30" # Glitch Mob - We Can Make the World Stop
OPERATIONAL_PLAYLIST_URL="https://music.youtube.com/playlist?list=PLvKgYUw_tuTudYkcfgWCc_e9OyDhfFFSI"

mode="${1:-}" 

case "$mode" in
	activation|anthem)
		open_url "$PRIMARY_ANTHEM_URL"
		;;
	deep|playlist)
		open_url "$OPERATIONAL_PLAYLIST_URL"
		;;
	debug|design)
		open_url "$OPERATIONAL_PLAYLIST_URL"
		;;
	--help|-h|help|"")
		show_help
		;;
	*)
		echo "Unknown mode: $mode" >&2
		show_help
		exit 1
		;;
esac

