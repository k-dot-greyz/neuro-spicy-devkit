#!/bin/bash

# 🧠 Neuro-Spicy Health Check (Core Essentials Only)
# Validates the essential environment for neuro-spicy development

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
VERBOSE=false
FIX=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        --fix|-f)
            FIX=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  --verbose, -v    Show verbose information"
            echo "  --fix, -f        Show fix suggestions"
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

test_git() {
    log_info "Checking Git..."
    
    if command -v git >/dev/null 2>&1; then
        local git_version
        git_version=$(git --version 2>&1)
        log_success "Git: $git_version"
        
        # Check Git configuration
        local user_name user_email
        user_name=$(git config --global user.name 2>/dev/null || echo "")
        user_email=$(git config --global user.email 2>/dev/null || echo "")
        
        if [[ -n "$user_name" && -n "$user_email" ]]; then
            log_success "Git configured: $user_name <$user_email>"
        else
            log_warn "Git not configured"
            if [[ "$FIX" == "true" ]]; then
                echo -e "${BLUE}💡 Run: git config --global user.name 'Your Name'${NC}"
                echo -e "${BLUE}💡 Run: git config --global user.email 'your.email@example.com'${NC}"
            fi
        fi
        
        return 0
    else
        log_error "Git: Not installed"
        if [[ "$FIX" == "true" ]]; then
            echo -e "${BLUE}💡 Install: sudo apt-get install git${NC}"
            echo -e "${BLUE}💡 Or: brew install git${NC}"
        fi
        return 1
    fi
}

test_nodejs() {
    log_info "Checking Node.js..."
    
    if command -v node >/dev/null 2>&1; then
        local node_version npm_version
        node_version=$(node --version 2>&1)
        npm_version=$(npm --version 2>&1)
        
        if [[ "$node_version" =~ v(1[8-9]|2[0-9]) ]]; then
            log_success "Node.js: $node_version"
            log_success "npm: $npm_version"
            return 0
        else
            log_error "Node.js: Version 18+ required (found: $node_version)"
            if [[ "$FIX" == "true" ]]; then
                echo -e "${BLUE}💡 Install: curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - && sudo apt-get install -y nodejs${NC}"
                echo -e "${BLUE}💡 Or: brew install node@18${NC}"
            fi
            return 1
        fi
    else
        log_error "Node.js: Not installed"
        if [[ "$FIX" == "true" ]]; then
            echo -e "${BLUE}💡 Install: curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - && sudo apt-get install -y nodejs${NC}"
            echo -e "${BLUE}💡 Or: brew install node@18${NC}"
        fi
        return 1
    fi
}

test_python() {
    log_info "Checking Python..."
    
    if command -v python3 >/dev/null 2>&1; then
        local python_version
        python_version=$(python3 --version 2>&1)
        
        if [[ "$python_version" =~ Python\ 3\.([8-9]|1[0-9]) ]]; then
            log_success "Python: $python_version"
            return 0
        else
            log_error "Python: Version 3.8+ required (found: $python_version)"
            if [[ "$FIX" == "true" ]]; then
                echo -e "${BLUE}💡 Install: sudo apt-get install python3.11${NC}"
                echo -e "${BLUE}💡 Or: brew install python@3.11${NC}"
            fi
            return 1
        fi
    elif command -v python >/dev/null 2>&1; then
        local python_version
        python_version=$(python --version 2>&1)
        
        if [[ "$python_version" =~ Python\ 3\.([8-9]|1[0-9]) ]]; then
            log_success "Python: $python_version"
            return 0
        else
            log_error "Python: Version 3.8+ required (found: $python_version)"
            if [[ "$FIX" == "true" ]]; then
                echo -e "${BLUE}💡 Install: sudo apt-get install python3.11${NC}"
                echo -e "${BLUE}💡 Or: brew install python@3.11${NC}"
            fi
            return 1
        fi
    else
        log_error "Python: Not installed"
        if [[ "$FIX" == "true" ]]; then
            echo -e "${BLUE}💡 Install: sudo apt-get install python3.11${NC}"
            echo -e "${BLUE}💡 Or: brew install python@3.11${NC}"
        fi
        return 1
    fi
}

test_github_token() {
    log_info "Checking GitHub token..."
    
    if [[ -n "${GITHUB_TOKEN:-}" ]]; then
        log_success "GitHub token: Set"
        return 0
    else
        log_warn "GitHub token: Not set"
        if [[ "$FIX" == "true" ]]; then
            echo -e "${BLUE}💡 Set: export GITHUB_TOKEN='your_token_here'${NC}"
            echo -e "${BLUE}💡 Or: ./scripts/setup-github-token.sh${NC}"
        fi
        return 1
    fi
}

test_cursor() {
    log_info "Checking Cursor..."
    
    # Check common Cursor installation paths
    local cursor_paths=(
        "/usr/local/bin/cursor"
        "/opt/cursor/cursor"
        "$HOME/.local/bin/cursor"
        "/Applications/Cursor.app/Contents/MacOS/Cursor"
    )
    
    for path in "${cursor_paths[@]}"; do
        if [[ -f "$path" ]]; then
            log_success "Cursor: Installed"
            return 0
        fi
    done
    
    log_warn "Cursor: Not found"
    if [[ "$FIX" == "true" ]]; then
        echo -e "${BLUE}💡 Download: https://cursor.sh/${NC}"
    fi
    return 1
}

test_vscode() {
    log_info "Checking VSCode..."
    
    if command -v code >/dev/null 2>&1; then
        local code_version
        code_version=$(code --version 2>&1 | head -n1)
        log_success "VSCode: $code_version"
        return 0
    else
        # Check common VSCode installation paths
        local vscode_paths=(
            "/usr/local/bin/code"
            "/opt/visual-studio-code/code"
            "$HOME/.local/bin/code"
            "/Applications/Visual Studio Code.app/Contents/MacOS/Electron"
        )
        
        for path in "${vscode_paths[@]}"; do
            if [[ -f "$path" ]]; then
                log_success "VSCode: Installed"
                return 0
            fi
        done
        
        log_warn "VSCode: Not found"
        if [[ "$FIX" == "true" ]]; then
            echo -e "${BLUE}💡 Install: sudo apt-get install code${NC}"
            echo -e "${BLUE}💡 Or: brew install --cask visual-studio-code${NC}"
        fi
        return 1
    fi
}

show_summary() {
    local results=("$@")
    
    echo ""
    echo -e "${MAGENTA}🧠 Neuro-Spicy Health Check Summary${NC}"
    echo -e "${MAGENTA}=================================${NC}"
    
    local total_checks=${#results[@]}
    local passed_checks=0
    local failed_checks=0
    
    for result in "${results[@]}"; do
        if [[ "$result" == "0" ]]; then
            ((passed_checks++))
        else
            ((failed_checks++))
        fi
    done
    
    echo "Total Checks: $total_checks"
    echo -e "${GREEN}Passed: $passed_checks${NC}"
    echo -e "${RED}Failed: $failed_checks${NC}"
    
    if [[ $failed_checks -eq 0 ]]; then
        echo ""
        echo -e "${GREEN}🎉 All core essentials are ready!${NC}"
        echo -e "${BLUE}Run: ./scripts/neuro-spicy-setup-core.sh --components core${NC}"
    else
        echo ""
        echo -e "${YELLOW}⚠️ Some components need attention${NC}"
        echo -e "${BLUE}Run: ./scripts/health-check-core.sh --fix${NC}"
    fi
}

# Main execution
echo -e "${MAGENTA}🧠 Neuro-Spicy Health Check (Core Essentials)${NC}"
echo -e "${MAGENTA}=============================================${NC}"
echo ""

# Run tests
test_git
git_result=$?

test_nodejs
nodejs_result=$?

test_python
python_result=$?

test_github_token
github_result=$?

test_cursor
cursor_result=$?

test_vscode
vscode_result=$?

# Show summary
show_summary "$git_result" "$nodejs_result" "$python_result" "$github_result" "$cursor_result" "$vscode_result"

if [[ "$VERBOSE" == "true" ]]; then
    echo ""
    echo -e "${CYAN}🔍 Verbose Information:${NC}"
    echo "OS: $(uname -s)"
    echo "Architecture: $(uname -m)"
    echo "Shell: $SHELL"
    echo "Working Directory: $(pwd)"
fi
