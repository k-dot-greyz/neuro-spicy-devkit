#!/bin/bash

# Make bash scripts executable (cross-platform)

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 Making bash scripts executable...${NC}"

# List of scripts to make executable
scripts=(
    "health-check-core.sh"
    "neuro-spicy-setup-core.sh"
    "git-push-retry.sh"
    "setup-github-token.sh"
    "neuro-spicy-init.sh"
    "setup-bash-default.sh"
    "test-bash-scripts.sh"
)

# Make scripts executable
for script in "${scripts[@]}"; do
    if [[ -f "$script" ]]; then
        chmod +x "$script"
        echo -e "${GREEN}✅ Made $script executable${NC}"
    else
        echo -e "${BLUE}⚠️ $script not found${NC}"
    fi
done

echo -e "${GREEN}🎉 All bash scripts are now executable!${NC}"
