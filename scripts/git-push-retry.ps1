# 🔄 Git Push with Retry (Exponential Backoff)
# Reliable git push for flaky networks / CI environments

param(
    [string]$Branch = "",
    [string]$Remote = "origin",
    [int]$Retries = 4,
    [switch]$Force,
    [switch]$DryRun,
    [switch]$Help
)

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

if ($Help) {
    Write-ColorOutput "Usage: .\git-push-retry.ps1 [OPTIONS]" "Cyan"
    Write-ColorOutput ""
    Write-ColorOutput "Pushes the current branch to a remote with retry + exponential backoff."
    Write-ColorOutput ""
    Write-ColorOutput "Options:"
    Write-ColorOutput "  -Branch <name>    Branch to push (default: current branch)"
    Write-ColorOutput "  -Remote <name>    Remote name (default: origin)"
    Write-ColorOutput "  -Retries <count>  Max retry attempts (default: 4)"
    Write-ColorOutput "  -Force            Force push (use with caution)"
    Write-ColorOutput "  -DryRun           Show what would be done without pushing"
    Write-ColorOutput "  -Help             Show this help message"
    Write-ColorOutput ""
    Write-ColorOutput "Examples:"
    Write-ColorOutput "  .\git-push-retry.ps1 -Branch main"
    Write-ColorOutput "  .\git-push-retry.ps1 -Branch feature/cool-stuff -Retries 3"
    exit 0
}

# Resolve branch
if ([string]::IsNullOrEmpty($Branch)) {
    try {
        $Branch = (git rev-parse --abbrev-ref HEAD 2>&1).Trim()
    } catch {
        Write-ColorOutput "❌ Not in a git repository or unable to determine current branch" "Red"
        exit 1
    }
}

# Verify git state
try {
    git rev-parse --git-dir 2>&1 | Out-Null
} catch {
    Write-ColorOutput "❌ Not in a git repository" "Red"
    exit 1
}

# Build push args
$pushArgs = @("push", "-u", $Remote, $Branch)
if ($Force) {
    $pushArgs = @("push", "-u", "--force-with-lease", $Remote, $Branch)
}

# Dry run
if ($DryRun) {
    Write-ColorOutput "🔍 DRY RUN — would execute:" "Yellow"
    Write-ColorOutput "  git $($pushArgs -join ' ')" "Cyan"
    Write-ColorOutput "  Remote: $Remote" "Cyan"
    Write-ColorOutput "  Branch: $Branch" "Cyan"
    Write-ColorOutput "  Max retries: $Retries" "Cyan"
    Write-ColorOutput "  Force: $Force" "Cyan"
    exit 0
}

# Push with retry
Write-ColorOutput "🔄 Pushing $Branch to $Remote..." "Cyan"

$attempt = 1
$backoff = 4

while ($attempt -le $Retries) {
    Write-ColorOutput "  Attempt ${attempt}/${Retries}..." "Cyan"

    $result = & git @pushArgs 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-ColorOutput "✅ Push successful on attempt $attempt" "Green"
        exit 0
    }

    if ($attempt -eq $Retries) {
        Write-ColorOutput "❌ Push failed after $Retries attempts" "Red"
        Write-ColorOutput "$result" "Red"
        exit 1
    }

    Write-ColorOutput "⚠️ Push failed. Retrying in ${backoff}s..." "Yellow"
    Start-Sleep -Seconds $backoff
    $backoff = $backoff * 2
    $attempt++
}
