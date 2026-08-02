#!/bin/bash

# 🔄 Git Push with Retry (Exponential Backoff)
# Reliable git push for flaky networks / CI environments

set -euo pipefail

# --- Color Definitions ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
# shellcheck disable=SC2034
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# --- Defaults ---
BRANCH=""
REMOTE="origin"
MAX_RETRIES=4
DRY_RUN=false
FORCE=false

# --- Usage ---
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Pushes the current branch to a remote with retry + exponential backoff."
    echo ""
    echo "Options:"
    echo "  --branch, -b <name>    Branch to push (default: current branch)"
    echo "  --remote, -r <name>    Remote name (default: origin)"
    echo "  --retries, -n <count>  Max retry attempts (default: 4)"
    echo "  --force, -f            Force push (use with caution)"
    echo "  --dry-run, -d          Show what would be done without pushing"
    echo "  --help, -h             Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 --branch main"
    echo "  $0 --branch feature/cool-stuff --retries 3"
    echo "  $0 --dry-run"
}

# --- Parse Arguments ---
while [[ $# -gt 0 ]]; do
    case $1 in
        --branch|-b)
            BRANCH="$2"
            shift 2
            ;;
        --remote|-r)
            REMOTE="$2"
            shift 2
            ;;
        --retries|-n)
            MAX_RETRIES="$2"
            shift 2
            ;;
        --force|-f)
            FORCE=true
            shift
            ;;
        --dry-run|-d)
            DRY_RUN=true
            shift
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

# --- Resolve branch ---
if [[ -z "$BRANCH" ]]; then
    BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null) || {
        echo -e "${RED}ERROR: Not in a git repository or unable to determine current branch${NC}"
        exit 1
    }
fi

# --- Verify git state ---
if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo -e "${RED}ERROR: Not in a git repository${NC}"
    exit 1
fi

# --- Build push command ---
PUSH_CMD="git push -u ${REMOTE} ${BRANCH}"
if [[ "$FORCE" == "true" ]]; then
    PUSH_CMD="git push -u --force-with-lease ${REMOTE} ${BRANCH}"
fi

# --- Dry run ---
if [[ "$DRY_RUN" == "true" ]]; then
    echo -e "${YELLOW}🔍 DRY RUN — would execute:${NC}"
    echo -e "${CYAN}  ${PUSH_CMD}${NC}"
    echo -e "${CYAN}  Remote: ${REMOTE}${NC}"
    echo -e "${CYAN}  Branch: ${BRANCH}${NC}"
    echo -e "${CYAN}  Max retries: ${MAX_RETRIES}${NC}"
    echo -e "${CYAN}  Force: ${FORCE}${NC}"
    exit 0
fi

# --- Push with retry ---
echo -e "${CYAN}🔄 Pushing ${BRANCH} to ${REMOTE}...${NC}"

attempt=1
backoff=4

while [[ $attempt -le $MAX_RETRIES ]]; do
    echo -e "${CYAN}  Attempt ${attempt}/${MAX_RETRIES}...${NC}"

    if $PUSH_CMD 2>&1; then
        echo -e "${GREEN}✅ Push successful on attempt ${attempt}${NC}"
        exit 0
    fi

    if [[ $attempt -eq $MAX_RETRIES ]]; then
        echo -e "${RED}❌ Push failed after ${MAX_RETRIES} attempts${NC}"
        exit 1
    fi

    echo -e "${YELLOW}⚠️ Push failed. Retrying in ${backoff}s...${NC}"
    sleep "$backoff"
    backoff=$((backoff * 2))
    attempt=$((attempt + 1))
done
