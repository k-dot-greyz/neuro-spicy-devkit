#!/bin/bash

# GitHub MCP Registry Integration (Bash/Linux Version)
# Discovers and integrates new MCP servers from GitHub

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
SEARCH=""
LIST=false
INSTALL=false
SERVER=""
VERBOSE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --search)
            SEARCH="$2"
            shift 2
            ;;
        --list)
            LIST=true
            shift
            ;;
        --install)
            INSTALL=true
            shift
            ;;
        --server)
            SERVER="$2"
            shift 2
            ;;
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  --search <query>     Search for specific MCP servers"
            echo "  --list              List popular MCP servers"
            echo "  --install --server <name>  Install specific MCP server"
            echo "  --verbose, -v       Show detailed output"
            echo "  --help, -h          Show this help message"
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

search_github_mcp_repos() {
    local query="${1:-mcp server}"
    
    echo -e "${BLUE}🔍 Searching GitHub for MCP servers...${NC}"
    
    local search_url="https://api.github.com/search/repositories?q=${query}+language:typescript+language:javascript+language:python&sort=updated&order=desc"
    local headers=()
    
    if [[ -n "${GITHUB_TOKEN:-}" ]]; then
        headers+=("-H" "Authorization: token $GITHUB_TOKEN")
    fi
    
    if command -v curl &> /dev/null; then
        local response
        if response=$(curl -s "${headers[@]}" "$search_url"); then
            echo "$response" | jq -r '.items[] | select(.name | test("mcp|model-context-protocol") or (.description // "" | test("mcp|model-context-protocol")) or (.topics[]? | test("mcp|model-context-protocol"))) | "\(.name)|\(.full_name)|\(.description // "No description")|\(.stargazers_count)|\(.updated_at)|\(.language // "Unknown")|\(.html_url)|\(.clone_url)"'
        else
            log_error "Failed to search GitHub"
            return 1
        fi
    else
        log_error "curl not found. Please install curl to use this feature."
        return 1
    fi
}

show_mcp_repos() {
    local repos="$1"
    
    echo -e "${MAGENTA}📋 Available MCP Servers${NC}"
    echo -e "${MAGENTA}=======================${NC}"
    
    while IFS='|' read -r name full_name description stars updated language url clone_url; do
        local star_display=""
        local star_count=$((stars < 5 ? stars : 5))
        for ((i=0; i<star_count; i++)); do
            star_display+="⭐"
        done
        
        echo -e "${GREEN}📦 $name${NC}"
        echo -e "   Description: $description"
        echo -e "   Language: $language | Stars: $stars $star_display"
        echo -e "   Updated: $(date -d "$updated" '+%Y-%m-%d' 2>/dev/null || echo "$updated")"
        echo -e "   URL: $url"
        echo ""
    done <<< "$repos"
}

install_mcp_server() {
    local server_name="$1"
    
    echo -e "${BLUE}📦 Installing MCP Server: $server_name${NC}"
    
    # Common MCP server installation patterns
    case "$server_name" in
        "git-mcp-server")
            local install_cmd="npm install -g @cyanheads/git-mcp-server"
            ;;
        "filesystem-mcp-server")
            local install_cmd="npm install -g @modelcontextprotocol/server-filesystem"
            ;;
        "shadcn-ui-mcp-server")
            local install_cmd="npm install -g @jpisnice/shadcn-ui-mcp-server"
            ;;
        "brave-search-mcp")
            local install_cmd="npm install -g @modelcontextprotocol/server-brave-search"
            ;;
        "fetch-mcp")
            local install_cmd="npm install -g @modelcontextprotocol/server-fetch"
            ;;
        *)
            log_error "Unknown MCP server: $server_name"
            echo -e "${YELLOW}Available servers: git-mcp-server, filesystem-mcp-server, shadcn-ui-mcp-server, brave-search-mcp, fetch-mcp${NC}"
            return 1
            ;;
    esac
    
    echo -e "${CYAN}Running: $install_cmd${NC}"
    if eval "$install_cmd"; then
        log_success "Successfully installed $server_name"
        return 0
    else
        log_error "Failed to install $server_name"
        return 1
    fi
}

get_popular_mcp_servers() {
    echo -e "${MAGENTA}🌟 Popular MCP Servers${NC}"
    echo -e "${MAGENTA}======================${NC}"
    
    cat << EOF
📦 Git MCP Server
   Git repository operations and version control
   Install: npm install -g @cyanheads/git-mcp-server

📦 Filesystem MCP Server
   File system access and management
   Install: npm install -g @modelcontextprotocol/server-filesystem

📦 Brave Search MCP
   Web search using Brave Search API
   Install: npm install -g @modelcontextprotocol/server-brave-search

📦 Fetch MCP Server
   Web content fetching and processing
   Install: npm install -g @modelcontextprotocol/server-fetch

📦 Shadcn UI MCP Server
   Shadcn/UI component library access
   Install: npm install -g @jpisnice/shadcn-ui-mcp-server
EOF
}

test_mcp_server() {
    local server_name="$1"
    
    echo -e "${BLUE}🧪 Testing MCP Server: $server_name${NC}"
    
    # Test if server is installed
    if npm list -g --depth=0 2>/dev/null | grep -q "$server_name"; then
        log_success "$server_name is installed"
        
        # Try to get help/version
        if command -v "$server_name" &> /dev/null; then
            if "$server_name" --help &> /dev/null; then
                log_success "$server_name responds to --help"
            else
                log_warn "$server_name installed but no --help available"
            fi
        else
            log_warn "$server_name installed but may not be executable"
        fi
        
        return 0
    else
        log_error "$server_name not found in global packages"
        return 1
    fi
}

# Main execution
echo -e "${MAGENTA}🔍 GitHub MCP Registry Integration${NC}"
echo -e "${MAGENTA}=================================${NC}"
echo ""

if [[ "$LIST" == "true" ]]; then
    get_popular_mcp_servers
    exit 0
fi

if [[ "$INSTALL" == "true" && -n "$SERVER" ]]; then
    if install_mcp_server "$SERVER"; then
        test_mcp_server "$SERVER"
    fi
    exit 0
fi

if [[ -n "$SEARCH" ]]; then
    if repos=$(search_github_mcp_repos "$SEARCH"); then
        if [[ -n "$repos" ]]; then
            show_mcp_repos "$repos"
        else
            log_error "No MCP repositories found for: $SEARCH"
        fi
    fi
    exit 0
fi

# Default: Show popular servers
get_popular_mcp_servers

echo ""
echo -e "${CYAN}💡 Usage Examples:${NC}"
echo -e "${CYAN}  $0 --list                              # List popular servers${NC}"
echo -e "${CYAN}  $0 --search 'brave'                    # Search for specific servers${NC}"
echo -e "${CYAN}  $0 --install --server 'git-mcp-server'${NC}"
