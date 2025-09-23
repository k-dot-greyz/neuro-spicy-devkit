# 🧹 Cleanup Execution Plan - Detailed File Analysis

## 📊 **Current File Inventory**

### **✅ CORE FILES (Keep in `main` branch)**
```
Root Level:
├── README.md ✅
├── LICENSE ✅
├── init.ps1 ✅
├── init.sh ✅

Scripts (Core):
├── scripts/neuro-spicy-init.sh ✅
├── scripts/neuro-spicy-init.ps1 ✅
├── scripts/health-check-core.sh ✅
├── scripts/health-check-core.ps1 ✅
├── scripts/neuro-spicy-setup-core.sh ✅
├── scripts/neuro-spicy-setup-core.ps1 ✅
├── scripts/git-push-retry.sh ✅
├── scripts/git-push-retry.ps1 ✅
├── scripts/make-executable-core.sh ✅
├── scripts/setup-bash-default.sh ✅
├── scripts/test-bash-scripts.sh ✅

Documentation (Core):
├── docs/CORE_FOCUS_PLAN.md ✅
├── docs/BASH_LINUX_DEFAULT.md ✅
├── docs/BEGINNER_JOURNEY.md ✅

Portable Dev Environment (Core):
├── portable-dev-env/cursor/ ✅
├── portable-dev-env/vscode/ ✅
├── portable-dev-env/profiles/templates/ ✅
├── portable-dev-env/docs/GITHUB_TOKEN_SETUP.md ✅
├── portable-dev-env/docs/USAGE_GUIDE.md ✅
├── portable-dev-env/README.md ✅
```

### **❌ HISTORICAL ARTIFACTS (Move to `archive` branch)**
```
Root Level:
├── DEV_ENVIRONMENT_SETUP.md ❌ (zenOS references)
├── DEV_SETUP_CHEAT_SHEET.md ❌ (zenOS references)
├── NEURO_SPICY_INTEGRATION.md ❌ (zenOS references)
├── genesis-block-soundtrack.json ❌ (personal references)
├── soundtrack-player.html ❌ (personal references)
├── SOUNDTRACK.md ❌ (personal references)
├── audio-profile.md ❌ (personal references)
├── get_setup_commands.py ❌ (zenOS references)
├── soundtrack-cli.py ❌ (personal references)
├── manifest.yaml ❌ (personal references)
├── bin/focus-audio.sh ❌ (personal references)

Documentation (Historical):
├── docs/PROMPTOS_ZENOS_INTEGRATION_PLAN.md ❌ (zenOS references)
├── docs/PERSONAL_PROFILE_IMPLEMENTATION_PLAN.md ❌ (may contain personal refs)
├── docs/PROFILE_ARCHITECTURE_DIAGRAM.md ❌ (may contain personal refs)
├── docs/WORKFLOW_DIAGRAM.md ❌ (may contain personal refs)

Portable Dev Environment (Historical):
├── portable-dev-env/scripts/demo-workflow.sh ❌ (may contain personal refs)
├── portable-dev-env/scripts/neuro-spicy-setup.ps1 ❌ (may contain personal refs)
├── portable-dev-env/scripts/neuro-spicy-setup.sh ❌ (may contain personal refs)
├── portable-dev-env/gists/ ❌ (may contain personal gist references)
```

### **🔧 DEVELOPMENT TOOLS (Move to `development` branch)**
```
Root Level:
├── CLEANUP_PLAN.md 🔧
├── CLEANUP_EXECUTION_PLAN.md 🔧
├── RELEASE_SUMMARY.md 🔧
├── INTERACTIVE_SETUP_SUMMARY.md 🔧

Scripts (Development):
├── scripts/cleanup-personal-refs.ps1 🔧
├── scripts/comprehensive-audit.ps1 🔧
├── scripts/release-audit.ps1 🔧
├── scripts/integrate-promptos-zenos.ps1 🔧

Portable Dev Environment (Development):
├── portable-dev-env/scripts/demo-gist-creation.sh 🔧
├── portable-dev-env/scripts/gist-manager.ps1 🔧
├── portable-dev-env/scripts/gist-manager.sh 🔧
├── portable-dev-env/scripts/health-check.ps1 🔧
├── portable-dev-env/scripts/health-check.sh 🔧
├── portable-dev-env/scripts/make-executable.sh 🔧
├── portable-dev-env/scripts/mcp-registry.ps1 🔧
├── portable-dev-env/scripts/mcp-registry.sh 🔧
├── portable-dev-env/scripts/profile-loader.ps1 🔧
├── portable-dev-env/scripts/profile-loader.sh 🔧
├── portable-dev-env/scripts/README.md 🔧
├── portable-dev-env/scripts/setup.sh 🔧
```

## 🚀 **Step-by-Step Execution Plan**

### **Step 1: Create Backup Branch**
```bash
git checkout -b backup-before-cleanup
git add .
git commit -m "backup: Complete state before cleanup"
git push origin backup-before-cleanup
```

### **Step 2: Create Development Branch**
```bash
git checkout -b development
# Keep development tools and documentation
# Remove historical artifacts and core files
```

### **Step 3: Create Archive Branch**
```bash
git checkout -b archive
# Keep only historical artifacts
# Remove development tools and core files
```

### **Step 4: Clean Main Branch**
```bash
git checkout main
# Remove all non-core files
# Keep only essential public release files
```

### **Step 5: Final Validation**
```bash
# Test each branch
# Verify core functionality
# Check for remaining personal references
```

## 📋 **Detailed File Actions**

### **Files to DELETE from `main` branch:**
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
- `bin/focus-audio.sh`
- `docs/PROMPTOS_ZENOS_INTEGRATION_PLAN.md`
- `docs/PERSONAL_PROFILE_IMPLEMENTATION_PLAN.md`
- `docs/PROFILE_ARCHITECTURE_DIAGRAM.md`
- `docs/WORKFLOW_DIAGRAM.md`
- `portable-dev-env/scripts/demo-workflow.sh`
- `portable-dev-env/scripts/neuro-spicy-setup.ps1`
- `portable-dev-env/scripts/neuro-spicy-setup.sh`
- `portable-dev-env/gists/`
- `scripts/cleanup-personal-refs.ps1`
- `scripts/comprehensive-audit.ps1`
- `scripts/release-audit.ps1`
- `scripts/integrate-promptos-zenos.ps1`
- `CLEANUP_PLAN.md`
- `CLEANUP_EXECUTION_PLAN.md`
- `RELEASE_SUMMARY.md`
- `INTERACTIVE_SETUP_SUMMARY.md`

### **Files to KEEP in `main` branch:**
- `README.md`
- `LICENSE`
- `init.ps1`
- `init.sh`
- `scripts/neuro-spicy-init.sh`
- `scripts/neuro-spicy-init.ps1`
- `scripts/health-check-core.sh`
- `scripts/health-check-core.ps1`
- `scripts/neuro-spicy-setup-core.sh`
- `scripts/neuro-spicy-setup-core.ps1`
- `scripts/git-push-retry.sh`
- `scripts/git-push-retry.ps1`
- `scripts/make-executable-core.sh`
- `scripts/setup-bash-default.sh`
- `scripts/test-bash-scripts.sh`
- `docs/CORE_FOCUS_PLAN.md`
- `docs/BASH_LINUX_DEFAULT.md`
- `docs/BEGINNER_JOURNEY.md`
- `portable-dev-env/cursor/`
- `portable-dev-env/vscode/`
- `portable-dev-env/profiles/templates/`
- `portable-dev-env/docs/GITHUB_TOKEN_SETUP.md`
- `portable-dev-env/docs/USAGE_GUIDE.md`
- `portable-dev-env/README.md`

## 🎯 **Expected Results**

### **`main` branch (Public Release)**
- **Files**: ~15 core files
- **Size**: Minimal, focused
- **Purpose**: Public release, easy adoption
- **Content**: Core functionality only

### **`development` branch (Development Tools)**
- **Files**: ~20 development files
- **Size**: Medium
- **Purpose**: Development and maintenance
- **Content**: Audit tools, documentation, advanced features

### **`archive` branch (Historical Artifacts)**
- **Files**: ~15 historical files
- **Size**: Medium
- **Purpose**: Historical preservation
- **Content**: Personal references, zenOS integration, old documentation

## ✅ **Success Criteria**

### **Clean Public Repository**
- [ ] No personal references in `main`
- [ ] No zenOS references in `main`
- [ ] No development artifacts in `main`
- [ ] Core functionality intact
- [ ] Interactive setup works
- [ ] Documentation is clean
- [ ] Ready for public release

### **Organized Development**
- [ ] Development tools in `development` branch
- [ ] Historical artifacts in `archive` branch
- [ ] Clean separation of concerns
- [ ] Easy maintenance and updates

---

*This execution plan provides a clear roadmap for creating a clean, professional public repository while preserving development history and tools in appropriate branches.*
