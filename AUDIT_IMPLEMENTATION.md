# 🔍 Audit Implementation Tracking

**Issue:** #3  
**Branch:** `audit/security-fixes-2026-02-05`  
**Audit Date:** February 05, 2026  
**Status:** 🟡 In Progress

### Reconciliation (2026-04-19)

Compared against this branch, `main`, and **open PRs** [#4](https://github.com/k-dot-greyz/neuro-spicy-devkit/pull/4) / [#5](https://github.com/k-dot-greyz/neuro-spicy-devkit/pull/5):

| Area | On this branch | Still a gap vs audit / `main` | Tracked in |
|------|----------------|------------------------------|------------|
| Core shell scripts | `health-check-core.sh`, `neuro-spicy-setup-core.sh` present | `git-push-retry.sh` missing here; **PR #5 adds it** | [#15](https://github.com/k-dot-greyz/neuro-spicy-devkit/issues/15) |
| Root `.gitignore` | Missing here | **PR #5 adds** user profiles + env ignores | [#16](https://github.com/k-dot-greyz/neuro-spicy-devkit/issues/16) |
| SEC-001 token storage | Init still writes plaintext token to rc + profile JSON | Keychain/secret-service + **no token in profile JSON** | [#17](https://github.com/k-dot-greyz/neuro-spicy-devkit/issues/17) |
| README / troubleshooting | N/A in this file | Broken fences, placeholders, no troubleshooting | [#14](https://github.com/k-dot-greyz/neuro-spicy-devkit/issues/14) |
| `SECURITY.md` + this doc | `SECURITY.md` absent; sections below partly stale | Add policy doc + fix examples/fences in this file | [#18](https://github.com/k-dot-greyz/neuro-spicy-devkit/issues/18) |

---

## 🎯 Implementation Roadmap

This document tracks the implementation of fixes for findings from the comprehensive repository audit.

### 🔴 Tier 1: Critical (MUST FIX)

#### SEC-001: Plain-text Token Storage
**Status:** ❌ Not Started  
**Priority:** P0 (Blocker)  
**Estimated Effort:** 2-3 hours

**Current State:**
```json
// File: scripts/neuro-spicy-init.sh, Line ~351
"github_token": "$GITHUB_TOKEN"  // ❌ Vulnerable!
```

**Target State:**
```bash
# OS-specific secure storage
store_github_token() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS Keychain
        security add-generic-password -U \
            -s "neuro-spicy-devkit" \
            -a "github-token" \
            -w "$GITHUB_TOKEN"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux Secret Service
        if command_exists secret-tool; then
            echo -n "$GITHUB_TOKEN" | secret-tool store \
                --label='Neuro-Spicy GitHub Token' \
                service neuro-spicy-devkit \
                username github-token
        else
            # Fallback: GPG-encrypted file
            echo "$GITHUB_TOKEN" | gpg --encrypt \
                --recipient "$GIT_USER_EMAIL" \
                > ~/.config/neuro-spicy/token.gpg
            chmod 600 ~/.config/neuro-spicy/token.gpg
        fi
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
        # Windows Credential Manager
        cmdkey /generic:neuro-spicy-github \
            /user:token /pass:"$GITHUB_TOKEN"
    fi
}
```

**Implementation Steps:**
- [ ] Create `store_github_token()` function
- [ ] Create `retrieve_github_token()` function  
- [ ] Update `configure_github()` to use secure storage
- [ ] Remove token from user profile JSON
- [ ] Add keychain helper scripts
- [ ] Test on macOS, Linux, Windows

**Files to Modify:**
- `scripts/neuro-spicy-init.sh`
- `portable-dev-env/templates/profile.template.json` (remove token field)

**New Files:**
- `scripts/lib/keychain-helpers.sh` (platform-specific functions)

---

### 🟠 Tier 2: High Priority (SHOULD FIX)

#### FUNC-001: Missing Referenced Scripts
**Status:** 🟡 Partially addressed on this branch (see reconciliation table)  
**Priority:** P1 (High)  
**Estimated Effort:** 1-2 hours

**Missing Scripts:**
1. `scripts/health-check-core.sh` — **present** on this branch
2. `scripts/neuro-spicy-setup-core.sh` — **present** on this branch
3. `scripts/git-push-retry.sh` — **still missing** here; added in **PR #5** ([#15](https://github.com/k-dot-greyz/neuro-spicy-devkit/issues/15))

**Implementation Plan:**

##### health-check-core.sh
```bash
#!/usr/bin/env bash
# Health check for neuro-spicy development environment

set -euo pipefail

print_color() { echo -e "\033[$1m$2\033[0m"; }
GREEN=32; YELLOW=33; RED=31; CYAN=36

print_color $CYAN "🌟 Neuro-Spicy DevKit Health Check"
echo

# Check system resources
print_color $YELLOW "💻 Checking system resources..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    FREE_MEM=$(vm_stat | grep "Pages free" | awk '{print $3}' | sed 's/\.//')
    echo "  ✅ Free memory: $(($FREE_MEM * 4096 / 1024 / 1024))MB"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    FREE_MEM=$(free -m | awk '/^Mem:/{print $4}')
    echo "  ✅ Free memory: ${FREE_MEM}MB"
fi

# Check disk space
DISK_FREE=$(df -h . | tail -1 | awk '{print $4}')
echo "  ✅ Disk space available: $DISK_FREE"

# Check required commands
print_color $YELLOW "⚙️ Checking required tools..."
REQUIRED_CMDS=("git" "curl" "jq")
for cmd in "${REQUIRED_CMDS[@]}"; do
    if command -v "$cmd" &>/dev/null; then
        echo "  ✅ $cmd installed"
    else
        print_color $RED "  ❌ $cmd not found - install required"
        exit 1
    fi
done

# Check git config
print_color $YELLOW "🔑 Checking git configuration..."
if git config --global user.name &>/dev/null; then
    echo "  ✅ Git user.name: $(git config --global user.name)"
else
    print_color $RED "  ❌ Git user.name not set"
fi

if git config --global user.email &>/dev/null; then
    echo "  ✅ Git user.email: $(git config --global user.email)"
else
    print_color $RED "  ❌ Git user.email not set"
fi

echo
print_color $GREEN "✅ Health check complete!"
```

**Implementation Steps:**
- [x] Create `scripts/health-check-core.sh` (this branch)
- [x] Create `scripts/neuro-spicy-setup-core.sh` (this branch)
- [ ] Create `scripts/git-push-retry.sh` — open: [#15](https://github.com/k-dot-greyz/neuro-spicy-devkit/issues/15) / merge **PR #5**
- [ ] Make scripts executable
- [ ] Add error handling for missing scripts
- [ ] Test script execution

---

#### FUNC-002: Silent Script Failures
**Status:** ❌ Not Started  
**Priority:** P1 (High)  
**Estimated Effort:** 1 hour

**Implementation:**
```bash
run_script_safely() {
    local script_path="$1"
    local script_name=$(basename "$script_path")
    
    if [ -f "$script_path" ]; then
        print_color $YELLOW "🚀 Running $script_name..."
        chmod +x "$script_path"
        local exit_code=0
        "$script_path" || exit_code=$?
        if [ "$exit_code" -eq 0 ]; then
            print_color $GREEN "✅ $script_name completed successfully"
            return 0
        else
            print_color $RED "❌ $script_name failed (exit code: $exit_code)"
            print_color $YELLOW "ℹ️  Check the script output above for details"
            return 1
        fi
    else
        print_color $RED "❌ Script not found: $script_path"
        print_color $YELLOW "ℹ️  You can:"
        print_color $YELLOW "     1. Run the setup again to download missing scripts"
        print_color $YELLOW "     2. Manually create the script"
        print_color $YELLOW "     3. Skip this step (not recommended)"
        
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 1
        fi
    fi
}
```

**Implementation Steps:**
- [ ] Create `run_script_safely()` wrapper function
- [ ] Replace all direct script calls with wrapper
- [ ] Add helpful error messages
- [ ] Test error handling paths

---

### 🟡 Tier 3: Medium Priority (NICE TO HAVE)

#### DOC-001: Missing Security Documentation
**Status:** ❌ Not Started  
**Priority:** P2 (Medium)  
**Estimated Effort:** 1 hour

**Implementation:**
- [ ] Create `SECURITY.md`
- [ ] Add token handling section
- [ ] Add platform-specific instructions
- [ ] Add vulnerability reporting section
- [ ] Add security best practices

**Template:** See Issue #3 for full SECURITY.md template

---

#### DOC-002: Missing Troubleshooting Guide
**Status:** ❌ Not Started  
**Priority:** P2 (Medium)  
**Estimated Effort:** 1 hour

**Sections to Add to README:**

````markdown
## 🔧 Troubleshooting

### Common Issues

#### Issue: "Health check script not found"
**Cause:** Missing `health-check-core.sh` script  
**Solution:**
```bash
# Download the script manually
curl -o scripts/health-check-core.sh \
    https://raw.githubusercontent.com/k-dot-greyz/neuro-spicy-devkit/main/scripts/health-check-core.sh
chmod +x scripts/health-check-core.sh
```

#### Issue: "GitHub token validation failed"
**Cause:** Invalid or expired token  
**Solution:**
1. Generate new token at https://github.com/settings/tokens
2. Required scopes: `repo`, `workflow`, `user`
3. Run setup again with new token

#### Issue: "Permission denied" on macOS Keychain
**Cause:** macOS security settings  
**Solution:**
```bash
# Allow Terminal to access Keychain
# System Preferences > Security & Privacy > Privacy > Full Disk Access
# Add Terminal.app or your terminal emulator
```
````

**Implementation Steps:**
- [ ] Add Troubleshooting section to README
- [ ] Document 5-10 common errors
- [ ] Add platform-specific solutions
- [ ] Link to SECURITY.md

---

## 📅 Timeline

Original target (2026-02-12) slipped; work split across **PR #4** (audit branch) and **PR #5** (`cursor/development-environment-setup-7103`, 2026-03-22). Use GitHub issues **#14–#18** (2026-04-19) for current gap tracking.

### Week 1 (Current)
- [ ] Day 1-2: Implement SEC-001 (secure token storage) — [#17](https://github.com/k-dot-greyz/neuro-spicy-devkit/issues/17)
- [ ] Day 3: Finish FUNC-001 (`git-push-retry.sh` on `main`) — [#15](https://github.com/k-dot-greyz/neuro-spicy-devkit/issues/15)
- [ ] Day 4: Add error handling (FUNC-002)
- [ ] Day 5: Testing on multiple platforms

### Week 2
- [ ] Day 1: Create SECURITY.md (DOC-001) — [#18](https://github.com/k-dot-greyz/neuro-spicy-devkit/issues/18)
- [ ] Day 2: README + troubleshooting (DOC-002) — [#14](https://github.com/k-dot-greyz/neuro-spicy-devkit/issues/14)
- [ ] Day 3-4: Final testing and bug fixes
- [ ] Day 5: Mark PR as ready for review

### Week 3
- [ ] Code review and feedback
- [ ] Address review comments
- [ ] Merge to main
- [ ] Tag v1.0.0
- [ ] Update dev-master registry

---

## 🧑‍💻 Development Notes

### Testing Strategy

**Platforms:**
- macOS 13+ (M1/M2 and Intel)
- Linux (Ubuntu 22.04, Arch Linux)
- Windows 11 (PowerShell 7+)

**Test Scenarios:**
1. Fresh clone, no existing config
2. Existing old profile (migration path)
3. Missing scripts error handling
4. Invalid token handling
5. Cross-platform keychain operations

### Security Review Checklist

- [ ] No plain-text secrets in any file
- [ ] All credentials use OS keychain
- [ ] `.gitignore` prevents credential leaks
- [ ] User profile sanitized
- [ ] Token retrieval functions secure
- [ ] Error messages don't leak secrets
- [ ] File permissions set correctly (600/700)

---

## 📊 Progress Tracker

**Overall:** partial — core shell scripts exist on this branch; SEC-001, `git-push-retry.sh`, root `.gitignore`, and docs remain (see issues **#14–#18**).

**By Priority:**
- 🔴 P0 (Critical): 0/1 — SEC-001 ([#17](https://github.com/k-dot-greyz/neuro-spicy-devkit/issues/17))
- 🟠 P1 (High): 2/3 — FUNC-001 two of three scripts; FUNC-003 / missing retry ([#15](https://github.com/k-dot-greyz/neuro-spicy-devkit/issues/15)); FUNC-002 open
- 🟡 P2 (Medium): 0/2 — SECURITY + README/troubleshooting ([#14](https://github.com/k-dot-greyz/neuro-spicy-devkit/issues/14), [#18](https://github.com/k-dot-greyz/neuro-spicy-devkit/issues/18))
- 🟢 P3 (Low): _not used_ — remove stray “0/3” counts from older drafts

**By Category:**
- Security: 0/1 (keychain + no secrets in profiles)
- Functionality: 2/3 (missing `git-push-retry.sh` on `main` until **PR #5**)
- Documentation: README + `SECURITY.md` + this tracker updates ([#14](https://github.com/k-dot-greyz/neuro-spicy-devkit/issues/14), [#18](https://github.com/k-dot-greyz/neuro-spicy-devkit/issues/18))
- Repo hygiene: `.gitignore` ([#16](https://github.com/k-dot-greyz/neuro-spicy-devkit/issues/16))

---

## 🔗 References

- **Audit Issue:** #3
- **Audit Report:** See Issue #3 for full findings
- **Branch:** `audit/security-fixes-2026-02-05`
- **Framework:** dev-master v1.0.0
- **Audit ID:** AUDIT-NSDK-2026-02-05

---

## 📝 Changelog

### 2026-04-19
- ✅ Reconciled tracker with codebase + open PR **#5**
- ✅ Opened gap issues **#14–#18** (README, `git-push-retry`, `.gitignore`, SEC-001, SECURITY + doc fixes)
- ✅ Fixed FUNC-002 example (`exit_code` capture) and DOC-002 nested markdown fences in this file

### 2026-02-05
- ✅ Created implementation tracking document
- ✅ Created feature branch `audit/security-fixes-2026-02-05`
- 🟡 Waiting to begin implementation

---

**Next Action:** Merge or cherry-pick **PR #5** for `git-push-retry.sh` + `.gitignore`, then drive **SEC-001** ([#17](https://github.com/k-dot-greyz/neuro-spicy-devkit/issues/17)).

**Questions/Blockers:** None at this time

**Estimated Completion:** TBD — follow issues **#14–#18**
