# Neuro-Spicy DevKit Health Check System
# Comprehensive environment validation and setup suggestions

param(
    [switch]$Verbose,
    [switch]$Fix,
    [switch]$Suggest
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

function Test-Docker {
    Write-ColorOutput "🐳 Checking Docker..." $Blue
    
    try {
        $DockerVersion = docker --version 2>$null
        if ($DockerVersion) {
            Write-ColorOutput "✅ Docker: $DockerVersion" $Green
            
            # Check if Docker is running
            try {
                $DockerInfo = docker info 2>$null
                if ($DockerInfo) {
                    Write-ColorOutput "✅ Docker is running" $Green
                    
                    # Check Docker MCP Gateway
                    try {
                        $MCPGateway = docker mcp gateway run --help 2>$null
                        if ($MCPGateway) {
                            Write-ColorOutput "✅ Docker MCP Gateway available" $Green
                            return @{ Status = "OK"; Version = $DockerVersion; Running = $true; MCPGateway = $true }
                        } else {
                            Write-ColorOutput "⚠️ Docker MCP Gateway not available" $Yellow
                            return @{ Status = "Partial"; Version = $DockerVersion; Running = $true; MCPGateway = $false }
                        }
                    } catch {
                        Write-ColorOutput "⚠️ Docker MCP Gateway not available" $Yellow
                        return @{ Status = "Partial"; Version = $DockerVersion; Running = $true; MCPGateway = $false }
                    }
                } else {
                    Write-ColorOutput "❌ Docker is not running" $Red
                    return @{ Status = "NotRunning"; Version = $DockerVersion; Running = $false; MCPGateway = $false }
                }
            } catch {
                Write-ColorOutput "❌ Docker is not running" $Red
                return @{ Status = "NotRunning"; Version = $DockerVersion; Running = $false; MCPGateway = $false }
            }
        } else {
            Write-ColorOutput "❌ Docker not found" $Red
            return @{ Status = "NotFound"; Version = $null; Running = $false; MCPGateway = $false }
        }
    } catch {
        Write-ColorOutput "❌ Docker not found" $Red
        return @{ Status = "NotFound"; Version = $null; Running = $false; MCPGateway = $false }
    }
}

function Test-Git {
    Write-ColorOutput "📝 Checking Git..." $Blue
    
    try {
        $GitVersion = git --version 2>$null
        if ($GitVersion) {
            Write-ColorOutput "✅ Git: $GitVersion" $Green
            
            # Check Git configuration
            try {
                $GitUser = git config --global user.name 2>$null
                $GitEmail = git config --global user.email 2>$null
                
                if ($GitUser -and $GitEmail) {
                    Write-ColorOutput "✅ Git configured: $GitUser <$GitEmail>" $Green
                    return @{ Status = "OK"; Version = $GitVersion; Configured = $true; User = $GitUser; Email = $GitEmail }
                } else {
                    Write-ColorOutput "⚠️ Git not fully configured" $Yellow
                    return @{ Status = "Partial"; Version = $GitVersion; Configured = $false; User = $GitUser; Email = $GitEmail }
                }
            } catch {
                Write-ColorOutput "⚠️ Git not fully configured" $Yellow
                return @{ Status = "Partial"; Version = $GitVersion; Configured = $false; User = $null; Email = $null }
            }
        } else {
            Write-ColorOutput "❌ Git not found" $Red
            return @{ Status = "NotFound"; Version = $null; Configured = $false; User = $null; Email = $null }
        }
    } catch {
        Write-ColorOutput "❌ Git not found" $Red
        return @{ Status = "NotFound"; Version = $null; Configured = $false; User = $null; Email = $null }
    }
}

function Test-NodeJS {
    Write-ColorOutput "📦 Checking Node.js..." $Blue
    
    try {
        $NodeVersion = node --version 2>$null
        if ($NodeVersion) {
            Write-ColorOutput "✅ Node.js: $NodeVersion" $Green
            
            # Check npm
            try {
                $NpmVersion = npm --version 2>$null
                if ($NpmVersion) {
                    Write-ColorOutput "✅ npm: $NpmVersion" $Green
                    
                    # Check for MCP servers
                    $MCPServers = @()
                    $GlobalPackages = npm list -g --depth=0 2>$null
                    
                    if ($GlobalPackages -match "git-mcp-server") { $MCPServers += "git-mcp-server" }
                    if ($GlobalPackages -match "mcp-server-filesystem") { $MCPServers += "mcp-server-filesystem" }
                    if ($GlobalPackages -match "shadcn-ui-mcp-server") { $MCPServers += "shadcn-ui-mcp-server" }
                    
                    if ($MCPServers.Count -gt 0) {
                        Write-ColorOutput "✅ MCP Servers installed: $($MCPServers -join ', ')" $Green
                    } else {
                        Write-ColorOutput "⚠️ No MCP servers installed" $Yellow
                    }
                    
                    return @{ Status = "OK"; NodeVersion = $NodeVersion; NpmVersion = $NpmVersion; MCPServers = $MCPServers }
                } else {
                    Write-ColorOutput "❌ npm not found" $Red
                    return @{ Status = "Partial"; NodeVersion = $NodeVersion; NpmVersion = $null; MCPServers = @() }
                }
            } catch {
                Write-ColorOutput "❌ npm not found" $Red
                return @{ Status = "Partial"; NodeVersion = $NodeVersion; NpmVersion = $null; MCPServers = @() }
            }
        } else {
            Write-ColorOutput "❌ Node.js not found" $Red
            return @{ Status = "NotFound"; NodeVersion = $null; NpmVersion = $null; MCPServers = @() }
        }
    } catch {
        Write-ColorOutput "❌ Node.js not found" $Red
        return @{ Status = "NotFound"; NodeVersion = $null; NpmVersion = $null; MCPServers = @() }
    }
}

function Test-Python {
    Write-ColorOutput "🐍 Checking Python..." $Blue
    
    try {
        $PythonVersion = python --version 2>$null
        if ($PythonVersion) {
            Write-ColorOutput "✅ Python: $PythonVersion" $Green
            
            # Check pip
            try {
                $PipVersion = pip --version 2>$null
                if ($PipVersion) {
                    Write-ColorOutput "✅ pip: $PipVersion" $Green
                    return @{ Status = "OK"; Version = $PythonVersion; PipVersion = $PipVersion }
                } else {
                    Write-ColorOutput "❌ pip not found" $Red
                    return @{ Status = "Partial"; Version = $PythonVersion; PipVersion = $null }
                }
            } catch {
                Write-ColorOutput "❌ pip not found" $Red
                return @{ Status = "Partial"; Version = $PythonVersion; PipVersion = $null }
            }
        } else {
            Write-ColorOutput "❌ Python not found" $Red
            return @{ Status = "NotFound"; Version = $null; PipVersion = $null }
        }
    } catch {
        Write-ColorOutput "❌ Python not found" $Red
        return @{ Status = "NotFound"; Version = $null; PipVersion = $null }
    }
}

function Test-GitHubToken {
    Write-ColorOutput "🔑 Checking GitHub Token..." $Blue
    
    if ($env:GITHUB_TOKEN) {
        try {
            $Response = Invoke-RestMethod -Uri "https://api.github.com/user" -Headers @{Authorization = "token $env:GITHUB_TOKEN"}
            Write-ColorOutput "✅ GitHub Token valid for: $($Response.login)" $Green
            return @{ Status = "OK"; User = $Response.login; Token = $env:GITHUB_TOKEN.Substring(0,10) + "..." }
        } catch {
            Write-ColorOutput "❌ GitHub Token invalid" $Red
            return @{ Status = "Invalid"; User = $null; Token = $null }
        }
    } else {
        Write-ColorOutput "⚠️ GitHub Token not set" $Yellow
        return @{ Status = "NotSet"; User = $null; Token = $null }
    }
}

function Test-Cursor {
    Write-ColorOutput "🎯 Checking Cursor..." $Blue
    
    $CursorPaths = @(
        "$env:APPDATA\Cursor",
        "$env:LOCALAPPDATA\Programs\cursor",
        "C:\Users\$env:USERNAME\AppData\Local\Programs\cursor"
    )
    
    foreach ($Path in $CursorPaths) {
        if (Test-Path $Path) {
            Write-ColorOutput "✅ Cursor found at: $Path" $Green
            
            # Check for MCP config
            $MCPConfigPath = Join-Path $Path "mcp.json"
            if (Test-Path $MCPConfigPath) {
                Write-ColorOutput "✅ Cursor MCP config found" $Green
                return @{ Status = "OK"; Path = $Path; MCPConfig = $true }
            } else {
                Write-ColorOutput "⚠️ Cursor MCP config not found" $Yellow
                return @{ Status = "Partial"; Path = $Path; MCPConfig = $false }
            }
        }
    }
    
    Write-ColorOutput "❌ Cursor not found" $Red
    return @{ Status = "NotFound"; Path = $null; MCPConfig = $false }
}

function Get-SetupSuggestions {
    param($Results)
    
    Write-ColorOutput "💡 Setup Suggestions:" $Magenta
    Write-ColorOutput "===================" $Magenta
    
    # Docker suggestions
    if ($Results.Docker.Status -eq "NotFound") {
        Write-ColorOutput "🐳 Install Docker:" $Yellow
        Write-ColorOutput "   winget install Docker.DockerDesktop" $Cyan
        Write-ColorOutput "   Or download from: https://www.docker.com/products/docker-desktop" $Cyan
    } elseif ($Results.Docker.Status -eq "NotRunning") {
        Write-ColorOutput "🐳 Start Docker Desktop" $Yellow
    }
    
    # Git suggestions
    if ($Results.Git.Status -eq "NotFound") {
        Write-ColorOutput "📝 Install Git:" $Yellow
        Write-ColorOutput "   winget install Git.Git" $Cyan
    } elseif ($Results.Git.Status -eq "Partial") {
        Write-ColorOutput "📝 Configure Git:" $Yellow
        Write-ColorOutput "   git config --global user.name 'Your Name'" $Cyan
        Write-ColorOutput "   git config --global user.email 'your.email@example.com'" $Cyan
    }
    
    # Node.js suggestions
    if ($Results.NodeJS.Status -eq "NotFound") {
        Write-ColorOutput "📦 Install Node.js:" $Yellow
        Write-ColorOutput "   winget install OpenJS.NodeJS.LTS" $Cyan
    } elseif ($Results.NodeJS.MCPServers.Count -eq 0) {
        Write-ColorOutput "📦 Install MCP Servers:" $Yellow
        Write-ColorOutput "   npm install -g @cyanheads/git-mcp-server" $Cyan
        Write-ColorOutput "   npm install -g @modelcontextprotocol/server-filesystem" $Cyan
        Write-ColorOutput "   npm install -g @jpisnice/shadcn-ui-mcp-server" $Cyan
    }
    
    # GitHub Token suggestions
    if ($Results.GitHubToken.Status -eq "NotSet") {
        Write-ColorOutput "🔑 Set GitHub Token:" $Yellow
        Write-ColorOutput "   Create token at: https://github.com/settings/tokens" $Cyan
        Write-ColorOutput "   Set scopes: gist, repo" $Cyan
        Write-ColorOutput "   Set environment: `$env:GITHUB_TOKEN='your_token_here'" $Cyan
    }
    
    # Cursor suggestions
    if ($Results.Cursor.Status -eq "NotFound") {
        Write-ColorOutput "🎯 Install Cursor:" $Yellow
        Write-ColorOutput "   Download from: https://cursor.sh" $Cyan
    } elseif ($Results.Cursor.Status -eq "Partial") {
        Write-ColorOutput "🎯 Setup Cursor MCP:" $Yellow
        Write-ColorOutput "   Run: .\portable-dev-env\scripts\setup.sh --platform windows --components cursor" $Cyan
    }
}

function Show-Summary {
    param($Results)
    
    Write-ColorOutput "📊 Health Check Summary" $Blue
    Write-ColorOutput "======================" $Blue
    
    $TotalChecks = 6
    $PassedChecks = 0
    
    if ($Results.Docker.Status -eq "OK") { $PassedChecks++ }
    if ($Results.Git.Status -eq "OK") { $PassedChecks++ }
    if ($Results.NodeJS.Status -eq "OK") { $PassedChecks++ }
    if ($Results.Python.Status -eq "OK") { $PassedChecks++ }
    if ($Results.GitHubToken.Status -eq "OK") { $PassedChecks++ }
    if ($Results.Cursor.Status -eq "OK") { $PassedChecks++ }
    
    Write-ColorOutput "✅ Passed: $PassedChecks/$TotalChecks" $Green
    
    if ($PassedChecks -eq $TotalChecks) {
        Write-ColorOutput "🎉 All systems ready for neuro-spicy development!" $Green
    } elseif ($PassedChecks -ge 4) {
        Write-ColorOutput "⚠️ Most systems ready, some setup needed" $Yellow
    } else {
        Write-ColorOutput "❌ Significant setup required" $Red
    }
}

# Main execution
Write-ColorOutput "🧠 Neuro-Spicy DevKit Health Check" $Magenta
Write-ColorOutput "=================================" $Magenta
Write-ColorOutput ""

$Results = @{
    Docker = Test-Docker
    Git = Test-Git
    NodeJS = Test-NodeJS
    Python = Test-Python
    GitHubToken = Test-GitHubToken
    Cursor = Test-Cursor
}

Write-ColorOutput ""
Show-Summary $Results

if ($Suggest) {
    Write-ColorOutput ""
    Get-SetupSuggestions $Results
}

if ($Verbose) {
    Write-ColorOutput ""
    Write-ColorOutput "🔍 Detailed Results:" $Cyan
    $Results | ConvertTo-Json -Depth 3 | Write-ColorOutput $Cyan
}
