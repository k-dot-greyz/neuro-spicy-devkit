# 🔑 GitHub Token Setup
# Guides the user through setting up a GitHub Personal Access Token
# Stores it as a user-level environment variable

param(
    [switch]$Test,
    [switch]$DryRun,
    [switch]$Help
)

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Test-GitHubToken {
    param([string]$Token)

    try {
        $response = Invoke-RestMethod -Uri "https://api.github.com/user" -Headers @{
            Authorization = "token $Token"
        } -ErrorAction Stop
        Write-ColorOutput "✅ Token valid — authenticated as: $($response.login)" "Green"
        return $true
    } catch {
        $status = $_.Exception.Response.StatusCode.Value__
        Write-ColorOutput "❌ Token invalid (HTTP $status)" "Red"
        return $false
    }
}

if ($Help) {
    Write-ColorOutput "Usage: .\setup-github-token.ps1 [OPTIONS]" "Cyan"
    Write-ColorOutput ""
    Write-ColorOutput "Sets up a GitHub Personal Access Token for Neuro-Spicy DevKit."
    Write-ColorOutput ""
    Write-ColorOutput "Options:"
    Write-ColorOutput "  -Test       Test existing token without prompting"
    Write-ColorOutput "  -DryRun     Show what would be done without making changes"
    Write-ColorOutput "  -Help       Show this help message"
    Write-ColorOutput ""
    Write-ColorOutput "Required token scopes: repo, gist, user"
    Write-ColorOutput "Create at: https://github.com/settings/tokens"
    exit 0
}

# Test-only mode
if ($Test) {
    $existingToken = $env:GITHUB_TOKEN
    if ($existingToken) {
        Write-ColorOutput "🔍 Testing existing GITHUB_TOKEN..." "Cyan"
        $result = Test-GitHubToken -Token $existingToken
        if ($result) { exit 0 } else { exit 1 }
    }
    Write-ColorOutput "⚠️ No token found. Run without -Test to set one up." "Yellow"
    exit 1
}

# Dry run
if ($DryRun) {
    Write-ColorOutput "🔍 DRY RUN — would:" "Yellow"
    Write-ColorOutput "  1. Prompt for GitHub Personal Access Token" "Cyan"
    Write-ColorOutput "  2. Validate token against api.github.com" "Cyan"
    Write-ColorOutput "  3. Store as user-level environment variable" "Cyan"
    exit 0
}

# Main setup flow
Write-ColorOutput "🔑 GitHub Token Setup" "Magenta"
Write-ColorOutput "=====================" "Magenta"
Write-ColorOutput ""

# Check existing
$existingToken = $env:GITHUB_TOKEN
if ($existingToken) {
    Write-ColorOutput "⚠️ GITHUB_TOKEN is already set." "Yellow"
    Write-ColorOutput "Testing it..." "Cyan"
    if (Test-GitHubToken -Token $existingToken) {
        $response = Read-Host "Replace with a new token? (y/N)"
        if ($response -notmatch "^[Yy]$") {
            Write-ColorOutput "Keeping existing token." "Green"
            exit 0
        }
    }
    Write-ColorOutput ""
}

# Instructions
Write-ColorOutput "To create a GitHub Personal Access Token:" "Cyan"
Write-ColorOutput "  1. Go to: https://github.com/settings/tokens" "Cyan"
Write-ColorOutput "  2. Click 'Generate new token (classic)'" "Cyan"
Write-ColorOutput "  3. Required scopes: repo, gist, user" "Cyan"
Write-ColorOutput "  4. Copy the token (you won't see it again!)" "Cyan"
Write-ColorOutput ""

# Prompt
$secureToken = Read-Host "Enter your GitHub Personal Access Token" -AsSecureString
$tokenInput = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureToken)
)

# Validate length
if ($tokenInput.Length -lt 40) {
    Write-ColorOutput "❌ Token too short (expected 40+ characters). Aborting." "Red"
    exit 1
}

# Test
Write-ColorOutput "🔍 Validating token..." "Cyan"
if (-not (Test-GitHubToken -Token $tokenInput)) {
    Write-ColorOutput "Token validation failed. Not saving." "Red"
    exit 1
}

# Store as user-level env var (persists across sessions)
[System.Environment]::SetEnvironmentVariable("GITHUB_TOKEN", $tokenInput, "User")
$env:GITHUB_TOKEN = $tokenInput
Write-ColorOutput "✅ Token stored as user-level environment variable" "Green"

Write-ColorOutput ""
Write-ColorOutput "🎉 GitHub token setup complete!" "Green"
Write-ColorOutput "Token is available in this session and future shells." "Cyan"
