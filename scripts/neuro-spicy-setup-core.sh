#!/bin/bash

# 🧠 Neuro-Spicy Setup (Core Essentials Only)
# Sets up the essential environment for neuro-spicy development

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
COMPONENTS="core"
SKIP_BACKUP=false
DRY_RUN=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --components|-c)
            COMPONENTS="$2"
            shift 2
            ;;
        --skip-backup|-s)
            SKIP_BACKUP=true
            shift
            ;;
        --dry-run|-d)
            DRY_RUN=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  --components, -c <type>    Components to setup (core, minimal, all)"
            echo "  --skip-backup, -s         Skip creating backup"
            echo "  --dry-run, -d             Show what would be done without making changes"
            echo "  --help, -h                Show this help message"
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

test_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Run health check
    local health_check_script="$SCRIPT_DIR/health-check-core.sh"
    if [[ -f "$health_check_script" ]]; then
        if bash "$health_check_script"; then
            return 0
        else
            return 1
        fi
    else
        log_error "Health check script not found"
        return 1
    fi
}

backup_current_setup() {
    if [[ "$SKIP_BACKUP" == "true" ]]; then
        log_warn "Skipping backup (--skip-backup specified)"
        return
    fi
    
    log_info "Creating backup..."
    local backup_dir="backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$backup_dir"
    
    # Backup current setup
    if [[ -d "portable-dev-env" ]]; then
        cp -r "portable-dev-env" "$backup_dir/"
    fi
    if [[ -d "docs" ]]; then
        cp -r "docs" "$backup_dir/"
    fi
    
    log_success "Backup created: $backup_dir"
}

setup_cursor_config() {
    log_info "Setting up Cursor configuration..."
    
    local cursor_dir="$HOME/.config/Cursor"
    local cursor_config_dir="$cursor_dir/User"
    
    # Create Cursor directories
    mkdir -p "$cursor_config_dir"
    
    # Copy neuro-spicy rules
    local rules_source="portable-dev-env/cursor/rules/ai-behavior-rules.md"
    local rules_dest="$cursor_config_dir/ai-behavior-rules.md"
    
    if [[ -f "$rules_source" ]]; then
        cp "$rules_source" "$rules_dest"
        log_success "Cursor AI behavior rules configured"
    fi
    
    # Copy project context
    local context_source="portable-dev-env/cursor/memories/project-context.md"
    local context_dest="$cursor_config_dir/project-context.md"
    
    if [[ -f "$context_source" ]]; then
        cp "$context_source" "$context_dest"
        log_success "Cursor project context configured"
    fi
}

setup_vscode_config() {
    log_info "Setting up VSCode configuration..."
    
    local vscode_dir="$HOME/.config/Code/User"
    
    # Create VSCode directory
    mkdir -p "$vscode_dir"
    
    # Copy settings
    local settings_source="portable-dev-env/vscode/settings/settings.json"
    local settings_dest="$vscode_dir/settings.json"
    
    if [[ -f "$settings_source" ]]; then
        cp "$settings_source" "$settings_dest"
        log_success "VSCode settings configured"
    fi
    
    # Copy extensions
    local extensions_source="portable-dev-env/vscode/extensions/extensions.json"
    local extensions_dest="$vscode_dir/extensions.json"
    
    if [[ -f "$extensions_source" ]]; then
        cp "$extensions_source" "$extensions_dest"
        log_success "VSCode extensions configured"
    fi
}

setup_git_config() {
    log_info "Setting up Git configuration..."
    
    # Check if Git is configured
    local user_name user_email
    user_name=$(git config --global user.name 2>/dev/null || echo "")
    user_email=$(git config --global user.email 2>/dev/null || echo "")
    
    if [[ -z "$user_name" || -z "$user_email" ]]; then
        log_warn "Git not configured. Please configure manually:"
        echo -e "${BLUE}git config --global user.name 'Your Name'${NC}"
        echo -e "${BLUE}git config --global user.email 'your.email@example.com'${NC}"
    else
        log_success "Git already configured: $user_name <$user_email>"
    fi
    
    # Set up useful Git aliases
    git config --global alias.st status
    git config --global alias.co checkout
    git config --global alias.br branch
    git config --global alias.ci commit
    git config --global alias.unstage 'reset HEAD --'
    git config --global alias.last 'log -1 HEAD'
    git config --global alias.visual '!gitk'
    
    log_success "Git aliases configured"
}

setup_environment_variables() {
    log_info "Setting up environment variables..."
    
    # Check GitHub token
    if [[ -z "${GITHUB_TOKEN:-}" ]]; then
        log_warn "GitHub token not set"
        echo -e "${BLUE}💡 Set: export GITHUB_TOKEN='your_token_here'${NC}"
        echo -e "${BLUE}💡 Or run: ./scripts/setup-github-token.sh${NC}"
    else
        log_success "GitHub token configured"
    fi
    
    # Set up PATH if needed
    local node_path="$HOME/.local/bin"
    if [[ -d "$node_path" ]]; then
        if [[ ":$PATH:" != *":$node_path:"* ]]; then
            log_warn "npm path not in PATH"
            echo -e "${BLUE}💡 Add: $node_path to your PATH environment variable${NC}"
            echo -e "${BLUE}💡 Add to ~/.bashrc or ~/.zshrc: export PATH=\"\$PATH:$node_path\"${NC}"
        else
            log_success "npm path configured"
        fi
    fi
}

test_setup() {
    log_info "Testing setup..."
    
    local tests_passed=0
    local tests_total=0
    
    # Test Cursor config
    ((tests_total++))
    if [[ -f "$HOME/.config/Cursor/User/ai-behavior-rules.md" ]]; then
        log_success "Cursor Config"
        ((tests_passed++))
    else
        log_error "Cursor Config"
    fi
    
    # Test VSCode config
    ((tests_total++))
    if [[ -f "$HOME/.config/Code/User/settings.json" ]]; then
        log_success "VSCode Config"
        ((tests_passed++))
    else
        log_error "VSCode Config"
    fi
    
    # Test Git config
    ((tests_total++))
    if [[ -n "$(git config --global user.name 2>/dev/null)" ]]; then
        log_success "Git Config"
        ((tests_passed++))
    else
        log_error "Git Config"
    fi
    
    if [[ $tests_passed -eq $tests_total ]]; then
        return 0
    else
        return 1
    fi
}

show_next_steps() {
    echo ""
    echo -e "${GREEN}🎉 Neuro-Spicy Setup Complete!${NC}"
    echo -e "${GREEN}=============================${NC}"
    echo ""
    echo -e "${CYAN}Next steps:${NC}"
    echo "1. Restart Cursor/VSCode to load new settings"
    echo "2. Test Git: git status"
    echo "3. Test GitHub: ./scripts/git-push-retry.sh --branch main"
    echo ""
    echo -e "${MAGENTA}🧠 Your neuro-spicy environment is ready! 🚀${NC}"
}

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Main execution
echo -e "${MAGENTA}🧠 Neuro-Spicy Setup (Core Essentials)${NC}"
echo -e "${MAGENTA}======================================${NC}"
echo ""

if [[ "$DRY_RUN" == "true" ]]; then
    echo -e "${YELLOW}🔍 DRY RUN MODE - No changes will be made${NC}"
    echo -e "${YELLOW}This would:${NC}"
    echo -e "${YELLOW}- Configure Cursor AI behavior rules${NC}"
    echo -e "${YELLOW}- Configure VSCode settings and extensions${NC}"
    echo -e "${YELLOW}- Set up Git configuration and aliases${NC}"
    echo -e "${YELLOW}- Configure environment variables${NC}"
    exit 0
fi

# Check prerequisites
if ! test_prerequisites; then
    log_error "Prerequisites not met. Please fix issues above."
    exit 1
fi

# Create backup
backup_current_setup

# Setup components based on selection
case "${COMPONENTS,,}" in
    "core")
        log_info "Setting up core components..."
        setup_cursor_config
        setup_vscode_config
        setup_git_config
        setup_environment_variables
        ;;
    "minimal")
        log_info "Setting up minimal components..."
        setup_git_config
        setup_environment_variables
        ;;
    *)
        log_info "Setting up all components..."
        setup_cursor_config
        setup_vscode_config
        setup_git_config
        setup_environment_variables
        ;;
esac

# Test setup
if test_setup; then
    show_next_steps
else
    log_error "Setup incomplete. Please check the errors above."
    exit 1
fi
