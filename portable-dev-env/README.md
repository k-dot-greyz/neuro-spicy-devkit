# Portable Dev Environment System

A comprehensive, portable development environment configuration system for Cursor/VSCode that can be easily shared, versioned, and deployed across different machines.

## 🎯 Goals

- **Portability**: Works across Windows, Linux, macOS
- **Version Control**: All configs stored in Git/GitHub Gists
- **Modularity**: Mix and match components
- **Automation**: One-command setup
- **Documentation**: Self-documenting configurations

## 📁 Structure

```
portable-dev-env/
├── cursor/                    # Cursor-specific configurations
│   ├── rules/                # AI rules and behaviors
│   ├── memories/             # Knowledge base and context
│   ├── workflows/            # Reusable workflow templates
│   └── templates/             # Configuration templates
├── vscode/                   # VSCode configurations
│   ├── settings/             # Editor settings
│   ├── extensions/           # Extension recommendations
│   └── snippets/             # Code snippets
├── scripts/                  # Setup and management scripts
├── gists/                    # GitHub Gist integration
└── docs/                     # Documentation
```

## 🚀 Quick Start

```bash
# Clone the portable dev environment
git clone <your-repo> portable-dev-env
cd portable-dev-env

# Setup for your platform
./scripts/setup.sh --platform linux
./scripts/setup.sh --platform windows
./scripts/setup.sh --platform macos

# Sync with GitHub Gists
./scripts/sync-gists.sh
```

## 🔧 Components

### 1. Cursor Rules System
- **AI Behavior Rules**: Define how AI should interact
- **Project-Specific Rules**: Tailored for different project types
- **Language Rules**: Optimized for Python, TypeScript, etc.

### 2. Memory System
- **Context Memories**: Project knowledge and history
- **Code Patterns**: Reusable code templates
- **API Documentation**: Integrated docs and examples

### 3. Workflow Templates
- **Development Workflows**: Common dev tasks
- **Debugging Workflows**: Systematic debugging approaches
- **Testing Workflows**: Automated testing patterns

### 4. GitHub Gist Integration
- **Config Sharing**: Share configurations via Gists
- **Version Control**: Track changes to configurations
- **Collaboration**: Team-shared development environments

## 📋 Features

- ✅ **Cross-Platform**: Windows, Linux, macOS support
- ✅ **Version Controlled**: Git-based configuration management
- ✅ **Modular**: Pick and choose components
- ✅ **Automated**: One-command setup and sync
- ✅ **Documented**: Self-documenting with examples
- ✅ **Collaborative**: Team-shared configurations
- ✅ **Extensible**: Easy to add new components

---

*Part of Operation Atlas infrastructure*
