#!/bin/bash

# 🚀 Setup Bash/Linux as Default for Neuro-Spicy DevKit
# Makes bash scripts the primary interface

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

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

setup_bash_default() {
    log_info "Setting up bash/linux as default..."
    
    # Make all bash scripts executable
    log_info "Making bash scripts executable..."
    chmod +x scripts/*.sh
    
    # Create symlinks for easy access (if on Linux/macOS)
    if [[ "$OSTYPE" == "linux-gnu"* ]] || [[ "$OSTYPE" == "darwin"* ]]; then
        log_info "Creating symlinks for easy access..."
        
        # Create symlinks in project root
        ln -sf scripts/health-check-core.sh health-check
        ln -sf scripts/neuro-spicy-setup-core.sh neuro-spicy-setup
        ln -sf scripts/git-push-retry.sh git-push-retry
        
        log_success "Symlinks created for easy access"
    fi
    
    # Update shell profile for PATH (if on Linux/macOS)
    if [[ "$OSTYPE" == "linux-gnu"* ]] || [[ "$OSTYPE" == "darwin"* ]]; then
        log_info "Setting up PATH in shell profile..."
        
        local shell_profile=""
        if [[ "$SHELL" == *"zsh"* ]]; then
            shell_profile="$HOME/.zshrc"
        elif [[ "$SHELL" == *"bash"* ]]; then
            shell_profile="$HOME/.bashrc"
        fi
        
        if [[ -n "$shell_profile" ]]; then
            local project_dir
            project_dir="$(pwd)"
            
            # Add project scripts to PATH if not already there
            if ! grep -q "neuro-spicy-devkit" "$shell_profile" 2>/dev/null; then
                echo "" >> "$shell_profile"
                echo "# Neuro-Spicy DevKit" >> "$shell_profile"
                echo "export PATH=\"\$PATH:$project_dir/scripts\"" >> "$shell_profile"
                log_success "Added neuro-spicy-devkit to PATH in $shell_profile"
            else
                log_info "neuro-spicy-devkit already in PATH"
            fi
        fi
    fi
    
    log_success "Bash/linux setup complete!"
}

show_usage() {
    echo -e "${MAGENTA}🧠 Neuro-Spicy DevKit - Bash/Linux Default Setup${NC}"
    echo -e "${MAGENTA}===============================================${NC}"
    echo ""
    echo "This script sets up bash/linux as the default interface for the neuro-spicy devkit."
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --help, -h    Show this help message"
    echo ""
    echo "What this script does:"
    echo "1. Makes all bash scripts executable"
    echo "2. Creates symlinks for easy access (Linux/macOS)"
    echo "3. Adds project scripts to PATH (Linux/macOS)"
    echo "4. Sets up bash as the primary interface"
    echo ""
    echo "After running this script, you can use:"
    echo "  ./health-check-core.sh                    # Check environment"
    echo "  ./neuro-spicy-setup-core.sh --components core  # Setup environment"
    echo "  ./git-push-retry.sh --branch main         # Reliable git operations"
    echo ""
    echo "Or with symlinks (Linux/macOS):"
    echo "  ./health-check                            # Check environment"
    echo "  ./neuro-spicy-setup --components core    # Setup environment"
    echo "  ./git-push-retry --branch main           # Reliable git operations"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --help|-h)
            show_usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Main execution
echo -e "${MAGENTA}🧠 Neuro-Spicy DevKit - Bash/Linux Default Setup${NC}"
echo -e "${MAGENTA}===============================================${NC}"
echo ""

setup_bash_default

echo ""
echo -e "${GREEN}🎉 Bash/Linux setup complete!${NC}"
echo -e "${GREEN}============================${NC}"
echo ""
echo -e "${CYAN}Next steps:${NC}"
echo "1. Run: ./scripts/health-check-core.sh"
echo "2. Run: ./scripts/neuro-spicy-setup-core.sh --components core"
echo "3. Test: ./scripts/git-push-retry.sh --branch main"
echo ""
echo -e "${MAGENTA}🧠 Your neuro-spicy devkit is now bash/linux ready! 🚀${NC}"
