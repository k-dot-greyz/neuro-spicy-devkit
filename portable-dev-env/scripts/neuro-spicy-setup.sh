#!/bin/bash

# Neuro-Spicy DevKit Ultimate Setup Script (Bash/Linux Version)
# Comprehensive environment setup with auto-detection and GitHub MCP registry integration

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
PLATFORM="linux"
COMPONENTS="all"
AUTO_FIX=false
VERBOSE=false
SKIP_HEALTH_CHECK=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --platform)
            PLATFORM="$2"
            shift 2
            ;;
        --components)
            COMPONENTS="$2"
            shift 2
            ;;
        --auto-fix)
            AUTO_FIX=true
            shift
            ;;
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        --skip-health-check)
            SKIP_HEALTH_CHECK=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  --platform <platform>     Target platform (linux, macos)"
            echo "  --components <components> Components to install (all, nodejs, mcp, cursor, github, gists)"
            echo "  --auto-fix               Attempt to fix issues automatically"
            echo "  --verbose, -v            Show detailed output"
            echo "  --skip-health-check      Skip initial health check"
            echo "  --help, -h               Show this help message"
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

show_banner() {
    echo -e "${MAGENTA}🧠 Neuro-Spicy DevKit Ultimate Setup${NC}"
    echo -e "${MAGENTA}====================================${NC}"
    echo -e "${CYAN}Turning environment setup bugs into features!${NC}"
    echo ""
}

detect_package_manager() {
    if command -v apt &> /dev/null; then
        echo "apt"
    elif command -v yum &> /dev/null; then
        echo "yum"
    elif command -v dnf &> /dev/null; then
        echo "dnf"
    elif command -v pacman &> /dev/null; then
        echo "pacman"
    elif command -v brew &> /dev/null; then
        echo "brew"
    elif command -v zypper &> /dev/null; then
        echo "zypper"
    else
        echo "unknown"
    fi
}

install_nodejs() {
    echo -e "${BLUE}📦 Installing Node.js...${NC}"
    
    local package_manager
    package_manager=$(detect_package_manager)
    
    case "$package_manager" in
        "apt")
            sudo apt update
            sudo apt install -y nodejs npm
            ;;
        "yum")
            sudo yum install -y nodejs npm
            ;;
        "dnf")
            sudo dnf install -y nodejs npm
            ;;
        "pacman")
            sudo pacman -Syu --noconfirm nodejs npm
            ;;
        "brew")
            brew install node
            ;;
        "zypper")
            sudo zypper install -y nodejs npm
            ;;
        *)
            log_error "No supported package manager found"
            echo -e "${YELLOW}Please install Node.js manually from: https://nodejs.org${NC}"
            return 1
            ;;
    esac
    
    # Verify installation
    if command -v node &> /dev/null && command -v npm &> /dev/null; then
        local node_version npm_version
        node_version=$(node --version)
        npm_version=$(npm --version)
        log_success "Node.js: $node_version, npm: $npm_version"
        return 0
    else
        log_error "Node.js installation failed"
        return 1
    fi
}

install_mcp_servers() {
    echo -e "${BLUE}🔧 Installing MCP Servers...${NC}"
    
    local servers=(
        "@cyanheads/git-mcp-server"
        "@modelcontextprotocol/server-filesystem"
        "@jpisnice/shadcn-ui-mcp-server"
    )
    
    local success_count=0
    for server in "${servers[@]}"; do
        echo -e "${CYAN}Installing $server...${NC}"
        if npm install -g "$server"; then
            log_success "Installed $server"
            ((success_count++))
        else
            log_error "Failed to install $server"
        fi
    done
    
    log_success "Installed $success_count/${#servers[@]} MCP servers"
    return $((success_count == ${#servers[@]} ? 0 : 1))
}

setup_cursor_mcp() {
    echo -e "${BLUE}🎯 Setting up Cursor MCP...${NC}"
    
    local cursor_config_dir="$HOME/.cursor"
    local mcp_config_file="$cursor_config_dir/mcp.json"
    
    # Create Cursor config directory
    mkdir -p "$cursor_config_dir"
    
    # Create MCP config
    cat > "$mcp_config_file" << 'EOF'
{
  "mcpServers": {
    "docker-gateway": {
      "command": "docker",
      "args": ["mcp", "gateway", "run", "--enable-all-servers"],
      "type": "stdio",
      "env": {
        "DOCKER_DEFAULT_PLATFORM": "linux/amd64"
      }
    },
    "git": {
      "command": "git-mcp-server",
      "args": [],
      "env": {
        "GIT_USER_NAME": "Your Name",
        "GIT_USER_EMAIL": "yourname.yourname@gmail.com"
      }
    },
    "filesystem": {
      "command": "mcp-server-filesystem",
      "args": [],
      "env": {}
    }
  }
}
EOF
    
    log_success "Cursor MCP config created"
    return 0
}

setup_github_token() {
    echo -e "${BLUE}🔑 Setting up GitHub Token...${NC}"
    
    if [[ -n "${GITHUB_TOKEN:-}" ]]; then
        if curl -s -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user | grep -q '"login"'; then
            local github_user
            github_user=$(curl -s -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user | grep '"login"' | cut -d'"' -f4)
            log_success "GitHub Token valid for: $github_user"
            return 0
        else
            log_error "GitHub Token invalid"
            return 1
        fi
    else
        log_warn "GitHub Token not set"
        echo -e "${CYAN}Create token at: https://github.com/settings/tokens${NC}"
        echo -e "${CYAN}Set scopes: gist, repo${NC}"
        echo -e "${CYAN}Set environment: export GITHUB_TOKEN='your_token_here'${NC}"
        return 1
    fi
}

run_health_check() {
    echo -e "${BLUE}🏥 Running Health Check...${NC}"
    
    local health_check_script
    health_check_script="$(dirname "$0")/health-check.sh"
    
    if [[ -f "$health_check_script" ]]; then
        bash "$health_check_script" --suggest
        return 0
    else
        log_warn "Health check script not found"
        return 1
    fi
}

create_sample_gists() {
    echo -e "${BLUE}📝 Creating sample Gists...${NC}"
    
    local gist_manager_script
    gist_manager_script="$(dirname "$0")/gist-manager.sh"
    
    if [[ -f "$gist_manager_script" ]]; then
        bash "$gist_manager_script" init
        bash "$gist_manager_script" create cursor-rules
        log_success "Sample Gists created"
        return 0
    else
        log_warn "Gist manager script not found"
        return 1
    fi
}

show_completion_summary() {
    local results="$1"
    
    echo ""
    echo -e "${GREEN}🎉 Neuro-Spicy DevKit Setup Complete!${NC}"
    echo -e "${GREEN}=====================================${NC}"
    echo ""
    
    local total_steps=5
    local completed_steps=0
    
    if echo "$results" | grep -q "NODEJS=true"; then
        ((completed_steps++))
        echo -e "${GREEN}✅ Node.js installed${NC}"
    fi
    if echo "$results" | grep -q "MCP_SERVERS=true"; then
        ((completed_steps++))
        echo -e "${GREEN}✅ MCP Servers installed${NC}"
    fi
    if echo "$results" | grep -q "CURSOR_MCP=true"; then
        ((completed_steps++))
        echo -e "${GREEN}✅ Cursor MCP configured${NC}"
    fi
    if echo "$results" | grep -q "GITHUB_TOKEN=true"; then
        ((completed_steps++))
        echo -e "${GREEN}✅ GitHub Token validated${NC}"
    fi
    if echo "$results" | grep -q "GISTS=true"; then
        ((completed_steps++))
        echo -e "${GREEN}✅ Sample Gists created${NC}"
    fi
    
    echo ""
    echo -e "${CYAN}📊 Completion: $completed_steps/$total_steps${NC}"
    
    if [[ $completed_steps -eq $total_steps ]]; then
        echo -e "${GREEN}🚀 Ready for neuro-spicy development!${NC}"
    elif [[ $completed_steps -ge 3 ]]; then
        echo -e "${YELLOW}⚠️ Mostly ready, some manual setup needed${NC}"
    else
        echo -e "${RED}❌ Significant manual setup required${NC}"
    fi
    
    echo ""
    echo -e "${CYAN}💡 Next Steps:${NC}"
    echo -e "${CYAN}  • Run health check: ./health-check.sh --suggest${NC}"
    echo -e "${CYAN}  • Create Gists: ./gist-manager.sh create <name>${NC}"
    echo -e "${CYAN}  • Explore MCPs: ./mcp-registry.sh --list${NC}"
    echo -e "${CYAN}  • Start coding with your neuro-spicy superpowers! 🧠✨${NC}"
}

# Main execution
show_banner

# Initialize results
NODEJS=false
MCP_SERVERS=false
CURSOR_MCP=false
GITHUB_TOKEN=false
GISTS=false

# Run health check first
if [[ "$SKIP_HEALTH_CHECK" != "true" ]]; then
    run_health_check
fi

# Install Node.js if needed
if [[ "$COMPONENTS" == "all" || "$COMPONENTS" == "nodejs" ]]; then
    if install_nodejs; then
        NODEJS=true
    fi
fi

# Install MCP servers
if [[ "$COMPONENTS" == "all" || "$COMPONENTS" == "mcp" ]]; then
    if install_mcp_servers; then
        MCP_SERVERS=true
    fi
fi

# Setup Cursor MCP
if [[ "$COMPONENTS" == "all" || "$COMPONENTS" == "cursor" ]]; then
    if setup_cursor_mcp; then
        CURSOR_MCP=true
    fi
fi

# Setup GitHub Token
if [[ "$COMPONENTS" == "all" || "$COMPONENTS" == "github" ]]; then
    if setup_github_token; then
        GITHUB_TOKEN=true
    fi
fi

# Create sample Gists
if [[ "$COMPONENTS" == "all" || "$COMPONENTS" == "gists" ]]; then
    if create_sample_gists; then
        GISTS=true
    fi
fi

# Show completion summary
RESULTS="NODEJS=$NODEJS MCP_SERVERS=$MCP_SERVERS CURSOR_MCP=$CURSOR_MCP GITHUB_TOKEN=$GITHUB_TOKEN GISTS=$GISTS"
show_completion_summary "$RESULTS"

