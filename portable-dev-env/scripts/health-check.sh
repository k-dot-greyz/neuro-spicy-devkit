#!/bin/bash

# Neuro-Spicy DevKit Health Check System (Bash/Linux Version)
# Comprehensive environment validation and setup suggestions

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Parse command line arguments
VERBOSE=false
FIX=false
SUGGEST=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        --fix)
            FIX=true
            shift
            ;;
        --suggest)
            SUGGEST=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  --verbose, -v    Show detailed output"
            echo "  --fix            Attempt to fix issues automatically"
            echo "  --suggest        Show setup suggestions"
            echo "  --help, -h       Show this help message"
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

test_docker() {
    echo -e "${BLUE}🐳 Checking Docker...${NC}"
    
    if command -v docker &> /dev/null; then
        DOCKER_VERSION=$(docker --version 2>/dev/null)
        log_success "Docker: $DOCKER_VERSION"
        
        # Check if Docker is running
        if docker info &> /dev/null; then
            log_success "Docker is running"
            
            # Check Docker MCP Gateway
            if docker mcp gateway run --help &> /dev/null; then
                log_success "Docker MCP Gateway available"
                echo "DOCKER_STATUS=OK"
                echo "DOCKER_VERSION=$DOCKER_VERSION"
                echo "DOCKER_RUNNING=true"
                echo "DOCKER_MCP_GATEWAY=true"
            else
                log_warn "Docker MCP Gateway not available"
                echo "DOCKER_STATUS=Partial"
                echo "DOCKER_VERSION=$DOCKER_VERSION"
                echo "DOCKER_RUNNING=true"
                echo "DOCKER_MCP_GATEWAY=false"
            fi
        else
            log_error "Docker is not running"
            echo "DOCKER_STATUS=NotRunning"
            echo "DOCKER_VERSION=$DOCKER_VERSION"
            echo "DOCKER_RUNNING=false"
            echo "DOCKER_MCP_GATEWAY=false"
        fi
    else
        log_error "Docker not found"
        echo "DOCKER_STATUS=NotFound"
        echo "DOCKER_VERSION="
        echo "DOCKER_RUNNING=false"
        echo "DOCKER_MCP_GATEWAY=false"
    fi
}

test_git() {
    echo -e "${BLUE}📝 Checking Git...${NC}"
    
    if command -v git &> /dev/null; then
        GIT_VERSION=$(git --version 2>/dev/null)
        log_success "Git: $GIT_VERSION"
        
        # Check Git configuration
        GIT_USER=$(git config --global user.name 2>/dev/null || echo "")
        GIT_EMAIL=$(git config --global user.email 2>/dev/null || echo "")
        
        if [[ -n "$GIT_USER" && -n "$GIT_EMAIL" ]]; then
            log_success "Git configured: $GIT_USER <$GIT_EMAIL>"
            echo "GIT_STATUS=OK"
            echo "GIT_VERSION=$GIT_VERSION"
            echo "GIT_CONFIGURED=true"
            echo "GIT_USER=$GIT_USER"
            echo "GIT_EMAIL=$GIT_EMAIL"
        else
            log_warn "Git not fully configured"
            echo "GIT_STATUS=Partial"
            echo "GIT_VERSION=$GIT_VERSION"
            echo "GIT_CONFIGURED=false"
            echo "GIT_USER=$GIT_USER"
            echo "GIT_EMAIL=$GIT_EMAIL"
        fi
    else
        log_error "Git not found"
        echo "GIT_STATUS=NotFound"
        echo "GIT_VERSION="
        echo "GIT_CONFIGURED=false"
        echo "GIT_USER="
        echo "GIT_EMAIL="
    fi
}

test_nodejs() {
    echo -e "${BLUE}📦 Checking Node.js...${NC}"
    
    if command -v node &> /dev/null; then
        NODE_VERSION=$(node --version 2>/dev/null)
        log_success "Node.js: $NODE_VERSION"
        
        # Check npm
        if command -v npm &> /dev/null; then
            NPM_VERSION=$(npm --version 2>/dev/null)
            log_success "npm: $NPM_VERSION"
            
            # Check for MCP servers
            MCP_SERVERS=()
            if npm list -g --depth=0 2>/dev/null | grep -q "git-mcp-server"; then
                MCP_SERVERS+=("git-mcp-server")
            fi
            if npm list -g --depth=0 2>/dev/null | grep -q "mcp-server-filesystem"; then
                MCP_SERVERS+=("mcp-server-filesystem")
            fi
            if npm list -g --depth=0 2>/dev/null | grep -q "shadcn-ui-mcp-server"; then
                MCP_SERVERS+=("shadcn-ui-mcp-server")
            fi
            
            if [[ ${#MCP_SERVERS[@]} -gt 0 ]]; then
                log_success "MCP Servers installed: ${MCP_SERVERS[*]}"
            else
                log_warn "No MCP servers installed"
            fi
            
            echo "NODEJS_STATUS=OK"
            echo "NODEJS_VERSION=$NODE_VERSION"
            echo "NPM_VERSION=$NPM_VERSION"
            echo "MCP_SERVERS=${MCP_SERVERS[*]}"
        else
            log_error "npm not found"
            echo "NODEJS_STATUS=Partial"
            echo "NODEJS_VERSION=$NODE_VERSION"
            echo "NPM_VERSION="
            echo "MCP_SERVERS="
        fi
    else
        log_error "Node.js not found"
        echo "NODEJS_STATUS=NotFound"
        echo "NODEJS_VERSION="
        echo "NPM_VERSION="
        echo "MCP_SERVERS="
    fi
}

test_python() {
    echo -e "${BLUE}🐍 Checking Python...${NC}"
    
    if command -v python3 &> /dev/null; then
        PYTHON_VERSION=$(python3 --version 2>/dev/null)
        log_success "Python: $PYTHON_VERSION"
        
        # Check pip
        if command -v pip3 &> /dev/null; then
            PIP_VERSION=$(pip3 --version 2>/dev/null)
            log_success "pip: $PIP_VERSION"
            echo "PYTHON_STATUS=OK"
            echo "PYTHON_VERSION=$PYTHON_VERSION"
            echo "PIP_VERSION=$PIP_VERSION"
        else
            log_error "pip not found"
            echo "PYTHON_STATUS=Partial"
            echo "PYTHON_VERSION=$PYTHON_VERSION"
            echo "PIP_VERSION="
        fi
    elif command -v python &> /dev/null; then
        PYTHON_VERSION=$(python --version 2>/dev/null)
        log_success "Python: $PYTHON_VERSION"
        
        # Check pip
        if command -v pip &> /dev/null; then
            PIP_VERSION=$(pip --version 2>/dev/null)
            log_success "pip: $PIP_VERSION"
            echo "PYTHON_STATUS=OK"
            echo "PYTHON_VERSION=$PYTHON_VERSION"
            echo "PIP_VERSION=$PIP_VERSION"
        else
            log_error "pip not found"
            echo "PYTHON_STATUS=Partial"
            echo "PYTHON_VERSION=$PYTHON_VERSION"
            echo "PIP_VERSION="
        fi
    else
        log_error "Python not found"
        echo "PYTHON_STATUS=NotFound"
        echo "PYTHON_VERSION="
        echo "PIP_VERSION="
    fi
}

test_github_token() {
    echo -e "${BLUE}🔑 Checking GitHub Token...${NC}"
    
    if [[ -n "${GITHUB_TOKEN:-}" ]]; then
        if curl -s -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user | grep -q '"login"'; then
            GITHUB_USER=$(curl -s -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user | grep '"login"' | cut -d'"' -f4)
            log_success "GitHub Token valid for: $GITHUB_USER"
            echo "GITHUB_TOKEN_STATUS=OK"
            echo "GITHUB_USER=$GITHUB_USER"
            echo "GITHUB_TOKEN=${GITHUB_TOKEN:0:10}..."
        else
            log_error "GitHub Token invalid"
            echo "GITHUB_TOKEN_STATUS=Invalid"
            echo "GITHUB_USER="
            echo "GITHUB_TOKEN="
        fi
    else
        log_warn "GitHub Token not set"
        echo "GITHUB_TOKEN_STATUS=NotSet"
        echo "GITHUB_USER="
        echo "GITHUB_TOKEN="
    fi
}

test_cursor() {
    echo -e "${BLUE}🎯 Checking Cursor...${NC}"
    
    CURSOR_PATHS=(
        "$HOME/.cursor"
        "$HOME/.config/cursor"
        "/opt/cursor"
        "/usr/local/bin/cursor"
    )
    
    for path in "${CURSOR_PATHS[@]}"; do
        if [[ -d "$path" ]]; then
            log_success "Cursor found at: $path"
            
            # Check for MCP config
            MCP_CONFIG_PATH="$path/mcp.json"
            if [[ -f "$MCP_CONFIG_PATH" ]]; then
                log_success "Cursor MCP config found"
                echo "CURSOR_STATUS=OK"
                echo "CURSOR_PATH=$path"
                echo "CURSOR_MCP_CONFIG=true"
                return
            else
                log_warn "Cursor MCP config not found"
                echo "CURSOR_STATUS=Partial"
                echo "CURSOR_PATH=$path"
                echo "CURSOR_MCP_CONFIG=false"
                return
            fi
        fi
    done
    
    log_error "Cursor not found"
    echo "CURSOR_STATUS=NotFound"
    echo "CURSOR_PATH="
    echo "CURSOR_MCP_CONFIG=false"
}

get_setup_suggestions() {
    echo -e "${MAGENTA}💡 Setup Suggestions:${NC}"
    echo -e "${MAGENTA}===================${NC}"
    
    # Docker suggestions
    if [[ "$DOCKER_STATUS" == "NotFound" ]]; then
        echo -e "${YELLOW}🐳 Install Docker:${NC}"
        echo -e "${CYAN}   # Ubuntu/Debian:${NC}"
        echo -e "${CYAN}   curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh${NC}"
        echo -e "${CYAN}   # macOS:${NC}"
        echo -e "${CYAN}   brew install --cask docker${NC}"
        echo -e "${CYAN}   # Or download from: https://www.docker.com/products/docker-desktop${NC}"
    elif [[ "$DOCKER_STATUS" == "NotRunning" ]]; then
        echo -e "${YELLOW}🐳 Start Docker:${NC}"
        echo -e "${CYAN}   sudo systemctl start docker  # Linux${NC}"
        echo -e "${CYAN}   # Or start Docker Desktop${NC}"
    fi
    
    # Git suggestions
    if [[ "$GIT_STATUS" == "NotFound" ]]; then
        echo -e "${YELLOW}📝 Install Git:${NC}"
        echo -e "${CYAN}   # Ubuntu/Debian:${NC}"
        echo -e "${CYAN}   sudo apt update && sudo apt install git${NC}"
        echo -e "${CYAN}   # macOS:${NC}"
        echo -e "${CYAN}   brew install git${NC}"
    elif [[ "$GIT_STATUS" == "Partial" ]]; then
        echo -e "${YELLOW}📝 Configure Git:${NC}"
        echo -e "${CYAN}   git config --global user.name 'Your Name'${NC}"
        echo -e "${CYAN}   git config --global user.email 'your.email@example.com'${NC}"
    fi
    
    # Node.js suggestions
    if [[ "$NODEJS_STATUS" == "NotFound" ]]; then
        echo -e "${YELLOW}📦 Install Node.js:${NC}"
        echo -e "${CYAN}   # Using Node Version Manager (recommended):${NC}"
        echo -e "${CYAN}   curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash${NC}"
        echo -e "${CYAN}   nvm install --lts && nvm use --lts${NC}"
        echo -e "${CYAN}   # Or download from: https://nodejs.org${NC}"
    elif [[ -z "$MCP_SERVERS" ]]; then
        echo -e "${YELLOW}📦 Install MCP Servers:${NC}"
        echo -e "${CYAN}   npm install -g @cyanheads/git-mcp-server${NC}"
        echo -e "${CYAN}   npm install -g @modelcontextprotocol/server-filesystem${NC}"
        echo -e "${CYAN}   npm install -g @jpisnice/shadcn-ui-mcp-server${NC}"
    fi
    
    # GitHub Token suggestions
    if [[ "$GITHUB_TOKEN_STATUS" == "NotSet" ]]; then
        echo -e "${YELLOW}🔑 Set GitHub Token:${NC}"
        echo -e "${CYAN}   Create token at: https://github.com/settings/tokens${NC}"
        echo -e "${CYAN}   Set scopes: gist, repo${NC}"
        echo -e "${CYAN}   Set environment: export GITHUB_TOKEN='your_token_here'${NC}"
    fi
    
    # Cursor suggestions
    if [[ "$CURSOR_STATUS" == "NotFound" ]]; then
        echo -e "${YELLOW}🎯 Install Cursor:${NC}"
        echo -e "${CYAN}   Download from: https://cursor.sh${NC}"
    elif [[ "$CURSOR_STATUS" == "Partial" ]]; then
        echo -e "${YELLOW}🎯 Setup Cursor MCP:${NC}"
        echo -e "${CYAN}   Run: ./portable-dev-env/scripts/setup.sh --platform linux --components cursor${NC}"
    fi
}

show_summary() {
    echo -e "${BLUE}📊 Health Check Summary${NC}"
    echo -e "${BLUE}======================${NC}"
    
    TOTAL_CHECKS=6
    PASSED_CHECKS=0
    
    if [[ "$DOCKER_STATUS" == "OK" ]]; then ((PASSED_CHECKS++)); fi
    if [[ "$GIT_STATUS" == "OK" ]]; then ((PASSED_CHECKS++)); fi
    if [[ "$NODEJS_STATUS" == "OK" ]]; then ((PASSED_CHECKS++)); fi
    if [[ "$PYTHON_STATUS" == "OK" ]]; then ((PASSED_CHECKS++)); fi
    if [[ "$GITHUB_TOKEN_STATUS" == "OK" ]]; then ((PASSED_CHECKS++)); fi
    if [[ "$CURSOR_STATUS" == "OK" ]]; then ((PASSED_CHECKS++)); fi
    
    echo -e "${GREEN}✅ Passed: $PASSED_CHECKS/$TOTAL_CHECKS${NC}"
    
    if [[ $PASSED_CHECKS -eq $TOTAL_CHECKS ]]; then
        echo -e "${GREEN}🎉 All systems ready for neuro-spicy development!${NC}"
    elif [[ $PASSED_CHECKS -ge 4 ]]; then
        echo -e "${YELLOW}⚠️ Most systems ready, some setup needed${NC}"
    else
        echo -e "${RED}❌ Significant setup required${NC}"
    fi
}

# Main execution
echo -e "${MAGENTA}🧠 Neuro-Spicy DevKit Health Check${NC}"
echo -e "${MAGENTA}=================================${NC}"
echo ""

# Run all tests and capture results
DOCKER_RESULT=$(test_docker)
eval "$DOCKER_RESULT"

GIT_RESULT=$(test_git)
eval "$GIT_RESULT"

NODEJS_RESULT=$(test_nodejs)
eval "$NODEJS_RESULT"

PYTHON_RESULT=$(test_python)
eval "$PYTHON_RESULT"

GITHUB_TOKEN_RESULT=$(test_github_token)
eval "$GITHUB_TOKEN_RESULT"

CURSOR_RESULT=$(test_cursor)
eval "$CURSOR_RESULT"

echo ""
show_summary

if [[ "$SUGGEST" == "true" ]]; then
    echo ""
    get_setup_suggestions
fi

if [[ "$VERBOSE" == "true" ]]; then
    echo ""
    echo -e "${CYAN}🔍 Detailed Results:${NC}"
    echo "DOCKER_STATUS=$DOCKER_STATUS"
    echo "GIT_STATUS=$GIT_STATUS"
    echo "NODEJS_STATUS=$NODEJS_STATUS"
    echo "PYTHON_STATUS=$PYTHON_STATUS"
    echo "GITHUB_TOKEN_STATUS=$GITHUB_TOKEN_STATUS"
    echo "CURSOR_STATUS=$CURSOR_STATUS"
fi
