# 🧠 Neuro-Spicy Setup (Core Essentials Only)
# Sets up the essential environment for neuro-spicy development

param(
    [string]$Components = "core",
    [switch]$SkipBackup,
    [switch]$DryRun
)

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Test-Prerequisites {
    Write-ColorOutput "🔍 Checking prerequisites..." "Cyan"
    
    # Run health check
    $healthCheckScript = "$PSScriptRoot\health-check-core.ps1"
    if (Test-Path $healthCheckScript) {
        & $healthCheckScript
        return $LASTEXITCODE -eq 0
    } else {
        Write-ColorOutput "❌ Health check script not found" "Red"
        return $false
    }
}

function Backup-CurrentSetup {
    if ($SkipBackup) {
        Write-ColorOutput "⏭️ Skipping backup (--SkipBackup specified)" "Yellow"
        return
    }
    
    Write-ColorOutput "💾 Creating backup..." "Cyan"
    $backupDir = "backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
    
    # Backup current setup
    if (Test-Path "portable-dev-env") {
        Copy-Item -Path "portable-dev-env" -Destination "$backupDir/portable-dev-env" -Recurse -Force
    }
    if (Test-Path "docs") {
        Copy-Item -Path "docs" -Destination "$backupDir/docs" -Recurse -Force
    }
    
    Write-ColorOutput "✅ Backup created: $backupDir" "Green"
}

function Setup-CursorConfig {
    Write-ColorOutput "🎯 Setting up Cursor configuration..." "Cyan"
    
    $cursorDir = "$env:APPDATA\Cursor"
    $cursorConfigDir = "$cursorDir\User"
    
    # Create Cursor directories
    New-Item -ItemType Directory -Path $cursorConfigDir -Force | Out-Null
    
    # Copy neuro-spicy rules
    $rulesSource = "portable-dev-env\cursor\rules\ai-behavior-rules.md"
    $rulesDest = "$cursorConfigDir\ai-behavior-rules.md"
    
    if (Test-Path $rulesSource) {
        Copy-Item -Path $rulesSource -Destination $rulesDest -Force
        Write-ColorOutput "✅ Cursor AI behavior rules configured" "Green"
    }
    
    # Copy project context
    $contextSource = "portable-dev-env\cursor\memories\project-context.md"
    $contextDest = "$cursorConfigDir\project-context.md"
    
    if (Test-Path $contextSource) {
        Copy-Item -Path $contextSource -Destination $contextDest -Force
        Write-ColorOutput "✅ Cursor project context configured" "Green"
    }
}

function Setup-VSCodeConfig {
    Write-ColorOutput "🎯 Setting up VSCode configuration..." "Cyan"
    
    $vscodeDir = "$env:APPDATA\Code\User"
    
    # Create VSCode directory
    New-Item -ItemType Directory -Path $vscodeDir -Force | Out-Null
    
    # Copy settings
    $settingsSource = "portable-dev-env\vscode\settings\settings.json"
    $settingsDest = "$vscodeDir\settings.json"
    
    if (Test-Path $settingsSource) {
        Copy-Item -Path $settingsSource -Destination $settingsDest -Force
        Write-ColorOutput "✅ VSCode settings configured" "Green"
    }
    
    # Copy extensions
    $extensionsSource = "portable-dev-env\vscode\extensions\extensions.json"
    $extensionsDest = "$vscodeDir\extensions.json"
    
    if (Test-Path $extensionsSource) {
        Copy-Item -Path $extensionsSource -Destination $extensionsDest -Force
        Write-ColorOutput "✅ VSCode extensions configured" "Green"
    }
}

function Setup-GitConfig {
    Write-ColorOutput "🎯 Setting up Git configuration..." "Cyan"
    
    # Check if Git is configured
    $userName = git config --global user.name 2>&1
    $userEmail = git config --global user.email 2>&1
    
    if (-not $userName -or -not $userEmail) {
        Write-ColorOutput "⚠️ Git not configured. Please configure manually:" "Yellow"
        Write-ColorOutput "git config --global user.name 'Your Name'" "Blue"
        Write-ColorOutput "git config --global user.email 'your.email@example.com'" "Blue"
    } else {
        Write-ColorOutput "✅ Git already configured: $userName <$userEmail>" "Green"
    }
    
    # Set up useful Git aliases
    git config --global alias.st status
    git config --global alias.co checkout
    git config --global alias.br branch
    git config --global alias.ci commit
    git config --global alias.unstage 'reset HEAD --'
    git config --global alias.last 'log -1 HEAD'
    git config --global alias.visual '!gitk'
    
    Write-ColorOutput "✅ Git aliases configured" "Green"
}

function Setup-EnvironmentVariables {
    Write-ColorOutput "🎯 Setting up environment variables..." "Cyan"
    
    # Check GitHub token
    if (-not $env:GITHUB_TOKEN) {
        Write-ColorOutput "⚠️ GitHub token not set" "Yellow"
        Write-ColorOutput "💡 Set: `$env:GITHUB_TOKEN = 'your_token_here'" "Blue"
        Write-ColorOutput "💡 Or run: .\scripts\setup-github-token.ps1" "Blue"
    } else {
        Write-ColorOutput "✅ GitHub token configured" "Green"
    }
    
    # Set up PATH if needed
    $nodePath = "$env:APPDATA\npm"
    if (Test-Path $nodePath) {
        $currentPath = $env:PATH
        if ($currentPath -notlike "*$nodePath*") {
            Write-ColorOutput "⚠️ npm path not in PATH" "Yellow"
            Write-ColorOutput "💡 Add: $nodePath to your PATH environment variable" "Blue"
        } else {
            Write-ColorOutput "✅ npm path configured" "Green"
        }
    }
}

function Test-Setup {
    Write-ColorOutput "🧪 Testing setup..." "Cyan"
    
    $tests = @{
        "Cursor Config" = Test-Path "$env:APPDATA\Cursor\User\ai-behavior-rules.md"
        "VSCode Config" = Test-Path "$env:APPDATA\Code\User\settings.json"
        "Git Config" = (git config --global user.name 2>&1) -ne ""
    }
    
    $allPassed = $true
    foreach ($testName in $tests.Keys) {
        if ($tests[$testName]) {
            Write-ColorOutput "✅ $testName" "Green"
        } else {
            Write-ColorOutput "❌ $testName" "Red"
            $allPassed = $false
        }
    }
    
    return $allPassed
}

function Show-NextSteps {
    Write-ColorOutput ""
    Write-ColorOutput "🎉 Neuro-Spicy Setup Complete!" "Green"
    Write-ColorOutput "=============================" "Green"
    Write-ColorOutput ""
    Write-ColorOutput "Next steps:" "Cyan"
    Write-ColorOutput "1. Restart Cursor/VSCode to load new settings" "White"
    Write-ColorOutput "2. Test Git: git status" "White"
    Write-ColorOutput "3. Test GitHub: .\scripts\git-push-retry.ps1 -Branch main" "White"
    Write-ColorOutput ""
    Write-ColorOutput "🧠 Your neuro-spicy environment is ready! 🚀" "Magenta"
}

# Main execution
Write-ColorOutput "🧠 Neuro-Spicy Setup (Core Essentials)" "Magenta"
Write-ColorOutput "======================================" "Magenta"
Write-ColorOutput ""

if ($DryRun) {
    Write-ColorOutput "🔍 DRY RUN MODE - No changes will be made" "Yellow"
    Write-ColorOutput "This would:" "Yellow"
    Write-ColorOutput "- Configure Cursor AI behavior rules" "Yellow"
    Write-ColorOutput "- Configure VSCode settings and extensions" "Yellow"
    Write-ColorOutput "- Set up Git configuration and aliases" "Yellow"
    Write-ColorOutput "- Configure environment variables" "Yellow"
    exit 0
}

# Check prerequisites
if (-not (Test-Prerequisites)) {
    Write-ColorOutput "❌ Prerequisites not met. Please fix issues above." "Red"
    exit 1
}

# Create backup
Backup-CurrentSetup

# Setup components based on selection
switch ($Components.ToLower()) {
    "core" {
        Write-ColorOutput "🔧 Setting up core components..." "Cyan"
        Setup-CursorConfig
        Setup-VSCodeConfig
        Setup-GitConfig
        Setup-EnvironmentVariables
    }
    "minimal" {
        Write-ColorOutput "🔧 Setting up minimal components..." "Cyan"
        Setup-GitConfig
        Setup-EnvironmentVariables
    }
    default {
        Write-ColorOutput "🔧 Setting up all components..." "Cyan"
        Setup-CursorConfig
        Setup-VSCodeConfig
        Setup-GitConfig
        Setup-EnvironmentVariables
    }
}

# Test setup
if (Test-Setup) {
    Show-NextSteps
} else {
    Write-ColorOutput "❌ Setup incomplete. Please check the errors above." "Red"
    exit 1
}
