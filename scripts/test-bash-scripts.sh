#!/bin/bash

# 🧪 Test Bash Scripts for Neuro-Spicy DevKit
# Verifies that bash scripts work correctly

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

log_error() {
    echo -e "${RED}ERROR: $1${NC}"
}

test_script_syntax() {
    local script="$1"
    log_info "Testing syntax: $script"
    
    if bash -n "$script"; then
        log_success "Syntax OK: $script"
        return 0
    else
        log_error "Syntax error: $script"
        return 1
    fi
}

test_script_help() {
    local script="$1"
    log_info "Testing help: $script"
    
    if bash "$script" --help >/dev/null 2>&1; then
        log_success "Help OK: $script"
        return 0
    else
        log_error "Help failed: $script"
        return 1
    fi
}

test_script_dry_run() {
    local script="$1"
    log_info "Testing dry run: $script"
    
    if bash "$script" --dry-run >/dev/null 2>&1; then
        log_success "Dry run OK: $script"
        return 0
    else
        log_error "Dry run failed: $script"
        return 1
    fi
}

# Main execution
echo -e "${MAGENTA}🧪 Testing Bash Scripts for Neuro-Spicy DevKit${NC}"
echo -e "${MAGENTA}=============================================${NC}"
echo ""

# Test scripts
scripts=(
    "health-check-core.sh"
    "neuro-spicy-setup-core.sh"
    "git-push-retry.sh"
)

total_tests=0
passed_tests=0

for script in "${scripts[@]}"; do
    if [[ -f "$script" ]]; then
        echo -e "${BLUE}Testing $script...${NC}"
        
        # Test syntax
        ((total_tests++))
        if test_script_syntax "$script"; then
            ((passed_tests++))
        fi
        
        # Test help
        ((total_tests++))
        if test_script_help "$script"; then
            ((passed_tests++))
        fi
        
        # Test dry run (if supported)
        if [[ "$script" == "neuro-spicy-setup-core.sh" ]]; then
            ((total_tests++))
            if test_script_dry_run "$script"; then
                ((passed_tests++))
            fi
        fi
        
        echo ""
    else
        log_error "Script not found: $script"
    fi
done

# Show summary
echo -e "${MAGENTA}Test Summary${NC}"
echo -e "${MAGENTA}============${NC}"
echo "Total Tests: $total_tests"
echo -e "${GREEN}Passed: $passed_tests${NC}"
echo -e "${RED}Failed: $((total_tests - passed_tests))${NC}"

if [[ $passed_tests -eq $total_tests ]]; then
    echo ""
    echo -e "${GREEN}🎉 All bash scripts are working correctly!${NC}"
    echo -e "${GREEN}Your neuro-spicy devkit is ready for Linux/macOS! 🚀${NC}"
    exit 0
else
    echo ""
    echo -e "${RED}❌ Some tests failed. Please check the errors above.${NC}"
    exit 1
fi
