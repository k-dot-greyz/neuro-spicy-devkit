#!/bin/bash

# Portable Dev Environment Setup Script
# Sets up a portable development environment for Cursor/VSCode

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
PLATFORM=""
VERBOSE=false
COMPONENTS=""

print_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Setup portable development environment for Cursor/VSCode."
    echo ""
    echo "OPTIONS:"
    echo "  --platform <os>        Target platform (linux, windows, macos)"
    echo "  --components <list>    Components to install (cursor, vscode, mcp, all)"
    echo "  --verbose, -v          Show detailed output"
    echo "  --help, -h            Show this help message"
    echo ""
    echo "EXAMPLES:"
    echo "  $0 --platform linux --components all"
    echo "  $0 --platform windows --components cursor,mcp"
    echo "  $0 --platform macos --components vscode --verbose"
}

detect_platform() {
    if [ -n "$PLATFORM" ]; then
        return 0
    fi
    
    case "$(uname -s)" in
        Linux*)
            PLATFORM="linux"
            ;;
        Darwin*)
            PLATFORM="macos"
            ;;
        CYGWIN*|MINGW*|MSYS*)
            PLATFORM="windows"
            ;;
        *)
            echo -e "${RED}❌ Unsupported platform: $(uname -s)${NC}"
            return 1
            ;;
    esac
    
    echo -e "${GREEN}✅ Detected platform: $PLATFORM${NC}"
}

check_dependencies() {
    echo -e "${BLUE}🔍 Checking dependencies...${NC}"
    
    local missing_deps=()
    
    # Check git
    if ! command -v git &> /dev/null; then
        missing_deps+=("git")
    else
        echo -e "${GREEN}✅ Git: $(git --version)${NC}"
    fi
    
    # Check curl
    if ! command -v curl &> /dev/null; then
        missing_deps+=("curl")
    else
        echo -e "${GREEN}✅ curl: $(curl --version | head -n1)${NC}"
    fi
    
    # Platform-specific dependencies
    case "$PLATFORM" in
        linux)
            if ! command -v jq &> /dev/null; then
                missing_deps+=("jq")
            else
                echo -e "${GREEN}✅ jq: $(jq --version)${NC}"
            fi
            ;;
        windows)
            if ! command -v powershell &> /dev/null; then
                missing_deps+=("powershell")
            else
                echo -e "${GREEN}✅ PowerShell: $(powershell --version)${NC}"
            fi
            ;;
        macos)
            if ! command -v brew &> /dev/null; then
                echo -e "${YELLOW}⚠️  Homebrew not found (recommended for macOS)${NC}"
            else
                echo -e "${GREEN}✅ Homebrew: $(brew --version | head -n1)${NC}"
            fi
            ;;
    esac
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        echo -e "${YELLOW}⚠️  Missing dependencies: ${missing_deps[*]}${NC}"
        echo -e "${YELLOW}Please install missing dependencies and try again.${NC}"
        return 1
    fi
    
    return 0
}

setup_cursor() {
    echo -e "${BLUE}🎯 Setting up Cursor configuration...${NC}"
    
    local cursor_dir=""
    case "$PLATFORM" in
        linux)
            cursor_dir="$HOME/.cursor"
            ;;
        macos)
            cursor_dir="$HOME/Library/Application Support/Cursor"
            ;;
        windows)
            cursor_dir="$APPDATA/Cursor"
            ;;
    esac
    
    # Create Cursor directory
    mkdir -p "$cursor_dir"
    
    # Copy MCP configuration
    if [ -f "$PORTABLE_ENV_DIR/../configs/mcp-linux.json" ]; then
        cp "$PORTABLE_ENV_DIR/../configs/mcp-linux.json" "$cursor_dir/mcp.json"
        echo -e "${GREEN}✅ Cursor MCP configuration installed${NC}"
    fi
    
    # Copy rules
    if [ -d "$PORTABLE_ENV_DIR/cursor/rules" ]; then
        mkdir -p "$cursor_dir/rules"
        cp -r "$PORTABLE_ENV_DIR/cursor/rules"/* "$cursor_dir/rules/"
        echo -e "${GREEN}✅ Cursor rules installed${NC}"
    fi
    
    # Copy memories
    if [ -d "$PORTABLE_ENV_DIR/cursor/memories" ]; then
        mkdir -p "$cursor_dir/memories"
        cp -r "$PORTABLE_ENV_DIR/cursor/memories"/* "$cursor_dir/memories/"
        echo -e "${GREEN}✅ Cursor memories installed${NC}"
    fi
    
    # Copy workflows
    if [ -d "$PORTABLE_ENV_DIR/cursor/workflows" ]; then
        mkdir -p "$cursor_dir/workflows"
        cp -r "$PORTABLE_ENV_DIR/cursor/workflows"/* "$cursor_dir/workflows/"
        echo -e "${GREEN}✅ Cursor workflows installed${NC}"
    fi
}

setup_vscode() {
    echo -e "${BLUE}🎯 Setting up VSCode configuration...${NC}"
    
    local vscode_dir=""
    case "$PLATFORM" in
        linux)
            vscode_dir="$HOME/.config/Code/User"
            ;;
        macos)
            vscode_dir="$HOME/Library/Application Support/Code/User"
            ;;
        windows)
            vscode_dir="$APPDATA/Code/User"
            ;;
    esac
    
    # Create VSCode directory
    mkdir -p "$vscode_dir"
    
    # Copy settings
    if [ -d "$PORTABLE_ENV_DIR/vscode/settings" ]; then
        cp -r "$PORTABLE_ENV_DIR/vscode/settings"/* "$vscode_dir/"
        echo -e "${GREEN}✅ VSCode settings installed${NC}"
    fi
    
    # Copy extensions
    if [ -f "$PORTABLE_ENV_DIR/vscode/extensions/extensions.json" ]; then
        cp "$PORTABLE_ENV_DIR/vscode/extensions/extensions.json" "$vscode_dir/extensions.json"
        echo -e "${GREEN}✅ VSCode extensions configuration installed${NC}"
    fi
    
    # Copy snippets
    if [ -d "$PORTABLE_ENV_DIR/vscode/snippets" ]; then
        mkdir -p "$vscode_dir/snippets"
        cp -r "$PORTABLE_ENV_DIR/vscode/snippets"/* "$vscode_dir/snippets/"
        echo -e "${GREEN}✅ VSCode snippets installed${NC}"
    fi
}

setup_mcp() {
    echo -e "${BLUE}🎯 Setting up MCP configuration...${NC}"
    
    # Run platform-specific MCP setup
    case "$PLATFORM" in
        linux)
            if [ -f "$PORTABLE_ENV_DIR/../scripts/setup-linux-mcp.sh" ]; then
                chmod +x "$PORTABLE_ENV_DIR/../scripts/setup-linux-mcp.sh"
                "$PORTABLE_ENV_DIR/../scripts/setup-linux-mcp.sh" --all
            fi
            ;;
        windows)
            echo -e "${YELLOW}⚠️  Windows MCP setup not yet implemented${NC}"
            echo -e "${YELLOW}   Please install Node.js and run MCP setup manually${NC}"
            ;;
        macos)
            echo -e "${YELLOW}⚠️  macOS MCP setup not yet implemented${NC}"
            echo -e "${YELLOW}   Please install Node.js and run MCP setup manually${NC}"
            ;;
    esac
}

setup_gist_integration() {
    echo -e "${BLUE}🎯 Setting up GitHub Gist integration...${NC}"
    
    # Make gist manager executable
    if [ -f "$PORTABLE_ENV_DIR/scripts/gist-manager.sh" ]; then
        chmod +x "$PORTABLE_ENV_DIR/scripts/gist-manager.sh"
        echo -e "${GREEN}✅ Gist manager script made executable${NC}"
    fi
    
    # Check for GitHub token
    if [ -z "${GITHUB_TOKEN:-}" ]; then
        echo -e "${YELLOW}⚠️  GITHUB_TOKEN not set${NC}"
        echo -e "${YELLOW}   Set GITHUB_TOKEN environment variable to use gist features${NC}"
        echo -e "${YELLOW}   Create a token at: https://github.com/settings/tokens${NC}"
    else
        echo -e "${GREEN}✅ GitHub token found${NC}"
    fi
}

create_workspace_config() {
    echo -e "${BLUE}🎯 Creating workspace configuration...${NC}"
    
    local workspace_file="$PORTABLE_ENV_DIR/portable-dev-env.code-workspace"
    
    cat > "$workspace_file" << EOF
{
    "folders": [
        {
            "name": "Portable Dev Environment",
            "path": "."
        },
        {
            "name": "Cursor Config",
            "path": "./cursor"
        },
        {
            "name": "VSCode Config",
            "path": "./vscode"
        },
        {
            "name": "Scripts",
            "path": "./scripts"
        }
    ],
    "settings": {
        "editor.wordWrap": "wordWrapColumn",
        "editor.tabSize": 4,
        "editor.insertSpaces": true,
        "files.autoSave": "afterDelay",
        "files.autoSaveDelay": 1000,
        "terminal.integrated.defaultProfile.$PLATFORM": "bash"
    },
    "extensions": {
        "recommendations": [
            "ms-vscode.vscode-json",
            "redhat.vscode-yaml",
            "ms-vscode.powershell",
            "ms-python.python",
            "ms-vscode.vscode-typescript-next"
        ]
    }
}
EOF
    
    echo -e "${GREEN}✅ Workspace configuration created: $workspace_file${NC}"
}

generate_setup_report() {
    echo ""
    echo -e "${BLUE}📊 Setup Report${NC}"
    echo "==============="
    echo -e "${GREEN}✅ Platform: $PLATFORM${NC}"
    echo -e "${GREEN}✅ Components: $COMPONENTS${NC}"
    echo -e "${GREEN}✅ Setup completed successfully${NC}"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo -e "${YELLOW}1. Restart Cursor/VSCode to load new configurations${NC}"
    echo -e "${YELLOW}2. Install recommended extensions${NC}"
    echo -e "${YELLOW}3. Configure API keys for MCP servers${NC}"
    echo -e "${YELLOW}4. Test the setup with: ./scripts/test-setup.sh${NC}"
    echo ""
    echo -e "${CYAN}For gist integration:${NC}"
    echo -e "${CYAN}  ./scripts/gist-manager.sh init${NC}"
    echo -e "${CYAN}  ./scripts/gist-manager.sh list${NC}"
}

main() {
    # Parse command line arguments
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
            --verbose|-v)
                VERBOSE=true
                shift
                ;;
            --help|-h)
                print_usage
                exit 0
                ;;
            *)
                echo -e "${RED}Unknown option: $1${NC}"
                print_usage
                exit 1
                ;;
        esac
    done
    
    echo -e "${BLUE}🚀 Portable Dev Environment Setup${NC}"
    echo "=================================="
    
    # Detect platform if not specified
    if [ -z "$PLATFORM" ]; then
        detect_platform
    fi
    
    # Set default components if not specified
    if [ -z "$COMPONENTS" ]; then
        COMPONENTS="all"
    fi
    
    # Check dependencies
    if ! check_dependencies; then
        exit 1
    fi
    
    # Setup components
    if [[ "$COMPONENTS" == *"cursor"* ]] || [[ "$COMPONENTS" == "all" ]]; then
        setup_cursor
    fi
    
    if [[ "$COMPONENTS" == *"vscode"* ]] || [[ "$COMPONENTS" == "all" ]]; then
        setup_vscode
    fi
    
    if [[ "$COMPONENTS" == *"mcp"* ]] || [[ "$COMPONENTS" == "all" ]]; then
        setup_mcp
    fi
    
    # Setup gist integration
    setup_gist_integration
    
    # Create workspace config
    create_workspace_config
    
    # Generate report
    generate_setup_report
}

main "$@"
