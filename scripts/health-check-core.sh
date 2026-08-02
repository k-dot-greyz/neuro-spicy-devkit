#!/bin/bash

# 🧠 Neuro-Spicy Health Check (Core Essentials Only)
# Validates the essential environment for neuro-spicy development

set -euo pipefail

# --- Color Definitions (Neuro-Spicy Standard) ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
# shellcheck disable=SC2034
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# --- Logging Functions ---
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

# --- Header Function ---
print_header() {
    echo -e "${MAGENTA}🧠 $1${NC}"
    echo -e "${MAGENTA}======================================${NC}"
    echo ""
}

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
        
        if [[ "$node_version" =~ v(1[8-9]|[2-9][0-9]|[1-9][0-9]{2,}) ]]; then
            log_success "Node.js: $node_version"
            log_success "npm: $npm_version"
            return 0
        else
            log_error "Node.js: Version 18+ required (found: $node_version)"
            if [[ "$FIX" == "true" ]]; then
                echo -e "${BLUE}💡 Install (nvm): nvm install --lts${NC}"
                echo -e "${BLUE}💡 Install (apt): curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - && sudo apt-get install -y nodejs${NC}"
                echo -e "${BLUE}💡 Install (brew): brew install node${NC}"
            fi
            return 1
        fi
    else
        log_error "Node.js: Not installed"
        if [[ "$FIX" == "true" ]]; then
            echo -e "${BLUE}💡 Install (nvm): nvm install --lts${NC}"
            echo -e "${BLUE}💡 Install (apt): curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - && sudo apt-get install -y nodejs${NC}"
            echo -e "${BLUE}💡 Install (brew): brew install node${NC}"
        fi
        return 1
    fi
}

test_python() {
    log_info "Checking Python..."
    
    if command -v python3 >/dev/null 2>&1; then
        local python_version
        python_version=$(python3 --version 2>&1)
        
        if [[ "$python_version" =~ Python\ 3\.([8-9]|[1-9][0-9]) ]]; then
            log_success "Python: $python_version"
            return 0
        else
            log_error "Python: Version 3.8+ required (found: $python_version)"
            if [[ "$FIX" == "true" ]]; then
                echo -e "${BLUE}💡 Install: sudo apt-get install python3${NC}"
                echo -e "${BLUE}💡 Or: brew install python${NC}"
            fi
            return 1
        fi
    elif command -v python >/dev/null 2>&1; then
        local python_version
        python_version=$(python --version 2>&1)
        
        if [[ "$python_version" =~ Python\ 3\.([8-9]|[1-9][0-9]) ]]; then
            log_success "Python: $python_version"
            return 0
        else
            log_error "Python: Version 3.8+ required (found: $python_version)"
            if [[ "$FIX" == "true" ]]; then
                echo -e "${BLUE}💡 Install: sudo apt-get install python3${NC}"
                echo -e "${BLUE}💡 Or: brew install python${NC}"
            fi
            return 1
        fi
    else
        log_error "Python: Not installed"
        if [[ "$FIX" == "true" ]]; then
            echo -e "${BLUE}💡 Install: sudo apt-get install python3${NC}"
            echo -e "${BLUE}💡 Or: brew install python${NC}"
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

test_rust() {
    log_info "Checking Rust..."

    if command -v rustc >/dev/null 2>&1; then
        local rust_version
        rust_version=$(rustc --version 2>&1)
        log_success "Rust: $rust_version"

        if command -v cargo >/dev/null 2>&1; then
            log_success "Cargo: $(cargo --version 2>&1)"
        else
            log_warn "Cargo: Not found (should come with rustup)"
        fi

        if command -v clippy-driver >/dev/null 2>&1 || rustup component list 2>/dev/null | grep -q "clippy.*installed"; then
            log_success "Clippy: Installed"
        else
            log_warn "Clippy: Not installed"
            if [[ "$FIX" == "true" ]]; then
                echo -e "${BLUE}💡 Install: rustup component add clippy${NC}"
            fi
        fi

        if command -v rustfmt >/dev/null 2>&1; then
            log_success "Rustfmt: Installed"
        else
            log_warn "Rustfmt: Not installed"
            if [[ "$FIX" == "true" ]]; then
                echo -e "${BLUE}💡 Install: rustup component add rustfmt${NC}"
            fi
        fi

        return 0
    else
        log_warn "Rust: Not installed"
        if [[ "$FIX" == "true" ]]; then
            echo -e "${BLUE}💡 Install: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh${NC}"
        fi
        return 1
    fi
}

test_typescript() {
    log_info "Checking TypeScript toolchain..."

    local ts_found=false

    if command -v tsc >/dev/null 2>&1; then
        log_success "TypeScript: $(tsc --version 2>&1)"
        ts_found=true
    else
        log_warn "TypeScript (tsc): Not found"
        if [[ "$FIX" == "true" ]]; then
            echo -e "${BLUE}💡 Install: npm install -g typescript${NC}"
        fi
    fi

    if command -v pnpm >/dev/null 2>&1; then
        log_success "pnpm: $(pnpm --version 2>&1)"
    else
        log_warn "pnpm: Not found"
        if [[ "$FIX" == "true" ]]; then
            echo -e "${BLUE}💡 Install: npm install -g pnpm${NC}"
        fi
    fi

    if command -v npx >/dev/null 2>&1; then
        log_success "npx: Available"
    fi

    if [[ "$ts_found" == "true" ]]; then return 0; else return 1; fi
}

test_astro_vite() {
    log_info "Checking Astro / Vite..."

    local found=false

    if command -v astro >/dev/null 2>&1; then
        log_success "Astro CLI: $(astro --version 2>&1 | head -1)"
        found=true
    else
        log_warn "Astro CLI: Not found (project-local is fine)"
        if [[ "$FIX" == "true" ]]; then
            echo -e "${BLUE}💡 Scaffold: npm create astro@latest${NC}"
        fi
    fi

    if command -v vite >/dev/null 2>&1; then
        log_success "Vite: $(vite --version 2>&1 | head -1)"
        found=true
    elif [[ -f "node_modules/.bin/vite" ]]; then
        log_success "Vite: Found (project-local)"
        found=true
    else
        log_warn "Vite: Not found (project-local is fine)"
        if [[ "$FIX" == "true" ]]; then
            echo -e "${BLUE}💡 Install: npm install -D vite${NC}"
        fi
    fi

    if [[ "$found" == "true" ]]; then return 0; else return 1; fi
}

test_playwright() {
    log_info "Checking Playwright..."

    if command -v playwright >/dev/null 2>&1 || npx playwright --version >/dev/null 2>&1; then
        local pw_version
        pw_version=$(npx playwright --version 2>&1 | head -1) || pw_version="installed"
        log_success "Playwright: $pw_version"
        return 0
    else
        log_warn "Playwright: Not found"
        if [[ "$FIX" == "true" ]]; then
            echo -e "${BLUE}💡 Install: npm install -D @playwright/test${NC}"
            echo -e "${BLUE}💡 Then: npx playwright install${NC}"
        fi
        return 1
    fi
}

test_ai_cli() {
    log_info "Checking AI CLI tools..."

    local found=0

    if command -v claude >/dev/null 2>&1; then
        log_success "Claude CLI: Installed"
        found=$((found + 1))
    else
        log_warn "Claude CLI: Not found"
        if [[ "$FIX" == "true" ]]; then
            echo -e "${BLUE}💡 Install: npm install -g @anthropic-ai/claude-cli${NC}"
        fi
    fi

    if command -v gemini >/dev/null 2>&1; then
        log_success "Gemini CLI: Installed"
        found=$((found + 1))
    else
        log_warn "Gemini CLI: Not found"
        if [[ "$FIX" == "true" ]]; then
            echo -e "${BLUE}💡 Install: npm install -g @anthropic-ai/gemini-cli${NC}"
        fi
    fi

    if command -v docker >/dev/null 2>&1; then
        log_success "Docker: $(docker --version 2>&1 | head -1)"
        found=$((found + 1))
        if command -v docker-compose >/dev/null 2>&1 || docker compose version >/dev/null 2>&1; then
            log_success "Docker Compose: Available"
        fi
    else
        log_warn "Docker: Not found"
        if [[ "$FIX" == "true" ]]; then
            echo -e "${BLUE}💡 Install: https://docs.docker.com/get-docker/${NC}"
        fi
    fi

    if command -v gh >/dev/null 2>&1; then
        log_success "GitHub CLI: $(gh --version 2>&1 | head -1)"
        found=$((found + 1))
    else
        log_warn "GitHub CLI (gh): Not found"
        if [[ "$FIX" == "true" ]]; then
            echo -e "${BLUE}💡 Install: https://cli.github.com/${NC}"
        fi
    fi

    if [[ $found -gt 0 ]]; then return 0; else return 1; fi
}

test_dev_tools() {
    log_info "Checking dev tools..."

    local found=0

    if command -v shellcheck >/dev/null 2>&1; then
        log_success "ShellCheck: $(shellcheck --version 2>&1 | grep version: | head -1)"
        found=$((found + 1))
    else
        log_warn "ShellCheck: Not found"
        if [[ "$FIX" == "true" ]]; then
            echo -e "${BLUE}💡 Install: sudo apt-get install shellcheck${NC}"
        fi
    fi

    if command -v shfmt >/dev/null 2>&1; then
        log_success "shfmt: $(shfmt --version 2>&1)"
        found=$((found + 1))
    else
        log_warn "shfmt: Not found"
        if [[ "$FIX" == "true" ]]; then
            echo -e "${BLUE}💡 Install: go install mvdan.cc/sh/v3/cmd/shfmt@latest${NC}"
        fi
    fi

    if command -v jq >/dev/null 2>&1; then
        log_success "jq: $(jq --version 2>&1)"
        found=$((found + 1))
    fi

    if command -v rg >/dev/null 2>&1; then
        log_success "ripgrep: $(rg --version 2>&1 | head -1)"
        found=$((found + 1))
    fi

    if command -v tree >/dev/null 2>&1; then
        log_success "tree: Available"
        found=$((found + 1))
    fi

    if [[ $found -gt 0 ]]; then return 0; else return 1; fi
}

test_openclaw() {
    log_info "Checking OpenClaw..."
    
    if command -v openclaw >/dev/null 2>&1; then
        local oc_version
        oc_version=$(openclaw --version 2>&1 | head -n1)
        log_success "OpenClaw: $oc_version"
        
        # Check if config exists
        if [[ -f "$HOME/.openclaw/openclaw.json" ]]; then
            log_success "OpenClaw config: Found"
        else
            log_warn "OpenClaw config: Not initialized"
            if [[ "$FIX" == "true" ]]; then
                echo -e "${BLUE}💡 Run: openclaw onboard${NC}"
            fi
        fi
        return 0
    else
        log_warn "OpenClaw: Not installed"
        if [[ "$FIX" == "true" ]]; then
            echo -e "${BLUE}💡 Install: npm install -g openclaw@latest${NC}"
            echo -e "${BLUE}💡 Or: curl -fsSL https://openclaw.ai/install.sh | bash${NC}"
        fi
        return 1
    fi
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
            passed_checks=$((passed_checks + 1))
        else
            failed_checks=$((failed_checks + 1))
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
echo -e "${MAGENTA}🧠 Neuro-Spicy Health Check (Full Stack)${NC}"
echo -e "${MAGENTA}========================================${NC}"
echo ""

# Run tests (wrapped in conditionals so set -e doesn't kill us on optional failures)
# --- Core (required) ---
if test_git; then git_result=0; else git_result=$?; fi
if test_nodejs; then nodejs_result=0; else nodejs_result=$?; fi
if test_python; then python_result=0; else python_result=$?; fi
if test_github_token; then github_result=0; else github_result=$?; fi

# --- Languages & frameworks ---
if test_rust; then rust_result=0; else rust_result=$?; fi
if test_typescript; then ts_result=0; else ts_result=$?; fi
if test_astro_vite; then av_result=0; else av_result=$?; fi
if test_playwright; then pw_result=0; else pw_result=$?; fi

# --- Dev tools & AI ---
if test_dev_tools; then devtools_result=0; else devtools_result=$?; fi
if test_ai_cli; then ai_result=0; else ai_result=$?; fi

# --- Editors ---
if test_openclaw; then openclaw_result=0; else openclaw_result=$?; fi
if test_cursor; then cursor_result=0; else cursor_result=$?; fi
if test_vscode; then vscode_result=0; else vscode_result=$?; fi

# Show summary
show_summary "$git_result" "$nodejs_result" "$python_result" "$github_result" \
    "$rust_result" "$ts_result" "$av_result" "$pw_result" \
    "$devtools_result" "$ai_result" \
    "$openclaw_result" "$cursor_result" "$vscode_result"

if [[ "$VERBOSE" == "true" ]]; then
    echo ""
    echo -e "${CYAN}🔍 Verbose Information:${NC}"
    echo "OS: $(uname -s)"
    echo "Architecture: $(uname -m)"
    echo "Shell: $SHELL"
    echo "Working Directory: $(pwd)"
fi
