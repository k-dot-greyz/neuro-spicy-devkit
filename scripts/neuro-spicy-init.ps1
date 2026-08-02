# 🧠 Neuro-Spicy DevKit - Interactive Initialization Script (PowerShell)
# Guides users through complete setup with proper authentication flow

param(
    [switch]$Verbose,
    [switch]$Force
)

# Configuration variables
$script:GIT_USER_NAME = ""
$script:GIT_USER_EMAIL = ""
$script:GITHUB_TOKEN = ""
$script:GITHUB_USERNAME = ""
$script:CURSOR_INSTALLED = $false
$script:VSCODE_INSTALLED = $false

# Function to display colored output
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

# Function to display header
function Show-Header {
    Write-Host ""
    Write-ColorOutput "🧠 Neuro-Spicy DevKit - Interactive Setup" "Magenta"
    Write-ColorOutput "========================================" "Magenta"
    Write-Host ""
}

# Function to display section header
function Show-Section {
    param([string]$Title)
    Write-Host ""
    Write-ColorOutput "📋 $Title" "Cyan"
    Write-ColorOutput ("=" * $Title.Length) "Cyan"
    Write-Host ""
}

# Function to prompt for input with validation
function Get-UserInput {
    param(
        [string]$Prompt,
        [string]$VariableName,
        [scriptblock]$ValidationScript = $null,
        [string]$DefaultValue = ""
    )
    
    do {
        if ($DefaultValue) {
            $input = Read-Host "$Prompt (default: $DefaultValue)"
            if ([string]::IsNullOrEmpty($input)) {
                $input = $DefaultValue
            }
        } else {
            $input = Read-Host $Prompt
        }
        
        if ($ValidationScript) {
            try {
                $isValid = & $ValidationScript $input
                if ($isValid) {
                    Set-Variable -Name $VariableName -Value $input -Scope Script
                    break
                } else {
                    Write-ColorOutput "❌ Invalid input. Please try again." "Red"
                }
            } catch {
                Write-ColorOutput "❌ Validation error: $($_.Exception.Message)" "Red"
            }
        } else {
            Set-Variable -Name $VariableName -Value $input -Scope Script
            break
        }
    } while ($true)
}

# Validation functions
function Test-Email {
    param([string]$Email)
    $emailRegex = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return $Email -match $emailRegex
}

function Test-GitHubToken {
    param([string]$Token)
    return $Token.Length -ge 40
}

function Test-GitHubUsername {
    param([string]$Username)
    $usernameRegex = '^[a-zA-Z0-9]([a-zA-Z0-9]|-)*[a-zA-Z0-9]$'
    return ($Username -match $usernameRegex) -and ($Username.Length -ge 1) -and ($Username.Length -le 39)
}

# Function to check if command exists
function Test-Command {
    param([string]$Command)
    return (Get-Command $Command -ErrorAction SilentlyContinue) -ne $null
}

# Function to check Git configuration
function Test-GitConfig {
    try {
        $name = git config --global user.name 2>$null
        $email = git config --global user.email 2>$null
        
        if ($name -and $email) {
            Write-ColorOutput "✅ Git already configured: $name <$email>" "Green"
            return $true
        } else {
            return $false
        }
    } catch {
        return $false
    }
}

# Function to check GitHub token
function Test-GitHubTokenExists {
    if ($env:GITHUB_TOKEN) {
        Write-ColorOutput "✅ GitHub token already set" "Green"
        return $true
    } else {
        return $false
    }
}

# Function to test GitHub token
function Test-GitHubTokenValid {
    param([string]$Token)
    
    try {
        $headers = @{
            "Authorization" = "token $Token"
            "User-Agent" = "Neuro-Spicy-DevKit"
        }
        
        $response = Invoke-RestMethod -Uri "https://api.github.com/user" -Headers $headers -ErrorAction Stop
        
        if ($response.login) {
            Write-ColorOutput "✅ GitHub token valid for user: $($response.login)" "Green"
            $script:GITHUB_USERNAME = $response.login
            return $true
        } else {
            Write-ColorOutput "❌ Invalid GitHub token" "Red"
            return $false
        }
    } catch {
        Write-ColorOutput "❌ Failed to validate GitHub token: $($_.Exception.Message)" "Red"
        return $false
    }
}

# Function to install dependencies
function Install-Dependencies {
    Show-Section "Installing Dependencies"
    
    # Check for Node.js
    if (-not (Test-Command "node")) {
        Write-ColorOutput "📦 Installing Node.js..." "Yellow"
        try {
            if (Test-Command "winget") {
                winget install OpenJS.NodeJS.LTS
            } elseif (Test-Command "choco") {
                choco install nodejs
            } else {
                Write-ColorOutput "❌ Please install Node.js manually from https://nodejs.org/" "Red"
                return $false
            }
        } catch {
            Write-ColorOutput "❌ Failed to install Node.js: $($_.Exception.Message)" "Red"
            return $false
        }
    } else {
        $nodeVersion = node -v
        Write-ColorOutput "✅ Node.js already installed: $nodeVersion" "Green"
    }
    
    # Check for Python
    if (-not (Test-Command "python")) {
        Write-ColorOutput "📦 Installing Python..." "Yellow"
        try {
            if (Test-Command "winget") {
                winget install Python.Python.3
            } elseif (Test-Command "choco") {
                choco install python
            } else {
                Write-ColorOutput "❌ Please install Python manually from https://python.org/" "Red"
                return $false
            }
        } catch {
            Write-ColorOutput "❌ Failed to install Python: $($_.Exception.Message)" "Red"
            return $false
        }
    } else {
        $pythonVersion = python -V
        Write-ColorOutput "✅ Python already installed: $pythonVersion" "Green"
    }
    
    return $true
}

# Function to configure Git
function Set-GitConfig {
    Show-Section "Git Configuration"
    
    if (Test-GitConfig) {
        Write-ColorOutput "Git is already configured. Do you want to update it? (y/N)" "Yellow"
        $response = Read-Host
        if ($response -notmatch '^[Yy]$') {
            return
        }
    }
    
    Get-UserInput "Enter your full name" "GIT_USER_NAME"
    Get-UserInput "Enter your email address" "GIT_USER_EMAIL" { Test-Email $_ }
    
    # Configure Git
    git config --global user.name $script:GIT_USER_NAME
    git config --global user.email $script:GIT_USER_EMAIL
    
    Write-ColorOutput "✅ Git configured: $($script:GIT_USER_NAME) <$($script:GIT_USER_EMAIL)>" "Green"
}

# Function to configure GitHub
function Set-GitHubConfig {
    Show-Section "GitHub Configuration"
    
    # Check for existing token
    if ($env:GITHUB_TOKEN) {
        Write-ColorOutput "GitHub token already set. Do you want to update it? (y/N)" "Yellow"
        $response = Read-Host
        if ($response -notmatch '^[Yy]$') {
            return
        }
    }
    
    Write-ColorOutput "To use GitHub features, you'll need a Personal Access Token." "White"
    Write-ColorOutput "Create one at: https://github.com/settings/tokens" "White"
    Write-ColorOutput "Required scopes: repo, gist, user" "White"
    Write-Host ""
    
    Get-UserInput "Enter your GitHub Personal Access Token" "GITHUB_TOKEN" { Test-GitHubToken $_ }
    
    # Test the token
    if (Test-GitHubTokenValid $script:GITHUB_TOKEN) {
        # Set environment variable
        [Environment]::SetEnvironmentVariable("GITHUB_TOKEN", $script:GITHUB_TOKEN, "User")
        $env:GITHUB_TOKEN = $script:GITHUB_TOKEN
        
        Write-ColorOutput "✅ GitHub token configured and tested" "Green"
    } else {
        Write-ColorOutput "❌ Failed to configure GitHub token" "Red"
        return $false
    }
    
    return $true
}

# Function to check and install editors
function Test-Editors {
    Show-Section "Editor Configuration"
    
    # Check for Cursor
    if (Test-Command "cursor") {
        try {
            $cursorVersion = cursor --version 2>$null | Select-Object -First 1
            Write-ColorOutput "✅ Cursor already installed: $cursorVersion" "Green"
            $script:CURSOR_INSTALLED = $true
        } catch {
            Write-ColorOutput "✅ Cursor already installed" "Green"
            $script:CURSOR_INSTALLED = $true
        }
    } else {
        Write-ColorOutput "📝 Cursor not found. Install from: https://cursor.sh" "Yellow"
        Write-ColorOutput "Do you want to open the download page? (y/N)" "Yellow"
        $response = Read-Host
        if ($response -match '^[Yy]$') {
            Start-Process "https://cursor.sh"
        }
    }
    
    # Check for VSCode
    if (Test-Command "code") {
        try {
            $codeVersion = code --version 2>$null | Select-Object -First 1
            Write-ColorOutput "✅ VSCode already installed: $codeVersion" "Green"
            $script:VSCODE_INSTALLED = $true
        } catch {
            Write-ColorOutput "✅ VSCode already installed" "Green"
            $script:VSCODE_INSTALLED = $true
        }
    } else {
        Write-ColorOutput "📝 VSCode not found. Install from: https://code.visualstudio.com/" "Yellow"
        Write-ColorOutput "Do you want to open the download page? (y/N)" "Yellow"
        $response = Read-Host
        if ($response -match '^[Yy]$') {
            Start-Process "https://code.visualstudio.com/"
        }
    }
}

# Function to run health check
function Invoke-HealthCheck {
    Show-Section "Health Check"
    
    if (Test-Path "./scripts/health-check-core.ps1") {
        Write-ColorOutput "🔍 Running health check..." "Yellow"
        & "./scripts/health-check-core.ps1"
    } else {
        Write-ColorOutput "❌ Health check script not found" "Red"
    }
}

# Function to run core setup
function Invoke-CoreSetup {
    Show-Section "Core Environment Setup"
    
    if (Test-Path "./scripts/neuro-spicy-setup-core.ps1") {
        Write-ColorOutput "⚙️ Running core setup..." "Yellow"
        & "./scripts/neuro-spicy-setup-core.ps1" -Components "core"
    } else {
        Write-ColorOutput "❌ Core setup script not found" "Red"
    }
}

# Function to create user profile
function New-UserProfile {
    Show-Section "User Profile Creation"
    
    Write-ColorOutput "Would you like to create a custom user profile? (y/N)" "White"
    $response = Read-Host
    if ($response -match '^[Yy]$') {
        Write-ColorOutput "📝 Creating user profile..." "Yellow"
        
        # Create user profile directory if it doesn't exist
        $profileDir = "./portable-dev-env/profiles/user"
        if (-not (Test-Path $profileDir)) {
            New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
        }
        
        # Create user profile JSON
        $profileData = @{
            profile = @{
                name = "user-profile"
                title = "User Profile"
                description = "Custom profile for $($script:GIT_USER_NAME)"
                version = "1.0.0"
                author = $script:GIT_USER_NAME
                tags = @("user", "custom", "personal")
                platforms = @("windows", "linux", "macos")
            }
            user = @{
                name = $script:GIT_USER_NAME
                email = $script:GIT_USER_EMAIL
                github_username = $script:GITHUB_USERNAME
                github_token = $script:GITHUB_TOKEN
            }
            tools = @{
                nodejs = @{
                    version = if (Test-Command "node") { node -v } else { "not installed" }
                    check = "node -v"
                }
                python = @{
                    version = if (Test-Command "python") { python -V } else { "not installed" }
                    check = "python -V"
                }
                git = @{
                    version = if (Test-Command "git") { git --version } else { "not installed" }
                    check = "git --version"
                }
            }
            shellConfig = @{
                powershell = @{
                    aliases = @{
                        dev = "npm run dev"
                        build = "npm run build"
                        test = "npm test"
                        push = "./scripts/git-push-retry.ps1 -Branch main"
                    }
                }
            }
            created_at = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
        }
        
        $profileJson = $profileData | ConvertTo-Json -Depth 10
        $profileJson | Out-File -FilePath "$profileDir/user-profile.json" -Encoding UTF8
        
        Write-ColorOutput "✅ User profile created: $profileDir/user-profile.json" "Green"
    }
}

# Function to display final summary
function Show-Summary {
    Show-Section "Setup Complete!"
    
    Write-ColorOutput "🎉 Neuro-Spicy DevKit initialization complete!" "Green"
    Write-Host ""
    Write-ColorOutput "📋 Summary:" "White"
    Write-ColorOutput "  • Git configured: $($script:GIT_USER_NAME) <$($script:GIT_USER_EMAIL)>" "White"
    Write-ColorOutput "  • GitHub token: $($script:GITHUB_TOKEN.Substring(0, 8))... (for $($script:GITHUB_USERNAME))" "White"
    Write-ColorOutput "  • Cursor: $(if ($script:CURSOR_INSTALLED) { '✅ Installed' } else { '❌ Not installed' })" "White"
    Write-ColorOutput "  • VSCode: $(if ($script:VSCODE_INSTALLED) { '✅ Installed' } else { '❌ Not installed' })" "White"
    Write-Host ""
    Write-ColorOutput "🚀 Next steps:" "White"
    Write-ColorOutput "  1. Run: ./scripts/health-check-core.ps1" "White"
    Write-ColorOutput "  2. Run: ./scripts/neuro-spicy-setup-core.ps1 -Components core" "White"
    Write-ColorOutput "  3. Start coding with your neuro-spicy optimized environment!" "White"
    Write-Host ""
    Write-ColorOutput "🧠 Welcome to the neuro-spicy development experience! 🚀" "Magenta"
}

# Main execution
function Start-NeuroSpicyInit {
    Show-Header
    
    Write-ColorOutput "This script will guide you through setting up your neuro-spicy development environment." "White"
    Write-ColorOutput "We'll configure Git, GitHub, and check your development tools." "White"
    Write-Host ""
    Write-ColorOutput "Press Enter to continue or Ctrl+C to exit..." "Yellow"
    Read-Host
    
    # Step 1: Install dependencies
    if (-not (Install-Dependencies)) {
        Write-ColorOutput "❌ Failed to install dependencies" "Red"
        return
    }
    
    # Step 2: Configure Git
    Set-GitConfig
    
    # Step 3: Configure GitHub
    if (-not (Set-GitHubConfig)) {
        Write-ColorOutput "❌ Failed to configure GitHub" "Red"
        return
    }
    
    # Step 4: Check editors
    Test-Editors
    
    # Step 5: Run health check
    Invoke-HealthCheck
    
    # Step 6: Run core setup
    Invoke-CoreSetup
    
    # Step 7: Create user profile
    New-UserProfile
    
    # Step 8: Display summary
    Show-Summary
}

# Run main function
Start-NeuroSpicyInit
