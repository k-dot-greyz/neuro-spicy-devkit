#!/bin/bash

# 🔑 GitHub Token Setup
# Guides the user through setting up a GitHub Personal Access Token
# Stores it securely in ~/.config/neuro-spicy/credentials (chmod 600)

set -euo pipefail

# --- Color Definitions ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
# shellcheck disable=SC2034
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# --- Defaults ---
CREDS_DIR="$HOME/.config/neuro-spicy"
CREDS_FILE="$CREDS_DIR/credentials"
DRY_RUN=false
TEST_ONLY=false

# --- Usage ---
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Sets up a GitHub Personal Access Token for Neuro-Spicy DevKit."
    echo "Token is stored in ${CREDS_FILE} with restricted permissions."
    echo ""
    echo "Options:"
    echo "  --test, -t       Test existing token without prompting"
    echo "  --dry-run, -d    Show what would be done without making changes"
    echo "  --help, -h       Show this help message"
    echo ""
    echo "Required token scopes: repo, gist, user"
    echo "Create at: https://github.com/settings/tokens"
}

# --- Parse Arguments ---
while [[ $# -gt 0 ]]; do
    case $1 in
        --test|-t)
            TEST_ONLY=true
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

# --- Test token validity ---
test_token() {
    local token="$1"
    local response
    response=$(curl -s -w "\n%{http_code}" -H "Authorization: token ${token}" https://api.github.com/user 2>/dev/null) || {
        echo -e "${RED}❌ Network error — could not reach api.github.com${NC}"
        return 1
    }

    local http_code
    http_code=$(echo "$response" | tail -1)
    local body
    body=$(echo "$response" | head -n -1)

    if [[ "$http_code" == "200" ]]; then
        local username
        username=$(echo "$body" | grep '"login"' | head -1 | cut -d'"' -f4)
        echo -e "${GREEN}✅ Token valid — authenticated as: ${username}${NC}"
        return 0
    else
        echo -e "${RED}❌ Token invalid (HTTP ${http_code})${NC}"
        return 1
    fi
}

# --- Test-only mode ---
if [[ "$TEST_ONLY" == "true" ]]; then
    if [[ -n "${GITHUB_TOKEN:-}" ]]; then
        echo -e "${CYAN}🔍 Testing existing GITHUB_TOKEN...${NC}"
        test_token "$GITHUB_TOKEN"
        exit $?
    elif [[ -f "$CREDS_FILE" ]]; then
        echo -e "${CYAN}🔍 Loading token from ${CREDS_FILE}...${NC}"
        # shellcheck source=/dev/null
        source "$CREDS_FILE"
        if [[ -n "${GITHUB_TOKEN:-}" ]]; then
            test_token "$GITHUB_TOKEN"
            exit $?
        fi
    fi
    echo -e "${YELLOW}⚠️ No token found. Run without --test to set one up.${NC}"
    exit 1
fi

# --- Dry run ---
if [[ "$DRY_RUN" == "true" ]]; then
    echo -e "${YELLOW}🔍 DRY RUN — would:${NC}"
    echo -e "${CYAN}  1. Prompt for GitHub Personal Access Token${NC}"
    echo -e "${CYAN}  2. Validate token against api.github.com${NC}"
    echo -e "${CYAN}  3. Store in ${CREDS_FILE} (chmod 600)${NC}"
    echo -e "${CYAN}  4. Wire ~/.bashrc and ~/.zshrc to source it${NC}"
    exit 0
fi

# --- Main setup flow ---
echo -e "${MAGENTA}🔑 GitHub Token Setup${NC}"
echo -e "${MAGENTA}=====================${NC}"
echo ""

# Check for existing token
if [[ -n "${GITHUB_TOKEN:-}" ]]; then
    echo -e "${YELLOW}⚠️ GITHUB_TOKEN is already set in your environment.${NC}"
    echo -e "${CYAN}Testing it...${NC}"
    if test_token "$GITHUB_TOKEN"; then
        echo ""
        echo -ne "${YELLOW}Replace with a new token? (y/N): ${NC}"
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            echo -e "${GREEN}Keeping existing token.${NC}"
            exit 0
        fi
    fi
    echo ""
fi

# Instructions
echo -e "${CYAN}To create a GitHub Personal Access Token:${NC}"
echo -e "${CYAN}  1. Go to: https://github.com/settings/tokens${NC}"
echo -e "${CYAN}  2. Click 'Generate new token (classic)'${NC}"
echo -e "${CYAN}  3. Required scopes: repo, gist, user${NC}"
echo -e "${CYAN}  4. Copy the token (you won't see it again!)${NC}"
echo ""

# Prompt for token
echo -ne "${YELLOW}Enter your GitHub Personal Access Token: ${NC}"
read -rs token_input
echo ""

# Validate length
if [[ ${#token_input} -lt 40 ]]; then
    echo -e "${RED}❌ Token too short (expected 40+ characters). Aborting.${NC}"
    exit 1
fi

# Test the token
echo -e "${CYAN}🔍 Validating token...${NC}"
if ! test_token "$token_input"; then
    echo -e "${RED}Token validation failed. Not saving.${NC}"
    exit 1
fi

# Store securely (umask 077 prevents race condition where file is briefly world-readable)
mkdir -p "$CREDS_DIR"
chmod 700 "$CREDS_DIR"
(
    umask 077
    printf 'export GITHUB_TOKEN=%q\n' "$token_input" > "$CREDS_FILE"
)
echo -e "${GREEN}✅ Token saved to ${CREDS_FILE} (mode 600)${NC}"

# Wire into shell configs
# shellcheck disable=SC2016
if ! grep -q "neuro-spicy/credentials" ~/.bashrc 2>/dev/null; then
    echo '[ -f ~/.config/neuro-spicy/credentials ] && source ~/.config/neuro-spicy/credentials' >> ~/.bashrc
    echo -e "${GREEN}✅ Added source line to ~/.bashrc${NC}"
fi
# shellcheck disable=SC2016
if ! grep -q "neuro-spicy/credentials" ~/.zshrc 2>/dev/null; then
    echo '[ -f ~/.config/neuro-spicy/credentials ] && source ~/.config/neuro-spicy/credentials' >> ~/.zshrc
    echo -e "${GREEN}✅ Added source line to ~/.zshrc${NC}"
fi

# Export for current session
export GITHUB_TOKEN="$token_input"

echo ""
echo -e "${GREEN}🎉 GitHub token setup complete!${NC}"
echo -e "${CYAN}Token is available in this session and future shells.${NC}"
