#!/bin/bash

# Git Push Retry Script (Bash/Linux Version)
# Handles network issues and retries failed pushes

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Default values
BRANCH="main"
MAX_RETRIES=3
DELAY_SECONDS=5

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --branch|-b)
            BRANCH="$2"
            shift 2
            ;;
        --max-retries|-r)
            MAX_RETRIES="$2"
            shift 2
            ;;
        --delay|-d)
            DELAY_SECONDS="$2"
            shift 2
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  --branch, -b <branch>        Branch to push (default: main)"
            echo "  --max-retries, -r <number>   Maximum retry attempts (default: 3)"
            echo "  --delay, -d <seconds>       Delay between retries (default: 5)"
            echo "  --help, -h                   Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0 --branch main --max-retries 5 --delay 10"
            echo "  $0 -b develop -r 2 -d 3"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

log_info() {
    echo -e "${CYAN}INFO: $1${NC}"
}

log_success() {
    echo -e "${GREEN}SUCCESS: $1${NC}"
}

log_warn() {
    echo -e "${YELLOW}WARN: $1${NC}"
}

log_error() {
    echo -e "${RED}ERROR: $1${NC}"
}

test_git_push() {
    local branch="$1"
    
    echo -e "${BLUE}🚀 Attempting to push to origin/$branch...${NC}"
    
    if git push origin "$branch" 2>&1; then
        echo -e "${GREEN}✅ Push successful!${NC}"
        return 0
    else
        local exit_code=$?
        echo -e "${RED}❌ Push failed with exit code: $exit_code${NC}"
        return 1
    fi
}

start_push_retry() {
    local branch="$1"
    local max_retries="$2"
    local delay_seconds="$3"
    
    echo -e "${MAGENTA}🔄 Git Push Retry Script${NC}"
    echo -e "${MAGENTA}=======================${NC}"
    echo ""
    
    for ((attempt=1; attempt<=max_retries; attempt++)); do
        echo -e "${CYAN}📤 Attempt $attempt of $max_retries${NC}"
        
        if test_git_push "$branch"; then
            echo -e "${GREEN}🎉 Push completed successfully!${NC}"
            return 0
        fi
        
        if [[ $attempt -lt $max_retries ]]; then
            echo -e "${YELLOW}⏳ Waiting $delay_seconds seconds before retry...${NC}"
            sleep "$delay_seconds"
        fi
    done
    
    echo -e "${RED}❌ All push attempts failed after $max_retries tries${NC}"
    echo -e "${YELLOW}💡 Try checking your network connection or Git credentials${NC}"
    return 1
}

# Main execution
start_push_retry "$BRANCH" "$MAX_RETRIES" "$DELAY_SECONDS"
