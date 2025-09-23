# Neuro-Spicy DevKit Ultimate Setup Script
# Comprehensive environment setup with auto-detection and GitHub MCP registry integration

param(
    [string]$Platform = "windows",
    [string]$Components = "all",
    [switch]$AutoFix,
    [switch]$Verbose,
    [switch]$SkipHealthCheck
)

# Colors for output
$Red = "Red"
$Green = "Green"
$Yellow = "Yellow"
$Blue = "Blue"
$Cyan = "Cyan"
$Magenta = "Magenta"

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Show-Banner {
    Write-ColorOutput "🧠 Neuro-Spicy DevKit Ultimate Setup" $Magenta
    Write-ColorOutput "====================================" $Magenta
    Write-ColorOutput "Turning environment setup bugs into features!" $Cyan
    Write-ColorOutput ""
}

function Install-NodeJS {
    Write-ColorOutput "📦 Installing Node.js..." $Blue
    
    try {
        # Try winget first
        winget install OpenJS.NodeJS.LTS --accept-package-agreements --accept-source-agreements
        Write-ColorOutput "✅ Node.js installed via winget" $Green
        
        # Refresh PATH
        $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "User")
        
        # Verify installation
        $NodeVersion = node --version 2>$null
        $NpmVersion = npm --version 2>$null
        
        if ($NodeVersion -and $NpmVersion) {
            Write-ColorOutput "✅ Node.js: $NodeVersion, npm: $NpmVersion" $Green
            return $true
        } else {
            Write-ColorOutput "⚠️ Node.js installed but not in PATH" $Yellow
            return $false
        }
    }
    catch {
        Write-ColorOutput "❌ Failed to install Node.js: $($_.Exception.Message)" $Red
        Write-ColorOutput "Please install manually from: https://nodejs.org" $Yellow
        return $false
    }
}

function Install-MCPServers {
    Write-ColorOutput "🔧 Installing MCP Servers..." $Blue
    
    $Servers = @(
        "@cyanheads/git-mcp-server",
        "@modelcontextprotocol/server-filesystem",
        "@jpisnice/shadcn-ui-mcp-server"
    )
    
    $SuccessCount = 0
    foreach ($Server in $Servers) {
        try {
            Write-ColorOutput "Installing $Server..." $Cyan
            npm install -g $Server
            Write-ColorOutput "✅ Installed $Server" $Green
            $SuccessCount++
        }
        catch {
            Write-ColorOutput "❌ Failed to install $Server`: $($_.Exception.Message)" $Red
        }
    }
    
    Write-ColorOutput "✅ Installed $SuccessCount/$($Servers.Count) MCP servers" $Green
    return $SuccessCount -eq $Servers.Count
}

function Setup-CursorMCP {
    Write-ColorOutput "🎯 Setting up Cursor MCP..." $Blue
    
    $CursorConfigDir = "$env:APPDATA\Cursor"
    $MCPConfigFile = Join-Path $CursorConfigDir "mcp.json"
    
    if (!(Test-Path $CursorConfigDir)) {
        Write-ColorOutput "❌ Cursor config directory not found" $Red
        return $false
    }
    
    # Create MCP config
    $MCPConfig = @{
        mcpServers = @{
            "docker-gateway" = @{
                command = "docker"
                args = @("mcp", "gateway", "run", "--enable-all-servers")
                type = "stdio"
                env = @{
                    DOCKER_DEFAULT_PLATFORM = "linux/amd64"
                }
            }
            "git" = @{
                command = "git-mcp-server"
                args = @()
                env = @{
                    GIT_USER_NAME = "Your Name"
                    GIT_USER_EMAIL = "yourname.yourname@gmail.com"
                }
            }
            "filesystem" = @{
                command = "mcp-server-filesystem"
                args = @()
                env = @{}
            }
        }
    }
    
    try {
        $MCPConfig | ConvertTo-Json -Depth 4 | Out-File -FilePath $MCPConfigFile -Encoding UTF8
        Write-ColorOutput "✅ Cursor MCP config created" $Green
        return $true
    }
    catch {
        Write-ColorOutput "❌ Failed to create Cursor MCP config`: $($_.Exception.Message)" $Red
        return $false
    }
}

function Setup-GitHubToken {
    Write-ColorOutput "🔑 Setting up GitHub Token..." $Blue
    
    if ($env:GITHUB_TOKEN) {
        try {
            $Response = Invoke-RestMethod -Uri "https://api.github.com/user" -Headers @{Authorization = "token $env:GITHUB_TOKEN"}
            Write-ColorOutput "✅ GitHub Token valid for: $($Response.login)" $Green
            return $true
        }
        catch {
            Write-ColorOutput "❌ GitHub Token invalid" $Red
            return $false
        }
    } else {
        Write-ColorOutput "⚠️ GitHub Token not set" $Yellow
        Write-ColorOutput "Create token at: https://github.com/settings/tokens" $Cyan
        Write-ColorOutput "Set scopes: gist, repo" $Cyan
        Write-ColorOutput "Set environment: `$env:GITHUB_TOKEN='your_token_here'" $Cyan
        return $false
    }
}

function Run-HealthCheck {
    Write-ColorOutput "🏥 Running Health Check..." $Blue
    
    try {
        $HealthCheckScript = Join-Path $PSScriptRoot "health-check.ps1"
        if (Test-Path $HealthCheckScript) {
            & $HealthCheckScript -Suggest
            return $true
        } else {
            Write-ColorOutput "⚠️ Health check script not found" $Yellow
            return $false
        }
    }
    catch {
        Write-ColorOutput "❌ Health check failed`: $($_.Exception.Message)" $Red
        return $false
    }
}

function Create-SampleGists {
    Write-ColorOutput "📝 Creating sample Gists..." $Blue
    
    try {
        $GistManagerScript = Join-Path $PSScriptRoot "gist-manager.ps1"
        if (Test-Path $GistManagerScript) {
            & $GistManagerScript init
            & $GistManagerScript create cursor-rules
            Write-ColorOutput "✅ Sample Gists created" $Green
            return $true
        } else {
            Write-ColorOutput "⚠️ Gist manager script not found" $Yellow
            return $false
        }
    }
    catch {
        Write-ColorOutput "❌ Failed to create Gists`: $($_.Exception.Message)" $Red
        return $false
    }
}

function Show-CompletionSummary {
    param($Results)
    
    Write-ColorOutput ""
    Write-ColorOutput "🎉 Neuro-Spicy DevKit Setup Complete!" $Green
    Write-ColorOutput "=====================================" $Green
    Write-ColorOutput ""
    
    $TotalSteps = 5
    $CompletedSteps = 0
    
    if ($Results.NodeJS) { $CompletedSteps++; Write-ColorOutput "✅ Node.js installed" $Green }
    if ($Results.MCPServers) { $CompletedSteps++; Write-ColorOutput "✅ MCP Servers installed" $Green }
    if ($Results.CursorMCP) { $CompletedSteps++; Write-ColorOutput "✅ Cursor MCP configured" $Green }
    if ($Results.GitHubToken) { $CompletedSteps++; Write-ColorOutput "✅ GitHub Token validated" $Green }
    if ($Results.Gists) { $CompletedSteps++; Write-ColorOutput "✅ Sample Gists created" $Green }
    
    Write-ColorOutput ""
    Write-ColorOutput "📊 Completion: $CompletedSteps/$TotalSteps" $Cyan
    
    if ($CompletedSteps -eq $TotalSteps) {
        Write-ColorOutput "🚀 Ready for neuro-spicy development!" $Green
    } elseif ($CompletedSteps -ge 3) {
        Write-ColorOutput "⚠️ Mostly ready, some manual setup needed" $Yellow
    } else {
        Write-ColorOutput "❌ Significant manual setup required" $Red
    }
    
    Write-ColorOutput ""
    Write-ColorOutput "💡 Next Steps:" $Cyan
    Write-ColorOutput "  • Run health check: .\health-check.ps1 -Suggest" $Cyan
    Write-ColorOutput "  • Create Gists: .\gist-manager.ps1 create <name>" $Cyan
    Write-ColorOutput "  • Explore MCPs: .\mcp-registry.ps1 -List" $Cyan
    Write-ColorOutput "  • Start coding with your neuro-spicy superpowers! 🧠✨" $Cyan
}

# Main execution
Show-Banner

$Results = @{
    NodeJS = $false
    MCPServers = $false
    CursorMCP = $false
    GitHubToken = $false
    Gists = $false
}

# Run health check first
if (!$SkipHealthCheck) {
    Run-HealthCheck
}

# Install Node.js if needed
if ($Components -eq "all" -or $Components -eq "nodejs") {
    $Results.NodeJS = Install-NodeJS
}

# Install MCP servers
if ($Components -eq "all" -or $Components -eq "mcp") {
    $Results.MCPServers = Install-MCPServers
}

# Setup Cursor MCP
if ($Components -eq "all" -or $Components -eq "cursor") {
    $Results.CursorMCP = Setup-CursorMCP
}

# Setup GitHub Token
if ($Components -eq "all" -or $Components -eq "github") {
    $Results.GitHubToken = Setup-GitHubToken
}

# Create sample Gists
if ($Components -eq "all" -or $Components -eq "gists") {
    $Results.Gists = Create-SampleGists
}

Show-CompletionSummary $Results

