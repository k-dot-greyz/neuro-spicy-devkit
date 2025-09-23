# Portable Dev Environment Usage Guide

## 🎯 Overview

This portable dev environment system provides a comprehensive, shareable configuration for Cursor/VSCode development that can be easily deployed across different machines and platforms.

## 🚀 Quick Start

### 1. Setup
```bash
# Clone or navigate to the portable dev environment
cd portable-dev-env

# Make scripts executable
chmod +x scripts/*.sh

# Setup for your platform
./scripts/setup.sh --platform linux --components all
./scripts/setup.sh --platform windows --components cursor,mcp
./scripts/setup.sh --platform macos --components vscode --verbose
```

### 2. GitHub Gist Integration
```bash
# Set your GitHub token
export GITHUB_TOKEN="your_github_token_here"

# Initialize gist management
./scripts/gist-manager.sh init

# Create and share configurations
./scripts/gist-manager.sh create cursor-rules
./scripts/gist-manager.sh update mcp-config-linux
./scripts/gist-manager.sh list
```

## 📁 Structure Overview

```
portable-dev-env/
├── cursor/                    # Cursor-specific configurations
│   ├── rules/                # AI behavior rules and guidelines
│   ├── memories/             # Project context and knowledge base
│   └── workflows/            # Development workflow templates
├── vscode/                   # VSCode configurations
│   ├── settings/             # Editor settings and preferences
│   ├── extensions/           # Extension recommendations
│   └── snippets/             # Code snippets (future)
├── scripts/                  # Setup and management scripts
├── gists/                    # GitHub Gist integration
└── docs/                     # Documentation
```

## 🎨 Cursor Configuration

### AI Behavior Rules
The `cursor/rules/ai-behavior-rules.md` file defines how AI should interact in your development environment:

- **Communication Style**: Casual, direct, engaging
- **Technical Guidelines**: Code quality, file management, tool usage
- **Project-Specific Rules**: Tailored for Python, TypeScript, DevOps
- **Memory and Context**: Context management and knowledge base rules
- **Workflow Rules**: Development, debugging, and code review workflows

### Memory System
The `cursor/memories/project-context.md` file maintains:

- **Current Projects**: zenOS, mcp-config, Operation-Atlas, context-inbox
- **Development Patterns**: Code organization, AI integration, workflow patterns
- **Technical Preferences**: Environment, tools, code style
- **Knowledge Base**: Common patterns, API usage, troubleshooting
- **Current Focus**: Immediate priorities and long-term goals

### Workflow Templates
The `cursor/workflows/development-workflow.md` file provides:

- **Standard Development Workflow**: Project setup, feature development, code review
- **Debugging Workflow**: Issue reproduction, investigation, fix implementation
- **Testing Workflow**: Unit, integration, and E2E testing
- **Deployment Workflow**: Pre-deployment, deployment, post-deployment
- **AI-Assisted Development**: Planning, development, deployment phases

## 🛠️ VSCode Configuration

### Settings
The `vscode/settings/settings.json` file includes:

- **Editor Settings**: Word wrap, tab size, formatting, auto-save
- **File Management**: Auto-save, trim whitespace, insert final newline
- **Search/Exclude**: Exclude node_modules, build directories, etc.
- **Terminal**: Platform-specific terminal profiles
- **Language Support**: Python, TypeScript, JavaScript, YAML, JSON
- **Extensions**: ESLint, Prettier, Git, Docker, Azure tools

### Extensions
The `vscode/extensions/extensions.json` file recommends:

- **Core Extensions**: JSON, YAML, PowerShell, Python, TypeScript
- **Code Quality**: Pylint, Flake8, MyPy, Black, ESLint, Prettier
- **Development**: Docker, Kubernetes, Terraform, Ansible
- **Cloud**: Azure Functions, Resource Groups, Storage, VMs, Web Apps
- **Git**: GitHub Actions, Pull Request GitHub

## 🔧 Scripts

### Setup Script (`scripts/setup.sh`)
```bash
# Platform detection and setup
./scripts/setup.sh --platform linux --components all
./scripts/setup.sh --platform windows --components cursor,mcp
./scripts/setup.sh --platform macos --components vscode --verbose
```

**Features:**
- Automatic platform detection
- Component-based installation
- Dependency checking
- Workspace configuration creation

### Gist Manager (`scripts/gist-manager.sh`)
```bash
# Gist management
./scripts/gist-manager.sh init
./scripts/gist-manager.sh create <name>
./scripts/gist-manager.sh update <name>
./scripts/gist-manager.sh list
./scripts/gist-manager.sh backup
```

**Features:**
- GitHub Gist creation and management
- Configuration sharing via Gists
- Local backup and restore
- Template gist creation

## 📋 Usage Patterns

### Daily Development
1. **Morning**: Check system health, review overnight changes
2. **Development**: Use AI-assisted development with Cursor rules
3. **Testing**: Follow testing workflow templates
4. **Documentation**: Keep project context updated
5. **Evening**: Commit changes, update project status

### Team Collaboration
1. **Share Configurations**: Use GitHub Gists to share configurations
2. **Version Control**: Track configuration changes in Git
3. **Documentation**: Maintain shared knowledge base
4. **Workflows**: Use standardized workflow templates

### Cross-Platform Development
1. **Platform Detection**: Automatic platform detection and setup
2. **Component Selection**: Choose relevant components for each platform
3. **Dependency Management**: Automated dependency checking and installation
4. **Configuration Sync**: Sync configurations across platforms

## 🔄 Maintenance

### Regular Updates
```bash
# Update configurations
git pull origin main

# Re-run setup
./scripts/setup.sh --platform <platform> --components all

# Update gists
./scripts/gist-manager.sh update <name>
```

### Backup and Restore
```bash
# Backup gists
./scripts/gist-manager.sh backup

# Restore from backup
./scripts/gist-manager.sh restore
```

### Health Checks
```bash
# Test setup
./scripts/test-setup.sh

# Check dependencies
./scripts/check-dependencies.sh
```

## 🎯 Best Practices

### Configuration Management
- **Version Control**: Keep all configurations in Git
- **Documentation**: Document all customizations
- **Testing**: Test configurations on multiple platforms
- **Backup**: Regular backup of configurations

### Team Collaboration
- **Shared Gists**: Use GitHub Gists for shared configurations
- **Documentation**: Maintain shared knowledge base
- **Workflows**: Use standardized workflow templates
- **Communication**: Clear communication about changes

### Development Workflow
- **AI Integration**: Leverage AI-assisted development
- **Code Quality**: Follow established code quality guidelines
- **Testing**: Comprehensive testing at all levels
- **Documentation**: Keep documentation up to date

## 🆘 Troubleshooting

### Common Issues
1. **Platform Detection**: Manual platform specification if auto-detection fails
2. **Dependencies**: Install missing dependencies manually
3. **Permissions**: Fix file permissions for scripts
4. **GitHub Token**: Set GITHUB_TOKEN environment variable

### Getting Help
1. **Documentation**: Check this guide and other docs
2. **Scripts**: Use verbose mode for detailed output
3. **Health Checks**: Run health check scripts
4. **Community**: Share issues and solutions via Gists

---

*This portable dev environment system provides a comprehensive, shareable, and maintainable development setup for modern development workflows.*
