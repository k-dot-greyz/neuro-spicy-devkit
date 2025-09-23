#!/bin/bash

# Make scripts executable (Linux/macOS only)
# This script is for Linux/macOS environments

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Making bash scripts executable..."

chmod +x "$SCRIPT_DIR"/*.sh

echo "✅ All bash scripts are now executable!"
echo ""
echo "Available scripts:"
ls -la "$SCRIPT_DIR"/*.sh
