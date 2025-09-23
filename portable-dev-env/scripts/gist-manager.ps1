# GitHub Gist Manager for Portable Dev Environment (PowerShell Version)
# Manages sharing and syncing of development environment configurations

param(
    [Parameter(Position=0)]
    [string]$Command = "",
    
    [Parameter(Position=1)]
    [string]$Name = "",
    
    [switch]$Public,
    [string]$Token = ""
)

# Colors for output
$Red = "Red"
$Green = "Green"
$Yellow = "Yellow"
$Blue = "Blue"
$Cyan = "Cyan"

# Configuration
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PortableEnvDir = Split-Path -Parent $ScriptDir
$GistsDir = Join-Path $PortableEnvDir "gists"
$ConfigFile = Join-Path $GistsDir "gist-config.json"

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Show-Usage {
    Write-ColorOutput "Usage: .\gist-manager.ps1 [COMMAND] [OPTIONS]" $Blue
    Write-ColorOutput ""
    Write-ColorOutput "Manage GitHub Gists for portable dev environment configurations." $Blue
    Write-ColorOutput ""
    Write-ColorOutput "COMMANDS:" $Blue
    Write-ColorOutput "  init                    Initialize gist management" $Blue
    Write-ColorOutput "  create <name>           Create a new gist from local config" $Blue
    Write-ColorOutput "  update <name>           Update existing gist" $Blue
    Write-ColorOutput "  list                    List all managed gists" $Blue
    Write-ColorOutput "  delete <name>           Delete a gist" $Blue
    Write-ColorOutput "  backup                  Backup all gists locally" $Blue
    Write-ColorOutput ""
    Write-ColorOutput "OPTIONS:" $Blue
    Write-ColorOutput "  -Verbose                Show detailed output" $Blue
    Write-ColorOutput "  -Public                 Create public gists (default: private)" $Blue
    Write-ColorOutput "  -Token <token>          GitHub token (or set GITHUB_TOKEN env var)" $Blue
    Write-ColorOutput ""
    Write-ColorOutput "EXAMPLES:" $Blue
    Write-ColorOutput "  .\gist-manager.ps1 init" $Blue
    Write-ColorOutput "  .\gist-manager.ps1 create cursor-rules" $Blue
    Write-ColorOutput "  .\gist-manager.ps1 update mcp-config-linux" $Blue
    Write-ColorOutput "  .\gist-manager.ps1 list" $Blue
}

function Test-Dependencies {
    $MissingDeps = @()
    
    # Check curl
    if (!(Get-Command curl -ErrorAction SilentlyContinue)) {
        $MissingDeps += "curl"
    }
    
    if ($MissingDeps.Count -gt 0) {
        Write-ColorOutput "❌ Missing dependencies: $($MissingDeps -join ', ')" $Red
        Write-ColorOutput "Please install missing dependencies and try again." $Yellow
        return $false
    }
    
    return $true
}

function Test-GitHubToken {
    if ($Token) {
        $env:GITHUB_TOKEN = $Token
    }
    
    if (-not $env:GITHUB_TOKEN) {
        Write-ColorOutput "❌ GitHub token not found" $Red
        Write-ColorOutput "Please set GITHUB_TOKEN environment variable or use -Token option" $Yellow
        Write-ColorOutput "Create a token at: https://github.com/settings/tokens" $Yellow
        return $false
    }
    
    # Test token
    try {
        $Response = Invoke-RestMethod -Uri "https://api.github.com/user" -Headers @{Authorization = "token $env:GITHUB_TOKEN"}
        Write-ColorOutput "✅ GitHub token is valid for user: $($Response.login)" $Green
        return $true
    }
    catch {
        Write-ColorOutput "❌ Invalid GitHub token" $Red
        return $false
    }
}

function Initialize-GistManagement {
    Write-ColorOutput "🚀 Initializing Gist Management" $Blue
    
    # Create directories
    if (!(Test-Path $GistsDir)) {
        New-Item -ItemType Directory -Path $GistsDir -Force | Out-Null
    }
    if (!(Test-Path (Join-Path $GistsDir "backups"))) {
        New-Item -ItemType Directory -Path (Join-Path $GistsDir "backups") -Force | Out-Null
    }
    if (!(Test-Path (Join-Path $GistsDir "templates"))) {
        New-Item -ItemType Directory -Path (Join-Path $GistsDir "templates") -Force | Out-Null
    }
    
    # Create config file if it doesn't exist
    if (!(Test-Path $ConfigFile)) {
        $Config = @{
            gists = @{}
            last_sync = $null
            version = "1.0.0"
        } | ConvertTo-Json -Depth 3
        
        $Config | Out-File -FilePath $ConfigFile -Encoding UTF8
        Write-ColorOutput "✅ Created gist configuration file" $Green
    }
    
    # Create template gists
    Create-TemplateGists
    
    Write-ColorOutput "🎉 Gist management initialized" $Green
}

function Create-TemplateGists {
    Write-ColorOutput "Creating template gists..." $Cyan
    
    # Cursor Rules Template
    $CursorRulesPath = Join-Path $PortableEnvDir "cursor\rules\ai-behavior-rules.md"
    if (Test-Path $CursorRulesPath) {
        Create-Gist "cursor-rules" "Cursor AI Behavior Rules" $CursorRulesPath "AI behavior rules for Cursor development environment"
    }
    
    # MCP Configuration Template
    $MCPConfigPath = Join-Path (Split-Path -Parent $PortableEnvDir) "configs\mcp-linux.json"
    if (Test-Path $MCPConfigPath) {
        Create-Gist "mcp-config-linux" "MCP Configuration for Linux" $MCPConfigPath "Linux-optimized MCP server configuration"
    }
    
    # Development Workflow Template
    $WorkflowPath = Join-Path $PortableEnvDir "cursor\workflows\development-workflow.md"
    if (Test-Path $WorkflowPath) {
        Create-Gist "dev-workflow" "Development Workflow Templates" $WorkflowPath "Reusable development workflow templates"
    }
}

function Create-Gist {
    param(
        [string]$Name,
        [string]$Title,
        [string]$FilePath,
        [string]$Description,
        [bool]$Public = $false
    )
    
    Write-ColorOutput "Creating gist: $Name" $Blue
    
    if (!(Test-Path $FilePath)) {
        Write-ColorOutput "❌ File not found: $FilePath" $Red
        return $false
    }
    
    $Filename = Split-Path -Leaf $FilePath
    $Content = Get-Content -Path $FilePath -Raw -Encoding UTF8
    
    # Create gist JSON
    $GistJson = @{
        description = $Description
        public = $Public
        files = @{
            $Filename = @{
                content = $Content
            }
        }
    } | ConvertTo-Json -Depth 4
    
    # Create gist via GitHub API
    try {
        $Response = Invoke-RestMethod -Uri "https://api.github.com/gists" -Method Post -Headers @{Authorization = "token $env:GITHUB_TOKEN"} -Body $GistJson -ContentType "application/json"
        
        $GistId = $Response.id
        $GistUrl = $Response.html_url
        
        # Update local config
        $Config = Get-Content -Path $ConfigFile -Raw | ConvertFrom-Json
        $Config.gists | Add-Member -NotePropertyName $Name -NotePropertyValue @{
            id = $GistId
            url = $GistUrl
            title = $Title
        } -Force
        $Config | ConvertTo-Json -Depth 4 | Out-File -FilePath $ConfigFile -Encoding UTF8
        
        Write-ColorOutput "✅ Created gist: $Name" $Green
        Write-ColorOutput "   ID: $GistId" $Cyan
        Write-ColorOutput "   URL: $GistUrl" $Cyan
        
        return $true
    }
    catch {
        Write-ColorOutput "❌ Failed to create gist: $Name" $Red
        Write-ColorOutput "   Error: $($_.Exception.Message)" $Red
        return $false
    }
}

function List-Gists {
    Write-ColorOutput "📋 Managed Gists" $Blue
    Write-ColorOutput "==================" $Blue
    
    if (Test-Path $ConfigFile) {
        $Config = Get-Content -Path $ConfigFile -Raw | ConvertFrom-Json
        
        foreach ($Gist in $Config.gists.PSObject.Properties) {
            $GistInfo = $Gist.Value
            Write-ColorOutput "✅ $($Gist.Name): $($GistInfo.title) ($($GistInfo.id))" $Green
        }
        
        Write-ColorOutput ""
        Write-ColorOutput "Total: $($Config.gists.PSObject.Properties.Count) gists" $Cyan
    }
    else {
        Write-ColorOutput "No gists configured yet. Run 'init' first." $Yellow
    }
}

# Main execution
if ($Command -eq "" -or $Command -eq "help") {
    Show-Usage
    exit 0
}

# Check dependencies
if (!(Test-Dependencies)) {
    exit 1
}

# Check GitHub token
if (!(Test-GitHubToken)) {
    exit 1
}

# Execute command
switch ($Command.ToLower()) {
    "init" {
        Initialize-GistManagement
    }
    "create" {
        if ($Name -eq "") {
            Write-ColorOutput "❌ Gist name required" $Red
            Show-Usage
            exit 1
        }
        # Create gist based on name
        switch ($Name) {
            "cursor-rules" {
                $FilePath = Join-Path $PortableEnvDir "cursor\rules\ai-behavior-rules.md"
                Create-Gist "cursor-rules" "Cursor AI Behavior Rules" $FilePath "AI behavior rules for Cursor development environment" $Public
            }
            "mcp-config-linux" {
                $FilePath = Join-Path (Split-Path -Parent $PortableEnvDir) "configs\mcp-linux.json"
                Create-Gist "mcp-config-linux" "MCP Configuration for Linux" $FilePath "Linux-optimized MCP server configuration" $Public
            }
            "dev-workflow" {
                $FilePath = Join-Path $PortableEnvDir "cursor\workflows\development-workflow.md"
                Create-Gist "dev-workflow" "Development Workflow Templates" $FilePath "Reusable development workflow templates" $Public
            }
            default {
                Write-ColorOutput "❌ Unknown gist name: $Name" $Red
                Write-ColorOutput "Available: cursor-rules, mcp-config-linux, dev-workflow" $Yellow
            }
        }
    }
    "list" {
        List-Gists
    }
    default {
        Write-ColorOutput "❌ Unknown command: $Command" $Red
        Show-Usage
        exit 1
    }
}
