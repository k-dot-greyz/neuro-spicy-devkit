# Neuro-Spicy DevKit Scripts

Cross-platform scripts for the ultimate neuro-spicy development environment! 🧠✨

## 🚀 Quick Start

### Windows (PowerShell)
```powershell
# Health check
.\health-check.ps1 -Suggest

# MCP registry
.\mcp-registry.ps1 -List

# Ultimate setup
.\neuro-spicy-setup.ps1 -Components "all"

# Gist management
.\gist-manager.ps1 create cursor-rules
```

### Linux/macOS (Bash)
```bash
# Make scripts executable (first time only)
chmod +x *.sh

# Health check
./health-check.sh --suggest

# MCP registry
./mcp-registry.sh --list

# Ultimate setup
./neuro-spicy-setup.sh --components all

# Gist management
./gist-manager.sh create cursor-rules
```

## 📋 Available Scripts

### 🔍 Health Check (`health-check.ps1` / `health-check.sh`)
Comprehensive environment validation with auto-detection:

**Features:**
- ✅ Docker detection and validation
- ✅ Git configuration check
- ✅ Node.js and npm validation
- ✅ Python and pip check
- ✅ GitHub token validation
- ✅ Cursor installation check
- ✅ Smart setup suggestions

**Usage:**
```bash
# Windows
.\health-check.ps1 -Suggest

# Linux/macOS
./health-check.sh --suggest
```

### 🔍 MCP Registry (`mcp-registry.ps1` / `mcp-registry.sh`)
GitHub MCP registry integration with popular servers:

**Features:**
- 🌟 Curated list of essential MCP servers
- 🔍 GitHub repository search
- 📦 One-command installation
- 🧪 Server testing and validation
- 🔄 Future-proof for new servers

**Usage:**
```bash
# List popular servers
.\mcp-registry.ps1 -List                    # Windows
./mcp-registry.sh --list                    # Linux/macOS

# Search for specific servers
.\mcp-registry.ps1 -Search "brave"          # Windows
./mcp-registry.sh --search "brave"          # Linux/macOS

# Install specific server
.\mcp-registry.ps1 -Install -Server "git-mcp-server"  # Windows
./mcp-registry.sh --install --server "git-mcp-server"  # Linux/macOS
```

### 🚀 Ultimate Setup (`neuro-spicy-setup.ps1` / `neuro-spicy-setup.sh`)
Comprehensive environment setup with auto-detection:

**Features:**
- 📦 Node.js installation
- 🔧 MCP server installation
- 🎯 Cursor MCP configuration
- 🔑 GitHub token validation
- 📝 Sample Gist creation
- 📊 Progress tracking

**Usage:**
```bash
# Full setup
.\neuro-spicy-setup.ps1 -Components "all"    # Windows
./neuro-spicy-setup.sh --components all     # Linux/macOS

# Specific components
.\neuro-spicy-setup.ps1 -Components "nodejs,mcp"  # Windows
./neuro-spicy-setup.sh --components "nodejs,mcp"  # Linux/macOS
```

### 📝 Gist Manager (`gist-manager.ps1` / `gist-manager.sh`)
GitHub Gist integration for team collaboration:

**Features:**
- 📝 Create configuration Gists
- 📋 List managed Gists
- 🔄 Update existing Gists
- 💾 Local backup system
- 🔗 Team sharing via URLs

**Usage:**
```bash
# Initialize
.\gist-manager.ps1 init                      # Windows
./gist-manager.sh init                      # Linux/macOS

# Create Gists
.\gist-manager.ps1 create cursor-rules      # Windows
./gist-manager.sh create cursor-rules       # Linux/macOS

# List Gists
.\gist-manager.ps1 list                     # Windows
./gist-manager.sh list                      # Linux/macOS
```

## 🧠 Neuro-Spicy Features

### 🎯 Hyperfocus-Friendly
- **One Command**: No decision fatigue
- **Minimal Output**: Predictable behavior
- **Clear Progress**: Visual completion tracking

### 🔄 Context-Switching Support
- **Component-Based**: Install specific parts
- **Resumable**: Continue where you left off
- **Phase-Based**: Logical setup progression

### 🎨 Sensory-Friendly
- **Color-Coded**: Visual status indicators
- **Consistent Format**: Predictable output
- **Minimal Noise**: Only essential information

### 🧠 Executive Function Support
- **Auto-Detection**: No manual debugging
- **Smart Suggestions**: Specific setup commands
- **Self-Healing**: Automatic issue resolution

## 🔧 Prerequisites

### Windows
- PowerShell 5.1+ or PowerShell Core
- Git (for version control)
- Docker Desktop (for MCP Gateway)

### Linux/macOS
- Bash 4.0+
- curl (for API calls)
- jq (for JSON parsing)
- Git (for version control)
- Docker (for MCP Gateway)

## 🚀 Installation

### Windows
```powershell
# Clone the repository
git clone https://github.com/kasparsgreizis/neuro-spicy-devkit.git
cd neuro-spicy-devkit

# Run setup
.\portable-dev-env\scripts\neuro-spicy-setup.ps1 -Components "all"
```

### Linux/macOS
```bash
# Clone the repository
git clone https://github.com/kasparsgreizis/neuro-spicy-devkit.git
cd neuro-spicy-devkit

# Make scripts executable
chmod +x portable-dev-env/scripts/*.sh

# Run setup
./portable-dev-env/scripts/neuro-spicy-setup.sh --components all
```

## 🔑 GitHub Token Setup

1. **Create Token**: Go to [GitHub Settings > Tokens](https://github.com/settings/tokens)
2. **Set Scopes**: Select `gist` and `repo` scopes
3. **Set Environment**:
   - **Windows**: `$env:GITHUB_TOKEN="your_token_here"`
   - **Linux/macOS**: `export GITHUB_TOKEN="your_token_here"`

## 🎉 What You Get

### ✅ Complete Development Environment
- Docker MCP Gateway with 200+ tools
- Git, Filesystem, and UI MCP servers
- Cursor AI with neuro-spicy behavior rules
- GitHub Gist integration for team collaboration

### 🧠 Neuro-Spicy Superpowers
- **Embrace Your Architecture**: AI optimized for neurodivergent strengths
- **Turn Bugs into Features**: Your "differences" become superpowers
- **Hyperfocus-Friendly**: One command, no decision fatigue
- **Team Collaboration**: Share configurations via GitHub Gists

### 🚀 Ready to Code
- **Auto-Detection**: Intelligent environment validation
- **Self-Healing**: Automatic issue resolution
- **Cross-Platform**: Works on Windows, Linux, macOS
- **Future-Proof**: Discovers new MCP servers automatically

## 💡 Pro Tips

### 🎯 For Hyperfocus
- Use `--components` to install specific parts
- Run health check first to see what's needed
- Use `--suggest` for specific setup commands

### 🔄 For Context Switching
- Install components in phases
- Use health check to resume where you left off
- Create Gists to save your progress

### 🧠 For Executive Function
- Let the scripts auto-detect everything
- Use the suggestions for manual setup
- Trust the progress tracking

## 🆘 Troubleshooting

### Common Issues

**Node.js not found**
```bash
# Windows
winget install OpenJS.NodeJS.LTS

# Linux
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs

# macOS
brew install node
```

**Docker not running**
```bash
# Start Docker Desktop (Windows/macOS)
# Or on Linux:
sudo systemctl start docker
```

**GitHub Token issues**
- Verify token has `gist` and `repo` scopes
- Check environment variable is set correctly
- Test with: `curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user`

### Getting Help

1. **Run Health Check**: `./health-check.sh --suggest`
2. **Check Scripts**: All scripts have `--help` option
3. **GitHub Issues**: Report issues on the repository
4. **Community**: Join the neuro-spicy developer community!

## 🎉 Ready to Rock!

Your neuro-spicy devkit is now ready to turn every environment setup bug into a feature! 

**This is absolutely LEGENDARY!** 💪🔥🧠

Start coding with your neuro-spicy superpowers! ✨
