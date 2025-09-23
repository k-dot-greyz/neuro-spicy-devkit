#!/bin/bash

# Neuro-Spicy DevKit Profile Loader
# VST Plugin-Style Development Environment Profiles

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PORTABLE_ENV_DIR="$(dirname "$SCRIPT_DIR")"
PROFILES_DIR="$PORTABLE_ENV_DIR/profiles"
TEMPLATES_DIR="$PROFILES_DIR/templates"
USER_PROFILES_DIR="$PROFILES_DIR/user"

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

show_usage() {
    echo -e "${BLUE}Usage: $0 [COMMAND] [OPTIONS]${NC}"
    echo ""
    echo "Neuro-Spicy DevKit Profile Loader - VST Plugin-Style Development Environment"
    echo ""
    echo "COMMANDS:"
    echo "  list                    List available profiles"
    echo "  load <profile>          Load a specific profile"
    echo "  create <name>           Create a new profile"
    echo "  validate <profile>      Validate a profile configuration"
    echo "  info <profile>          Show profile information"
    echo ""
    echo "OPTIONS:"
    echo "  --verbose, -v           Show detailed output"
    echo "  --dry-run               Show what would be done without executing"
    echo "  --help, -h              Show this help message"
    echo ""
    echo "EXAMPLES:"
    echo "  $0 list                              # List available profiles"
    echo "  $0 load frontend-developer           # Load frontend developer profile"
    echo "  $0 create my-custom-profile          # Create custom profile"
    echo "  $0 info frontend-developer           # Show profile details"
}

list_profiles() {
    echo -e "${MAGENTA}📋 Available Profiles${NC}"
    echo -e "${MAGENTA}===================${NC}"
    echo ""
    
    # List template profiles
    if [[ -d "$TEMPLATES_DIR" ]]; then
        echo -e "${BLUE}🎵 Template Profiles:${NC}"
        for profile_file in "$TEMPLATES_DIR"/*.json; do
            if [[ -f "$profile_file" ]]; then
                local profile_name
                profile_name=$(basename "$profile_file" .json)
                local profile_title
                profile_title=$(jq -r '.profile.name // "Unknown"' "$profile_file" 2>/dev/null || echo "Unknown")
                local profile_desc
                profile_desc=$(jq -r '.profile.description // "No description"' "$profile_file" 2>/dev/null || echo "No description")
                local profile_tags
                profile_tags=$(jq -r '.profile.tags[]? // empty' "$profile_file" 2>/dev/null | tr '\n' ' ' || echo "")
                
                echo -e "${GREEN}📦 $profile_name${NC}"
                echo -e "   Title: $profile_title"
                echo -e "   Description: $profile_desc"
                echo -e "   Tags: $profile_tags"
                echo ""
            fi
        done
    fi
    
    # List user profiles
    if [[ -d "$USER_PROFILES_DIR" ]]; then
        echo -e "${BLUE}🎨 User Profiles:${NC}"
        for profile_file in "$USER_PROFILES_DIR"/*.json; do
            if [[ -f "$profile_file" ]]; then
                local profile_name
                profile_name=$(basename "$profile_file" .json)
                local profile_title
                profile_title=$(jq -r '.profile.name // "Unknown"' "$profile_file" 2>/dev/null || echo "Unknown")
                local profile_desc
                profile_desc=$(jq -r '.profile.description // "No description"' "$profile_file" 2>/dev/null || echo "No description")
                
                echo -e "${GREEN}📦 $profile_name${NC}"
                echo -e "   Title: $profile_title"
                echo -e "   Description: $profile_desc"
                echo ""
            fi
        done
    fi
}

show_profile_info() {
    local profile_name="$1"
    local profile_file=""
    
    # Find profile file
    if [[ -f "$TEMPLATES_DIR/$profile_name.json" ]]; then
        profile_file="$TEMPLATES_DIR/$profile_name.json"
    elif [[ -f "$USER_PROFILES_DIR/$profile_name.json" ]]; then
        profile_file="$USER_PROFILES_DIR/$profile_name.json"
    else
        log_error "Profile '$profile_name' not found"
        return 1
    fi
    
    echo -e "${MAGENTA}📋 Profile Information: $profile_name${NC}"
    echo -e "${MAGENTA}===============================${NC}"
    echo ""
    
    # Extract profile information
    local profile_title
    profile_title=$(jq -r '.profile.name // "Unknown"' "$profile_file")
    local profile_desc
    profile_desc=$(jq -r '.profile.description // "No description"' "$profile_file")
    local profile_version
    profile_version=$(jq -r '.profile.version // "Unknown"' "$profile_file")
    local profile_author
    profile_author=$(jq -r '.profile.author // "Unknown"' "$profile_file")
    local profile_tags
    profile_tags=$(jq -r '.profile.tags[]? // empty' "$profile_file" | tr '\n' ' ')
    local profile_platforms
    profile_platforms=$(jq -r '.profile.compatibility.platforms[]? // empty' "$profile_file" | tr '\n' ' ')
    
    echo -e "${GREEN}Title:${NC} $profile_title"
    echo -e "${GREEN}Description:${NC} $profile_desc"
    echo -e "${GREEN}Version:${NC} $profile_version"
    echo -e "${GREEN}Author:${NC} $profile_author"
    echo -e "${GREEN}Tags:${NC} $profile_tags"
    echo -e "${GREEN}Platforms:${NC} $profile_platforms"
    echo ""
    
    # Show tools
    echo -e "${BLUE}🔧 Tools:${NC}"
    jq -r '.plugins.tools[]? | "  • \(.name) \(.version // "")"' "$profile_file" 2>/dev/null || echo "  No tools defined"
    echo ""
    
    # Show MCP servers
    echo -e "${BLUE}🎵 MCP Servers:${NC}"
    jq -r '.plugins.mcps[]? | "  • \(.name) (\(.package // ""))"' "$profile_file" 2>/dev/null || echo "  No MCP servers defined"
    echo ""
    
    # Show shell configuration
    echo -e "${BLUE}🐚 Shell Configuration:${NC}"
    local bash_aliases
    bash_aliases=$(jq -r '.shell.bash.aliases | keys[]? // empty' "$profile_file" 2>/dev/null | tr '\n' ' ')
    if [[ -n "$bash_aliases" ]]; then
        echo -e "  Bash Aliases: $bash_aliases"
    fi
    echo ""
}

validate_profile() {
    local profile_name="$1"
    local profile_file=""
    
    # Find profile file
    if [[ -f "$TEMPLATES_DIR/$profile_name.json" ]]; then
        profile_file="$TEMPLATES_DIR/$profile_name.json"
    elif [[ -f "$USER_PROFILES_DIR/$profile_name.json" ]]; then
        profile_file="$USER_PROFILES_DIR/$profile_name.json"
    else
        log_error "Profile '$profile_name' not found"
        return 1
    fi
    
    echo -e "${BLUE}🔍 Validating Profile: $profile_name${NC}"
    
    # Check JSON syntax
    if jq empty "$profile_file" 2>/dev/null; then
        log_success "JSON syntax is valid"
    else
        log_error "Invalid JSON syntax"
        return 1
    fi
    
    # Check required fields
    local required_fields=("profile.name" "profile.version" "profile.description")
    for field in "${required_fields[@]}"; do
        if jq -e ".$field" "$profile_file" >/dev/null 2>&1; then
            log_success "Required field '$field' present"
        else
            log_error "Required field '$field' missing"
            return 1
        fi
    done
    
    # Check plugin definitions
    if jq -e '.plugins' "$profile_file" >/dev/null 2>&1; then
        log_success "Plugin definitions present"
    else
        log_warn "No plugin definitions found"
    fi
    
    log_success "Profile validation completed"
}

load_profile() {
    local profile_name="$1"
    local profile_file=""
    
    # Find profile file
    if [[ -f "$TEMPLATES_DIR/$profile_name.json" ]]; then
        profile_file="$TEMPLATES_DIR/$profile_name.json"
    elif [[ -f "$USER_PROFILES_DIR/$profile_name.json" ]]; then
        profile_file="$USER_PROFILES_DIR/$profile_name.json"
    else
        log_error "Profile '$profile_name' not found"
        return 1
    fi
    
    echo -e "${MAGENTA}🎵 Loading Profile: $profile_name${NC}"
    echo -e "${MAGENTA}===============================${NC}"
    echo ""
    
    # Show profile info
    show_profile_info "$profile_name"
    
    # Validate profile
    if ! validate_profile "$profile_name"; then
        log_error "Profile validation failed"
        return 1
    fi
    
    echo -e "${BLUE}🚀 Profile loading would happen here...${NC}"
    echo -e "${CYAN}This is a proof-of-concept. Full implementation would:${NC}"
    echo -e "${CYAN}  • Install required tools${NC}"
    echo -e "${CYAN}  • Configure editors${NC}"
    echo -e "${CYAN}  • Set up MCP servers${NC}"
    echo -e "${CYAN}  • Configure shell environment${NC}"
    echo -e "${CYAN}  • Create workspace structure${NC}"
    echo -e "${CYAN}  • Apply user customizations${NC}"
    echo ""
    
    log_success "Profile '$profile_name' loaded successfully!"
}

create_profile() {
    local profile_name="$1"
    local profile_file="$USER_PROFILES_DIR/$profile_name.json"
    
    echo -e "${BLUE}🎨 Creating Profile: $profile_name${NC}"
    
    # Create user profiles directory if it doesn't exist
    mkdir -p "$USER_PROFILES_DIR"
    
    # Create basic profile template
    cat > "$profile_file" << 'EOF'
{
  "profile": {
    "name": "Custom Profile",
    "version": "1.0.0",
    "description": "A custom development profile",
    "author": "User",
    "tags": ["custom"],
    "compatibility": {
      "platforms": ["windows", "linux", "macos"],
      "minVersion": "1.0.0"
    }
  },
  "requirements": {
    "nodejs": ">=18.0.0",
    "npm": ">=8.0.0",
    "git": ">=2.30.0"
  },
  "plugins": {
    "tools": [],
    "editors": [],
    "mcps": []
  },
  "shell": {
    "bash": {
      "aliases": {},
      "functions": {},
      "env": {}
    },
    "powershell": {
      "aliases": {},
      "functions": {},
      "env": {}
    }
  },
  "workspace": {
    "folders": [],
    "settings": {}
  },
  "scripts": {
    "setup": [],
    "dev": "",
    "build": "",
    "test": ""
  }
}
EOF
    
    log_success "Profile '$profile_name' created at $profile_file"
    log_info "Edit the profile file to customize your development environment"
}

# Parse command line arguments
VERBOSE=false
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        list)
            list_profiles
            exit 0
            ;;
        load)
            if [[ $# -lt 2 ]]; then
                log_error "Profile name required for load command"
                show_usage
                exit 1
            fi
            load_profile "$2"
            exit 0
            ;;
        create)
            if [[ $# -lt 2 ]]; then
                log_error "Profile name required for create command"
                show_usage
                exit 1
            fi
            create_profile "$2"
            exit 0
            ;;
        validate)
            if [[ $# -lt 2 ]]; then
                log_error "Profile name required for validate command"
                show_usage
                exit 1
            fi
            validate_profile "$2"
            exit 0
            ;;
        info)
            if [[ $# -lt 2 ]]; then
                log_error "Profile name required for info command"
                show_usage
                exit 1
            fi
            show_profile_info "$2"
            exit 0
            ;;
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --help|-h)
            show_usage
            exit 0
            ;;
        *)
            log_error "Unknown command: $1"
            show_usage
            exit 1
            ;;
    esac
done

# If no command provided, show usage
show_usage
