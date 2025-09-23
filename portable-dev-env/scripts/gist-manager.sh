#!/bin/bash

# GitHub Gist Manager for Portable Dev Environment
# Manages sharing and syncing of development environment configurations

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PORTABLE_ENV_DIR="$(dirname "$SCRIPT_DIR")"
GISTS_DIR="$PORTABLE_ENV_DIR/gists"
CONFIG_FILE="$GISTS_DIR/gist-config.json"

print_usage() {
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Manage GitHub Gists for portable dev environment configurations."
    echo ""
    echo "COMMANDS:"
    echo "  init                    Initialize gist management"
    echo "  create <name>           Create a new gist from local config"
    echo "  update <name>           Update existing gist"
    echo "  sync <name>             Sync gist to local config"
    echo "  list                    List all managed gists"
    echo "  delete <name>           Delete a gist"
    echo "  backup                  Backup all gists locally"
    echo "  restore                 Restore from local backup"
    echo ""
    echo "OPTIONS:"
    echo "  --help, -h             Show this help message"
    echo "  --verbose, -v          Show detailed output"
    echo "  --public               Create public gists (default: private)"
    echo "  --token <token>        GitHub token (or set GITHUB_TOKEN env var)"
    echo ""
    echo "EXAMPLES:"
    echo "  $0 init                           # Initialize gist management"
    echo "  $0 create cursor-rules            # Create gist from cursor rules"
    echo "  $0 update mcp-config               # Update existing gist"
    echo "  $0 sync --verbose                  # Sync all gists with verbose output"
    echo "  $0 list                           # List all managed gists"
}

check_dependencies() {
    local missing_deps=()
    
    # Check curl
    if ! command -v curl &> /dev/null; then
        missing_deps+=("curl")
    fi
    
    # Check jq
    if ! command -v jq &> /dev/null; then
        missing_deps+=("jq")
    fi
    
    # Check git
    if ! command -v git &> /dev/null; then
        missing_deps+=("git")
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        echo -e "${RED}❌ Missing dependencies: ${missing_deps[*]}${NC}"
        echo -e "${YELLOW}Please install missing dependencies and try again.${NC}"
        return 1
    fi
    
    return 0
}

check_github_token() {
    if [ -z "${GITHUB_TOKEN:-}" ]; then
        echo -e "${RED}❌ GitHub token not found${NC}"
        echo -e "${YELLOW}Please set GITHUB_TOKEN environment variable or use --token option${NC}"
        echo -e "${YELLOW}Create a token at: https://github.com/settings/tokens${NC}"
        return 1
    fi
    
    # Test token
    if ! curl -s -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user > /dev/null; then
        echo -e "${RED}❌ Invalid GitHub token${NC}"
        return 1
    fi
    
    return 0
}

init_gist_management() {
    echo -e "${BLUE}🚀 Initializing Gist Management${NC}"
    
    # Create directories
    mkdir -p "$GISTS_DIR"
    mkdir -p "$GISTS_DIR/backups"
    mkdir -p "$GISTS_DIR/templates"
    
    # Create config file if it doesn't exist
    if [ ! -f "$CONFIG_FILE" ]; then
        cat > "$CONFIG_FILE" << 'EOF'
{
  "gists": {},
  "last_sync": null,
  "version": "1.0.0"
}
EOF
        echo -e "${GREEN}✅ Created gist configuration file${NC}"
    fi
    
    # Create template gists
    create_template_gists
    
    echo -e "${GREEN}🎉 Gist management initialized${NC}"
}

create_template_gists() {
    echo -e "${CYAN}Creating template gists...${NC}"
    
    # Cursor Rules Template
    if [ -f "$PORTABLE_ENV_DIR/cursor/rules/ai-behavior-rules.md" ]; then
        create_gist "cursor-rules" \
            "Cursor AI Behavior Rules" \
            "$PORTABLE_ENV_DIR/cursor/rules/ai-behavior-rules.md" \
            "AI behavior rules for Cursor development environment"
    fi
    
    # MCP Configuration Template
    if [ -f "$PORTABLE_ENV_DIR/../configs/mcp-linux.json" ]; then
        create_gist "mcp-config-linux" \
            "MCP Configuration for Linux" \
            "$PORTABLE_ENV_DIR/../configs/mcp-linux.json" \
            "Linux-optimized MCP server configuration"
    fi
    
    # Development Workflow Template
    if [ -f "$PORTABLE_ENV_DIR/cursor/workflows/development-workflow.md" ]; then
        create_gist "dev-workflow" \
            "Development Workflow Templates" \
            "$PORTABLE_ENV_DIR/cursor/workflows/development-workflow.md" \
            "Reusable development workflow templates"
    fi
}

create_gist() {
    local name="$1"
    local title="$2"
    local file_path="$3"
    local description="$4"
    local public="${5:-false}"
    
    echo -e "${BLUE}Creating gist: $name${NC}"
    
    if [ ! -f "$file_path" ]; then
        echo -e "${RED}❌ File not found: $file_path${NC}"
        return 1
    fi
    
    local filename=$(basename "$file_path")
    local content=$(cat "$file_path")
    
    # Create gist JSON
    local gist_json=$(jq -n \
        --arg description "$description" \
        --arg filename "$filename" \
        --arg content "$content" \
        --argjson public "$public" \
        '{
            description: $description,
            public: $public,
            files: {
                ($filename): {
                    content: $content
                }
            }
        }')
    
    # Create gist via GitHub API
    local response=$(curl -s -X POST \
        -H "Authorization: token $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        -d "$gist_json" \
        https://api.github.com/gists)
    
    local gist_id=$(echo "$response" | jq -r '.id')
    local gist_url=$(echo "$response" | jq -r '.html_url')
    
    if [ "$gist_id" != "null" ] && [ "$gist_id" != "" ]; then
        # Update local config
        jq --arg name "$name" \
           --arg id "$gist_id" \
           --arg url "$gist_url" \
           --arg title "$title" \
           '.gists[$name] = {id: $id, url: $url, title: $title}' \
           "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
        
        echo -e "${GREEN}✅ Created gist: $name${NC}"
        echo -e "${CYAN}   ID: $gist_id${NC}"
        echo -e "${CYAN}   URL: $gist_url${NC}"
    else
        echo -e "${RED}❌ Failed to create gist: $name${NC}"
        echo -e "${RED}   Response: $response${NC}"
        return 1
    fi
}

update_gist() {
    local name="$1"
    local verbose="${2:-false}"
    
    echo -e "${BLUE}Updating gist: $name${NC}"
    
    # Get gist info from config
    local gist_id=$(jq -r ".gists.$name.id" "$CONFIG_FILE")
    
    if [ "$gist_id" = "null" ] || [ "$gist_id" = "" ]; then
        echo -e "${RED}❌ Gist not found in config: $name${NC}"
        return 1
    fi
    
    # Find source file
    local source_file=""
    case "$name" in
        "cursor-rules")
            source_file="$PORTABLE_ENV_DIR/cursor/rules/ai-behavior-rules.md"
            ;;
        "mcp-config-linux")
            source_file="$PORTABLE_ENV_DIR/../configs/mcp-linux.json"
            ;;
        "dev-workflow")
            source_file="$PORTABLE_ENV_DIR/cursor/workflows/development-workflow.md"
            ;;
        *)
            echo -e "${RED}❌ Unknown gist name: $name${NC}"
            return 1
            ;;
    esac
    
    if [ ! -f "$source_file" ]; then
        echo -e "${RED}❌ Source file not found: $source_file${NC}"
        return 1
    fi
    
    local filename=$(basename "$source_file")
    local content=$(cat "$source_file")
    
    # Update gist JSON
    local gist_json=$(jq -n \
        --arg filename "$filename" \
        --arg content "$content" \
        '{
            files: {
                ($filename): {
                    content: $content
                }
            }
        }')
    
    # Update gist via GitHub API
    local response=$(curl -s -X PATCH \
        -H "Authorization: token $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        -d "$gist_json" \
        "https://api.github.com/gists/$gist_id")
    
    local updated_id=$(echo "$response" | jq -r '.id')
    
    if [ "$updated_id" = "$gist_id" ]; then
        echo -e "${GREEN}✅ Updated gist: $name${NC}"
        if [ "$verbose" = true ]; then
            echo -e "${CYAN}   Source: $source_file${NC}"
            echo -e "${CYAN}   Gist ID: $gist_id${NC}"
        fi
    else
        echo -e "${RED}❌ Failed to update gist: $name${NC}"
        echo -e "${RED}   Response: $response${NC}"
        return 1
    fi
}

list_gists() {
    echo -e "${BLUE}📋 Managed Gists${NC}"
    echo "=================="
    
    jq -r '.gists | to_entries[] | "\(.key): \(.value.title) (\(.value.id))"' "$CONFIG_FILE" | while read -r line; do
        echo -e "${GREEN}✅ $line${NC}"
    done
    
    echo ""
    echo -e "${CYAN}Total: $(jq '.gists | length' "$CONFIG_FILE") gists${NC}"
}

backup_gists() {
    echo -e "${BLUE}💾 Backing up gists...${NC}"
    
    local backup_dir="$GISTS_DIR/backups/$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$backup_dir"
    
    # Backup config
    cp "$CONFIG_FILE" "$backup_dir/gist-config.json"
    
    # Backup each gist
    jq -r '.gists | to_entries[] | "\(.key) \(.value.id)"' "$CONFIG_FILE" | while read -r name gist_id; do
        echo -e "${CYAN}Backing up: $name${NC}"
        
        local response=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
            "https://api.github.com/gists/$gist_id")
        
        echo "$response" > "$backup_dir/${name}.json"
    done
    
    echo -e "${GREEN}✅ Backup completed: $backup_dir${NC}"
}

main() {
    local command="${1:-}"
    local verbose=false
    local public=false
    local token=""
    
    # Parse options
    shift || true
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help|-h)
                print_usage
                exit 0
                ;;
            --verbose|-v)
                verbose=true
                shift
                ;;
            --public)
                public=true
                shift
                ;;
            --token)
                token="$2"
                export GITHUB_TOKEN="$token"
                shift 2
                ;;
            *)
                break
                ;;
        esac
    done
    
    # Check dependencies
    if ! check_dependencies; then
        exit 1
    fi
    
    # Check GitHub token
    if ! check_github_token; then
        exit 1
    fi
    
    # Execute command
    case "$command" in
        init)
            init_gist_management
            ;;
        create)
            if [ -z "${1:-}" ]; then
                echo -e "${RED}❌ Gist name required${NC}"
                print_usage
                exit 1
            fi
            create_gist "$1" "" "" "" "$public"
            ;;
        update)
            if [ -z "${1:-}" ]; then
                echo -e "${RED}❌ Gist name required${NC}"
                print_usage
                exit 1
            fi
            update_gist "$1" "$verbose"
            ;;
        list)
            list_gists
            ;;
        backup)
            backup_gists
            ;;
        *)
            echo -e "${RED}❌ Unknown command: $command${NC}"
            print_usage
            exit 1
            ;;
    esac
}

main "$@"
