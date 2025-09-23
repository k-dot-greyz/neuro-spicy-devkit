# Neuro-Spicy DevKit Profile Loader (PowerShell Version)
# VST Plugin-Style Development Environment Profiles

param(
    [Parameter(Position=0)]
    [string]$Command = "",
    
    [Parameter(Position=1)]
    [string]$ProfileName = "",
    
    [switch]$DryRun
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

function Show-Usage {
    Write-ColorOutput "Usage: .\profile-loader.ps1 [COMMAND] [OPTIONS]" $Blue
    Write-ColorOutput ""
    Write-ColorOutput "Neuro-Spicy DevKit Profile Loader - VST Plugin-Style Development Environment" $Blue
    Write-ColorOutput ""
    Write-ColorOutput "COMMANDS:" $Blue
    Write-ColorOutput "  list                    List available profiles" $Blue
    Write-ColorOutput "  load <profile>          Load a specific profile" $Blue
    Write-ColorOutput "  create <name>           Create a new profile" $Blue
    Write-ColorOutput "  validate <profile>      Validate a profile configuration" $Blue
    Write-ColorOutput "  info <profile>          Show profile information" $Blue
    Write-ColorOutput ""
    Write-ColorOutput "OPTIONS:" $Blue
    Write-ColorOutput "  -Verbose                Show detailed output" $Blue
    Write-ColorOutput "  -DryRun                 Show what would be done without executing" $Blue
    Write-ColorOutput "  -Help, -h               Show this help message" $Blue
    Write-ColorOutput ""
    Write-ColorOutput "EXAMPLES:" $Blue
    Write-ColorOutput "  .\profile-loader.ps1 list                              # List available profiles" $Blue
    Write-ColorOutput "  .\profile-loader.ps1 load frontend-developer           # Load frontend developer profile" $Blue
    Write-ColorOutput "  .\profile-loader.ps1 create my-custom-profile          # Create custom profile" $Blue
    Write-ColorOutput "  .\profile-loader.ps1 info frontend-developer           # Show profile details" $Blue
}

function Get-ProfilePath {
    param([string]$ProfileName)
    
    $ScriptDir = Split-Path -Parent $PSCommandPath
    $PortableEnvDir = Split-Path -Parent $ScriptDir
    $ProfilesDir = Join-Path $PortableEnvDir "profiles"
    $TemplatesDir = Join-Path $ProfilesDir "templates"
    $UserProfilesDir = Join-Path $ProfilesDir "user"
    
    # Check templates first
    $TemplatePath = Join-Path $TemplatesDir "$ProfileName.json"
    if (Test-Path $TemplatePath) {
        return $TemplatePath
    }
    
    # Check user profiles
    $UserPath = Join-Path $UserProfilesDir "$ProfileName.json"
    if (Test-Path $UserPath) {
        return $UserPath
    }
    
    return $null
}

function Get-ProfilesDirectory {
    $ScriptDir = Split-Path -Parent $PSCommandPath
    $PortableEnvDir = Split-Path -Parent $ScriptDir
    $ProfilesDir = Join-Path $PortableEnvDir "profiles"
    $TemplatesDir = Join-Path $ProfilesDir "templates"
    $UserProfilesDir = Join-Path $ProfilesDir "user"
    
    return @{
        Profiles = $ProfilesDir
        Templates = $TemplatesDir
        User = $UserProfilesDir
    }
}

function Show-ProfileList {
    Write-ColorOutput "📋 Available Profiles" $Magenta
    Write-ColorOutput "===================" $Magenta
    Write-ColorOutput ""
    
    $Dirs = Get-ProfilesDirectory
    
    # List template profiles
    if (Test-Path $Dirs.Templates) {
        Write-ColorOutput "🎵 Template Profiles:" $Blue
        $TemplateFiles = Get-ChildItem -Path $Dirs.Templates -Filter "*.json"
        foreach ($File in $TemplateFiles) {
            $ProfileName = [System.IO.Path]::GetFileNameWithoutExtension($File.Name)
            $ProfileData = Get-Content -Path $File.FullName -Raw | ConvertFrom-Json
            
            $Title = $ProfileData.profile.name
            $Description = $ProfileData.profile.description
            $Tags = ($ProfileData.profile.tags -join " ")
            
            Write-ColorOutput "📦 $ProfileName" $Green
            Write-ColorOutput "   Title: $Title"
            Write-ColorOutput "   Description: $Description"
            Write-ColorOutput "   Tags: $Tags"
            Write-ColorOutput ""
        }
    }
    
    # List user profiles
    if (Test-Path $Dirs.User) {
        Write-ColorOutput "🎨 User Profiles:" $Blue
        $UserFiles = Get-ChildItem -Path $Dirs.User -Filter "*.json"
        foreach ($File in $UserFiles) {
            $ProfileName = [System.IO.Path]::GetFileNameWithoutExtension($File.Name)
            $ProfileData = Get-Content -Path $File.FullName -Raw | ConvertFrom-Json
            
            $Title = $ProfileData.profile.name
            $Description = $ProfileData.profile.description
            
            Write-ColorOutput "📦 $ProfileName" $Green
            Write-ColorOutput "   Title: $Title"
            Write-ColorOutput "   Description: $Description"
            Write-ColorOutput ""
        }
    }
}

function Show-ProfileInfo {
    param([string]$ProfileName)
    
    $ProfilePath = Get-ProfilePath $ProfileName
    if (-not $ProfilePath) {
        Write-ColorOutput "❌ Profile '$ProfileName' not found" $Red
        return
    }
    
    $ProfileData = Get-Content -Path $ProfilePath -Raw | ConvertFrom-Json
    
    Write-ColorOutput "📋 Profile Information: $ProfileName" $Magenta
    Write-ColorOutput "===============================" $Magenta
    Write-ColorOutput ""
    
    Write-ColorOutput "Title: $($ProfileData.profile.name)" $Green
    Write-ColorOutput "Description: $($ProfileData.profile.description)" $Green
    Write-ColorOutput "Version: $($ProfileData.profile.version)" $Green
    Write-ColorOutput "Author: $($ProfileData.profile.author)" $Green
    Write-ColorOutput "Tags: $($ProfileData.profile.tags -join ' ')" $Green
    Write-ColorOutput "Platforms: $($ProfileData.profile.compatibility.platforms -join ' ')" $Green
    Write-ColorOutput ""
    
    # Show tools
    Write-ColorOutput "🔧 Tools:" $Blue
    if ($ProfileData.plugins.tools) {
        foreach ($Tool in $ProfileData.plugins.tools) {
            Write-ColorOutput "  • $($Tool.name) $($Tool.version)" $Cyan
        }
    } else {
        Write-ColorOutput "  No tools defined" $Cyan
    }
    Write-ColorOutput ""
    
    # Show MCP servers
    Write-ColorOutput "🎵 MCP Servers:" $Blue
    if ($ProfileData.plugins.mcps) {
        foreach ($MCP in $ProfileData.plugins.mcps) {
            Write-ColorOutput "  • $($MCP.name) ($($MCP.package))" $Cyan
        }
    } else {
        Write-ColorOutput "  No MCP servers defined" $Cyan
    }
    Write-ColorOutput ""
    
    # Show shell configuration
    Write-ColorOutput "🐚 Shell Configuration:" $Blue
    if ($ProfileData.shell.bash.aliases) {
        $Aliases = $ProfileData.shell.bash.aliases.PSObject.Properties.Name -join " "
        Write-ColorOutput "  Bash Aliases: $Aliases" $Cyan
    }
    Write-ColorOutput ""
}

function Test-ProfileValidation {
    param([string]$ProfileName)
    
    $ProfilePath = Get-ProfilePath $ProfileName
    if (-not $ProfilePath) {
        Write-ColorOutput "❌ Profile '$ProfileName' not found" $Red
        return $false
    }
    
    Write-ColorOutput "🔍 Validating Profile: $ProfileName" $Blue
    
    try {
        $ProfileData = Get-Content -Path $ProfilePath -Raw | ConvertFrom-Json
        Write-ColorOutput "✅ JSON syntax is valid" $Green
    }
    catch {
        Write-ColorOutput "❌ Invalid JSON syntax" $Red
        return $false
    }
    
    # Check required fields
    $RequiredFields = @("profile.name", "profile.version", "profile.description")
    foreach ($Field in $RequiredFields) {
        $FieldParts = $Field.Split('.')
        $Current = $ProfileData
        $Valid = $true
        
        foreach ($Part in $FieldParts) {
            if ($Current.PSObject.Properties.Name -contains $Part) {
                $Current = $Current.$Part
            } else {
                $Valid = $false
                break
            }
        }
        
        if ($Valid) {
            Write-ColorOutput "✅ Required field '$Field' present" $Green
        } else {
            Write-ColorOutput "❌ Required field '$Field' missing" $Red
            return $false
        }
    }
    
    # Check plugin definitions
    if ($ProfileData.plugins) {
        Write-ColorOutput "✅ Plugin definitions present" $Green
    } else {
        Write-ColorOutput "⚠️ No plugin definitions found" $Yellow
    }
    
    Write-ColorOutput "✅ Profile validation completed" $Green
    return $true
}

function Start-ProfileLoad {
    param([string]$ProfileName)
    
    $ProfilePath = Get-ProfilePath $ProfileName
    if (-not $ProfilePath) {
        Write-ColorOutput "❌ Profile '$ProfileName' not found" $Red
        return
    }
    
    Write-ColorOutput "🎵 Loading Profile: $ProfileName" $Magenta
    Write-ColorOutput "===============================" $Magenta
    Write-ColorOutput ""
    
    # Show profile info
    Show-ProfileInfo $ProfileName
    
    # Validate profile
    if (-not (Test-ProfileValidation $ProfileName)) {
        Write-ColorOutput "❌ Profile validation failed" $Red
        return
    }
    
    Write-ColorOutput "🚀 Profile loading would happen here..." $Blue
    Write-ColorOutput "This is a proof-of-concept. Full implementation would:" $Cyan
    Write-ColorOutput "  • Install required tools" $Cyan
    Write-ColorOutput "  • Configure editors" $Cyan
    Write-ColorOutput "  • Set up MCP servers" $Cyan
    Write-ColorOutput "  • Configure shell environment" $Cyan
    Write-ColorOutput "  • Create workspace structure" $Cyan
    Write-ColorOutput "  • Apply user customizations" $Cyan
    Write-ColorOutput ""
    
    Write-ColorOutput "✅ Profile '$ProfileName' loaded successfully!" $Green
}

function New-Profile {
    param([string]$ProfileName)
    
    Write-ColorOutput "🎨 Creating Profile: $ProfileName" $Blue
    
    $Dirs = Get-ProfilesDirectory
    $UserProfilesDir = $Dirs.User
    
    # Create user profiles directory if it doesn't exist
    if (-not (Test-Path $UserProfilesDir)) {
        New-Item -ItemType Directory -Path $UserProfilesDir -Force | Out-Null
    }
    
    $ProfilePath = Join-Path $UserProfilesDir "$ProfileName.json"
    
    # Create basic profile template
    $ProfileTemplate = @{
        profile = @{
            name = "Custom Profile"
            version = "1.0.0"
            description = "A custom development profile"
            author = "User"
            tags = @("custom")
            compatibility = @{
                platforms = @("windows", "linux", "macos")
                minVersion = "1.0.0"
            }
        }
        requirements = @{
            nodejs = ">=18.0.0"
            npm = ">=8.0.0"
            git = ">=2.30.0"
        }
        plugins = @{
            tools = @()
            editors = @()
            mcps = @()
        }
        shell = @{
            bash = @{
                aliases = @{}
                functions = @{}
                env = @{}
            }
            powershell = @{
                aliases = @{}
                functions = @{}
                env = @{}
            }
        }
        workspace = @{
            folders = @()
            settings = @{}
        }
        scripts = @{
            setup = @()
            dev = ""
            build = ""
            test = ""
        }
    }
    
    $ProfileTemplate | ConvertTo-Json -Depth 10 | Out-File -FilePath $ProfilePath -Encoding UTF8
    
    Write-ColorOutput "✅ Profile '$ProfileName' created at $ProfilePath" $Green
    Write-ColorOutput "Edit the profile file to customize your development environment" $Cyan
}

# Main execution
if ($Command -eq "" -or $Command -eq "help") {
    Show-Usage
    exit 0
}

switch ($Command.ToLower()) {
    "list" {
        Show-ProfileList
    }
    "load" {
        if ($ProfileName -eq "") {
            Write-ColorOutput "❌ Profile name required for load command" $Red
            Show-Usage
            exit 1
        }
        Start-ProfileLoad $ProfileName
    }
    "create" {
        if ($ProfileName -eq "") {
            Write-ColorOutput "❌ Profile name required for create command" $Red
            Show-Usage
            exit 1
        }
        New-Profile $ProfileName
    }
    "validate" {
        if ($ProfileName -eq "") {
            Write-ColorOutput "❌ Profile name required for validate command" $Red
            Show-Usage
            exit 1
        }
        Test-ProfileValidation $ProfileName
    }
    "info" {
        if ($ProfileName -eq "") {
            Write-ColorOutput "❌ Profile name required for info command" $Red
            Show-Usage
            exit 1
        }
        Show-ProfileInfo $ProfileName
    }
    default {
        Write-ColorOutput "❌ Unknown command: $Command" $Red
        Show-Usage
        exit 1
    }
}
