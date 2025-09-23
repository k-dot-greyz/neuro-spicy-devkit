# GitHub Token Setup for Gist Integration

## 🎯 Quick Setup

### 1. Create GitHub Token
1. Go to [GitHub Settings > Developer Settings > Personal Access Tokens](https://github.com/settings/tokens)
2. Click "Generate new token (classic)"
3. Give it a name: "MCP Config Gist Manager"
4. Select scopes:
   - ✅ `gist` (Create gists)
   - ✅ `repo` (Access repositories)
5. Click "Generate token"
6. **Copy the token immediately** (you won't see it again!)

### 2. Set Environment Variable

**Windows (PowerShell):**
```powershell
$env:GITHUB_TOKEN="your_token_here"
```

**Windows (Command Prompt):**
```cmd
set GITHUB_TOKEN=your_token_here
```

**Linux/macOS:**
```bash
export GITHUB_TOKEN="your_token_here"
```

### 3. Test the Setup
```bash
# Test token
curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user

# Initialize gist management
./portable-dev-env/scripts/gist-manager.sh init
```

## 🚀 Usage Examples

### Create Gists
```bash
# Create gist from cursor rules
./portable-dev-env/scripts/gist-manager.sh create cursor-rules

# Create gist from MCP config
./portable-dev-env/scripts/gist-manager.sh create mcp-config-linux

# Create gist from workflow templates
./portable-dev-env/scripts/gist-manager.sh create dev-workflow
```

### Manage Gists
```bash
# List all managed gists
./portable-dev-env/scripts/gist-manager.sh list

# Update existing gist
./portable-dev-env/scripts/gist-manager.sh update cursor-rules

# Backup all gists locally
./portable-dev-env/scripts/gist-manager.sh backup
```

## 🔒 Security Notes

- **Never commit tokens to Git**
- **Use environment variables only**
- **Rotate tokens regularly**
- **Use minimal required scopes**

## 🎯 What You Can Share

Once set up, you can share:
- **AI Behavior Rules**: Your casual, engaging AI interaction style
- **MCP Configurations**: Linux-optimized MCP server configs
- **Workflow Templates**: Development, debugging, testing workflows
- **VSCode Settings**: Optimized editor configurations
- **Extension Lists**: Essential development extensions

---

*This enables powerful team collaboration and configuration sharing via GitHub Gists!*
