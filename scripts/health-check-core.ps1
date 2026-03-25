# 🧠 Neuro-Spicy Health Check (Core Essentials Only)
# Validates the essential environment for neuro-spicy development

param(
    [switch]$Verbose,
    [switch]$Fix
)

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Test-Git {
    Write-ColorOutput "🔍 Checking Git..." "Cyan"
    
    try {
        $gitVersion = git --version 2>&1
        if ($gitVersion -match "git version") {
            Write-ColorOutput "✅ Git: $gitVersion" "Green"
            
            # Check Git configuration
            $userName = git config --global user.name 2>&1
            $userEmail = git config --global user.email 2>&1
            
            if ($userName -and $userEmail) {
                Write-ColorOutput "✅ Git configured: $userName <$userEmail>" "Green"
            } else {
                Write-ColorOutput "⚠️ Git not configured" "Yellow"
                if ($Fix) {
                    Write-ColorOutput "💡 Run: git config --global user.name 'Your Name'" "Blue"
                    Write-ColorOutput "💡 Run: git config --global user.email 'your.email@example.com'" "Blue"
                }
            }
            
            return $true
        }
    } catch {
        Write-ColorOutput "❌ Git: Not installed" "Red"
        if ($Fix) {
            Write-ColorOutput "💡 Install: winget install Git.Git" "Blue"
        }
        return $false
    }
}

function Test-NodeJS {
    Write-ColorOutput "🔍 Checking Node.js..." "Cyan"
    
    try {
        $nodeVersion = node --version 2>&1
        if ($nodeVersion -match "v(1[8-9]|[2-9][0-9]|[1-9][0-9]{2,})") {
            Write-ColorOutput "✅ Node.js: $nodeVersion" "Green"
            
            # Check npm
            $npmVersion = npm --version 2>&1
            Write-ColorOutput "✅ npm: $npmVersion" "Green"
            
            return $true
        } else {
            Write-ColorOutput "❌ Node.js: Version 18+ required (found: $nodeVersion)" "Red"
            if ($Fix) {
                Write-ColorOutput "💡 Install: winget install OpenJS.NodeJS.LTS" "Blue"
            }
            return $false
        }
    } catch {
        Write-ColorOutput "❌ Node.js: Not installed" "Red"
        if ($Fix) {
            Write-ColorOutput "💡 Install: winget install OpenJS.NodeJS.LTS" "Blue"
        }
        return $false
    }
}

function Test-Python {
    Write-ColorOutput "🔍 Checking Python..." "Cyan"
    
    try {
        $pythonVersion = python --version 2>&1
        if ($pythonVersion -match "Python 3\.([8-9]|[1-9][0-9])") {
            Write-ColorOutput "✅ Python: $pythonVersion" "Green"
            return $true
        } else {
            Write-ColorOutput "❌ Python: Version 3.8+ required (found: $pythonVersion)" "Red"
            if ($Fix) {
                Write-ColorOutput "💡 Install: winget install Python.Python.3" "Blue"
            }
            return $false
        }
    } catch {
        Write-ColorOutput "❌ Python: Not installed" "Red"
        if ($Fix) {
            Write-ColorOutput "💡 Install: winget install Python.Python.3" "Blue"
        }
        return $false
    }
}

function Test-GitHubToken {
    Write-ColorOutput "🔍 Checking GitHub token..." "Cyan"
    
    $token = $env:GITHUB_TOKEN
    if ($token) {
        Write-ColorOutput "✅ GitHub token: Set" "Green"
        return $true
    } else {
        Write-ColorOutput "⚠️ GitHub token: Not set" "Yellow"
        if ($Fix) {
            Write-ColorOutput "💡 Set: `$env:GITHUB_TOKEN = 'your_token_here'" "Blue"
            Write-ColorOutput "💡 Or: .\scripts\setup-github-token.ps1" "Blue"
        }
        return $false
    }
}

function Test-OpenClaw {
    Write-ColorOutput "🔍 Checking OpenClaw..." "Cyan"
    
    try {
        $ocVersion = openclaw --version 2>&1
        if ($ocVersion) {
            Write-ColorOutput "✅ OpenClaw: $($ocVersion[0])" "Green"
            
            if (Test-Path "$env:USERPROFILE\.openclaw\openclaw.json") {
                Write-ColorOutput "✅ OpenClaw config: Found" "Green"
            } else {
                Write-ColorOutput "⚠️ OpenClaw config: Not initialized" "Yellow"
                if ($Fix) {
                    Write-ColorOutput "💡 Run: openclaw onboard" "Blue"
                }
            }
            return $true
        }
    } catch {
        Write-ColorOutput "⚠️ OpenClaw: Not installed" "Yellow"
        if ($Fix) {
            Write-ColorOutput "💡 Install: npm install -g openclaw@latest" "Blue"
            Write-ColorOutput "💡 Or: iwr -useb https://openclaw.ai/install.ps1 | iex" "Blue"
        }
        return $false
    }
    return $false
}

function Test-Cursor {
    Write-ColorOutput "🔍 Checking Cursor..." "Cyan"
    
    $cursorPath = "$env:LOCALAPPDATA\Programs\cursor\Cursor.exe"
    if (Test-Path $cursorPath) {
        Write-ColorOutput "✅ Cursor: Installed" "Green"
        return $true
    } else {
        Write-ColorOutput "⚠️ Cursor: Not found" "Yellow"
        if ($Fix) {
            Write-ColorOutput "💡 Download: https://cursor.sh/" "Blue"
        }
        return $false
    }
}

function Test-VSCode {
    Write-ColorOutput "🔍 Checking VSCode..." "Cyan"
    
    try {
        $codeVersion = code --version 2>&1
        if ($codeVersion -match "[0-9]+\.[0-9]+\.[0-9]+") {
            Write-ColorOutput "✅ VSCode: $($codeVersion[0])" "Green"
            return $true
        }
    } catch {
        # Try alternative paths
        $vscodePath = "$env:LOCALAPPDATA\Programs\Microsoft VS Code\Code.exe"
        if (Test-Path $vscodePath) {
            Write-ColorOutput "✅ VSCode: Installed" "Green"
            return $true
        }
    }
    
    Write-ColorOutput "⚠️ VSCode: Not found" "Yellow"
    if ($Fix) {
        Write-ColorOutput "💡 Install: winget install Microsoft.VisualStudioCode" "Blue"
    }
    return $false
}

function Show-Summary {
    param([hashtable]$Results)
    
    Write-ColorOutput ""
    Write-ColorOutput "🧠 Neuro-Spicy Health Check Summary" "Magenta"
    Write-ColorOutput "=================================" "Magenta"
    
    $totalChecks = $Results.Count
    $passedChecks = ($Results.Values | Where-Object { $_ -eq $true }).Count
    $failedChecks = $totalChecks - $passedChecks
    
    Write-ColorOutput "Total Checks: $totalChecks" "White"
    Write-ColorOutput "Passed: $passedChecks" "Green"
    Write-ColorOutput "Failed: $failedChecks" "Red"
    
    if ($failedChecks -eq 0) {
        Write-ColorOutput ""
        Write-ColorOutput "🎉 All core essentials are ready!" "Green"
        Write-ColorOutput "Run: .\neuro-spicy-setup.ps1 --components core" "Blue"
    } else {
        Write-ColorOutput ""
        Write-ColorOutput "⚠️ Some components need attention" "Yellow"
        Write-ColorOutput "Run: .\health-check-core.ps1 -Fix" "Blue"
    }
}

# Main execution
Write-ColorOutput "🧠 Neuro-Spicy Health Check (Core Essentials)" "Magenta"
Write-ColorOutput "=============================================" "Magenta"
Write-ColorOutput ""

$results = @{
    "Git" = Test-Git
    "Node.js" = Test-NodeJS
    "Python" = Test-Python
    "GitHub Token" = Test-GitHubToken
    "OpenClaw" = Test-OpenClaw
    "Cursor" = Test-Cursor
    "VSCode" = Test-VSCode
}

Show-Summary -Results $results

if ($Verbose) {
    Write-ColorOutput ""
    Write-ColorOutput "🔍 Verbose Information:" "Cyan"
    Write-ColorOutput "Environment: $env:OS" "White"
    Write-ColorOutput "PowerShell: $($PSVersionTable.PSVersion)" "White"
    Write-ColorOutput "Working Directory: $(Get-Location)" "White"
}
