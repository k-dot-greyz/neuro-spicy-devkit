# 🗂️ Branch Organization Overview

## 📊 **Current Status**
- ✅ **Backup created**: `backup-before-cleanup` (complete state preserved)
- 🔄 **Currently on**: `development` branch
- ⏳ **Next**: Create `archive` branch, then clean `main`

## 🎯 **Branch Purposes**

### **`main` Branch - Public Release (Clean & Minimal)**
**Purpose**: Clean, professional public repository ready for adoption
**Target**: ~15 core files only

**✅ KEEP in `main`:**
```
Root Level:
├── README.md                    # Main project documentation
├── LICENSE                      # Generic license
├── init.ps1                     # Windows quick launcher
├── init.sh                      # Linux/macOS quick launcher

Core Scripts:
├── scripts/neuro-spicy-init.sh          # Linux/macOS interactive setup
├── scripts/neuro-spicy-init.ps1        # Windows interactive setup
├── scripts/health-check-core.sh         # Linux/macOS health check
├── scripts/health-check-core.ps1        # Windows health check
├── scripts/neuro-spicy-setup-core.sh    # Linux/macOS core setup
├── scripts/neuro-spicy-setup-core.ps1   # Windows core setup
├── scripts/git-push-retry.sh            # Linux/macOS git retry
├── scripts/git-push-retry.ps1           # Windows git retry
├── scripts/make-executable-core.sh       # Make scripts executable
├── scripts/setup-bash-default.sh        # Bash default setup
└── scripts/test-bash-scripts.sh         # Test bash scripts

Core Documentation:
├── docs/CORE_FOCUS_PLAN.md      # Core philosophy
├── docs/BASH_LINUX_DEFAULT.md   # Bash/Linux guide
└── docs/BEGINNER_JOURNEY.md      # Beginner's guide

Portable Dev Environment (Core):
├── portable-dev-env/cursor/             # Cursor configuration
├── portable-dev-env/vscode/             # VSCode configuration
├── portable-dev-env/profiles/templates/ # Profile templates
├── portable-dev-env/docs/GITHUB_TOKEN_SETUP.md
├── portable-dev-env/docs/USAGE_GUIDE.md
└── portable-dev-env/README.md
```

### **`development` Branch - Development Tools**
**Purpose**: Tools for maintaining and developing the project
**Target**: ~20 development files

**🔧 KEEP in `development`:**
```
Development Documentation:
├── CLEANUP_PLAN.md              # This cleanup plan
├── CLEANUP_EXECUTION_PLAN.md    # Detailed execution plan
├── RELEASE_SUMMARY.md            # Release documentation
└── INTERACTIVE_SETUP_SUMMARY.md  # Setup implementation docs

Development Scripts:
├── scripts/cleanup-personal-refs.ps1    # Personal reference cleanup
├── scripts/comprehensive-audit.ps1      # Full system audit
├── scripts/release-audit.ps1            # Release-ready audit
└── scripts/integrate-promptos-zenos.ps1 # zenOS integration

Advanced Portable Dev Environment:
├── portable-dev-env/scripts/demo-gist-creation.sh
├── portable-dev-env/scripts/gist-manager.ps1
├── portable-dev-env/scripts/gist-manager.sh
├── portable-dev-env/scripts/health-check.ps1
├── portable-dev-env/scripts/health-check.sh
├── portable-dev-env/scripts/make-executable.sh
├── portable-dev-env/scripts/mcp-registry.ps1
├── portable-dev-env/scripts/mcp-registry.sh
├── portable-dev-env/scripts/profile-loader.ps1
├── portable-dev-env/scripts/profile-loader.sh
├── portable-dev-env/scripts/README.md
└── portable-dev-env/scripts/setup.sh
```

### **`archive` Branch - Historical Artifacts**
**Purpose**: Preserve historical development and personal references
**Target**: ~15 historical files

**📦 KEEP in `archive`:**
```
Historical Documentation:
├── DEV_ENVIRONMENT_SETUP.md     # zenOS references
├── DEV_SETUP_CHEAT_SHEET.md     # zenOS references
├── NEURO_SPICY_INTEGRATION.md   # zenOS references

Personal References:
├── genesis-block-soundtrack.json # Personal soundtrack
├── soundtrack-player.html       # Personal player
├── SOUNDTRACK.md                # Personal soundtrack docs
├── audio-profile.md             # Personal audio profile
├── soundtrack-cli.py            # Personal CLI tool
├── manifest.yaml                # Personal manifest
└── bin/focus-audio.sh           # Personal audio script

Historical Scripts:
├── get_setup_commands.py        # zenOS references
├── portable-dev-env/scripts/demo-workflow.sh
├── portable-dev-env/scripts/neuro-spicy-setup.ps1
├── portable-dev-env/scripts/neuro-spicy-setup.sh
└── portable-dev-env/gists/     # Personal gist references
```

## 🚀 **Execution Plan**

### **Current Step**: Clean `development` branch
**What we're doing**: Remove historical artifacts and core files, keep only development tools

### **Next Steps**:
1. **Finish `development` branch** - remove core files, keep dev tools
2. **Create `archive` branch** - keep only historical artifacts
3. **Clean `main` branch** - keep only core public files
4. **Test and validate** each branch

## 📋 **What We've Done So Far**

### **✅ Completed**:
- Created `backup-before-cleanup` branch (complete state preserved)
- Switched to `development` branch
- Removed historical artifacts from `development`:
  - `DEV_ENVIRONMENT_SETUP.md`
  - `DEV_SETUP_CHEAT_SHEET.md`
  - `NEURO_SPICY_INTEGRATION.md`
  - `genesis-block-soundtrack.json`
  - `soundtrack-player.html`
  - `SOUNDTRACK.md`
  - `audio-profile.md`
  - `get_setup_commands.py`
  - `soundtrack-cli.py`
  - `manifest.yaml`
  - `bin/` directory

### **🔄 Currently Doing**:
- Cleaning `development` branch (removing core files, keeping dev tools)

### **⏳ Next**:
- Remove core files from `development` branch
- Create `archive` branch with historical artifacts
- Clean `main` branch to core files only

## 🎯 **End Result**

### **`main` Branch** (Public Release)
- **Files**: ~15 core files
- **Purpose**: Clean, professional public repository
- **Users**: Anyone can clone and use immediately

### **`development` Branch** (Development Tools)
- **Files**: ~20 development files
- **Purpose**: Tools for maintaining the project
- **Users**: Developers working on the project

### **`archive` Branch** (Historical Artifacts)
- **Files**: ~15 historical files
- **Purpose**: Preserve development history
- **Users**: Historical reference only

---

**This gives us a clean separation: public release, development tools, and historical preservation! 🎯**
