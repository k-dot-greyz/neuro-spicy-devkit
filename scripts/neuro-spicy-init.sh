#!/bin/bash

# 🧠 Neuro-Spicy DevKit - Interactive Initialization Script
# Guides users through complete setup with proper authentication flow

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Configuration variables
GIT_USER_NAME=""
GIT_USER_EMAIL=""
GITHUB_TOKEN=""
GITHUB_USERNAME=""
CURSOR_INSTALLED=false
VSCODE_INSTALLED=false

# Function to display colored output
print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to display header
print_header() {
    echo ""
    print_color $MAGENTA "🧠 Neuro-Spicy DevKit - Interactive Setup"
    print_color $MAGENTA "========================================"
    echo ""
}

# Function to display section header
print_section() {
    local title=$1
    echo ""
    print_color $CYAN "📋 $title"
    print_color $CYAN "$(printf '=%.0s' $(seq 1 ${#title}))"
    echo ""
}

# Function to prompt for input with validation
prompt_input() {
    local prompt=$1
    local variable_name=$2
    local validation_func=$3
    local default_value=$4
    
    while true; do
        if [ -n "$default_value" ]; then
            read -p "$(echo -e "${YELLOW}$prompt${NC} (default: $default_value): ")" input
            input=${input:-$default_value}
        else
            read -p "$(echo -e "${YELLOW}$prompt${NC}: ")" input
        fi
        
        if [ -n "$validation_func" ]; then
            if $validation_func "$input"; then
                eval "$variable_name='$input'"
                break
            else
                print_color $RED "❌ Invalid input. Please try again."
            fi
        else
            eval "$variable_name='$input'"
            break
        fi
    done
}

# Validation functions
validate_email() {
    local email=$1
    if [[ $email =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        return 0
    else
        return 1
    fi
}

validate_github_token() {
    local token=$1
    if [[ ${#token} -ge 40 ]]; then
        return 0
    else
        return 1
    fi
}

validate_github_username() {
    local username=$1
    if [[ $username =~ ^[a-zA-Z0-9]([a-zA-Z0-9]|-)*[a-zA-Z0-9]$ ]] && [[ ${#username} -ge 1 ]] && [[ ${#username} -le 39 ]]; then
        return 0
    else
        return 1
    fi
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check Git configuration
check_git_config() {
    local name=$(git config --global user.name 2>/dev/null)
    local email=$(git config --global user.email 2>/dev/null)
    
    if [ -n "$name" ] && [ -n "$email" ]; then
        print_color $GREEN "✅ Git already configured: $name <$email>"
        return 0
    else
        return 1
    fi
}

# Function to check GitHub token
check_github_token() {
    if [ -n "$GITHUB_TOKEN" ]; then
        print_color $GREEN "✅ GitHub token already set"
        return 0
    else
        return 1
    fi
}

# Function to test GitHub token
test_github_token() {
    local token=$1
    local response=$(curl -s -H "Authorization: token $token" https://api.github.com/user)
    
    if echo "$response" | grep -q '"login"'; then
        local username=$(echo "$response" | grep '"login"' | cut -d'"' -f4)
        print_color $GREEN "✅ GitHub token valid for user: $username"
        GITHUB_USERNAME="$username"
        return 0
    else
        print_color $RED "❌ Invalid GitHub token"
        return 1
    fi
}

# Function to install dependencies
install_dependencies() {
    print_section "Installing Dependencies"
    
    # Check for Node.js
    if ! command_exists node; then
        print_color $YELLOW "📦 Installing Node.js..."
        if command_exists brew; then
            brew install node
        elif command_exists apt-get; then
            curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
            sudo apt-get install -y nodejs
        elif command_exists yum; then
            curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
            sudo yum install -y nodejs
        else
            print_color $RED "❌ Please install Node.js manually from https://nodejs.org/"
            return 1
        fi
    else
        print_color $GREEN "✅ Node.js already installed: $(node -v)"
    fi
    
    # Check for Python
    if ! command_exists python3; then
        print_color $YELLOW "📦 Installing Python..."
        if command_exists brew; then
            brew install python
        elif command_exists apt-get; then
            sudo apt-get install -y python3 python3-pip
        elif command_exists yum; then
            sudo yum install -y python3 python3-pip
        else
            print_color $RED "❌ Please install Python manually from https://python.org/"
            return 1
        fi
    else
        print_color $GREEN "✅ Python already installed: $(python3 -V)"
    fi
}

# Function to configure Git
configure_git() {
    print_section "Git Configuration"
    
    if check_git_config; then
        print_color $YELLOW "Git is already configured. Do you want to update it? (y/N)"
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            return 0
        fi
    fi
    
    prompt_input "Enter your full name" "GIT_USER_NAME" "" ""
    prompt_input "Enter your email address" "GIT_USER_EMAIL" "validate_email" ""
    
    # Configure Git
    git config --global user.name "$GIT_USER_NAME"
    git config --global user.email "$GIT_USER_EMAIL"
    
    print_color $GREEN "✅ Git configured: $GIT_USER_NAME <$GIT_USER_EMAIL>"
}

# Function to configure GitHub
configure_github() {
    print_section "GitHub Configuration"
    
    # Check for existing token
    if [ -n "$GITHUB_TOKEN" ]; then
        print_color $YELLOW "GitHub token already set. Do you want to update it? (y/N)"
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            return 0
        fi
    fi
    
    print_color $WHITE "To use GitHub features, you'll need a Personal Access Token."
    print_color $WHITE "Create one at: https://github.com/settings/tokens"
    print_color $WHITE "Required scopes: repo, gist, user"
    echo ""
    
    prompt_input "Enter your GitHub Personal Access Token" "GITHUB_TOKEN" "validate_github_token" ""
    
    # Test the token
    if test_github_token "$GITHUB_TOKEN"; then
        # Set environment variable
        echo "export GITHUB_TOKEN='$GITHUB_TOKEN'" >> ~/.bashrc
        echo "export GITHUB_TOKEN='$GITHUB_TOKEN'" >> ~/.zshrc
        export GITHUB_TOKEN="$GITHUB_TOKEN"
        
        print_color $GREEN "✅ GitHub token configured and tested"
    else
        print_color $RED "❌ Failed to configure GitHub token"
        return 1
    fi
}

# Function to check and install editors
check_editors() {
    print_section "Editor Configuration"
    
    # Check for Cursor
    if command_exists cursor; then
        print_color $GREEN "✅ Cursor already installed: $(cursor --version 2>/dev/null | head -n1)"
        CURSOR_INSTALLED=true
    else
        print_color $YELLOW "📝 Cursor not found. Install from: https://cursor.sh"
        print_color $YELLOW "Do you want to open the download page? (y/N)"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            if command_exists open; then
                open "https://cursor.sh"
            elif command_exists xdg-open; then
                xdg-open "https://cursor.sh"
            fi
        fi
    fi
    
    # Check for VSCode
    if command_exists code; then
        print_color $GREEN "✅ VSCode already installed: $(code --version 2>/dev/null | head -n1)"
        VSCODE_INSTALLED=true
    else
        print_color $YELLOW "📝 VSCode not found. Install from: https://code.visualstudio.com/"
        print_color $YELLOW "Do you want to open the download page? (y/N)"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            if command_exists open; then
                open "https://code.visualstudio.com/"
            elif command_exists xdg-open; then
                xdg-open "https://code.visualstudio.com/"
            fi
        fi
    fi
}

# Function to run health check
run_health_check() {
    print_section "Health Check"
    
    if [ -f "./scripts/health-check-core.sh" ]; then
        print_color $YELLOW "🔍 Running health check..."
        ./scripts/health-check-core.sh
    else
        print_color $RED "❌ Health check script not found"
    fi
}

# Function to run core setup
run_core_setup() {
    print_section "Core Environment Setup"
    
    if [ -f "./scripts/neuro-spicy-setup-core.sh" ]; then
        print_color $YELLOW "⚙️ Running core setup..."
        ./scripts/neuro-spicy-setup-core.sh --components core
    else
        print_color $RED "❌ Core setup script not found"
    fi
}

# Function to create user profile
create_user_profile() {
    print_section "User Profile Creation"
    
    print_color $WHITE "Would you like to create a custom user profile? (y/N)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        print_color $YELLOW "📝 Creating user profile..."
        
        # Create user profile directory if it doesn't exist
        mkdir -p "./portable-dev-env/profiles/user"
        
        # Create user profile JSON
        cat > "./portable-dev-env/profiles/user/user-profile.json" << EOF
{
  "profile": {
    "name": "user-profile",
    "title": "User Profile",
    "description": "Custom profile for $GIT_USER_NAME",
    "version": "1.0.0",
    "author": "$GIT_USER_NAME",
    "tags": ["user", "custom", "personal"],
    "platforms": ["windows", "linux", "macos"]
  },
  "user": {
    "name": "$GIT_USER_NAME",
    "email": "$GIT_USER_EMAIL",
    "github_username": "$GITHUB_USERNAME",
    "github_token": "$GITHUB_TOKEN"
  },
  "tools": {
    "nodejs": {
      "version": "$(node -v 2>/dev/null || echo 'not installed')",
      "check": "node -v"
    },
    "python": {
      "version": "$(python3 -V 2>/dev/null || echo 'not installed')",
      "check": "python3 -V"
    },
    "git": {
      "version": "$(git --version 2>/dev/null || echo 'not installed')",
      "check": "git --version"
    }
  },
  "shellConfig": {
    "bash": {
      "aliases": {
        "dev": "npm run dev",
        "build": "npm run build",
        "test": "npm test",
        "push": "./scripts/git-push-retry.sh --branch main"
      }
    }
  },
  "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
        
        print_color $GREEN "✅ User profile created: ./portable-dev-env/profiles/user/user-profile.json"
    fi
}

# Function to display final summary
display_summary() {
    print_section "Setup Complete!"
    
    print_color $GREEN "🎉 Neuro-Spicy DevKit initialization complete!"
    echo ""
    print_color $WHITE "📋 Summary:"
    print_color $WHITE "  • Git configured: $GIT_USER_NAME <$GIT_USER_EMAIL>"
    print_color $WHITE "  • GitHub token: ${GITHUB_TOKEN:0:8}... (for $GITHUB_USERNAME)"
    print_color $WHITE "  • Cursor: $([ "$CURSOR_INSTALLED" = true ] && echo "✅ Installed" || echo "❌ Not installed")"
    print_color $WHITE "  • VSCode: $([ "$VSCODE_INSTALLED" = true ] && echo "✅ Installed" || echo "❌ Not installed")"
    echo ""
    print_color $WHITE "🚀 Next steps:"
    print_color $WHITE "  1. Run: ./scripts/health-check-core.sh"
    print_color $WHITE "  2. Run: ./scripts/neuro-spicy-setup-core.sh --components core"
    print_color $WHITE "  3. Start coding with your neuro-spicy optimized environment!"
    echo ""
    print_color $MAGENTA "🧠 Welcome to the neuro-spicy development experience! 🚀"
}

# Main execution
main() {
    print_header
    
    print_color $WHITE "This script will guide you through setting up your neuro-spicy development environment."
    print_color $WHITE "We'll configure Git, GitHub, and check your development tools."
    echo ""
    print_color $YELLOW "Press Enter to continue or Ctrl+C to exit..."
    read -r
    
    # Step 1: Install dependencies
    install_dependencies
    
    # Step 2: Configure Git
    configure_git
    
    # Step 3: Configure GitHub
    configure_github
    
    # Step 4: Check editors
    check_editors
    
    # Step 5: Run health check
    run_health_check
    
    # Step 6: Run core setup
    run_core_setup
    
    # Step 7: Create user profile
    create_user_profile
    
    # Step 8: Display summary
    display_summary
}

# Run main function
main "$@"
