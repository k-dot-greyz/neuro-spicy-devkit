# Git Push Retry Script
# Handles network issues and retries failed pushes

param(
    [string]$Branch = "main",
    [int]$MaxRetries = 3,
    [int]$DelaySeconds = 5
)

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Test-GitPush {
    param([string]$Branch)
    
    Write-ColorOutput "🚀 Attempting to push to origin/$Branch..." "Blue"
    
    try {
        $Result = git push origin $Branch 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "✅ Push successful!" "Green"
            return $true
        } else {
            Write-ColorOutput "❌ Push failed with exit code: $LASTEXITCODE" "Red"
            Write-ColorOutput "Error: $Result" "Red"
            return $false
        }
    }
    catch {
        Write-ColorOutput "❌ Push failed with exception: $($_.Exception.Message)" "Red"
        return $false
    }
}

function Start-PushRetry {
    param([string]$Branch, [int]$MaxRetries, [int]$DelaySeconds)
    
    Write-ColorOutput "🔄 Git Push Retry Script" "Magenta"
    Write-ColorOutput "=======================" "Magenta"
    Write-ColorOutput ""
    
    for ($Attempt = 1; $Attempt -le $MaxRetries; $Attempt++) {
        Write-ColorOutput "📤 Attempt $Attempt of $MaxRetries" "Cyan"
        
        if (Test-GitPush $Branch) {
            Write-ColorOutput "🎉 Push completed successfully!" "Green"
            return $true
        }
        
        if ($Attempt -lt $MaxRetries) {
            Write-ColorOutput "⏳ Waiting $DelaySeconds seconds before retry..." "Yellow"
            Start-Sleep -Seconds $DelaySeconds
        }
    }
    
    Write-ColorOutput "❌ All push attempts failed after $MaxRetries tries" "Red"
    Write-ColorOutput "💡 Try checking your network connection or Git credentials" "Yellow"
    return $false
}

# Main execution
if ($Branch -eq "") {
    Write-ColorOutput "Usage: .\git-push-retry.ps1 -Branch <branch> [-MaxRetries <number>] [-DelaySeconds <number>]" "Blue"
    Write-ColorOutput "Example: .\git-push-retry.ps1 -Branch main -MaxRetries 5 -DelaySeconds 10" "Blue"
    exit 1
}

Start-PushRetry -Branch $Branch -MaxRetries $MaxRetries -DelaySeconds $DelaySeconds
