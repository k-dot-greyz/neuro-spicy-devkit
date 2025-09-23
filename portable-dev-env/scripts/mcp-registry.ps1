# GitHub MCP Registry Integration
# Discovers and integrates new MCP servers from GitHub

param(
    [string]$Search = "",
    [switch]$List,
    [switch]$Install,
    [string]$Server = "",
    [switch]$Verbose
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

function Search-GitHubMCPRepos {
    param([string]$Query = "mcp server")
    
    Write-ColorOutput "🔍 Searching GitHub for MCP servers..." $Blue
    
    try {
        $SearchUrl = "https://api.github.com/search/repositories?q=$Query+language:typescript+language:javascript+language:python&sort=updated&order=desc"
        $Headers = @{}
        
        if ($env:GITHUB_TOKEN) {
            $Headers.Authorization = "token $env:GITHUB_TOKEN"
        }
        
        $Response = Invoke-RestMethod -Uri $SearchUrl -Headers $Headers
        
        $MCPRepos = @()
        foreach ($Repo in $Response.items) {
            # Filter for MCP-related repositories
            if ($Repo.name -match "mcp|model-context-protocol" -or 
                $Repo.description -match "mcp|model-context-protocol" -or
                $Repo.topics -contains "mcp" -or
                $Repo.topics -contains "model-context-protocol") {
                
                $MCPRepos += @{
                    Name = $Repo.name
                    FullName = $Repo.full_name
                    Description = $Repo.description
                    Stars = $Repo.stargazers_count
                    Updated = $Repo.updated_at
                    Language = $Repo.language
                    Url = $Repo.html_url
                    CloneUrl = $Repo.clone_url
                }
            }
        }
        
        return $MCPRepos
    }
    catch {
        Write-ColorOutput "❌ Failed to search GitHub: $($_.Exception.Message)" $Red
        return @()
    }
}

function Show-MCPRepos {
    param($Repos)
    
    Write-ColorOutput "📋 Available MCP Servers" $Magenta
    Write-ColorOutput "========================" $Magenta
    
    foreach ($Repo in $Repos) {
        $Stars = "⭐" * [Math]::Min($Repo.Stars, 5)
        Write-ColorOutput "📦 $($Repo.Name)" $Green
        Write-ColorOutput "   Description: $($Repo.Description)" $Cyan
        Write-ColorOutput "   Language: $($Repo.Language) | Stars: $($Repo.Stars) $Stars" $Yellow
        Write-ColorOutput "   Updated: $($Repo.Updated.ToString('yyyy-MM-dd'))" $Cyan
        Write-ColorOutput "   URL: $($Repo.Url)" $Blue
        Write-ColorOutput ""
    }
}

function Install-MCPServer {
    param([string]$ServerName)
    
    Write-ColorOutput "📦 Installing MCP Server: $ServerName" $Blue
    
    # Common MCP server installation patterns
    $InstallCommands = @{
        "git-mcp-server" = "npm install -g @cyanheads/git-mcp-server"
        "filesystem-mcp-server" = "npm install -g @modelcontextprotocol/server-filesystem"
        "shadcn-ui-mcp-server" = "npm install -g @jpisnice/shadcn-ui-mcp-server"
        "brave-search-mcp" = "npm install -g @modelcontextprotocol/server-brave-search"
        "fetch-mcp" = "npm install -g @modelcontextprotocol/server-fetch"
    }
    
    if ($InstallCommands.ContainsKey($ServerName)) {
        Write-ColorOutput "Running: $($InstallCommands[$ServerName])" $Cyan
        try {
            Invoke-Expression $InstallCommands[$ServerName]
            Write-ColorOutput "✅ Successfully installed $ServerName" $Green
            return $true
        }
        catch {
            Write-ColorOutput "❌ Failed to install $ServerName`: $($_.Exception.Message)" $Red
            return $false
        }
    } else {
        Write-ColorOutput "❌ Unknown MCP server: $ServerName" $Red
        Write-ColorOutput "Available servers: $($InstallCommands.Keys -join ', ')" $Yellow
        return $false
    }
}

function Get-PopularMCPServers {
    Write-ColorOutput "🌟 Popular MCP Servers" $Magenta
    Write-ColorOutput "======================" $Magenta
    
    $PopularServers = @(
        @{
            Name = "Git MCP Server"
            Package = "git-mcp-server"
            Description = "Git repository operations and version control"
            Install = "npm install -g @cyanheads/git-mcp-server"
        },
        @{
            Name = "Filesystem MCP Server"
            Package = "filesystem-mcp-server"
            Description = "File system access and management"
            Install = "npm install -g @modelcontextprotocol/server-filesystem"
        },
        @{
            Name = "Brave Search MCP"
            Package = "brave-search-mcp"
            Description = "Web search using Brave Search API"
            Install = "npm install -g @modelcontextprotocol/server-brave-search"
        },
        @{
            Name = "Fetch MCP Server"
            Package = "fetch-mcp"
            Description = "Web content fetching and processing"
            Install = "npm install -g @modelcontextprotocol/server-fetch"
        },
        @{
            Name = "Shadcn UI MCP Server"
            Package = "shadcn-ui-mcp-server"
            Description = "Shadcn/UI component library access"
            Install = "npm install -g @jpisnice/shadcn-ui-mcp-server"
        }
    )
    
    foreach ($Server in $PopularServers) {
        Write-ColorOutput "📦 $($Server.Name)" $Green
        Write-ColorOutput "   $($Server.Description)" $Cyan
        Write-ColorOutput "   Install: $($Server.Install)" $Yellow
        Write-ColorOutput ""
    }
}

function Test-MCPServer {
    param([string]$ServerName)
    
    Write-ColorOutput "🧪 Testing MCP Server: $ServerName" $Blue
    
    # Test if server is installed
    try {
        $GlobalPackages = npm list -g --depth=0 2>$null
        if ($GlobalPackages -match $ServerName) {
            Write-ColorOutput "✅ $ServerName is installed" $Green
            
            # Try to get help/version
            try {
                $HelpOutput = & $ServerName --help 2>$null
                if ($HelpOutput) {
                    Write-ColorOutput "✅ $ServerName responds to --help" $Green
                } else {
                    Write-ColorOutput "⚠️ $ServerName installed but no --help available" $Yellow
                }
            } catch {
                Write-ColorOutput "⚠️ $ServerName installed but may not be executable" $Yellow
            }
            
            return $true
        } else {
            Write-ColorOutput "❌ $ServerName not found in global packages" $Red
            return $false
        }
    } catch {
        Write-ColorOutput "❌ Failed to check $ServerName`: $($_.Exception.Message)" $Red
        return $false
    }
}

# Main execution
Write-ColorOutput "🔍 GitHub MCP Registry Integration" $Magenta
Write-ColorOutput "=================================" $Magenta
Write-ColorOutput ""

if ($List) {
    Get-PopularMCPServers
    exit 0
}

if ($Install -and $Server) {
    $Success = Install-MCPServer $Server
    if ($Success) {
        Test-MCPServer $Server
    }
    exit 0
}

if ($Search) {
    $Repos = Search-GitHubMCPRepos $Search
    if ($Repos.Count -gt 0) {
        Show-MCPRepos $Repos
    } else {
        Write-ColorOutput "❌ No MCP repositories found for: $Search" $Red
    }
    exit 0
}

# Default: Show popular servers
Get-PopularMCPServers

Write-ColorOutput "💡 Usage Examples:" $Cyan
Write-ColorOutput "  .\mcp-registry.ps1 -List                    # List popular servers" $Cyan
Write-ColorOutput "  .\mcp-registry.ps1 -Search 'brave'          # Search for specific servers" $Cyan
Write-ColorOutput "  .\mcp-registry.ps1 -Install -Server 'git-mcp-server'" $Cyan
