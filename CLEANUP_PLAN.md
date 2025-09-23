# 🧹 Neuro-Spicy DevKit - Cleanup Plan

## 🎯 **Objective**
Create a clean, public-ready repository by removing historical artifacts, personal references, and non-essential files while preserving the core functionality.

## 📋 **Current State Analysis**

### **✅ What Should Stay (Core Public Release)**
- **Interactive Setup System**
  - `scripts/neuro-spicy-init.sh` - Linux/macOS interactive setup
  - `scripts/neuro-spicy-init.ps1` - Windows interactive setup
  - `init.sh` & `init.ps1` - Quick launchers
- **Core Scripts**
  - `scripts/health-check-core.sh` & `scripts/health-check-core.ps1`
  - `scripts/neuro-spicy-setup-core.sh` & `scripts/neuro-spicy-setup-core.ps1`
  - `scripts/git-push-retry.sh` & `scripts/git-push-retry.ps1`
- **Essential Documentation**
  - `README.md` (cleaned version)
  - `docs/CORE_FOCUS_PLAN.md`
  - `docs/BASH_LINUX_DEFAULT.md`
  - `docs/BEGINNER_JOURNEY.md`
- **Portable Dev Environment**
  - `portable-dev-env/` (core structure only)
- **License & Basic Files**
  - `LICENSE` (generic version)

### **❌ What Should Be Removed/Stashed**

#### **1. Historical Artifacts**
- `DEV_ENVIRONMENT_SETUP.md` - References to zenOS
- `DEV_SETUP_CHEAT_SHEET.md` - References to zenOS
- `NEURO_SPICY_INTEGRATION.md` - References to zenOS
- `genesis-block-soundtrack.json` - Personal references
- `soundtrack-player.html` - Personal references
- `SOUNDTRACK.md` - Personal references
- `audio-profile.md` - Personal references
- `get_setup_commands.py` - References to zenOS
- `soundtrack-cli.py` - Personal references
- `manifest.yaml` - Personal references

#### **2. Cleanup & Audit Scripts (Development Tools)**
- `scripts/cleanup-personal-refs.ps1` - Development tool
- `scripts/comprehensive-audit.ps1` - Development tool
- `scripts/release-audit.ps1` - Development tool
- `scripts/integrate-promptos-zenos.ps1` - References to zenOS

#### **3. Documentation with Personal References**
- `docs/PROMPTOS_ZENOS_INTEGRATION_PLAN.md` - References to zenOS
- `docs/PERSONAL_PROFILE_IMPLEMENTATION_PLAN.md` - May contain personal refs
- `docs/PROFILE_ARCHITECTURE_DIAGRAM.md` - May contain personal refs
- `docs/WORKFLOW_DIAGRAM.md` - May contain personal refs

#### **4. Development Summary Files**
- `RELEASE_SUMMARY.md` - Development documentation
- `INTERACTIVE_SETUP_SUMMARY.md` - Development documentation

#### **5. Portable Dev Environment Artifacts**
- `portable-dev-env/gists/` - May contain personal gist references
- `portable-dev-env/scripts/demo-workflow.sh` - May contain personal refs
- `portable-dev-env/scripts/neuro-spicy-setup.ps1` - May contain personal refs
- `portable-dev-env/scripts/neuro-spicy-setup.sh` - May contain personal refs

## 🗂️ **Proposed Branch Structure**

### **Branch Strategy**
1. **`main`** - Clean public release branch
2. **`development`** - Development artifacts and tools
3. **`archive`** - Historical artifacts and personal references

### **Branch Contents**

#### **`main` Branch (Public Release)**
```
neuro-spicy-devkit/
├── README.md
├── LICENSE
├── init.sh
├── init.ps1
├── scripts/
│   ├── neuro-spicy-init.sh
│   ├── neuro-spicy-init.ps1
│   ├── health-check-core.sh
│   ├── health-check-core.ps1
│   ├── neuro-spicy-setup-core.sh
│   ├── neuro-spicy-setup-core.ps1
│   ├── git-push-retry.sh
│   ├── git-push-retry.ps1
│   ├── make-executable-core.sh
│   ├── setup-bash-default.sh
│   └── test-bash-scripts.sh
├── docs/
│   ├── CORE_FOCUS_PLAN.md
│   ├── BASH_LINUX_DEFAULT.md
│   └── BEGINNER_JOURNEY.md
└── portable-dev-env/
    ├── cursor/
    ├── vscode/
    └── profiles/templates/
```

#### **`development` Branch (Development Tools)**
```
neuro-spicy-devkit/
├── scripts/
│   ├── cleanup-personal-refs.ps1
│   ├── comprehensive-audit.ps1
│   ├── release-audit.ps1
│   └── integrate-promptos-zenos.ps1
├── docs/
│   ├── PROMPTOS_ZENOS_INTEGRATION_PLAN.md
│   ├── PERSONAL_PROFILE_IMPLEMENTATION_PLAN.md
│   ├── PROFILE_ARCHITECTURE_DIAGRAM.md
│   └── WORKFLOW_DIAGRAM.md
├── RELEASE_SUMMARY.md
└── INTERACTIVE_SETUP_SUMMARY.md
```

#### **`archive` Branch (Historical Artifacts)**
```
neuro-spicy-devkit/
├── DEV_ENVIRONMENT_SETUP.md
├── DEV_SETUP_CHEAT_SHEET.md
├── NEURO_SPICY_INTEGRATION.md
├── genesis-block-soundtrack.json
├── soundtrack-player.html
├── SOUNDTRACK.md
├── audio-profile.md
├── get_setup_commands.py
├── soundtrack-cli.py
├── manifest.yaml
└── portable-dev-env/
    ├── gists/
    └── scripts/
        ├── demo-workflow.sh
        ├── neuro-spicy-setup.ps1
        └── neuro-spicy-setup.sh
```

## 🚀 **Execution Plan**

### **Phase 1: Preparation**
1. Create new branches (`development`, `archive`)
2. Backup current state
3. Document current file structure

### **Phase 2: Branch Creation**
1. Create `development` branch with development tools
2. Create `archive` branch with historical artifacts
3. Verify branch contents

### **Phase 3: Main Branch Cleanup**
1. Remove non-essential files from `main`
2. Clean up any remaining personal references
3. Update README for public release
4. Test core functionality

### **Phase 4: Validation**
1. Run health checks on cleaned `main` branch
2. Test interactive setup
3. Verify all core functionality works
4. Final documentation review

### **Phase 5: Release**
1. Push all branches to remote
2. Set `main` as default branch
3. Create release tags
4. Update repository description

## 🔍 **Quality Assurance**

### **Pre-Cleanup Checklist**
- [ ] Identify all personal references
- [ ] Identify all zenOS references
- [ ] Identify all development-only tools
- [ ] Identify all historical artifacts
- [ ] Backup current state

### **Post-Cleanup Checklist**
- [ ] Core functionality works
- [ ] Interactive setup works
- [ ] No personal references remain
- [ ] No zenOS references remain
- [ ] Documentation is clean
- [ ] Repository is public-ready

## 🎯 **Success Criteria**

### **Clean Public Repository**
- ✅ No personal references
- ✅ No zenOS references
- ✅ No development artifacts
- ✅ Core functionality intact
- ✅ Interactive setup works
- ✅ Documentation is clean
- ✅ Ready for public release

### **Organized Development**
- ✅ Development tools in separate branch
- ✅ Historical artifacts archived
- ✅ Clean separation of concerns
- ✅ Easy maintenance and updates

## 📝 **Notes**

- **Backup Strategy**: Create full backup before cleanup
- **Testing Strategy**: Test each branch after creation
- **Documentation**: Update all documentation for public release
- **Version Control**: Use proper commit messages for cleanup
- **Release Strategy**: Tag releases appropriately

---

*This plan ensures a clean, professional public repository while preserving development history and tools in appropriate branches.*
